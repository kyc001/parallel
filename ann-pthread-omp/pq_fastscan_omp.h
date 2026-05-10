#pragma once
#include "pq_fastscan_simd.h"

#include <algorithm>
#include <cstdint>
#include <omp.h>
#include <queue>
#include <utility>
#include <vector>

namespace ann_fs {

static inline int fastscan_omp_block_size() {
#if defined(__AVX2__)
    return 32;
#else
    return kFastScanNeonBlockSize;
#endif
}

static inline void fastscan_omp_batch(const FastScanIndex& idx,
                                      const uint8_t* lut_u8,
                                      int blk,
                                      uint8_t* out_dis) {
#if defined(__AVX2__)
    fastscan_batch32(idx.codes_packed.data(), lut_u8, idx.M, idx.nblk, blk, out_dis);
#else
    fastscan_batch16(idx.codes_packed.data(), lut_u8, idx.M, idx.nblk, blk, out_dis);
#endif
}

static inline std::priority_queue<std::pair<float, uint32_t>>
fastscan_search_omp_intra(const FastScanIndex& idx, const float* base,
                          const float* query, size_t k, int p) {
    std::vector<uint8_t> lut_u8;
    build_lut_u8(idx, query, lut_u8);

    const size_t candidate_count = std::min(
        static_cast<size_t>(std::max<int>(p, static_cast<int>(k))),
        static_cast<size_t>(idx.N));
    const int nthreads = omp_get_max_threads();
    const int block_size = fastscan_omp_block_size();
    using CoarseHeap = std::priority_queue<std::pair<uint32_t, uint32_t>>;
    std::vector<CoarseHeap> local_heaps(nthreads);

    // 原 fastscan_search 粗排段：batch scan packed codes -> top-p candidates.
#pragma omp parallel num_threads(nthreads)
    {
        std::vector<uint8_t> block_dis(static_cast<size_t>(block_size), 0);
        CoarseHeap& coarse_q = local_heaps[omp_get_thread_num()];
#pragma omp for schedule(static)
        for (int blk = 0; blk < idx.nblk; ++blk) {
            fastscan_omp_batch(idx, lut_u8.data(), blk, block_dis.data());
            const int base_i = blk * block_size;
            for (int lane = 0; lane < block_size; ++lane) {
                const int i = base_i + lane;
                if (i >= idx.N) {
                    break;
                }
                const auto cand = std::make_pair(
                    static_cast<uint32_t>(block_dis[static_cast<size_t>(lane)]),
                    static_cast<uint32_t>(i));
                if (coarse_q.size() < candidate_count) {
                    coarse_q.push(cand);
                } else if (cand < coarse_q.top()) {
                    coarse_q.pop();
                    coarse_q.push(cand);
                }
            }
        }
    }

    CoarseHeap coarse_q;
    for (auto& local : local_heaps) {
        while (!local.empty()) {
            if (coarse_q.size() < candidate_count) {
                coarse_q.push(local.top());
            } else if (local.top() < coarse_q.top()) {
                coarse_q.pop();
                coarse_q.push(local.top());
            }
            local.pop();
        }
    }

    // 原 fastscan_search 精排段：串行 rerank top-p -> top-k.
    std::priority_queue<std::pair<float, uint32_t>> heap;
    while (!coarse_q.empty()) {
        const uint32_t idx_i = coarse_q.top().second;
        coarse_q.pop();
        const float dis = fs_ip_distance(
            base + static_cast<size_t>(idx_i) * idx.d, query, idx.d);
        if (heap.size() < k) {
            heap.emplace(dis, idx_i);
        } else if (dis < heap.top().first) {
            heap.pop();
            heap.emplace(dis, idx_i);
        }
    }
    return heap;
}

}  // namespace ann_fs
