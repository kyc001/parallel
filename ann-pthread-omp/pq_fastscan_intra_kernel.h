#pragma once
#include "pq_fastscan_simd.h"

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <queue>
#include <utility>
#include <vector>

namespace ann_fs_intra {

using CoarseHeap = std::priority_queue<std::pair<uint32_t, uint32_t>>;
using Heap = std::priority_queue<std::pair<float, uint32_t>>;

inline int block_size() {
#if defined(__AVX2__)
    return 32;
#else
    return ann_fs::kFastScanNeonBlockSize;
#endif
}

inline void batch(const ann_fs::FastScanIndex& idx, const uint8_t* lut_u8,
                  int blk, uint8_t* out_dis) {
#if defined(__AVX2__)
    ann_fs::fastscan_batch32(idx.codes_packed.data(), lut_u8, idx.M, idx.nblk,
                             blk, out_dis);
#else
    ann_fs::fastscan_batch16(idx.codes_packed.data(), lut_u8, idx.M, idx.nblk,
                             blk, out_dis);
#endif
}

inline void merge_into(CoarseHeap& dst, CoarseHeap src, size_t p) {
    while (!src.empty()) {
        const auto e = src.top();
        src.pop();
        if (dst.size() < p) {
            dst.push(e);
        } else if (e < dst.top()) {
            dst.pop();
            dst.push(e);
        }
    }
}

// Extracted from fastscan_search_omp_intra packed-code batch loop.
inline CoarseHeap chunk_coarse(const ann_fs::FastScanIndex& idx,
                               const uint8_t* lut_u8, int batch_lo,
                               int batch_hi, size_t p) {
    const size_t candidate_count = std::min(p, static_cast<size_t>(idx.N));
    const int bs = block_size();
    std::vector<uint8_t> block_dis(static_cast<size_t>(bs), 0);
    CoarseHeap coarse;
    for (int blk = batch_lo; blk < batch_hi; ++blk) {
        batch(idx, lut_u8, blk, block_dis.data());
        const int base_i = blk * bs;
        for (int lane = 0; lane < bs; ++lane) {
            const int i = base_i + lane;
            if (i >= idx.N) break;
            const auto cand = std::make_pair(
                static_cast<uint32_t>(block_dis[static_cast<size_t>(lane)]),
                static_cast<uint32_t>(i));
            if (coarse.size() < candidate_count) {
                coarse.push(cand);
            } else if (cand < coarse.top()) {
                coarse.pop();
                coarse.push(cand);
            }
        }
    }
    return coarse;
}

inline CoarseHeap chunk_coarse(const ann_fs::FastScanIndex& idx,
                               const float* query, int batch_lo,
                               int batch_hi, size_t p) {
    std::vector<uint8_t> lut_u8;
    ann_fs::build_lut_u8(idx, query, lut_u8);
    return chunk_coarse(idx, lut_u8.data(), batch_lo, batch_hi, p);
}

inline CoarseHeap merge_topp(std::vector<CoarseHeap>& locals, size_t p) {
    CoarseHeap coarse;
    const size_t candidate_count = p;
    for (auto& local : locals) merge_into(coarse, std::move(local), candidate_count);
    return coarse;
}

// Extracted from fastscan_search_omp_intra serial rerank stage.
inline Heap rerank(const ann_fs::FastScanIndex& idx, const float* base,
                   const float* query, size_t k, CoarseHeap coarse) {
    Heap result;
    while (!coarse.empty()) {
        const uint32_t idx_i = coarse.top().second;
        coarse.pop();
        const float dis = ann_fs::fs_ip_distance(
            base + static_cast<size_t>(idx_i) * idx.d, query, idx.d);
        if (result.size() < k) {
            result.emplace(dis, idx_i);
        } else if (dis < result.top().first) {
            result.pop();
            result.emplace(dis, idx_i);
        }
    }
    return result;
}

}  // namespace ann_fs_intra
