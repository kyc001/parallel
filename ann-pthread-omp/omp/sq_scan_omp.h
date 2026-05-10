#pragma once

#include <algorithm>
#include <cstdint>
#include <cstddef>
#include <omp.h>
#include <queue>
#include <utility>
#include <vector>

#if defined(__aarch64__) || defined(__ARM_NEON)
#include "simd/sq_scan_simd.h"
#define ANN_SQ_OMP_HAS_NEON 1
#elif defined(__AVX2__)
#include "simd/sq_scan_avx2.h"
#define ANN_SQ_OMP_HAS_AVX2 1
#else
#error "SQ SIMD requires ARM NEON or x86 AVX2. Compile x86 builds with -mavx2 -mfma."
#endif

namespace ann_sq_omp {

using SearchHeap = std::priority_queue<std::pair<float, uint32_t>>;
using CoarseHeap = std::priority_queue<std::pair<uint32_t, uint32_t>>;

static inline int NormalizeThreads(int nthreads) {
    return nthreads < 1 ? 1 : nthreads;
}

static inline size_t NormalizeRerankP(size_t rerank_p, size_t base_n, size_t k) {
    if (rerank_p < k) {
        rerank_p = k;
    }
    return std::min(rerank_p, base_n);
}

static inline uint32_t CoarseDistance(const uint8_t* x, const uint8_t* y, size_t d) {
#if defined(ANN_SQ_OMP_HAS_NEON)
    return sq_l2_distance_simd(x, y, static_cast<int>(d));
#else
    return sq_l2_distance_avx2(x, y, static_cast<int>(d));
#endif
}

static inline float ExactDistance(const float* base, const float* query, size_t d) {
#if defined(ANN_SQ_OMP_HAS_NEON)
    return ip_distance_simd(base, query, static_cast<int>(d));
#else
    return ann_avx2::ip_distance_avx2(base, query, static_cast<int>(d));
#endif
}

static inline void PushCoarse(CoarseHeap& heap, uint32_t dist, uint32_t id, size_t keep) {
    if (heap.size() < keep) {
        heap.push(std::make_pair(dist, id));
    } else if (dist < heap.top().first) {
        heap.push(std::make_pair(dist, id));
        heap.pop();
    }
}

static inline void PushTopK(SearchHeap& heap, float dist, uint32_t id, size_t k) {
    if (heap.size() < k) {
        heap.push(std::make_pair(dist, id));
    } else if (dist < heap.top().first) {
        heap.push(std::make_pair(dist, id));
        heap.pop();
    }
}

static inline CoarseHeap MergeCoarse(std::vector<CoarseHeap>& heaps, size_t keep) {
    CoarseHeap result;
    for (size_t i = 0; i < heaps.size(); ++i) {
        while (!heaps[i].empty()) {
            const std::pair<uint32_t, uint32_t> item = heaps[i].top();
            heaps[i].pop();
            PushCoarse(result, item.first, item.second, keep);
        }
    }
    return result;
}

static inline SearchHeap Rerank(float* base, float* query, size_t d,
                                size_t k, CoarseHeap& coarse) {
    SearchHeap result;
    while (!coarse.empty()) {
        const uint32_t id = coarse.top().second;
        coarse.pop();
        const float dist = ExactDistance(base + static_cast<size_t>(id) * d, query, d);
        PushTopK(result, dist, id, k);
    }
    return result;
}

}  // namespace ann_sq_omp

static inline void sq_search_inter_omp(
    float* base, float* queries, size_t base_n, size_t query_n,
    size_t d, size_t k, const SQIndex& sq_index, size_t rerank_p, int nthreads,
    std::vector<ann_sq_omp::SearchHeap>& results) {
    nthreads = ann_sq_omp::NormalizeThreads(nthreads);
    rerank_p = ann_sq_omp::NormalizeRerankP(rerank_p, base_n, k);
    results.clear();
    results.resize(query_n);

#pragma omp parallel for num_threads(nthreads) schedule(static)
    for (long long i = 0; i < static_cast<long long>(query_n); ++i) {
        const size_t idx = static_cast<size_t>(i);
        results[idx] =
            sq_search(base, queries + idx * d, base_n, d, k, sq_index, rerank_p);
    }
}

static inline ann_sq_omp::SearchHeap sq_search_intra_omp(
    float* base, float* query, size_t base_n, size_t d, size_t k,
    const SQIndex& sq_index, size_t rerank_p, int nthreads) {
    nthreads = ann_sq_omp::NormalizeThreads(nthreads);
    rerank_p = ann_sq_omp::NormalizeRerankP(rerank_p, base_n, k);
    std::vector<uint8_t> query_code(d);
    sq_index.encode_query(query, query_code.data());

    std::vector<ann_sq_omp::CoarseHeap> heaps(static_cast<size_t>(nthreads));

#pragma omp parallel num_threads(nthreads)
    {
        const int tid = omp_get_thread_num();
#pragma omp for schedule(static)
        for (long long i = 0; i < static_cast<long long>(base_n); ++i) {
            const size_t idx = static_cast<size_t>(i);
            const uint32_t dist = ann_sq_omp::CoarseDistance(
                sq_index.codes.data() + idx * d, query_code.data(), d);
            ann_sq_omp::PushCoarse(heaps[static_cast<size_t>(tid)], dist,
                                   static_cast<uint32_t>(idx), rerank_p);
        }
    }

    ann_sq_omp::CoarseHeap coarse = ann_sq_omp::MergeCoarse(heaps, rerank_p);
    return ann_sq_omp::Rerank(base, query, d, k, coarse);
}
