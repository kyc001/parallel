#pragma once
#include "flat_scan_dispatch.h"

#include <algorithm>
#include <cstdint>
#include <queue>
#include <utility>
#include <vector>

namespace flat_intra {

using Heap = std::priority_queue<std::pair<float, uint32_t>>;

inline void merge_into(Heap& dst, Heap src, size_t k) {
    while (!src.empty()) {
        const auto e = src.top();
        src.pop();
        if (dst.size() < k) {
            dst.push(e);
        } else if (e.first < dst.top().first) {
            dst.pop();
            dst.push(e);
        }
    }
}

inline Heap chunk_topk(float* base, const float* query, size_t lo, size_t hi,
                       size_t vecdim, size_t k) {
    Heap result;
    if (lo >= hi) return result;
    auto local = flat_search(base + lo * vecdim, const_cast<float*>(query),
                             hi - lo, vecdim, k);
    while (!local.empty()) {
        auto e = local.top();
        local.pop();
        e.second += static_cast<uint32_t>(lo);
        result.push(e);
    }
    return result;
}

inline Heap merge(std::vector<Heap>& locals, size_t k) {
    Heap result;
    for (auto& local : locals) merge_into(result, std::move(local), k);
    return result;
}

}  // namespace flat_intra
