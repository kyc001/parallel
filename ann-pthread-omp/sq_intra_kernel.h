#pragma once
#include "sq_scan_dispatch.h"

#include <cstddef>
#include <cstdint>
#include <queue>
#include <utility>
#include <vector>

namespace sq_intra {

using CoarseHeap = std::priority_queue<std::pair<uint32_t, uint32_t>>;
using Heap = std::priority_queue<std::pair<float, uint32_t>>;

inline uint32_t sq_l2_distance(const uint8_t* x, const uint8_t* y, int d) {
#if defined(__AVX2__)
    return sq_l2_distance_avx2(x, y, d);
#else
    return sq_l2_distance_simd(x, y, d);
#endif
}

inline float ip_distance(const float* x, const float* y, int d) {
#if defined(__AVX2__)
    return ann_avx2::ip_distance_avx2(x, y, d);
#else
    return ip_distance_simd(x, y, d);
#endif
}

inline void merge_into(CoarseHeap& dst, CoarseHeap src, size_t p) {
    while (!src.empty()) {
        const auto e = src.top();
        src.pop();
        if (dst.size() < p) {
            dst.push(e);
        } else if (e.first < dst.top().first) {
            dst.pop();
            dst.push(e);
        }
    }
}

// Extracted from sq_search_omp_intra coarse base loop.
inline CoarseHeap chunk_coarse(const SQIndex& sq_index, const uint8_t* query_code,
                               size_t vecdim, size_t lo, size_t hi, size_t p) {
    CoarseHeap coarse;
    for (size_t i = lo; i < hi; ++i) {
        const uint32_t dis = sq_l2_distance(
            sq_index.codes.data() + i * vecdim, query_code, static_cast<int>(vecdim));
        if (coarse.size() < p) {
            coarse.push({dis, static_cast<uint32_t>(i)});
        } else if (dis < coarse.top().first) {
            coarse.push({dis, static_cast<uint32_t>(i)});
            coarse.pop();
        }
    }
    return coarse;
}

inline CoarseHeap chunk_coarse(const SQIndex& sq_index, const float* query,
                               size_t lo, size_t hi, size_t p) {
    std::vector<uint8_t> query_code(sq_index.d);
    sq_index.encode_query(query, query_code.data());
    return chunk_coarse(sq_index, query_code.data(), sq_index.d, lo, hi, p);
}

inline CoarseHeap merge_topp(std::vector<CoarseHeap>& locals, size_t p) {
    CoarseHeap coarse;
    for (auto& local : locals) merge_into(coarse, std::move(local), p);
    return coarse;
}

// Extracted from sq_search_omp_intra serial rerank stage.
inline Heap rerank(const float* base, const float* query, size_t vecdim, size_t k,
                   CoarseHeap coarse) {
    Heap result;
    while (!coarse.empty()) {
        const uint32_t idx = coarse.top().second;
        coarse.pop();
        const float dis = ip_distance(
            base + static_cast<size_t>(idx) * vecdim, query, static_cast<int>(vecdim));
        if (result.size() < k) {
            result.push({dis, idx});
        } else if (dis < result.top().first) {
            result.push({dis, idx});
            result.pop();
        }
    }
    return result;
}

}  // namespace sq_intra
