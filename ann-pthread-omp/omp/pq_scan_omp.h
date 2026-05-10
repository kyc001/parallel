#pragma once

#include <algorithm>
#include <cstdint>
#include <cstddef>
#include <omp.h>
#include <queue>
#include <utility>
#include <vector>

#if defined(__aarch64__) || defined(__ARM_NEON)
#include "simd/pq_scan_simd.h"
#define ANN_PQ_OMP_HAS_NEON 1
#elif defined(__AVX2__)
#include "simd/pq_scan_avx2.h"
#define ANN_PQ_OMP_HAS_AVX2 1
#else
#error "PQ SIMD requires ARM NEON or x86 AVX2. Compile x86 builds with -mavx2 -mfma."
#endif

namespace ann_pq_omp {

using SearchHeap = std::priority_queue<std::pair<float, uint32_t>>;

static inline int NormalizeThreads(int nthreads) {
    return nthreads < 1 ? 1 : nthreads;
}

static inline size_t NormalizeRerankP(size_t rerank_p, size_t base_n, size_t k) {
    if (rerank_p < k) {
        rerank_p = k;
    }
    return std::min(rerank_p, base_n);
}

static inline float ExactDistance(const float* base, const float* query, size_t d) {
#if defined(ANN_PQ_OMP_HAS_NEON)
    return ip_distance_simd(base, query, static_cast<int>(d));
#else
    return ann_avx2::ip_distance_avx2(base, query, static_cast<int>(d));
#endif
}

static inline void PushTopK(SearchHeap& heap, float dist, uint32_t id, size_t k) {
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

static inline SearchHeap MergeHeaps(std::vector<SearchHeap>& heaps, size_t keep) {
    SearchHeap result;
    for (size_t i = 0; i < heaps.size(); ++i) {
        SearchHeap& heap = heaps[i];
        while (!heap.empty()) {
            const std::pair<float, uint32_t> item = heap.top();
            heap.pop();
            PushTopK(result, item.first, item.second, keep);
        }
    }
    return result;
}

static inline SearchHeap RerankCandidates(float* base, float* query, size_t d,
                                          size_t k, SearchHeap& coarse) {
    SearchHeap result;
    while (!coarse.empty()) {
        const uint32_t id = coarse.top().second;
        coarse.pop();
        const float dist = ExactDistance(base + static_cast<size_t>(id) * d, query, d);
        PushTopK(result, dist, id, k);
    }
    return result;
}

}  // namespace ann_pq_omp

static inline void pq_search_inter_omp(
    float* base, float* queries, size_t base_n, size_t query_n,
    size_t d, size_t k, const PQIndex& pq_index, size_t rerank_p, int nthreads,
    std::vector<ann_pq_omp::SearchHeap>& results) {
    nthreads = ann_pq_omp::NormalizeThreads(nthreads);
    rerank_p = ann_pq_omp::NormalizeRerankP(rerank_p, base_n, k);
    results.clear();
    results.resize(query_n);

#pragma omp parallel for num_threads(nthreads) schedule(static)
    for (long long i = 0; i < static_cast<long long>(query_n); ++i) {
        const size_t idx = static_cast<size_t>(i);
        results[idx] =
            pq_search(base, queries + idx * d, base_n, d, k, pq_index, rerank_p);
    }
}

static inline ann_pq_omp::SearchHeap pq_search_intra_omp(
    float* base, float* query, size_t base_n, size_t d, size_t k,
    const PQIndex& pq_index, size_t rerank_p, int nthreads) {
    nthreads = ann_pq_omp::NormalizeThreads(nthreads);
    rerank_p = ann_pq_omp::NormalizeRerankP(rerank_p, base_n, k);

    std::vector<float> lut(static_cast<size_t>(pq_index.M) * 256);
    pq_index.build_lut(query, lut.data());

    std::vector<ann_pq_omp::SearchHeap> heaps(static_cast<size_t>(nthreads));

#pragma omp parallel num_threads(nthreads)
    {
        const int tid = omp_get_thread_num();
#pragma omp for schedule(static)
        for (long long i = 0; i < static_cast<long long>(base_n); ++i) {
            const size_t idx = static_cast<size_t>(i);
            const float dist = adc_distance(
                lut.data(), pq_index.codes.data() + idx * pq_index.M, pq_index.M);
            ann_pq_omp::PushTopK(heaps[static_cast<size_t>(tid)], dist,
                                 static_cast<uint32_t>(idx), rerank_p);
        }
    }

    ann_pq_omp::SearchHeap coarse = ann_pq_omp::MergeHeaps(heaps, rerank_p);
    return ann_pq_omp::RerankCandidates(base, query, d, k, coarse);
}
