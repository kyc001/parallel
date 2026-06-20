#pragma once

#include <iomanip>
#include <iostream>

#include "common.h"
#include "params.h"
#include "search.h"

namespace ann_mpi {

static inline void PrintRunHeader(const Params& params,
                                  const SearchSettings& settings,
                                  int mpi_procs,
                                  bool no_mpi,
                                  size_t query_n) {
    if (params.use_hnsw_on_hnsw) {
        std::cout << "hnsw_on_hnsw_" << (no_mpi ? "no_mpi_omp" : "mpi_omp")
                  << ", mpi_procs=" << mpi_procs
                  << ", nthreads=" << params.nthreads
                  << ", nblocks=" << settings.local_nlist
                  << ", nprobe=" << params.nprobe
                  << ", hnsw_m=" << settings.hnsw_m
                  << ", ef=" << settings.hnsw_on_hnsw_ef
                  << ", query_n=" << query_n;
    } else if (params.use_nested_hnsw) {
        std::cout << "ivf_hnsw_nested_"
                  << (no_mpi ? "no_mpi_omp" : "mpi_omp")
                  << ", mpi_procs=" << mpi_procs
                  << ", nthreads=" << params.nthreads
                  << ", nlist=" << params.nlist
                  << ", local_nlist=" << settings.local_nlist
                  << ", nprobe=" << params.nprobe
                  << ", hnsw_m=" << settings.hnsw_m
                  << ", ef=" << settings.nested_ef
                  << ", query_n=" << query_n;
    } else if (params.use_hnsw) {
        std::cout << "block_hnsw_"
                  << (no_mpi ? "no_mpi_omp_multi_entry"
                             : "mpi_omp_multi_entry")
                  << ", mpi_procs=" << mpi_procs
                  << ", nthreads=" << params.nthreads
                  << ", hnsw_m=" << settings.hnsw_m
                  << ", ef=" << settings.hnsw_ef
                  << ", query_n=" << query_n;
    } else {
        std::cout << "ivfpq_" << ModeName(params.mode)
                  << (no_mpi ? "_no_mpi_omp_inter" : "_mpi_omp_inter")
                  << ", mpi_procs=" << mpi_procs
                  << ", nthreads=" << params.nthreads
                  << ", nlist=" << params.nlist
                  << ", local_nlist=" << settings.local_nlist
                  << ", nprobe=" << params.nprobe
                  << ", p=" << params.rerank_p
                  << ", query_n=" << query_n
                  << ", mode=" << ModeName(params.mode);
    }
    std::cout << "\n";
}

static inline void PrintMetrics(double recall, double latency_us,
                                double max_local_us,
                                double comm_merge_us) {
    std::cout << "average recall: " << recall << "\n";
    std::cout << "average latency (us): " << latency_us << "\n";
    std::cout << "max local search latency (us): " << max_local_us << "\n";
    std::cout << "comm+merge latency (us): " << comm_merge_us << "\n";
}

static inline void PrintPerRankLatency(const std::vector<double>& search_us,
                                       size_t query_n) {
    std::cout << "per-rank search latency (us):";
    for (size_t r = 0; r < search_us.size(); ++r) {
        std::cout << " rank" << r << "="
                  << search_us[r] / static_cast<double>(query_n);
    }
    std::cout << "\n";
}

}  // namespace ann_mpi
