#pragma once

#include <algorithm>
#include <memory>
#include <omp.h>
#include <vector>

#include "hnsw/hnsw_graph_utils.h"
#include "ivf/ivf_index.h"

namespace ann_hnsw_nested {

struct NestedIndex {
    ann_ivf::IVFIndex ivf;
    std::vector<std::unique_ptr<hnswlib::InnerProductSpace>> spaces;
    std::vector<std::unique_ptr<ann_hnsw::HnswIndex>> indexes;
    size_t d = 0;

    void build(const float* base, size_t n, size_t d_, size_t nlist,
               size_t M = 12, size_t ef_construction = 80, int ivf_iter = 6) {
        d = d_;
        ivf.build(base, n, d, nlist, ivf_iter);
        spaces.resize(ivf.nlist);
        indexes.resize(ivf.nlist);
        for (size_t c = 0; c < ivf.nlist; ++c) {
            const size_t begin = ivf.list_offsets[c];
            const size_t count = ivf.list_offsets[c + 1] - begin;
            if (count == 0) {
                continue;
            }
            spaces[c].reset(new hnswlib::InnerProductSpace(d));
            indexes[c].reset(new ann_hnsw::HnswIndex(
                spaces[c].get(), count, M, std::max(M, ef_construction)));
            for (size_t pos = begin; pos < ivf.list_offsets[c + 1]; ++pos) {
                indexes[c]->addPoint(ivf.reordered_base.data() + pos * d,
                                     static_cast<hnswlib::labeltype>(ivf.reordered_ids[pos]));
            }
        }
    }
};

static inline ann_hnsw::SearchHeap SearchOneList(const NestedIndex& nested,
                                                 uint32_t list_id,
                                                 const float* query,
                                                 size_t k, size_t ef) {
    if (list_id >= nested.indexes.size() || !nested.indexes[list_id]) {
        return ann_hnsw::SearchHeap();
    }
    nested.indexes[list_id]->setEf(ef);
    return ann_hnsw::ConvertResult(nested.indexes[list_id]->searchKnn(query, k), k);
}

}  // namespace ann_hnsw_nested

static inline ann_hnsw::SearchHeap hnsw_ivf_nested_search_static(
    const ann_hnsw_nested::NestedIndex& nested, const float* query,
    size_t k, size_t ef, size_t nprobe, int) {
    const std::vector<uint32_t> probes = nested.ivf.select_probes(query, nprobe);
    std::vector<ann_hnsw::SearchHeap> heaps;
    for (size_t i = 0; i < probes.size(); ++i) {
        heaps.push_back(ann_hnsw_nested::SearchOneList(nested, probes[i], query, k, ef));
    }
    return ann_hnsw::MergeHeaps(heaps, k);
}

static inline ann_hnsw::SearchHeap hnsw_ivf_nested_search_omp(
    const ann_hnsw_nested::NestedIndex& nested, const float* query,
    size_t k, size_t ef, size_t nprobe, int nthreads) {
    if (nthreads < 1) {
        nthreads = 1;
    }
    const std::vector<uint32_t> probes = nested.ivf.select_probes(query, nprobe);
    std::vector<ann_hnsw::SearchHeap> heaps(probes.size());

#pragma omp parallel for num_threads(nthreads) schedule(dynamic)
    for (long long i = 0; i < static_cast<long long>(probes.size()); ++i) {
        heaps[static_cast<size_t>(i)] =
            ann_hnsw_nested::SearchOneList(nested, probes[static_cast<size_t>(i)],
                                           query, k, ef);
    }
    return ann_hnsw::MergeHeaps(heaps, k);
}
