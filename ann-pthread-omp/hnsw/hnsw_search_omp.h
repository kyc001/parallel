#pragma once

#include <omp.h>
#include <vector>

#include "hnsw/hnsw_graph_utils.h"

static inline ann_hnsw::SearchHeap hnsw_search_multi_entry_omp(
    const ann_hnsw::HnswIndex& index, const float* query, size_t k,
    size_t ef, int nthreads) {
    if (nthreads < 1) {
        nthreads = 1;
    }
    const std::vector<uint32_t> entries = ann_hnsw::PickEntries(index, nthreads);
    std::vector<ann_hnsw::SearchHeap> heaps(entries.size());

#pragma omp parallel for num_threads(nthreads) schedule(static)
    for (long long i = 0; i < static_cast<long long>(entries.size()); ++i) {
        heaps[static_cast<size_t>(i)] = ann_hnsw::SearchLayer0FromEntry(
            index, query, entries[static_cast<size_t>(i)], k, ef);
    }
    return ann_hnsw::MergeHeaps(heaps, k);
}
