// Flat-AVX2 with cache blocking: scan base vectors in tiles so that a tile
// plus the query fits into L2, reducing DRAM traffic for repeated passes.
// For a single-query search this is of limited value (one sweep), but we
// include the variant so we can quantify whether the Flat workload is
// already bandwidth-saturated (predicted "blocking gives no gain").
#pragma once

#include <cstddef>
#include <cstdint>
#include <immintrin.h>
#include <queue>
#include <utility>

#include "flat_scan_avx2.h"  // reuse ip_distance_avx2 + horizontal_sum

namespace ann_avx2_blocked {

// Tile size chosen to keep (tile_N * vecdim * 4 B) near L2 (~1 MB per core).
// 2048 * 96 * 4 = ~750 KB, fits comfortably in L2 of Raptor Lake P-core.
constexpr size_t kTileN = 2048;

inline std::priority_queue<std::pair<float, uint32_t>>
flat_search_blocked(const float* base, const float* query, size_t base_number,
                    size_t vecdim, size_t k) {
    std::priority_queue<std::pair<float, uint32_t>> q;

    for (size_t block = 0; block < base_number; block += kTileN) {
        const size_t end = std::min(block + kTileN, base_number);
        for (size_t i = block; i < end; ++i) {
            float dis = ann_avx2::ip_distance_avx2(
                base + i * vecdim, query, static_cast<int>(vecdim));
            if (q.size() < k) {
                q.push({dis, static_cast<uint32_t>(i)});
            } else if (dis < q.top().first) {
                q.push({dis, static_cast<uint32_t>(i)});
                q.pop();
            }
        }
    }
    return q;
}

}  // namespace ann_avx2_blocked
