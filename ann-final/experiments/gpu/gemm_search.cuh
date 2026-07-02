#pragma once

#include <algorithm>
#include <cstdint>
#include <stdexcept>
#include <vector>

#include "common.cuh"
#include "gemm_kernel.cuh"
#include "topk.cuh"

namespace ann_gpu {

inline std::vector<SearchHeap> gpu_gemm_search(float* base, float* queries,
                                               size_t base_n, size_t query_n,
                                               size_t dim, size_t k,
                                               GpuSearchStats* stats = NULL,
                                               size_t query_chunk = 128,
                                               int requested_threads = 256,
                                               bool use_tree_topk = false,
                                               bool use_cublas_score = false) {
    if (k != static_cast<size_t>(kGpuTopK)) {
        throw std::runtime_error("gpu_gemm_search currently expects k=10");
    }
    if (base_n > static_cast<size_t>(0x7fffffff) ||
        query_n > static_cast<size_t>(0x7fffffff) ||
        dim > static_cast<size_t>(0x7fffffff)) {
        throw std::runtime_error("dataset dimension exceeds CUDA int limit");
    }

    GpuSearchStats local;
    if (use_cublas_score) {
        local.mode = use_tree_topk ? "gpu_cublas_batch_tree_topk"
                                   : "gpu_cublas_batch_topk";
    } else {
        local.mode = use_tree_topk ? "gpu_gemm_batch_tree_topk"
                                   : "gpu_gemm_batch_topk";
    }
    local.query_n = query_n;
    local.base_n = base_n;
    local.dim = dim;

    const int threads = ClampThreads(requested_threads);
    const size_t shared_bytes = static_cast<size_t>(threads) * kGpuTopK *
        (sizeof(float) + sizeof(uint32_t));
    const size_t base_bytes = base_n * dim * sizeof(float);

    float* d_base = NULL;
    float* d_queries = NULL;
    float* d_scores = NULL;
    float* d_dist = NULL;
    uint32_t* d_ids = NULL;
    ANN_GPU_CHECK(cudaMalloc(&d_base, base_bytes));
    ANN_GPU_CHECK(cudaMalloc(&d_queries, query_chunk * dim * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_scores, query_chunk * base_n * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_dist, query_chunk * k * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_ids, query_chunk * k * sizeof(uint32_t)));

    cudaEvent_t a, b, c, d, e;
    ANN_GPU_CHECK(cudaEventCreate(&a));
    ANN_GPU_CHECK(cudaEventCreate(&b));
    ANN_GPU_CHECK(cudaEventCreate(&c));
    ANN_GPU_CHECK(cudaEventCreate(&d));
    ANN_GPU_CHECK(cudaEventCreate(&e));

    ANN_GPU_CHECK(cudaEventRecord(a));
    ANN_GPU_CHECK(cudaMemcpy(d_base, base, base_bytes, cudaMemcpyHostToDevice));
    ANN_GPU_CHECK(cudaEventRecord(b));
    ANN_GPU_CHECK(cudaEventSynchronize(b));
    local.base_copy_ms = ElapsedMs(a, b);

    cublasHandle_t handle = NULL;
    if (use_cublas_score) {
        ANN_CUBLAS_CHECK(cublasCreate(&handle));
    }

    std::vector<float> all_dist(query_n * k);
    std::vector<uint32_t> all_ids(query_n * k);

    for (size_t begin = 0; begin < query_n; begin += query_chunk) {
        const size_t chunk = std::min(query_chunk, query_n - begin);
        const size_t query_bytes = chunk * dim * sizeof(float);
        const size_t result_bytes = chunk * k * sizeof(float);
        const size_t id_bytes = chunk * k * sizeof(uint32_t);

        ANN_GPU_CHECK(cudaEventRecord(a));
        ANN_GPU_CHECK(cudaMemcpy(d_queries, queries + begin * dim, query_bytes,
                                 cudaMemcpyHostToDevice));
        ANN_GPU_CHECK(cudaEventRecord(b));

        if (use_cublas_score) {
            const float alpha = 1.0f;
            const float beta = 0.0f;
            ANN_CUBLAS_CHECK(cublasSgemm(
                handle, CUBLAS_OP_T, CUBLAS_OP_N,
                static_cast<int>(base_n), static_cast<int>(chunk),
                static_cast<int>(dim), &alpha, d_base,
                static_cast<int>(dim), d_queries, static_cast<int>(dim),
                &beta, d_scores, static_cast<int>(base_n)));
        } else {
            dim3 block(16, 16);
            dim3 grid(DivUp(base_n, 16), DivUp(chunk, 16));
            ScoreGemmKernel<<<grid, block>>>(d_base, d_queries, d_scores,
                                             static_cast<int>(base_n),
                                             static_cast<int>(chunk),
                                             static_cast<int>(dim));
            ANN_GPU_CHECK(cudaGetLastError());
        }
        ANN_GPU_CHECK(cudaEventRecord(c));

        if (use_tree_topk) {
            ScoreTopKTreeKernel<<<static_cast<unsigned int>(chunk), threads,
                                  shared_bytes>>>(d_scores, d_dist, d_ids,
                                                  static_cast<int>(base_n));
        } else {
            ScoreTopKKernel<<<static_cast<unsigned int>(chunk), threads,
                              shared_bytes>>>(d_scores, d_dist, d_ids,
                                              static_cast<int>(base_n));
        }
        ANN_GPU_CHECK(cudaGetLastError());
        ANN_GPU_CHECK(cudaEventRecord(d));

        ANN_GPU_CHECK(cudaMemcpy(all_dist.data() + begin * k, d_dist,
                                 result_bytes, cudaMemcpyDeviceToHost));
        ANN_GPU_CHECK(cudaMemcpy(all_ids.data() + begin * k, d_ids,
                                 id_bytes, cudaMemcpyDeviceToHost));
        ANN_GPU_CHECK(cudaEventRecord(e));
        ANN_GPU_CHECK(cudaEventSynchronize(e));

        local.query_copy_ms += ElapsedMs(a, b);
        local.score_ms += ElapsedMs(b, c);
        local.topk_ms += ElapsedMs(c, d);
        local.result_copy_ms += ElapsedMs(d, e);
        local.online_ms += ElapsedMs(a, e);
    }

    ANN_GPU_CHECK(cudaEventDestroy(a));
    ANN_GPU_CHECK(cudaEventDestroy(b));
    ANN_GPU_CHECK(cudaEventDestroy(c));
    ANN_GPU_CHECK(cudaEventDestroy(d));
    ANN_GPU_CHECK(cudaEventDestroy(e));
    if (handle) {
        ANN_CUBLAS_CHECK(cublasDestroy(handle));
    }
    ANN_GPU_CHECK(cudaFree(d_base));
    ANN_GPU_CHECK(cudaFree(d_queries));
    ANN_GPU_CHECK(cudaFree(d_scores));
    ANN_GPU_CHECK(cudaFree(d_dist));
    ANN_GPU_CHECK(cudaFree(d_ids));

    if (stats) {
        *stats = local;
    }
    return BuildHeaps(all_dist, all_ids, query_n, k);
}

}  // namespace ann_gpu
