#pragma once

#include <algorithm>
#include <cstdint>
#include <cstddef>
#include <omp.h>
#include <queue>
#include <utility>
#include <vector>

#include "../simd/pq_fastscan_simd.h"

namespace ann_fastscan_omp {

using SearchHeap = std::priority_queue<std::pair<float, uint32_t>>;
using CoarseHeap = std::priority_queue<std::pair<uint32_t, uint32_t>>;

static inline int NormalizeThreads(int nthreads) {
    return nthreads < 1 ? 1 : nthreads;
}

static inline size_t NormalizeRerankP(size_t rerank_p, size_t base_n, size_t k) {
    if (rerank_p < k) {
        rerank_p = k;
    }
    return std::min(rerank_p, base_n);
}

static inline int BatchWidth() {
#if defined(__AVX2__)
    return 32;
#else
    return 16;
#endif
}

static inline void ComputeBlock(const ann_fs::FastScanIndex& index,
                                const std::vector<uint8_t>& lut,
                                int block, uint8_t* out) {
#if defined(__AVX2__)
    ann_fs::fastscan_batch32(index.codes_packed.data(), lut.data(), index.M,
                             index.nblk, block, out);
#else
    ann_fs::fastscan_batch16(index.codes_packed.data(), lut.data(), index.M,
                             index.nblk, block, out);
#endif
}

static inline void PushCoarse(CoarseHeap& heap, uint32_t dist, uint32_t id, size_t keep) {
    if (heap.size() < keep) {
        heap.push(std::make_pair(dist, id));
    } else if (dist < heap.top().first) {
        heap.push(std::make_pair(dist, id));
        heap.pop();
    }
}

static inline void PushTopK(SearchHeap& heap, float dist, uint32_t id, size_t k) {
    if (heap.size() < k) {
        heap.push(std::make_pair(dist, id));
    } else if (dist < heap.top().first) {
        heap.push(std::make_pair(dist, id));
        heap.pop();
    }
}

static inline CoarseHeap MergeCoarse(std::vector<CoarseHeap>& heaps, size_t keep) {
    CoarseHeap result;
    for (size_t i = 0; i < heaps.size(); ++i) {
        while (!heaps[i].empty()) {
            const std::pair<uint32_t, uint32_t> item = heaps[i].top();
            heaps[i].pop();
            PushCoarse(result, item.first, item.second, keep);
        }
    }
    return result;
}

static inline SearchHeap Rerank(const ann_fs::FastScanIndex& index,
                                const float* base, const float* query,
                                size_t k, CoarseHeap& coarse) {
    SearchHeap result;
    while (!coarse.empty()) {
        const uint32_t id = coarse.top().second;
        coarse.pop();
        const float dist =
            ann_fs::fs_ip_distance(base + static_cast<size_t>(id) * index.d, query, index.d);
        PushTopK(result, dist, id, k);
    }
    return result;
}

}  // namespace ann_fastscan_omp

static inline void fastscan_search_inter_omp(
    const ann_fs::FastScanIndex& index, const float* base, const float* queries,
    size_t query_n, size_t k, size_t rerank_p, int nthreads,
    std::vector<ann_fastscan_omp::SearchHeap>& results) {
    nthreads = ann_fastscan_omp::NormalizeThreads(nthreads);
    rerank_p = ann_fastscan_omp::NormalizeRerankP(rerank_p, static_cast<size_t>(index.N), k);
    results.clear();
    results.resize(query_n);

#pragma omp parallel for num_threads(nthreads) schedule(static)
    for (long long i = 0; i < static_cast<long long>(query_n); ++i) {
        const size_t idx = static_cast<size_t>(i);
        results[idx] = ann_fs::fastscan_search(
            index, base, queries + idx * index.d, k, static_cast<int>(rerank_p));
    }
}

static inline ann_fastscan_omp::SearchHeap fastscan_search_intra_omp(
    const ann_fs::FastScanIndex& index, const float* base, const float* query,
    size_t k, size_t rerank_p, int nthreads) {
    nthreads = ann_fastscan_omp::NormalizeThreads(nthreads);
    rerank_p = ann_fastscan_omp::NormalizeRerankP(rerank_p, static_cast<size_t>(index.N), k);
    std::vector<uint8_t> lut;
    ann_fs::build_lut_u8(index, query, lut);

    std::vector<ann_fastscan_omp::CoarseHeap> heaps(static_cast<size_t>(nthreads));
    const int width = ann_fastscan_omp::BatchWidth();

#pragma omp parallel num_threads(nthreads)
    {
        const int tid = omp_get_thread_num();
        std::vector<uint8_t> dist(static_cast<size_t>(width), 0);
#pragma omp for schedule(static)
        for (int block = 0; block < index.nblk; ++block) {
            ann_fastscan_omp::ComputeBlock(index, lut, block, dist.data());
            for (int lane = 0; lane < width; ++lane) {
                const uint32_t id = static_cast<uint32_t>(block * width + lane);
                if (id < static_cast<uint32_t>(index.N)) {
                    ann_fastscan_omp::PushCoarse(
                        heaps[static_cast<size_t>(tid)],
                        dist[static_cast<size_t>(lane)], id, rerank_p);
                }
            }
        }
    }

    ann_fastscan_omp::CoarseHeap coarse =
        ann_fastscan_omp::MergeCoarse(heaps, rerank_p);
    return ann_fastscan_omp::Rerank(index, base, query, k, coarse);
}
