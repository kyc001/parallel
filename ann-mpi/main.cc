// MPI + OpenMP ANN representative submission entry.
//
// This keeps the course-style main.cc workflow visible: load data, distribute
// base vectors, build a local index, search queries, merge candidates, and
// print Recall@10 plus latency.  Running with no arguments selects the measured
// representative path: Block-HNSW, m=16, ef=50, query_n=2000.

#include <algorithm>
#include <chrono>
#include <cstdlib>
#include <cstring>
#include <exception>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <vector>

#include "mpi_ann_runner.h"

int main(int argc, char** argv) {
#ifndef ANN_NO_MPI
    const bool request_thread_multiple =
        (std::getenv("USE_MPI_THREAD_MULTIPLE") != NULL);
    ann_mpi::MpiSession mpi(&argc, &argv, request_thread_multiple);
    const int rank = mpi.rank();
    const int world_size = mpi.world_size();

    const ann_mpi::Params params = ann_mpi::ParseParams(argc, argv);
    const ann_mpi::RuntimeOptions runtime = ann_mpi::ReadRuntimeOptions();

    if (rank == 0) {
        std::cout << "comm_mode="
                  << (runtime.use_nonblocking ? "nonblocking" : "blocking")
                  << "\n";
        std::cout << "mpi_thread_requested="
                  << ann_mpi::MpiThreadLevelName(
                         mpi.requested_thread_level())
                  << ", mpi_thread_provided="
                  << ann_mpi::MpiThreadLevelName(
                         mpi.provided_thread_level())
                  << "\n";
        std::cout << "base_partition="
                  << (runtime.use_shuffled_base ? "shuffled" : "contiguous");
        if (runtime.use_shuffled_base) {
            std::cout << ", shuffle_seed=" << runtime.shuffle_seed;
        }
        std::cout << "\n";
    }

    try {
        // ---------------- Data loading on rank 0 ----------------
        ann_mpi::DataBundle root_data;
        std::vector<uint64_t> root_global_ids;
        if (rank == 0) {
            root_data = ann_mpi::LoadAllData(params.query_limit);
            ann_mpi::PrepareGlobalIds(root_data, runtime, root_global_ids);
        }

        ann_mpi::ProblemShape shape = ann_mpi::ShapeFromData(root_data);
        ann_mpi::BroadcastShape(shape);
        if (shape.base_d != shape.query_d) {
            throw std::runtime_error("broadcast base/query dimension mismatch");
        }

        // ---------------- Query broadcast buffer ----------------
        std::vector<float> queries(shape.query_n * shape.query_d);
        if (rank == 0) {
            std::memcpy(queries.data(), root_data.queries.get(),
                        queries.size() * sizeof(float));
        }

        // ---------------- Base shard distribution ----------------
        std::vector<float> local_base;
        std::vector<uint64_t> local_global_ids;
        ann_mpi::ScatterBaseShard(root_data, root_global_ids, shape, rank,
                                  world_size, local_base, local_global_ids);

        const size_t local_n = local_global_ids.size();
        const ann_mpi::SearchSettings settings =
            ann_mpi::MakeSearchSettings(params, local_n);

        // ---------------- Local index build ----------------
        ann_mpi::LocalIndexes indexes;
        ann_mpi::BuildLocalIndexes(indexes, local_base.data(), local_n,
                                   shape.base_d, params, settings);

        // ---------------- Online search timing ----------------
        MPI_Barrier(MPI_COMM_WORLD);
        const double phase_begin = MPI_Wtime();
        ann_mpi::BroadcastQueries(queries.data(), queries.size(),
                                  runtime.use_nonblocking);

        std::vector<ann_mpi::SearchHeap> local_results;
        const double search_begin = MPI_Wtime();
        ann_mpi::SearchLocalIndexes(indexes, queries.data(), shape.base_d,
                                    shape.query_n, params, settings,
                                    local_results);
        const double search_us = (MPI_Wtime() - search_begin) * 1000000.0;

        // ---------------- Candidate packing and gather ----------------
        std::vector<float> local_distances;
        std::vector<uint64_t> local_ids;
        ann_mpi::PackCandidates(local_results, shape.query_n, ann_mpi::kTopK,
                                local_global_ids, local_distances, local_ids);

        std::vector<float> all_distances;
        std::vector<uint64_t> all_ids;
        if (rank == 0) {
            all_distances.resize(
                static_cast<size_t>(world_size) * local_distances.size());
            all_ids.resize(static_cast<size_t>(world_size) * local_ids.size());
        }

        ann_mpi::GatherFloat(
            local_distances.data(),
            ann_mpi::CheckedMpiCount(local_distances.size(),
                                     "candidate distance gather count"),
            rank == 0 ? all_distances.data() : NULL,
            ann_mpi::CheckedMpiCount(local_distances.size(),
                                     "candidate distance recv count"),
            runtime.use_nonblocking);
        ann_mpi::GatherUint64(
            local_ids.data(),
            ann_mpi::CheckedMpiCount(local_ids.size(),
                                     "candidate id gather count"),
            rank == 0 ? all_ids.data() : NULL,
            ann_mpi::CheckedMpiCount(local_ids.size(),
                                     "candidate id recv count"),
            runtime.use_nonblocking);

        double max_search_us = 0.0;
        MPI_Reduce(&search_us, &max_search_us, 1, MPI_DOUBLE, MPI_MAX, 0,
                   MPI_COMM_WORLD);

        std::vector<double> all_search_us;
        if (rank == 0) {
            all_search_us.resize(static_cast<size_t>(world_size));
        }
        double rank_search_us = search_us;
        ann_mpi::GatherDouble(&rank_search_us, 1,
                              rank == 0 ? all_search_us.data() : NULL, 1,
                              runtime.use_nonblocking);

        // ---------------- Rank 0 merge, recall, and output ----------------
        if (rank == 0) {
            std::vector<ann_mpi::SearchHeap> merged_results;
            ann_mpi::MergeGatheredCandidates(all_distances, all_ids,
                                             world_size, shape.query_n,
                                             ann_mpi::kTopK, merged_results);
            const double total_us =
                (MPI_Wtime() - phase_begin) * 1000000.0;
            const double recall = ann_mpi::RecallAtK(
                merged_results, root_data.gt.get(), shape.query_n,
                shape.gt_dim, ann_mpi::kTopK);
            const double comm_merge_us =
                std::max(0.0, total_us - max_search_us);

            std::cout << std::fixed << std::setprecision(5);
            ann_mpi::PrintRunHeader(params, settings, world_size, false,
                                    shape.query_n);
            ann_mpi::PrintMetrics(
                recall, total_us / static_cast<double>(shape.query_n),
                max_search_us / static_cast<double>(shape.query_n),
                comm_merge_us / static_cast<double>(shape.query_n));
            ann_mpi::PrintPerRankLatency(all_search_us, shape.query_n);
        }
    } catch (const std::exception& ex) {
        std::cerr << "[rank " << rank << "] " << ex.what() << "\n";
        mpi.Abort(1);
        return 1;
    }

    return 0;
#else
    try {
        const ann_mpi::Params params = ann_mpi::ParseParams(argc, argv);

        // ---------------- Data loading ----------------
        ann_mpi::DataBundle data = ann_mpi::LoadAllData(params.query_limit);

        // ---------------- Local index build ----------------
        const ann_mpi::SearchSettings settings =
            ann_mpi::MakeSearchSettings(params, data.base_n);
        ann_mpi::LocalIndexes indexes;
        ann_mpi::BuildLocalIndexes(indexes, data.base.get(), data.base_n,
                                   data.base_d, params, settings);

        // ---------------- Query search and scoring ----------------
        std::vector<ann_mpi::SearchHeap> results;
        const auto begin = std::chrono::high_resolution_clock::now();
        ann_mpi::SearchLocalIndexes(indexes, data.queries.get(), data.base_d,
                                    data.query_n, params, settings, results);
        const auto end = std::chrono::high_resolution_clock::now();
        const double total_us =
            std::chrono::duration<double, std::micro>(end - begin).count();
        const double recall = ann_mpi::RecallAtK(
            results, data.gt.get(), data.query_n, data.gt_dim,
            ann_mpi::kTopK);

        std::cout << std::fixed << std::setprecision(5);
        ann_mpi::PrintRunHeader(params, settings, 1, true, data.query_n);
        ann_mpi::PrintMetrics(
            recall, total_us / static_cast<double>(data.query_n),
            total_us / static_cast<double>(data.query_n), 0.0);
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << ex.what() << "\n";
        return 1;
    }
#endif
}
