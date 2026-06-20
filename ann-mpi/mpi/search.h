#pragma once

#include <algorithm>

#include "common.h"
#include "params.h"
#include "../hnsw/hnsw_ivf_nested.h"
#include "../hnsw/hnsw_on_hnsw.h"
#include "../hnsw/hnsw_search_omp.h"
#include "../ivf/ivf_pq_omp.h"

namespace ann_mpi {

struct SearchSettings {
    size_t local_nlist;
    size_t hnsw_m;
    size_t hnsw_ef;
    size_t nested_ef;
    size_t hnsw_on_hnsw_ef;
};

struct LocalIndexes {
    ann_ivfpq::IVFPQIndex ivfpq;
    ann_hnsw::HnswHolder hnsw;
    ann_hnsw_nested::NestedIndex nested;
    ann_hnsw_on_hnsw::HierarchicalIndex hnsw_on_hnsw;
};

static inline SearchSettings MakeSearchSettings(const Params& params,
                                                size_t local_n) {
    SearchSettings settings;
    settings.local_nlist =
        std::max<size_t>(1, std::min(params.nlist, local_n));
    settings.hnsw_m = std::max<size_t>(4, params.nlist);
    settings.hnsw_ef = std::max(params.nprobe, kTopK);
    settings.nested_ef = std::max(params.rerank_p, kTopK);
    settings.hnsw_on_hnsw_ef = std::max(params.rerank_p, kTopK);
    return settings;
}

static inline void BuildLocalIndexes(LocalIndexes& indexes,
                                     const float* local_base,
                                     size_t local_n, size_t d,
                                     const Params& params,
                                     const SearchSettings& settings) {
    if (params.use_hnsw_on_hnsw) {
        indexes.hnsw_on_hnsw.build(local_base, local_n, d,
                                   settings.local_nlist, settings.hnsw_m,
                                   120, settings.hnsw_on_hnsw_ef);
    } else if (params.use_nested_hnsw) {
        indexes.nested.build(local_base, local_n, d, settings.local_nlist,
                             settings.hnsw_m, 120, 8);
    } else if (params.use_hnsw) {
        indexes.hnsw = ann_hnsw::BuildIndex(local_base, local_n, d,
                                            settings.hnsw_m, 120,
                                            settings.hnsw_ef);
    } else {
        indexes.ivfpq.build(local_base, local_n, d, settings.local_nlist,
                            params.mode, 8, 8);
    }
}

static inline void SearchLocalIndexes(const LocalIndexes& indexes,
                                      const float* queries,
                                      size_t d, size_t query_n,
                                      const Params& params,
                                      const SearchSettings& settings,
                                      std::vector<SearchHeap>& results) {
    if (params.use_hnsw_on_hnsw) {
        results.assign(query_n, SearchHeap());
        for (size_t i = 0; i < query_n; ++i) {
            results[i] = ann_hnsw_on_hnsw::hnsw_on_hnsw_search_omp(
                indexes.hnsw_on_hnsw, queries + i * d, kTopK,
                settings.hnsw_on_hnsw_ef, params.nprobe, params.nthreads);
        }
    } else if (params.use_nested_hnsw) {
        results.assign(query_n, SearchHeap());
        for (size_t i = 0; i < query_n; ++i) {
            results[i] = hnsw_ivf_nested_search_omp(
                indexes.nested, queries + i * d, kTopK, settings.nested_ef,
                params.nprobe, params.nthreads);
        }
    } else if (params.use_hnsw) {
        results.assign(query_n, SearchHeap());
        for (size_t i = 0; i < query_n; ++i) {
            results[i] = hnsw_search_multi_entry_omp(
                *indexes.hnsw.index, queries + i * d, kTopK,
                settings.hnsw_ef, params.nthreads);
        }
    } else {
        ivf_pq_search_inter_omp(indexes.ivfpq, queries, query_n, kTopK,
                                params.nprobe, params.rerank_p,
                                params.nthreads, results);
    }
}

}  // namespace ann_mpi
