#pragma once

#include <algorithm>
#include <omp.h>
#include <pthread.h>
#include <vector>

#include "hnsw_graph_utils.h"

namespace ann_hnsw_layer0 {

struct ScanArg {
    const ann_hnsw::HnswIndex* index;
    const float* query;
    size_t k;
    size_t start;
    size_t end;
    ann_hnsw::SearchHeap heap;
};

static inline void* ScanWorker(void* arg) {
    ScanArg* a = static_cast<ScanArg*>(arg);
    for (size_t i = a->start; i < a->end; ++i) {
        const float dist = ann_hnsw::Distance(*a->index, a->query, static_cast<uint32_t>(i));
        ann_hnsw::PushTopK(a->heap, dist, static_cast<uint32_t>(i), a->k);
    }
    return nullptr;
}

}  // namespace ann_hnsw_layer0

static inline ann_hnsw::SearchHeap hnsw_layer0_search_static(
    const ann_hnsw::HnswIndex& index, const float* query, size_t k,
    size_t, int nthreads) {
    if (nthreads < 1) {
        nthreads = 1;
    }
    const size_t count = static_cast<size_t>(index.cur_element_count);
    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    std::vector<ann_hnsw_layer0::ScanArg> args(static_cast<size_t>(nthreads));
    const size_t chunk = (count + static_cast<size_t>(nthreads) - 1) /
                         static_cast<size_t>(nthreads);
    for (int t = 0; t < nthreads; ++t) {
        const size_t start = static_cast<size_t>(t) * chunk;
        const size_t end = std::min(start + chunk, count);
        args[static_cast<size_t>(t)] = {&index, query, k, start, end,
                                        ann_hnsw::SearchHeap()};
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &ann_hnsw_layer0::ScanWorker, &args[static_cast<size_t>(t)]);
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(threads[static_cast<size_t>(t)], nullptr);
    }
    std::vector<ann_hnsw::SearchHeap> heaps;
    for (int t = 0; t < nthreads; ++t) {
        heaps.push_back(std::move(args[static_cast<size_t>(t)].heap));
    }
    return ann_hnsw::MergeHeaps(heaps, k);
}

static inline ann_hnsw::SearchHeap hnsw_layer0_search_omp(
    const ann_hnsw::HnswIndex& index, const float* query, size_t k,
    size_t, int nthreads) {
    if (nthreads < 1) {
        nthreads = 1;
    }
    const size_t count = static_cast<size_t>(index.cur_element_count);
    std::vector<ann_hnsw::SearchHeap> heaps(static_cast<size_t>(nthreads));

#pragma omp parallel num_threads(nthreads)
    {
        const int tid = omp_get_thread_num();
#pragma omp for schedule(static)
        for (long long i = 0; i < static_cast<long long>(count); ++i) {
            const uint32_t id = static_cast<uint32_t>(i);
            const float dist = ann_hnsw::Distance(index, query, id);
            ann_hnsw::PushTopK(heaps[static_cast<size_t>(tid)], dist, id, k);
        }
    }
    return ann_hnsw::MergeHeaps(heaps, k);
}
