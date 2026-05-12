#pragma once

#include <omp.h>
#include <vector>

#include "ivf_pq_simd.h"

namespace ann_ivfpq_omp {

static inline int NormalizeThreads(int nthreads) {
    return nthreads < 1 ? 1 : nthreads;
}

static inline void BuildGlobalLutIfNeeded(const ann_ivfpq::IVFPQIndex& index,
                                          const float* query,
                                          std::vector<float>& lut,
                                          const float*& lut_ptr) {
    lut_ptr = nullptr;
    if (index.mode == ann_ivfpq::BuildMode::GlobalPQFirst) {
        lut.resize(static_cast<size_t>(index.global_pq.M) * 256);
        index.global_pq.build_lut(query, lut.data());
        lut_ptr = lut.data();
    }
}

}  // namespace ann_ivfpq_omp

static inline void ivf_pq_search_inter_omp(
    const ann_ivfpq::IVFPQIndex& index, const float* queries, size_t query_n,
    size_t k, size_t nprobe, size_t rerank_p, int nthreads,
    std::vector<ann_ivf::SearchHeap>& results) {
    nthreads = ann_ivfpq_omp::NormalizeThreads(nthreads);
    rerank_p = ann_ivfpq::NormalizeRerankP(rerank_p, index.n, k);
    results.clear();
    results.resize(query_n);

#pragma omp parallel for num_threads(nthreads) schedule(static)
    for (long long i = 0; i < static_cast<long long>(query_n); ++i) {
        const size_t idx = static_cast<size_t>(i);
        results[idx] = ivf_pq_search(index, queries + idx * index.d,
                                     k, nprobe, rerank_p);
    }
}

static inline ann_ivf::SearchHeap ivf_pq_search_intra_omp(
    const ann_ivfpq::IVFPQIndex& index, const float* query, size_t k,
    size_t nprobe, size_t rerank_p, int nthreads) {
    nthreads = ann_ivfpq_omp::NormalizeThreads(nthreads);
    rerank_p = ann_ivfpq::NormalizeRerankP(rerank_p, index.n, k);
    const std::vector<uint32_t> probes = index.ivf.select_probes(query, nprobe);

    std::vector<float> lut;
    const float* lut_ptr = nullptr;
    ann_ivfpq_omp::BuildGlobalLutIfNeeded(index, query, lut, lut_ptr);

    std::vector<ann_ivf::SearchHeap> heaps(static_cast<size_t>(nthreads));

#pragma omp parallel num_threads(nthreads)
    {
        const int tid = omp_get_thread_num();
#pragma omp for schedule(dynamic)
        for (long long i = 0; i < static_cast<long long>(probes.size()); ++i) {
            ann_ivfpq::ScanList(index, query, lut_ptr,
                                probes[static_cast<size_t>(i)], rerank_p,
                                heaps[static_cast<size_t>(tid)]);
        }
    }

    ann_ivf::SearchHeap coarse = ann_ivf::MergeHeaps(heaps, rerank_p);
    return ann_ivfpq::Rerank(index, query, k, coarse);
}
