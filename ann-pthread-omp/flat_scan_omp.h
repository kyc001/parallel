#pragma once
#include "flat_scan_dispatch.h"

#include <algorithm>
#include <cstdint>
#include <omp.h>
#include <queue>
#include <utility>
#include <vector>

inline std::priority_queue<std::pair<float, uint32_t>>
flat_search_omp_intra(float* base, float* query,
                      size_t base_number, size_t vecdim, size_t k) {
    const int nthreads = omp_get_max_threads();
    std::vector<std::priority_queue<std::pair<float, uint32_t>>> local_qs(nthreads);

#pragma omp parallel num_threads(nthreads)
    {
        const int tid = omp_get_thread_num();
        const size_t chunk = (base_number + nthreads - 1) / nthreads;
        const size_t lo = static_cast<size_t>(tid) * chunk;
        const size_t hi = std::min(lo + chunk, base_number);
        if (lo < hi) {
            auto pq = flat_search(base + lo * vecdim, query, hi - lo, vecdim, k);
            std::priority_queue<std::pair<float, uint32_t>> off;
            while (!pq.empty()) {
                auto [d, idx] = pq.top();
                off.push({d, idx + static_cast<uint32_t>(lo)});
                pq.pop();
            }
            local_qs[tid] = std::move(off);
        }
    }

    std::priority_queue<std::pair<float, uint32_t>> result;
    for (auto& q : local_qs) {
        while (!q.empty()) {
            if (result.size() < k) {
                result.push(q.top());
            } else if (q.top().first < result.top().first) {
                result.pop();
                result.push(q.top());
            }
            q.pop();
        }
    }
    return result;
}
