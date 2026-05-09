// Flat-AVX2 with fixed-size top-k array instead of std::priority_queue.
// Motivation: VTune flagged ~18.6% Machine Clears on the Flat path,
// traced to store-load dependency chains inside priority_queue maintenance
// (if (dis < q.top().first) { push; pop; }).
// For small k (here k=10), a linear-insertion fixed-size array avoids the
// heap's reheap cost, reduces branch count, and removes the store-load
// nuke. We predict: lower Machine Clears %, similar or better latency.
#pragma once

#include <cstddef>
#include <cstdint>
#include <immintrin.h>
#include <queue>
#include <utility>
#include <cfloat>

#include "flat_scan_avx2.h"

namespace ann_avx2_topk {

constexpr size_t kMaxK = 64;

// Returns a priority_queue (max-heap by distance) so callers can treat the
// result identically to flat_search; internally uses a fixed array.
inline std::priority_queue<std::pair<float, uint32_t>>
flat_search_array(const float* base, const float* query, size_t base_number,
                  size_t vecdim, size_t k) {
    // Fixed-size arrays, sorted ascending by distance; last entry is worst.
    float  top_d[kMaxK];
    uint32_t top_i[kMaxK];
    size_t filled = 0;
    float worst = FLT_MAX;  // = top_d[filled-1] once full

    for (size_t i = 0; i < base_number; ++i) {
        float dis = ann_avx2::ip_distance_avx2(
            base + i * vecdim, query, static_cast<int>(vecdim));
        if (filled < k) {
            // Linear insertion in the partial array.
            size_t pos = filled;
            while (pos > 0 && top_d[pos - 1] > dis) {
                top_d[pos] = top_d[pos - 1];
                top_i[pos] = top_i[pos - 1];
                --pos;
            }
            top_d[pos] = dis;
            top_i[pos] = static_cast<uint32_t>(i);
            ++filled;
            if (filled == k) worst = top_d[k - 1];
        } else if (dis < worst) {
            // Insert, shifting right; drop the last (largest) element.
            size_t pos = k - 1;
            while (pos > 0 && top_d[pos - 1] > dis) {
                top_d[pos] = top_d[pos - 1];
                top_i[pos] = top_i[pos - 1];
                --pos;
            }
            top_d[pos] = dis;
            top_i[pos] = static_cast<uint32_t>(i);
            worst = top_d[k - 1];
        }
    }

    std::priority_queue<std::pair<float, uint32_t>> q;
    for (size_t j = 0; j < filled; ++j) q.push({top_d[j], top_i[j]});
    return q;
}

}  // namespace ann_avx2_topk
