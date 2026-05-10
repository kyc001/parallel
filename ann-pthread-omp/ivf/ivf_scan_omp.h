#pragma once

#include <omp.h>
#include <vector>

#include "ivf/ivf_scan_simd.h"

namespace ann_ivf_omp {

static inline int NormalizeThreads(int nthreads) {
    return nthreads < 1 ? 1 : nthreads;
}

}  // namespace ann_ivf_omp

static inline void ivf_search_inter_omp(
    const ann_ivf::IVFIndex& index, const float* queries, size_t query_n,
    size_t k, size_t nprobe, int nthreads,
    std::vector<ann_ivf::SearchHeap>& results) {
    nthreads = ann_ivf_omp::NormalizeThreads(nthreads);
    results.clear();
    results.resize(query_n);

#pragma omp parallel for num_threads(nthreads) schedule(static)
    for (long long i = 0; i < static_cast<long long>(query_n); ++i) {
        const size_t idx = static_cast<size_t>(i);
        results[idx] = ivf_search(index, queries + idx * index.d, k, nprobe);
    }
}

static inline ann_ivf::SearchHeap ivf_search_intra_omp(
    const ann_ivf::IVFIndex& index, const float* query, size_t k,
    size_t nprobe, int nthreads) {
    nthreads = ann_ivf_omp::NormalizeThreads(nthreads);
    const std::vector<uint32_t> probes = index.select_probes(query, nprobe);
    std::vector<ann_ivf::SearchHeap> heaps(static_cast<size_t>(nthreads));

#pragma omp parallel num_threads(nthreads)
    {
        const int tid = omp_get_thread_num();
#pragma omp for schedule(dynamic)
        for (long long i = 0; i < static_cast<long long>(probes.size()); ++i) {
            ann_ivf::ScanList(index, query, probes[static_cast<size_t>(i)],
                              k, heaps[static_cast<size_t>(tid)]);
        }
    }

    return ann_ivf::MergeHeaps(heaps, k);
}
