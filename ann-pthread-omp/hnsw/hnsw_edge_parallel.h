#pragma once

#include <algorithm>
#include <omp.h>
#include <pthread.h>
#include <vector>

#include "hnsw/hnsw_graph_utils.h"

namespace ann_hnsw_edge {

static inline std::vector<uint32_t> SeedNodes(const ann_hnsw::HnswIndex& index,
                                              const float* query, size_t ef) {
    ann_hnsw::SearchHeap seed =
        ann_hnsw::ConvertResult(index.searchKnn(query, std::max<size_t>(ef / 4, 1)), ef);
    std::vector<uint32_t> nodes;
    while (!seed.empty()) {
        nodes.push_back(seed.top().second);
        seed.pop();
    }
    if (nodes.empty() && index.cur_element_count > 0) {
        nodes.push_back(static_cast<uint32_t>(index.enterpoint_node_));
    }
    return nodes;
}

static inline ann_hnsw::SearchHeap ExpandEdgesRange(const ann_hnsw::HnswIndex& index,
                                                    const float* query,
                                                    const std::vector<uint32_t>& seeds,
                                                    size_t begin, size_t end,
                                                    size_t k) {
    ann_hnsw::SearchHeap heap;
    for (size_t i = begin; i < end; ++i) {
        const uint32_t node = seeds[i];
        ann_hnsw::PushTopK(heap, ann_hnsw::Distance(index, query, node), node, k);
        const std::vector<uint32_t> neighbors = ann_hnsw::GetNeighbors(index, node, 0);
        for (size_t j = 0; j < neighbors.size(); ++j) {
            const uint32_t nb = neighbors[j];
            ann_hnsw::PushTopK(heap, ann_hnsw::Distance(index, query, nb), nb, k);
        }
    }
    return heap;
}

struct EdgeArg {
    const ann_hnsw::HnswIndex* index;
    const float* query;
    const std::vector<uint32_t>* seeds;
    size_t k;
    size_t start;
    size_t end;
    ann_hnsw::SearchHeap heap;
};

static inline void* EdgeWorker(void* arg) {
    EdgeArg* a = static_cast<EdgeArg*>(arg);
    a->heap = ExpandEdgesRange(*a->index, a->query, *a->seeds,
                               a->start, a->end, a->k);
    return nullptr;
}

}  // namespace ann_hnsw_edge

static inline ann_hnsw::SearchHeap hnsw_edge_search_static(
    const ann_hnsw::HnswIndex& index, const float* query, size_t k,
    size_t ef, int nthreads) {
    if (nthreads < 1) {
        nthreads = 1;
    }
    const std::vector<uint32_t> seeds = ann_hnsw_edge::SeedNodes(index, query, ef);
    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    std::vector<ann_hnsw_edge::EdgeArg> args(static_cast<size_t>(nthreads));
    const size_t chunk = (seeds.size() + static_cast<size_t>(nthreads) - 1) /
                         static_cast<size_t>(nthreads);
    for (int t = 0; t < nthreads; ++t) {
        const size_t start = static_cast<size_t>(t) * chunk;
        const size_t end = std::min(start + chunk, seeds.size());
        args[static_cast<size_t>(t)] = {&index, query, &seeds, k, start, end,
                                        ann_hnsw::SearchHeap()};
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &ann_hnsw_edge::EdgeWorker, &args[static_cast<size_t>(t)]);
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

static inline ann_hnsw::SearchHeap hnsw_edge_search_omp(
    const ann_hnsw::HnswIndex& index, const float* query, size_t k,
    size_t ef, int nthreads) {
    if (nthreads < 1) {
        nthreads = 1;
    }
    const std::vector<uint32_t> seeds = ann_hnsw_edge::SeedNodes(index, query, ef);
    std::vector<ann_hnsw::SearchHeap> heaps(static_cast<size_t>(nthreads));

#pragma omp parallel num_threads(nthreads)
    {
        const int tid = omp_get_thread_num();
#pragma omp for schedule(static)
        for (long long i = 0; i < static_cast<long long>(seeds.size()); ++i) {
            ann_hnsw::SearchHeap local =
                ann_hnsw_edge::ExpandEdgesRange(index, query, seeds,
                                                static_cast<size_t>(i),
                                                static_cast<size_t>(i + 1), k);
            std::vector<ann_hnsw::SearchHeap> pair_heaps(2);
            pair_heaps[0] = std::move(heaps[static_cast<size_t>(tid)]);
            pair_heaps[1] = std::move(local);
            heaps[static_cast<size_t>(tid)] = ann_hnsw::MergeHeaps(pair_heaps, k);
        }
    }
    return ann_hnsw::MergeHeaps(heaps, k);
}
