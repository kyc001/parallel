#pragma once
#include "pq_scan_dispatch.h"

#include <cstdint>
#include <omp.h>
#include <queue>
#include <utility>
#include <vector>

namespace ann_pq_omp {

inline float ip_distance(const float* x, const float* y, int d) {
#if defined(__AVX2__)
    return ann_avx2::ip_distance_avx2(x, y, d);
#else
    return ip_distance_simd(x, y, d);
#endif
}

}  // namespace ann_pq_omp

inline std::priority_queue<std::pair<float, uint32_t>>
pq_search_omp_intra(float* base, float* query, size_t base_number, size_t vecdim,
                    size_t k, const PQIndex& pq_index, size_t rerank_p) {
    std::vector<float> lut(static_cast<size_t>(pq_index.M) * 256);
    pq_index.build_lut(query, lut.data());

    // 原 pq_search 粗排段：ADC base loop -> top-p coarse heap.
    const int nthreads = omp_get_max_threads();
    using CoarseHeap = std::priority_queue<std::pair<float, uint32_t>>;
    std::vector<CoarseHeap> local_heaps(nthreads);

#pragma omp parallel num_threads(nthreads)
    {
        CoarseHeap& coarse_q = local_heaps[omp_get_thread_num()];
#pragma omp for schedule(static)
        for (long long i = 0; i < static_cast<long long>(base_number); ++i) {
            const float dis = adc_distance(
                lut.data(),
                pq_index.codes.data() + static_cast<size_t>(i) * pq_index.M,
                pq_index.M);

            if (coarse_q.size() < rerank_p) {
                coarse_q.push({dis, static_cast<uint32_t>(i)});
            } else if (dis < coarse_q.top().first) {
                coarse_q.push({dis, static_cast<uint32_t>(i)});
                coarse_q.pop();
            }
        }
    }

    CoarseHeap coarse_q;
    for (auto& local : local_heaps) {
        while (!local.empty()) {
            if (coarse_q.size() < rerank_p) {
                coarse_q.push(local.top());
            } else if (local.top().first < coarse_q.top().first) {
                coarse_q.pop();
                coarse_q.push(local.top());
            }
            local.pop();
        }
    }

    // 原 pq_search 精排段：串行 rerank top-p -> top-k.
    std::priority_queue<std::pair<float, uint32_t>> q;
    while (!coarse_q.empty()) {
        const uint32_t idx = coarse_q.top().second;
        coarse_q.pop();
        const float dis = ann_pq_omp::ip_distance(
            base + static_cast<size_t>(idx) * vecdim, query, static_cast<int>(vecdim));

        if (q.size() < k) {
            q.push({dis, idx});
        } else if (dis < q.top().first) {
            q.push({dis, idx});
            q.pop();
        }
    }
    return q;
}
