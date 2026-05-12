#pragma once

#include <algorithm>
#include <cstdint>
#include <cstddef>
#include <omp.h>
#include <queue>
#include <utility>
#include <vector>

#if defined(__aarch64__) || defined(__ARM_NEON)
#include "../simd/flat_scan_simd.h"
#define ANN_FLAT_OMP_HAS_NEON 1
#elif defined(__AVX2__)
#include "../simd/flat_scan_avx2.h"
#define ANN_FLAT_OMP_HAS_AVX2 1
#else
#include "flat_scan.h"
#endif

namespace ann_flat_omp {

using FlatHeap = std::priority_queue<std::pair<float, uint32_t>>;

static inline int NormalizeThreads(int nthreads) {
    return nthreads < 1 ? 1 : nthreads;
}

static inline float Distance(const float* base, const float* query, size_t d) {
#if defined(ANN_FLAT_OMP_HAS_NEON)
    return ip_distance_simd(base, query, static_cast<int>(d));
#elif defined(ANN_FLAT_OMP_HAS_AVX2)
    return ann_avx2::ip_distance_avx2(base, query, static_cast<int>(d));
#else
    float dot = 0.0f;
    for (size_t i = 0; i < d; ++i) {
        dot += base[i] * query[i];
    }
    return 1.0f - dot;
#endif
}

static inline void PushTopK(FlatHeap& heap, float dist, uint32_t id, size_t k) {
    if (k == 0) {
        return;
    }
    if (heap.size() < k) {
        heap.push(std::make_pair(dist, id));
    } else if (dist < heap.top().first) {
        heap.push(std::make_pair(dist, id));
        heap.pop();
    }
}

static inline FlatHeap MergeHeaps(std::vector<FlatHeap>& heaps, size_t k) {
    FlatHeap result;
    for (size_t i = 0; i < heaps.size(); ++i) {
        FlatHeap& heap = heaps[i];
        while (!heap.empty()) {
            const std::pair<float, uint32_t> item = heap.top();
            heap.pop();
            PushTopK(result, item.first, item.second, k);
        }
    }
    return result;
}

}  // namespace ann_flat_omp

static inline void flat_search_inter_omp(
    float* base, float* queries, size_t base_n, size_t query_n,
    size_t d, size_t k, int nthreads,
    std::vector<ann_flat_omp::FlatHeap>& results) {
    nthreads = ann_flat_omp::NormalizeThreads(nthreads);
    results.clear();
    results.resize(query_n);

#pragma omp parallel for num_threads(nthreads) schedule(static)
    for (long long i = 0; i < static_cast<long long>(query_n); ++i) {
        results[static_cast<size_t>(i)] =
            flat_search(base, queries + static_cast<size_t>(i) * d, base_n, d, k);
    }
}

static inline ann_flat_omp::FlatHeap flat_search_intra_omp(
    float* base, float* query, size_t base_n, size_t d, size_t k, int nthreads) {
    nthreads = ann_flat_omp::NormalizeThreads(nthreads);
    std::vector<ann_flat_omp::FlatHeap> heaps(static_cast<size_t>(nthreads));

#pragma omp parallel num_threads(nthreads)
    {
        const int tid = omp_get_thread_num();
#pragma omp for schedule(static)
        for (long long i = 0; i < static_cast<long long>(base_n); ++i) {
            const size_t idx = static_cast<size_t>(i);
            const float dist = ann_flat_omp::Distance(base + idx * d, query, d);
            ann_flat_omp::PushTopK(heaps[static_cast<size_t>(tid)], dist,
                                   static_cast<uint32_t>(idx), k);
        }
    }

    return ann_flat_omp::MergeHeaps(heaps, k);
}
