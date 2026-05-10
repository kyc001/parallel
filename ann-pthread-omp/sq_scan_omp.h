#pragma once
#include "sq_scan_dispatch.h"

#include <cstdint>
#include <omp.h>
#include <queue>
#include <utility>
#include <vector>

namespace ann_sq_omp {

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

}  // namespace ann_sq_omp

inline std::priority_queue<std::pair<float, uint32_t>>
sq_search_omp_intra(float* base, float* query, size_t base_number, size_t vecdim,
                    size_t k, const SQIndex& sq_index, size_t rerank_p) {
    std::vector<uint8_t> query_code(vecdim);
    sq_index.encode_query(query, query_code.data());
    const uint8_t* qc = query_code.data();

    // 原 sq_search 粗排段：base loop -> top-p coarse heap.
    const int nthreads = omp_get_max_threads();
    using CoarseHeap = std::priority_queue<std::pair<uint32_t, uint32_t>>;
    std::vector<CoarseHeap> local_heaps(nthreads);

#pragma omp parallel num_threads(nthreads)
    {
        CoarseHeap& coarse_q = local_heaps[omp_get_thread_num()];
#pragma omp for schedule(runtime)
        for (long long i = 0; i < static_cast<long long>(base_number); ++i) {
            const uint32_t dis = ann_sq_omp::sq_l2_distance(
                sq_index.codes.data() + static_cast<size_t>(i) * vecdim,
                qc, static_cast<int>(vecdim));

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

    // 原 sq_search 精排段：串行 rerank top-p -> top-k.
    std::priority_queue<std::pair<float, uint32_t>> q;
    while (!coarse_q.empty()) {
        const uint32_t idx = coarse_q.top().second;
        coarse_q.pop();
        const float dis = ann_sq_omp::ip_distance(
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
