#pragma once

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstring>
#include <stdexcept>
#include <vector>

#include "common.cuh"
#include "gemm_kernel.cuh"
#include "topk.cuh"

namespace ann_gpu {

__global__ void SelectProbeKernel(const float* __restrict__ centroid_scores,
                                  uint32_t* __restrict__ probes,
                                  int nlist, int nprobe) {
    const int query_id = blockIdx.x;
    if (threadIdx.x != 0) {
        return;
    }

    float best_score[32];
    uint32_t best_id[32];
    for (int i = 0; i < nprobe; ++i) {
        best_score[i] = ANN_GPU_NEG_INFINITY;
        best_id[i] = kInvalidId;
    }

    const float* row = centroid_scores + static_cast<size_t>(query_id) * nlist;
    for (int cid = 0; cid < nlist; ++cid) {
        int worst = 0;
        for (int i = 1; i < nprobe; ++i) {
            if (best_score[i] < best_score[worst]) {
                worst = i;
            }
        }
        if (row[cid] > best_score[worst]) {
            best_score[worst] = row[cid];
            best_id[worst] = static_cast<uint32_t>(cid);
        }
    }

    for (int slot = 0; slot < nprobe; ++slot) {
        int best = 0;
        for (int i = 1; i < nprobe; ++i) {
            if (best_score[i] > best_score[best]) {
                best = i;
            }
        }
        probes[static_cast<size_t>(query_id) * nprobe + slot] = best_id[best];
        best_score[best] = ANN_GPU_NEG_INFINITY;
    }
}

__global__ void IvfSearchKernel(const float* __restrict__ list_vectors,
                                const uint32_t* __restrict__ list_ids,
                                const uint32_t* __restrict__ offsets,
                                const uint32_t* __restrict__ probes,
                                const float* __restrict__ queries,
                                float* __restrict__ out_dist,
                                uint32_t* __restrict__ out_id,
                                int dim, int nprobe) {
    const int query_id = blockIdx.x;
    const int tid = threadIdx.x;
    float local_score[kGpuTopK];
    uint32_t local_id[kGpuTopK];

#pragma unroll
    for (int i = 0; i < kGpuTopK; ++i) {
        local_score[i] = ANN_GPU_NEG_INFINITY;
        local_id[i] = kInvalidId;
    }

    const float* query = queries + static_cast<size_t>(query_id) * dim;
    for (int pi = 0; pi < nprobe; ++pi) {
        const uint32_t list = probes[static_cast<size_t>(query_id) * nprobe + pi];
        const uint32_t begin = offsets[list];
        const uint32_t end = offsets[list + 1];
        for (uint32_t pos = begin + static_cast<uint32_t>(tid);
             pos < end; pos += static_cast<uint32_t>(blockDim.x)) {
            const float* vector = list_vectors + static_cast<size_t>(pos) * dim;
            float score = 0.0f;
            for (int d = 0; d < dim; ++d) {
                score += vector[d] * query[d];
            }
            PushTopKScore(score, list_ids[pos], local_score, local_id);
        }
    }

    extern __shared__ unsigned char shared_raw[];
    float* shared_score = reinterpret_cast<float*>(shared_raw);
    uint32_t* shared_id =
        reinterpret_cast<uint32_t*>(shared_score + blockDim.x * kGpuTopK);
    const int offset = tid * kGpuTopK;
#pragma unroll
    for (int i = 0; i < kGpuTopK; ++i) {
        shared_score[offset + i] = local_score[i];
        shared_id[offset + i] = local_id[i];
    }
    __syncthreads();

    if (tid == 0) {
        float final_score[kGpuTopK];
        uint32_t final_id[kGpuTopK];
#pragma unroll
        for (int i = 0; i < kGpuTopK; ++i) {
            final_score[i] = ANN_GPU_NEG_INFINITY;
            final_id[i] = kInvalidId;
        }
        for (int i = 0; i < blockDim.x * kGpuTopK; ++i) {
            if (shared_id[i] != kInvalidId) {
                PushTopKScore(shared_score[i], shared_id[i],
                              final_score, final_id);
            }
        }
        for (int slot = 0; slot < kGpuTopK; ++slot) {
            int best = 0;
            for (int i = 1; i < kGpuTopK; ++i) {
                if (final_score[i] > final_score[best]) {
                    best = i;
                }
            }
            out_dist[static_cast<size_t>(query_id) * kGpuTopK + slot] =
                1.0f - final_score[best];
            out_id[static_cast<size_t>(query_id) * kGpuTopK + slot] =
                final_id[best];
            final_score[best] = ANN_GPU_NEG_INFINITY;
            final_id[best] = kInvalidId;
        }
    }
}

struct CpuIvfIndex {
    size_t nlist;
    size_t dim;
    std::vector<float> centroids;
    std::vector<uint32_t> offsets;
    std::vector<uint32_t> ids;
    std::vector<float> vectors;
};

inline float Dot(const float* a, const float* b, size_t dim) {
    float sum = 0.0f;
    for (size_t d = 0; d < dim; ++d) {
        sum += a[d] * b[d];
    }
    return sum;
}

inline void PushHostTopK(float score, uint32_t id,
                         float* best_score, uint32_t* best_id) {
    int worst = 0;
    for (int i = 1; i < kGpuTopK; ++i) {
        if (best_score[i] < best_score[worst]) {
            worst = i;
        }
    }
    if (score > best_score[worst]) {
        best_score[worst] = score;
        best_id[worst] = id;
    }
}

inline CpuIvfIndex BuildCpuIvf(float* base, size_t base_n, size_t dim,
                               size_t nlist, int iterations,
                               GpuSearchStats* stats) {
    const auto t0 = std::chrono::high_resolution_clock::now();
    CpuIvfIndex index;
    index.nlist = nlist;
    index.dim = dim;
    index.centroids.assign(nlist * dim, 0.0f);
    for (size_t c = 0; c < nlist; ++c) {
        const size_t src = std::min(base_n - 1, c * base_n / nlist);
        std::memcpy(index.centroids.data() + c * dim, base + src * dim,
                    dim * sizeof(float));
    }

    std::vector<uint32_t> assign(base_n, 0);
    std::vector<float> sums(nlist * dim, 0.0f);
    std::vector<uint32_t> counts(nlist, 0);
    for (int it = 0; it < iterations; ++it) {
        std::fill(sums.begin(), sums.end(), 0.0f);
        std::fill(counts.begin(), counts.end(), 0u);
        for (size_t i = 0; i < base_n; ++i) {
            uint32_t best = 0;
            float best_score = Dot(base + i * dim, index.centroids.data(), dim);
            for (size_t c = 1; c < nlist; ++c) {
                const float score =
                    Dot(base + i * dim, index.centroids.data() + c * dim, dim);
                if (score > best_score) {
                    best_score = score;
                    best = static_cast<uint32_t>(c);
                }
            }
            assign[i] = best;
            counts[best]++;
            float* dst = sums.data() + static_cast<size_t>(best) * dim;
            const float* src = base + i * dim;
            for (size_t d = 0; d < dim; ++d) {
                dst[d] += src[d];
            }
        }
        for (size_t c = 0; c < nlist; ++c) {
            if (counts[c] == 0) {
                continue;
            }
            float* centroid = index.centroids.data() + c * dim;
            const float inv = 1.0f / static_cast<float>(counts[c]);
            for (size_t d = 0; d < dim; ++d) {
                centroid[d] = sums[c * dim + d] * inv;
            }
        }
    }

    for (size_t i = 0; i < base_n; ++i) {
        uint32_t best = 0;
        float best_score = Dot(base + i * dim, index.centroids.data(), dim);
        for (size_t c = 1; c < nlist; ++c) {
            const float score =
                Dot(base + i * dim, index.centroids.data() + c * dim, dim);
            if (score > best_score) {
                best_score = score;
                best = static_cast<uint32_t>(c);
            }
        }
        assign[i] = best;
    }

    std::vector<uint32_t> sizes(nlist, 0);
    for (size_t i = 0; i < base_n; ++i) {
        sizes[assign[i]]++;
    }
    index.offsets.assign(nlist + 1, 0);
    for (size_t c = 0; c < nlist; ++c) {
        index.offsets[c + 1] = index.offsets[c] + sizes[c];
    }
    std::vector<uint32_t> cursor = index.offsets;
    index.ids.resize(base_n);
    index.vectors.resize(base_n * dim);
    for (size_t i = 0; i < base_n; ++i) {
        const uint32_t list = assign[i];
        const uint32_t pos = cursor[list]++;
        index.ids[pos] = static_cast<uint32_t>(i);
        std::memcpy(index.vectors.data() + static_cast<size_t>(pos) * dim,
                    base + i * dim, dim * sizeof(float));
    }

    if (stats) {
        const auto t1 = std::chrono::high_resolution_clock::now();
        stats->build_ms =
            std::chrono::duration<float, std::milli>(t1 - t0).count();
    }
    return index;
}

inline std::vector<SearchHeap> gpu_ivf_search(float* base, float* queries,
                                              size_t base_n, size_t query_n,
                                              size_t dim, size_t k,
                                              size_t nlist, size_t nprobe,
                                              GpuSearchStats* stats = NULL,
                                              size_t query_chunk = 128,
                                              int requested_threads = 256) {
    if (k != static_cast<size_t>(kGpuTopK)) {
        throw std::runtime_error("gpu_ivf_search currently expects k=10");
    }
    nlist = std::max<size_t>(1, std::min(nlist, base_n));
    nprobe = std::max<size_t>(1, std::min(nprobe, nlist));
    if (nprobe > 32) {
        throw std::runtime_error("gpu_ivf_search supports nprobe <= 32");
    }

    GpuSearchStats local;
    local.mode = "gpu_ivf_batch_topk";
    local.query_n = query_n;
    local.base_n = base_n;
    local.dim = dim;
    local.nlist = nlist;
    local.nprobe = nprobe;
    CpuIvfIndex index = BuildCpuIvf(base, base_n, dim, nlist, 2, &local);

    const int threads = ClampThreads(requested_threads);
    const size_t shared_bytes = static_cast<size_t>(threads) * kGpuTopK *
        (sizeof(float) + sizeof(uint32_t));

    float* d_centroids = NULL;
    float* d_vectors = NULL;
    uint32_t* d_offsets = NULL;
    uint32_t* d_list_ids = NULL;
    float* d_queries = NULL;
    float* d_centroid_scores = NULL;
    uint32_t* d_probes = NULL;
    float* d_dist = NULL;
    uint32_t* d_ids = NULL;

    ANN_GPU_CHECK(cudaMalloc(&d_centroids, index.centroids.size() * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_vectors, index.vectors.size() * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_offsets, index.offsets.size() * sizeof(uint32_t)));
    ANN_GPU_CHECK(cudaMalloc(&d_list_ids, index.ids.size() * sizeof(uint32_t)));
    ANN_GPU_CHECK(cudaMalloc(&d_queries, query_chunk * dim * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_centroid_scores, query_chunk * nlist * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_probes, query_chunk * nprobe * sizeof(uint32_t)));
    ANN_GPU_CHECK(cudaMalloc(&d_dist, query_chunk * k * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_ids, query_chunk * k * sizeof(uint32_t)));

    cudaEvent_t a, b, c, d, e, f;
    ANN_GPU_CHECK(cudaEventCreate(&a));
    ANN_GPU_CHECK(cudaEventCreate(&b));
    ANN_GPU_CHECK(cudaEventCreate(&c));
    ANN_GPU_CHECK(cudaEventCreate(&d));
    ANN_GPU_CHECK(cudaEventCreate(&e));
    ANN_GPU_CHECK(cudaEventCreate(&f));

    ANN_GPU_CHECK(cudaEventRecord(a));
    ANN_GPU_CHECK(cudaMemcpy(d_centroids, index.centroids.data(),
                             index.centroids.size() * sizeof(float),
                             cudaMemcpyHostToDevice));
    ANN_GPU_CHECK(cudaMemcpy(d_vectors, index.vectors.data(),
                             index.vectors.size() * sizeof(float),
                             cudaMemcpyHostToDevice));
    ANN_GPU_CHECK(cudaMemcpy(d_offsets, index.offsets.data(),
                             index.offsets.size() * sizeof(uint32_t),
                             cudaMemcpyHostToDevice));
    ANN_GPU_CHECK(cudaMemcpy(d_list_ids, index.ids.data(),
                             index.ids.size() * sizeof(uint32_t),
                             cudaMemcpyHostToDevice));
    ANN_GPU_CHECK(cudaEventRecord(b));
    ANN_GPU_CHECK(cudaEventSynchronize(b));
    local.base_copy_ms = ElapsedMs(a, b);

    std::vector<float> all_dist(query_n * k);
    std::vector<uint32_t> all_ids(query_n * k);

    for (size_t begin = 0; begin < query_n; begin += query_chunk) {
        const size_t chunk = std::min(query_chunk, query_n - begin);
        ANN_GPU_CHECK(cudaEventRecord(a));
        ANN_GPU_CHECK(cudaMemcpy(d_queries, queries + begin * dim,
                                 chunk * dim * sizeof(float),
                                 cudaMemcpyHostToDevice));
        ANN_GPU_CHECK(cudaEventRecord(b));

        dim3 block(16, 16);
        dim3 grid(DivUp(nlist, 16), DivUp(chunk, 16));
        ScoreGemmKernel<<<grid, block>>>(d_centroids, d_queries,
                                         d_centroid_scores,
                                         static_cast<int>(nlist),
                                         static_cast<int>(chunk),
                                         static_cast<int>(dim));
        ANN_GPU_CHECK(cudaGetLastError());
        ANN_GPU_CHECK(cudaEventRecord(c));

        SelectProbeKernel<<<static_cast<unsigned int>(chunk), 1>>>(
            d_centroid_scores, d_probes, static_cast<int>(nlist),
            static_cast<int>(nprobe));
        ANN_GPU_CHECK(cudaGetLastError());
        ANN_GPU_CHECK(cudaEventRecord(d));

        IvfSearchKernel<<<static_cast<unsigned int>(chunk), threads,
                          shared_bytes>>>(d_vectors, d_list_ids, d_offsets,
                                          d_probes, d_queries, d_dist, d_ids,
                                          static_cast<int>(dim),
                                          static_cast<int>(nprobe));
        ANN_GPU_CHECK(cudaGetLastError());
        ANN_GPU_CHECK(cudaEventRecord(e));

        ANN_GPU_CHECK(cudaMemcpy(all_dist.data() + begin * k, d_dist,
                                 chunk * k * sizeof(float),
                                 cudaMemcpyDeviceToHost));
        ANN_GPU_CHECK(cudaMemcpy(all_ids.data() + begin * k, d_ids,
                                 chunk * k * sizeof(uint32_t),
                                 cudaMemcpyDeviceToHost));
        ANN_GPU_CHECK(cudaEventRecord(f));
        ANN_GPU_CHECK(cudaEventSynchronize(f));

        local.query_copy_ms += ElapsedMs(a, b);
        local.score_ms += ElapsedMs(b, d);
        local.topk_ms += ElapsedMs(d, e);
        local.result_copy_ms += ElapsedMs(e, f);
        local.online_ms += ElapsedMs(a, f);
    }

    ANN_GPU_CHECK(cudaEventDestroy(a));
    ANN_GPU_CHECK(cudaEventDestroy(b));
    ANN_GPU_CHECK(cudaEventDestroy(c));
    ANN_GPU_CHECK(cudaEventDestroy(d));
    ANN_GPU_CHECK(cudaEventDestroy(e));
    ANN_GPU_CHECK(cudaEventDestroy(f));
    ANN_GPU_CHECK(cudaFree(d_centroids));
    ANN_GPU_CHECK(cudaFree(d_vectors));
    ANN_GPU_CHECK(cudaFree(d_offsets));
    ANN_GPU_CHECK(cudaFree(d_list_ids));
    ANN_GPU_CHECK(cudaFree(d_queries));
    ANN_GPU_CHECK(cudaFree(d_centroid_scores));
    ANN_GPU_CHECK(cudaFree(d_probes));
    ANN_GPU_CHECK(cudaFree(d_dist));
    ANN_GPU_CHECK(cudaFree(d_ids));

    if (stats) {
        *stats = local;
    }
    return BuildHeaps(all_dist, all_ids, query_n, k);
}

inline std::vector<SearchHeap> gpu_ivf_grouped_search(
    float* base, float* queries, size_t base_n, size_t query_n,
    size_t dim, size_t k, size_t nlist, size_t nprobe,
    GpuSearchStats* stats = NULL, size_t query_chunk = 128,
    int requested_threads = 256) {
    if (k != static_cast<size_t>(kGpuTopK)) {
        throw std::runtime_error("gpu_ivf_grouped_search currently expects k=10");
    }
    nlist = std::max<size_t>(1, std::min(nlist, base_n));
    nprobe = std::max<size_t>(1, std::min(nprobe, nlist));
    if (nprobe > 32) {
        throw std::runtime_error("gpu_ivf_grouped_search supports nprobe <= 32");
    }

    GpuSearchStats local;
    local.mode = "gpu_ivf_grouped_batch_gemm_topk";
    local.query_n = query_n;
    local.base_n = base_n;
    local.dim = dim;
    local.nlist = nlist;
    local.nprobe = nprobe;
    CpuIvfIndex index = BuildCpuIvf(base, base_n, dim, nlist, 2, &local);

    size_t max_list_size = 0;
    for (size_t c = 0; c < nlist; ++c) {
        max_list_size = std::max(
            max_list_size,
            static_cast<size_t>(index.offsets[c + 1] - index.offsets[c]));
    }
    if (max_list_size == 0) {
        throw std::runtime_error("gpu_ivf_grouped_search built empty IVF index");
    }

    const int threads = ClampThreads(requested_threads);
    const size_t shared_bytes = static_cast<size_t>(threads) * kGpuTopK *
        (sizeof(float) + sizeof(uint32_t));

    float* d_centroids = NULL;
    float* d_vectors = NULL;
    uint32_t* d_offsets = NULL;
    uint32_t* d_list_ids = NULL;
    float* d_queries = NULL;
    float* d_centroid_scores = NULL;
    uint32_t* d_probes = NULL;
    float* d_group_queries = NULL;
    float* d_group_scores = NULL;
    float* d_group_dist = NULL;
    uint32_t* d_group_ids = NULL;

    ANN_GPU_CHECK(cudaMalloc(&d_centroids, index.centroids.size() * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_vectors, index.vectors.size() * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_offsets, index.offsets.size() * sizeof(uint32_t)));
    ANN_GPU_CHECK(cudaMalloc(&d_list_ids, index.ids.size() * sizeof(uint32_t)));
    ANN_GPU_CHECK(cudaMalloc(&d_queries, query_chunk * dim * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_centroid_scores, query_chunk * nlist * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_probes, query_chunk * nprobe * sizeof(uint32_t)));
    ANN_GPU_CHECK(cudaMalloc(&d_group_queries, query_chunk * dim * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_group_scores, query_chunk * max_list_size * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_group_dist, query_chunk * k * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_group_ids, query_chunk * k * sizeof(uint32_t)));

    cudaEvent_t a, b, c, d, e, f;
    ANN_GPU_CHECK(cudaEventCreate(&a));
    ANN_GPU_CHECK(cudaEventCreate(&b));
    ANN_GPU_CHECK(cudaEventCreate(&c));
    ANN_GPU_CHECK(cudaEventCreate(&d));
    ANN_GPU_CHECK(cudaEventCreate(&e));
    ANN_GPU_CHECK(cudaEventCreate(&f));

    ANN_GPU_CHECK(cudaEventRecord(a));
    ANN_GPU_CHECK(cudaMemcpy(d_centroids, index.centroids.data(),
                             index.centroids.size() * sizeof(float),
                             cudaMemcpyHostToDevice));
    ANN_GPU_CHECK(cudaMemcpy(d_vectors, index.vectors.data(),
                             index.vectors.size() * sizeof(float),
                             cudaMemcpyHostToDevice));
    ANN_GPU_CHECK(cudaMemcpy(d_offsets, index.offsets.data(),
                             index.offsets.size() * sizeof(uint32_t),
                             cudaMemcpyHostToDevice));
    ANN_GPU_CHECK(cudaMemcpy(d_list_ids, index.ids.data(),
                             index.ids.size() * sizeof(uint32_t),
                             cudaMemcpyHostToDevice));
    ANN_GPU_CHECK(cudaEventRecord(b));
    ANN_GPU_CHECK(cudaEventSynchronize(b));
    local.base_copy_ms = ElapsedMs(a, b);

    std::vector<float> best_score(query_n * k, ANN_GPU_NEG_INFINITY);
    std::vector<uint32_t> best_ids(query_n * k, kInvalidId);
    std::vector<uint32_t> h_probes(query_chunk * nprobe);
    std::vector<std::vector<uint32_t> > groups(nlist);
    std::vector<float> h_group_queries(query_chunk * dim);
    std::vector<float> h_group_dist(query_chunk * k);
    std::vector<uint32_t> h_group_ids(query_chunk * k);

    const auto online_begin = std::chrono::high_resolution_clock::now();
    for (size_t begin = 0; begin < query_n; begin += query_chunk) {
        const size_t chunk = std::min(query_chunk, query_n - begin);
        ANN_GPU_CHECK(cudaEventRecord(a));
        ANN_GPU_CHECK(cudaMemcpy(d_queries, queries + begin * dim,
                                 chunk * dim * sizeof(float),
                                 cudaMemcpyHostToDevice));
        ANN_GPU_CHECK(cudaEventRecord(b));

        dim3 cblock(16, 16);
        dim3 cgrid(DivUp(nlist, 16), DivUp(chunk, 16));
        ScoreGemmKernel<<<cgrid, cblock>>>(d_centroids, d_queries,
                                           d_centroid_scores,
                                           static_cast<int>(nlist),
                                           static_cast<int>(chunk),
                                           static_cast<int>(dim));
        ANN_GPU_CHECK(cudaGetLastError());
        SelectProbeKernel<<<static_cast<unsigned int>(chunk), 1>>>((
            d_centroid_scores), d_probes, static_cast<int>(nlist),
            static_cast<int>(nprobe));
        ANN_GPU_CHECK(cudaGetLastError());
        ANN_GPU_CHECK(cudaEventRecord(c));
        ANN_GPU_CHECK(cudaMemcpy(h_probes.data(), d_probes,
                                 chunk * nprobe * sizeof(uint32_t),
                                 cudaMemcpyDeviceToHost));
        ANN_GPU_CHECK(cudaEventRecord(d));
        ANN_GPU_CHECK(cudaEventSynchronize(d));

        for (size_t list = 0; list < nlist; ++list) {
            groups[list].clear();
        }
        for (size_t q = 0; q < chunk; ++q) {
            for (size_t pi = 0; pi < nprobe; ++pi) {
                const uint32_t list = h_probes[q * nprobe + pi];
                if (list < nlist) {
                    groups[list].push_back(static_cast<uint32_t>(q));
                }
            }
        }

        local.query_copy_ms += ElapsedMs(a, b);
        local.score_ms += ElapsedMs(b, c);
        local.result_copy_ms += ElapsedMs(c, d);

        for (size_t list = 0; list < nlist; ++list) {
            const size_t group_size = groups[list].size();
            if (group_size == 0) {
                continue;
            }
            const uint32_t list_begin = index.offsets[list];
            const uint32_t list_end = index.offsets[list + 1];
            const size_t list_size =
                static_cast<size_t>(list_end - list_begin);
            if (list_size == 0) {
                continue;
            }

            for (size_t gi = 0; gi < group_size; ++gi) {
                const size_t local_q = groups[list][gi];
                std::memcpy(h_group_queries.data() + gi * dim,
                            queries + (begin + local_q) * dim,
                            dim * sizeof(float));
            }

            ANN_GPU_CHECK(cudaEventRecord(a));
            ANN_GPU_CHECK(cudaMemcpy(d_group_queries, h_group_queries.data(),
                                     group_size * dim * sizeof(float),
                                     cudaMemcpyHostToDevice));
            ANN_GPU_CHECK(cudaEventRecord(b));

            dim3 block(16, 16);
            dim3 grid(DivUp(list_size, 16), DivUp(group_size, 16));
            ScoreGemmKernel<<<grid, block>>>(
                d_vectors + static_cast<size_t>(list_begin) * dim,
                d_group_queries, d_group_scores,
                static_cast<int>(list_size), static_cast<int>(group_size),
                static_cast<int>(dim));
            ANN_GPU_CHECK(cudaGetLastError());
            ANN_GPU_CHECK(cudaEventRecord(c));

            ScoreTopKWithIdsTreeKernel<<<static_cast<unsigned int>(group_size),
                                          threads, shared_bytes>>>(
                d_group_scores, d_list_ids + list_begin,
                d_group_dist, d_group_ids, static_cast<int>(list_size));
            ANN_GPU_CHECK(cudaGetLastError());
            ANN_GPU_CHECK(cudaEventRecord(e));

            ANN_GPU_CHECK(cudaMemcpy(h_group_dist.data(), d_group_dist,
                                     group_size * k * sizeof(float),
                                     cudaMemcpyDeviceToHost));
            ANN_GPU_CHECK(cudaMemcpy(h_group_ids.data(), d_group_ids,
                                     group_size * k * sizeof(uint32_t),
                                     cudaMemcpyDeviceToHost));
            ANN_GPU_CHECK(cudaEventRecord(f));
            ANN_GPU_CHECK(cudaEventSynchronize(f));

            local.query_copy_ms += ElapsedMs(a, b);
            local.score_ms += ElapsedMs(b, c);
            local.topk_ms += ElapsedMs(c, e);
            local.result_copy_ms += ElapsedMs(e, f);

            for (size_t gi = 0; gi < group_size; ++gi) {
                const size_t query_id = begin + groups[list][gi];
                float* dst_score = best_score.data() + query_id * k;
                uint32_t* dst_id = best_ids.data() + query_id * k;
                for (size_t slot = 0; slot < k; ++slot) {
                    const uint32_t id = h_group_ids[gi * k + slot];
                    if (id != kInvalidId) {
                        PushHostTopK(1.0f - h_group_dist[gi * k + slot],
                                     id, dst_score, dst_id);
                    }
                }
            }
        }
    }
    const auto online_end = std::chrono::high_resolution_clock::now();
    local.online_ms =
        std::chrono::duration<float, std::milli>(online_end - online_begin)
            .count();

    ANN_GPU_CHECK(cudaEventDestroy(a));
    ANN_GPU_CHECK(cudaEventDestroy(b));
    ANN_GPU_CHECK(cudaEventDestroy(c));
    ANN_GPU_CHECK(cudaEventDestroy(d));
    ANN_GPU_CHECK(cudaEventDestroy(e));
    ANN_GPU_CHECK(cudaEventDestroy(f));
    ANN_GPU_CHECK(cudaFree(d_centroids));
    ANN_GPU_CHECK(cudaFree(d_vectors));
    ANN_GPU_CHECK(cudaFree(d_offsets));
    ANN_GPU_CHECK(cudaFree(d_list_ids));
    ANN_GPU_CHECK(cudaFree(d_queries));
    ANN_GPU_CHECK(cudaFree(d_centroid_scores));
    ANN_GPU_CHECK(cudaFree(d_probes));
    ANN_GPU_CHECK(cudaFree(d_group_queries));
    ANN_GPU_CHECK(cudaFree(d_group_scores));
    ANN_GPU_CHECK(cudaFree(d_group_dist));
    ANN_GPU_CHECK(cudaFree(d_group_ids));

    std::vector<float> all_dist(query_n * k);
    for (size_t qi = 0; qi < query_n; ++qi) {
        for (size_t slot = 0; slot < k; ++slot) {
            const float score = best_score[qi * k + slot];
            all_dist[qi * k + slot] =
                score == ANN_GPU_NEG_INFINITY ? 1.0f - ANN_GPU_NEG_INFINITY
                                              : 1.0f - score;
        }
    }

    if (stats) {
        *stats = local;
    }
    return BuildHeaps(all_dist, best_ids, query_n, k);
}

}  // namespace ann_gpu
