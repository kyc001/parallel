// MPI + OpenMP ANN entry for the MPI lab.
//
// Search plan:
//   1. Rank 0 loads DEEP100K base/query/ground-truth files.
//   2. Base vectors are partitioned contiguously and scattered to MPI ranks.
//   3. Query vectors are broadcast to all ranks for the online phase.
//   4. Each rank builds a local index for its base shard and searches all
//      queries with OpenMP parallelism. Supported modes are IVF-PQ,
//      block-HNSW, nested IVF+HNSW, and HNSW-on-HNSW.
//   5. Rank 0 gathers per-rank local top-k candidates and merges them into the
//      global top-k used for Recall@10.
//
// Server build:
//   mpic++ main.cc -o main -O2 -std=c++11 -I. -fopenmp -lpthread
//   Add -mavx2 -mfma on x86. The Makefile handles this automatically.
//
// Local fallback without MPI headers:
//   g++ main.cc -o build/main_no_mpi -O2 -std=c++11 -I. -fopenmp -lpthread \
//       -mavx2 -mfma -DANN_NO_MPI

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iomanip>
#include <iostream>
#include <limits>
#include <memory>
#include <set>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#ifndef ANN_NO_MPI
#include "mpi.h"
#endif

#include "ivf/ivf_pq_omp.h"
#include "hnsw/hnsw_ivf_nested.h"
#include "hnsw/hnsw_on_hnsw.h"
#include "hnsw/hnsw_search_omp.h"
#include "simd/ann_bench_common.h"

namespace {

using SearchHeap = ann_ivf::SearchHeap;

const size_t kTopK = 10;
const uint64_t kInvalidId = std::numeric_limits<uint64_t>::max();

struct Params {
    int nthreads;
    size_t nlist;
    size_t nprobe;
    size_t rerank_p;
    size_t query_limit;
    ann_ivfpq::BuildMode mode;
    bool use_hnsw;
    bool use_nested_hnsw;
    bool use_hnsw_on_hnsw;
};

struct DataBundle {
    std::unique_ptr<float[]> queries;
    std::unique_ptr<int[]> gt;
    std::unique_ptr<float[]> base;
    size_t query_n;
    size_t query_d;
    size_t gt_n;
    size_t gt_dim;
    size_t base_n;
    size_t base_d;

    DataBundle()
        : query_n(0), query_d(0), gt_n(0), gt_dim(0), base_n(0), base_d(0) {}
};

struct Range {
    size_t begin;
    size_t end;
};

int EnvInt(const char* name, int fallback) {
    const char* value = std::getenv(name);
    if (!value || !value[0]) {
        return fallback;
    }
    const int parsed = std::atoi(value);
    return parsed > 0 ? parsed : fallback;
}

int ParseIntArg(int argc, char** argv, int index, int fallback) {
    if (argc <= index) {
        return fallback;
    }
    const int parsed = std::atoi(argv[index]);
    return parsed > 0 ? parsed : fallback;
}

#ifndef ANN_NO_MPI
void BroadcastQueriesHelper(float* data, size_t count, bool nonblocking) {
    if (nonblocking) {
        MPI_Request req;
        MPI_Ibcast(data, static_cast<int>(count), MPI_FLOAT, 0, MPI_COMM_WORLD, &req);
        MPI_Wait(&req, MPI_STATUS_IGNORE);
    } else {
        MPI_Bcast(data, static_cast<int>(count), MPI_FLOAT, 0, MPI_COMM_WORLD);
    }
}

void GatherFloatHelper(float* send_buf, int send_count, float* recv_buf,
                       int recv_count, bool nonblocking) {
    if (nonblocking) {
        MPI_Request req;
        MPI_Igather(send_buf, send_count, MPI_FLOAT,
                    recv_buf, recv_count, MPI_FLOAT,
                    0, MPI_COMM_WORLD, &req);
        MPI_Wait(&req, MPI_STATUS_IGNORE);
    } else {
        MPI_Gather(send_buf, send_count, MPI_FLOAT,
                   recv_buf, recv_count, MPI_FLOAT,
                   0, MPI_COMM_WORLD);
    }
}

void GatherUint64Helper(uint64_t* send_buf, int send_count, uint64_t* recv_buf,
                        int recv_count, bool nonblocking) {
    if (nonblocking) {
        MPI_Request req;
        MPI_Igather(send_buf, send_count, MPI_UNSIGNED_LONG_LONG,
                    recv_buf, recv_count, MPI_UNSIGNED_LONG_LONG,
                    0, MPI_COMM_WORLD, &req);
        MPI_Wait(&req, MPI_STATUS_IGNORE);
    } else {
        MPI_Gather(send_buf, send_count, MPI_UNSIGNED_LONG_LONG,
                   recv_buf, recv_count, MPI_UNSIGNED_LONG_LONG,
                   0, MPI_COMM_WORLD);
    }
}

void GatherDoubleHelper(double* send_buf, int send_count, double* recv_buf,
                        int recv_count, bool nonblocking) {
    if (nonblocking) {
        MPI_Request req;
        MPI_Igather(send_buf, send_count, MPI_DOUBLE,
                    recv_buf, recv_count, MPI_DOUBLE,
                    0, MPI_COMM_WORLD, &req);
        MPI_Wait(&req, MPI_STATUS_IGNORE);
    } else {
        MPI_Gather(send_buf, send_count, MPI_DOUBLE,
                   recv_buf, recv_count, MPI_DOUBLE,
                   0, MPI_COMM_WORLD);
    }
}
#endif

size_t ParseSizeArg(int argc, char** argv, int index, size_t fallback) {
    if (argc <= index) {
        return fallback;
    }
    const long long parsed = std::atoll(argv[index]);
    return parsed > 0 ? static_cast<size_t>(parsed) : fallback;
}

ann_ivfpq::BuildMode ParseMode(int argc, char** argv, int index,
                               ann_ivfpq::BuildMode fallback) {
    if (argc <= index) {
        return fallback;
    }
    const std::string mode(argv[index]);
    if (mode == "global" || mode == "global-pq") {
        return ann_ivfpq::BuildMode::GlobalPQFirst;
    }
    if (mode == "local" || mode == "ivf-local" || mode == "ivf-first") {
        return ann_ivfpq::BuildMode::IVFLocalPQ;
    }
    return fallback;
}

bool IsHnswArg(const std::string& value) {
    return value == "hnsw" || value == "block-hnsw" || value == "graph";
}

bool IsNestedHnswArg(const std::string& value) {
    return value == "ivf-hnsw" || value == "nested-hnsw" ||
           value == "hnsw-ivf" || value == "nested";
}

bool IsHnswOnHnswArg(const std::string& value) {
    return value == "hnsw-on-hnsw" || value == "hnsw-hnsw" ||
           value == "hier-hnsw" || value == "hierarchical-hnsw";
}

Params ParseParams(int argc, char** argv) {
    Params params;
    params.nthreads = ParseIntArg(argc, argv, 1, EnvInt("OMP_NUM_THREADS", 2));
    params.nthreads = std::max(1, params.nthreads);
    params.nlist = ParseSizeArg(argc, argv, 2, 16);
    params.nprobe = ParseSizeArg(argc, argv, 3, 4);
    params.rerank_p = ParseSizeArg(argc, argv, 4, 1000);
    params.query_limit = ParseSizeArg(argc, argv, 5, 2000);
    params.mode = ParseMode(argc, argv, 6, ann_ivfpq::BuildMode::IVFLocalPQ);
    params.use_hnsw = false;
    params.use_nested_hnsw = false;
    params.use_hnsw_on_hnsw = false;
    if (argc > 6 && IsHnswArg(std::string(argv[6]))) {
        params.use_hnsw = true;
    }
    if (argc > 7 && IsHnswArg(std::string(argv[7]))) {
        params.use_hnsw = true;
    }
    if (argc > 6 && IsNestedHnswArg(std::string(argv[6]))) {
        params.use_nested_hnsw = true;
    }
    if (argc > 7 && IsNestedHnswArg(std::string(argv[7]))) {
        params.use_nested_hnsw = true;
    }
    if (argc > 6 && IsHnswOnHnswArg(std::string(argv[6]))) {
        params.use_hnsw_on_hnsw = true;
    }
    if (argc > 7 && IsHnswOnHnswArg(std::string(argv[7]))) {
        params.use_hnsw_on_hnsw = true;
    }
    if (params.use_nested_hnsw || params.use_hnsw_on_hnsw) {
        params.use_hnsw = false;
    }
    if (params.use_hnsw_on_hnsw) {
        params.use_nested_hnsw = false;
    }
    return params;
}

const char* ModeName(ann_ivfpq::BuildMode mode) {
    return mode == ann_ivfpq::BuildMode::IVFLocalPQ ? "local" : "global";
}

Range PartitionRange(size_t n, int rank, int world_size) {
    const size_t p = static_cast<size_t>(world_size);
    const size_t r = static_cast<size_t>(rank);
    const size_t base = n / p;
    const size_t extra = n % p;
    const size_t begin = r * base + std::min(r, extra);
    const size_t count = base + (r < extra ? 1 : 0);
    Range range;
    range.begin = begin;
    range.end = begin + count;
    return range;
}

int CheckedMpiCount(size_t count, const char* label) {
    if (count > static_cast<size_t>(std::numeric_limits<int>::max())) {
        throw std::runtime_error(std::string(label) + " exceeds MPI int count");
    }
    return static_cast<int>(count);
}

DataBundle LoadAllData(size_t query_limit) {
    DataBundle data;
    const std::string data_path = ann_bench::DefaultDataPath();
    data.queries = ann_bench::LoadData<float>(
        data_path + "DEEP100K.query.fbin", data.query_n, data.query_d);
    data.gt = ann_bench::LoadData<int>(
        data_path + "DEEP100K.gt.query.100k.top100.bin",
        data.gt_n, data.gt_dim);
    data.base = ann_bench::LoadData<float>(
        data_path + "DEEP100K.base.100k.fbin", data.base_n, data.base_d);

    if (data.base_d != data.query_d) {
        throw std::runtime_error("base/query dimension mismatch");
    }
    if (data.gt_n < data.query_n && data.gt_n < query_limit) {
        throw std::runtime_error("ground truth has fewer queries than input");
    }
    data.query_n = std::min(data.query_n, query_limit);
    data.query_n = std::min(data.query_n, data.gt_n);
    return data;
}

void PackCandidates(std::vector<SearchHeap>& results, size_t query_n,
                    size_t k, uint64_t global_offset,
                    std::vector<float>& distances,
                    std::vector<uint64_t>& ids) {
    distances.assign(query_n * k, std::numeric_limits<float>::infinity());
    ids.assign(query_n * k, kInvalidId);

    for (size_t qi = 0; qi < query_n; ++qi) {
        SearchHeap& heap = results[qi];
        size_t slot = 0;
        while (!heap.empty() && slot < k) {
            const std::pair<float, uint32_t> item = heap.top();
            heap.pop();
            distances[qi * k + slot] = item.first;
            ids[qi * k + slot] = global_offset + item.second;
            ++slot;
        }
    }
}

double RecallAtK(std::vector<SearchHeap>& results, const int* gt,
                 size_t query_n, size_t gt_dim, size_t k) {
    double total = 0.0;
    for (size_t i = 0; i < query_n; ++i) {
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) {
            gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
        }

        size_t hits = 0;
        SearchHeap& heap = results[i];
        while (!heap.empty()) {
            const uint32_t id = heap.top().second;
            heap.pop();
            if (gtset.find(id) != gtset.end()) {
                ++hits;
            }
        }
        total += static_cast<double>(hits) / static_cast<double>(k);
    }
    return total / static_cast<double>(query_n);
}

void MergeGatheredCandidates(const std::vector<float>& all_distances,
                             const std::vector<uint64_t>& all_ids,
                             int world_size, size_t query_n, size_t k,
                             std::vector<SearchHeap>& merged) {
    merged.assign(query_n, SearchHeap());
    for (size_t qi = 0; qi < query_n; ++qi) {
        SearchHeap& heap = merged[qi];
        for (int rank = 0; rank < world_size; ++rank) {
            const size_t base =
                (static_cast<size_t>(rank) * query_n + qi) * k;
            for (size_t j = 0; j < k; ++j) {
                const uint64_t id = all_ids[base + j];
                const float dist = all_distances[base + j];
                if (id == kInvalidId || !std::isfinite(dist)) {
                    continue;
                }
                ann_ivf::PushTopK(heap, dist, static_cast<uint32_t>(id), k);
            }
        }
    }
}

void SearchLocalIvfpq(const std::vector<float>& local_base,
                      const std::vector<float>& queries,
                      size_t local_n, size_t d, size_t query_n,
                      const Params& params, size_t local_nlist,
                      std::vector<SearchHeap>& local_results) {
    ann_ivfpq::IVFPQIndex index;
    index.build(local_base.data(), local_n, d, local_nlist,
                params.mode, 8, 8);
    ivf_pq_search_inter_omp(index, queries.data(), query_n, kTopK,
                            params.nprobe, params.rerank_p,
                            params.nthreads, local_results);
}

void SearchLocalHnsw(const std::vector<float>& local_base,
                     const std::vector<float>& queries,
                     size_t local_n, size_t d, size_t query_n,
                     const Params& params,
                     std::vector<SearchHeap>& local_results) {
    const size_t hnsw_m = std::max<size_t>(4, params.nlist);
    const size_t ef = std::max(params.nprobe, kTopK);
    ann_hnsw::HnswHolder holder =
        ann_hnsw::BuildIndex(local_base.data(), local_n, d, hnsw_m, 120, ef);

    local_results.assign(query_n, SearchHeap());
    for (size_t i = 0; i < query_n; ++i) {
        local_results[i] = hnsw_search_multi_entry_omp(
            *holder.index, queries.data() + i * d, kTopK, ef,
            params.nthreads);
    }
}

void SearchLocalNestedHnsw(const ann_hnsw_nested::NestedIndex& nested,
                           const float* queries,
                           size_t d, size_t query_n,
                           const Params& params, size_t ef,
                           std::vector<SearchHeap>& local_results) {
    local_results.assign(query_n, SearchHeap());
    for (size_t i = 0; i < query_n; ++i) {
        local_results[i] = hnsw_ivf_nested_search_omp(
            nested, queries + i * d, kTopK, ef,
            params.nprobe, params.nthreads);
    }
}

void SearchLocalHnswOnHnsw(const ann_hnsw_on_hnsw::HierarchicalIndex& index,
                           const float* queries, size_t d, size_t query_n,
                           const Params& params, size_t ef,
                           std::vector<SearchHeap>& local_results) {
    local_results.assign(query_n, SearchHeap());
    for (size_t i = 0; i < query_n; ++i) {
        local_results[i] = ann_hnsw_on_hnsw::hnsw_on_hnsw_search_omp(
            index, queries + i * d, kTopK, ef, params.nprobe,
            params.nthreads);
    }
}

#ifndef ANN_NO_MPI

void BroadcastSize(size_t& value) {
    uint64_t tmp = static_cast<uint64_t>(value);
    MPI_Bcast(&tmp, 1, MPI_UNSIGNED_LONG_LONG, 0, MPI_COMM_WORLD);
    value = static_cast<size_t>(tmp);
}

int RunMpi(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank = 0;
    int world_size = 1;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    const Params params = ParseParams(argc, argv);
    const bool use_nonblocking = (std::getenv("USE_NONBLOCKING_MPI") != nullptr);

    if (rank == 0) {
        std::cout << "comm_mode=" << (use_nonblocking ? "nonblocking" : "blocking") << "\n";
    }

    try {
        DataBundle root_data;
        if (rank == 0) {
            root_data = LoadAllData(params.query_limit);
        }

        size_t query_n = root_data.query_n;
        size_t query_d = root_data.query_d;
        size_t gt_dim = root_data.gt_dim;
        size_t base_n = root_data.base_n;
        size_t base_d = root_data.base_d;
        BroadcastSize(query_n);
        BroadcastSize(query_d);
        BroadcastSize(gt_dim);
        BroadcastSize(base_n);
        BroadcastSize(base_d);

        if (base_d != query_d) {
            throw std::runtime_error("broadcast base/query dimension mismatch");
        }

        std::vector<float> queries(query_n * query_d);
        if (rank == 0) {
            std::memcpy(queries.data(), root_data.queries.get(),
                        queries.size() * sizeof(float));
        }

        const Range local_range = PartitionRange(base_n, rank, world_size);
        const size_t local_n = local_range.end - local_range.begin;
        if (local_n == 0) {
            throw std::runtime_error("more MPI ranks than base vectors");
        }

        std::vector<float> local_base(local_n * base_d);
        std::vector<int> send_counts;
        std::vector<int> displs;
        if (rank == 0) {
            send_counts.resize(static_cast<size_t>(world_size));
            displs.resize(static_cast<size_t>(world_size));
            for (int r = 0; r < world_size; ++r) {
                const Range range = PartitionRange(base_n, r, world_size);
                send_counts[static_cast<size_t>(r)] =
                    CheckedMpiCount((range.end - range.begin) * base_d,
                                    "base scatter count");
                displs[static_cast<size_t>(r)] =
                    CheckedMpiCount(range.begin * base_d,
                                    "base scatter displacement");
            }
        }

        MPI_Scatterv(rank == 0 ? root_data.base.get() : NULL,
                     rank == 0 ? send_counts.data() : NULL,
                     rank == 0 ? displs.data() : NULL,
                     MPI_FLOAT,
                     local_base.data(),
                     CheckedMpiCount(local_base.size(), "local base count"),
                     MPI_FLOAT, 0, MPI_COMM_WORLD);

        const size_t local_nlist = std::max<size_t>(
            1, std::min(params.nlist, local_n));
        const size_t hnsw_m = std::max<size_t>(4, params.nlist);
        const size_t hnsw_ef = std::max(params.nprobe, kTopK);
        const size_t nested_ef = std::max(params.rerank_p, kTopK);
        const size_t hnsw_on_hnsw_ef = std::max(params.rerank_p, kTopK);

        ann_ivfpq::IVFPQIndex ivfpq_index;
        ann_hnsw::HnswHolder hnsw_holder;
        ann_hnsw_nested::NestedIndex nested_index;
        ann_hnsw_on_hnsw::HierarchicalIndex hnsw_on_hnsw_index;
        if (params.use_hnsw_on_hnsw) {
            hnsw_on_hnsw_index.build(local_base.data(), local_n, base_d,
                                     local_nlist, hnsw_m, 120,
                                     hnsw_on_hnsw_ef);
        } else if (params.use_nested_hnsw) {
            nested_index.build(local_base.data(), local_n, base_d, local_nlist,
                               hnsw_m, 120, 8);
        } else if (params.use_hnsw) {
            hnsw_holder = ann_hnsw::BuildIndex(
                local_base.data(), local_n, base_d, hnsw_m, 120, hnsw_ef);
        } else {
            ivfpq_index.build(local_base.data(), local_n, base_d, local_nlist,
                              params.mode, 8, 8);
        }

        MPI_Barrier(MPI_COMM_WORLD);
        const double phase_begin = MPI_Wtime();
        BroadcastQueriesHelper(queries.data(),
                               CheckedMpiCount(queries.size(), "query broadcast count"),
                               use_nonblocking);

        std::vector<SearchHeap> local_results;
        const double search_begin = MPI_Wtime();
        if (params.use_hnsw_on_hnsw) {
            SearchLocalHnswOnHnsw(hnsw_on_hnsw_index, queries.data(), base_d,
                                  query_n, params, hnsw_on_hnsw_ef,
                                  local_results);
        } else if (params.use_nested_hnsw) {
            SearchLocalNestedHnsw(nested_index, queries.data(), base_d, query_n,
                                  params, nested_ef, local_results);
        } else if (params.use_hnsw) {
            local_results.assign(query_n, SearchHeap());
            for (size_t i = 0; i < query_n; ++i) {
                local_results[i] = hnsw_search_multi_entry_omp(
                    *hnsw_holder.index, queries.data() + i * base_d, kTopK,
                    hnsw_ef, params.nthreads);
            }
        } else {
            ivf_pq_search_inter_omp(ivfpq_index, queries.data(), query_n, kTopK,
                                    params.nprobe, params.rerank_p,
                                    params.nthreads, local_results);
        }
        const double search_us = (MPI_Wtime() - search_begin) * 1000000.0;

        std::vector<float> local_distances;
        std::vector<uint64_t> local_ids;
        PackCandidates(local_results, query_n, kTopK, local_range.begin,
                       local_distances, local_ids);

        std::vector<float> all_distances;
        std::vector<uint64_t> all_ids;
        if (rank == 0) {
            all_distances.resize(
                static_cast<size_t>(world_size) * local_distances.size());
            all_ids.resize(static_cast<size_t>(world_size) * local_ids.size());
        }

        GatherFloatHelper(local_distances.data(),
                          CheckedMpiCount(local_distances.size(),
                                          "candidate distance gather count"),
                          rank == 0 ? all_distances.data() : NULL,
                          CheckedMpiCount(local_distances.size(),
                                          "candidate distance recv count"),
                          use_nonblocking);
        GatherUint64Helper(local_ids.data(),
                           CheckedMpiCount(local_ids.size(),
                                           "candidate id gather count"),
                           rank == 0 ? all_ids.data() : NULL,
                           CheckedMpiCount(local_ids.size(),
                                           "candidate id recv count"),
                           use_nonblocking);

        double max_search_us = 0.0;
        MPI_Reduce(&search_us, &max_search_us, 1, MPI_DOUBLE, MPI_MAX, 0,
                   MPI_COMM_WORLD);

        std::vector<double> all_search_us;
        if (rank == 0) {
            all_search_us.resize(world_size);
        }
        double rank_search_us = search_us;
        GatherDoubleHelper(&rank_search_us, 1,
                           rank == 0 ? all_search_us.data() : NULL, 1,
                           use_nonblocking);

        if (rank == 0) {
            std::vector<SearchHeap> merged;
            MergeGatheredCandidates(all_distances, all_ids, world_size,
                                    query_n, kTopK, merged);
            const double total_us = (MPI_Wtime() - phase_begin) * 1000000.0;
            const double recall =
                RecallAtK(merged, root_data.gt.get(), query_n, gt_dim, kTopK);
            const double comm_merge_us = std::max(0.0, total_us - max_search_us);

            std::cout << std::fixed << std::setprecision(5);
            if (params.use_hnsw_on_hnsw) {
                std::cout << "hnsw_on_hnsw_mpi_omp"
                          << ", mpi_procs=" << world_size
                          << ", nthreads=" << params.nthreads
                          << ", nblocks=" << local_nlist
                          << ", nprobe=" << params.nprobe
                          << ", hnsw_m=" << hnsw_m
                          << ", ef=" << hnsw_on_hnsw_ef
                          << ", query_n=" << query_n << "\n";
            } else if (params.use_nested_hnsw) {
                std::cout << "ivf_hnsw_nested_mpi_omp"
                          << ", mpi_procs=" << world_size
                          << ", nthreads=" << params.nthreads
                          << ", nlist=" << params.nlist
                          << ", local_nlist=" << local_nlist
                          << ", nprobe=" << params.nprobe
                          << ", hnsw_m=" << hnsw_m
                          << ", ef=" << nested_ef
                          << ", query_n=" << query_n << "\n";
            } else if (params.use_hnsw) {
                std::cout << "block_hnsw_mpi_omp_multi_entry"
                          << ", mpi_procs=" << world_size
                          << ", nthreads=" << params.nthreads
                          << ", hnsw_m=" << hnsw_m
                          << ", ef=" << hnsw_ef
                          << ", query_n=" << query_n << "\n";
            } else {
                std::cout << "ivfpq_" << ModeName(params.mode)
                          << "_mpi_omp_inter"
                          << ", mpi_procs=" << world_size
                          << ", nthreads=" << params.nthreads
                          << ", nlist=" << params.nlist
                          << ", local_nlist=" << local_nlist
                          << ", nprobe=" << params.nprobe
                          << ", p=" << params.rerank_p
                          << ", query_n=" << query_n
                          << ", mode=" << ModeName(params.mode) << "\n";
            }
            std::cout << "average recall: " << recall << "\n";
            std::cout << "average latency (us): "
                      << total_us / static_cast<double>(query_n) << "\n";
            std::cout << "max local search latency (us): "
                      << max_search_us / static_cast<double>(query_n) << "\n";
            std::cout << "comm+merge latency (us): "
                      << comm_merge_us / static_cast<double>(query_n) << "\n";

            std::cout << "per-rank search latency (us):";
            for (int r = 0; r < world_size; ++r) {
                std::cout << " rank" << r << "="
                          << all_search_us[r] / static_cast<double>(query_n);
            }
            std::cout << "\n";
        }
    } catch (const std::exception& ex) {
        std::cerr << "[rank " << rank << "] " << ex.what() << "\n";
        MPI_Abort(MPI_COMM_WORLD, 1);
    }

    MPI_Finalize();
    return 0;
}

#else

int RunNoMpi(int argc, char** argv) {
    const Params params = ParseParams(argc, argv);
    DataBundle data = LoadAllData(params.query_limit);
    const size_t local_nlist = std::max<size_t>(
        1, std::min(params.nlist, data.base_n));

    std::vector<SearchHeap> local_results;
    const size_t hnsw_m = std::max<size_t>(4, params.nlist);
    const size_t hnsw_ef = std::max(params.nprobe, kTopK);
    const size_t nested_ef = std::max(params.rerank_p, kTopK);
    const size_t hnsw_on_hnsw_ef = std::max(params.rerank_p, kTopK);
    ann_ivfpq::IVFPQIndex ivfpq_index;
    ann_hnsw::HnswHolder hnsw_holder;
    ann_hnsw_nested::NestedIndex nested_index;
    ann_hnsw_on_hnsw::HierarchicalIndex hnsw_on_hnsw_index;
    if (params.use_hnsw_on_hnsw) {
        hnsw_on_hnsw_index.build(data.base.get(), data.base_n, data.base_d,
                                 local_nlist, hnsw_m, 120,
                                 hnsw_on_hnsw_ef);
    } else if (params.use_nested_hnsw) {
        nested_index.build(data.base.get(), data.base_n, data.base_d,
                           local_nlist, hnsw_m, 120, 8);
    } else if (params.use_hnsw) {
        hnsw_holder = ann_hnsw::BuildIndex(
            data.base.get(), data.base_n, data.base_d, hnsw_m, 120, hnsw_ef);
    } else {
        ivfpq_index.build(data.base.get(), data.base_n, data.base_d,
                          local_nlist, params.mode, 8, 8);
    }

    const auto begin = std::chrono::high_resolution_clock::now();
    if (params.use_hnsw_on_hnsw) {
        SearchLocalHnswOnHnsw(hnsw_on_hnsw_index, data.queries.get(),
                              data.base_d, data.query_n, params,
                              hnsw_on_hnsw_ef, local_results);
    } else if (params.use_nested_hnsw) {
        SearchLocalNestedHnsw(nested_index, data.queries.get(),
                              data.base_d, data.query_n, params, nested_ef,
                              local_results);
    } else if (params.use_hnsw) {
        local_results.assign(data.query_n, SearchHeap());
        for (size_t i = 0; i < data.query_n; ++i) {
            local_results[i] = hnsw_search_multi_entry_omp(
                *hnsw_holder.index,
                data.queries.get() + i * data.base_d,
                kTopK, hnsw_ef, params.nthreads);
        }
    } else {
        ivf_pq_search_inter_omp(ivfpq_index, data.queries.get(), data.query_n,
                                kTopK, params.nprobe, params.rerank_p,
                                params.nthreads, local_results);
    }
    const auto end = std::chrono::high_resolution_clock::now();
    const double total_us =
        std::chrono::duration<double, std::micro>(end - begin).count();
    const double recall = RecallAtK(local_results, data.gt.get(),
                                    data.query_n, data.gt_dim, kTopK);

    std::cout << std::fixed << std::setprecision(5);
    if (params.use_hnsw_on_hnsw) {
        std::cout << "hnsw_on_hnsw_no_mpi_omp"
                  << ", mpi_procs=1"
                  << ", nthreads=" << params.nthreads
                  << ", nblocks=" << local_nlist
                  << ", nprobe=" << params.nprobe
                  << ", hnsw_m=" << hnsw_m
                  << ", ef=" << hnsw_on_hnsw_ef
                  << ", query_n=" << data.query_n << "\n";
    } else if (params.use_nested_hnsw) {
        std::cout << "ivf_hnsw_nested_no_mpi_omp"
                  << ", mpi_procs=1"
                  << ", nthreads=" << params.nthreads
                  << ", nlist=" << params.nlist
                  << ", local_nlist=" << local_nlist
                  << ", nprobe=" << params.nprobe
                  << ", hnsw_m=" << hnsw_m
                  << ", ef=" << nested_ef
                  << ", query_n=" << data.query_n << "\n";
    } else if (params.use_hnsw) {
        std::cout << "block_hnsw_no_mpi_omp_multi_entry"
                  << ", mpi_procs=1"
                  << ", nthreads=" << params.nthreads
                  << ", hnsw_m=" << hnsw_m
                  << ", ef=" << hnsw_ef
                  << ", query_n=" << data.query_n << "\n";
    } else {
        std::cout << "ivfpq_" << ModeName(params.mode)
                  << "_no_mpi_omp_inter"
                  << ", mpi_procs=1"
                  << ", nthreads=" << params.nthreads
                  << ", nlist=" << params.nlist
                  << ", local_nlist=" << local_nlist
                  << ", nprobe=" << params.nprobe
                  << ", p=" << params.rerank_p
                  << ", query_n=" << data.query_n
                  << ", mode=" << ModeName(params.mode) << "\n";
    }
    std::cout << "average recall: " << recall << "\n";
    std::cout << "average latency (us): "
              << total_us / static_cast<double>(data.query_n) << "\n";
    std::cout << "max local search latency (us): "
              << total_us / static_cast<double>(data.query_n) << "\n";
    std::cout << "comm+merge latency (us): 0.00000\n";
    return 0;
}

#endif

}  // namespace

int main(int argc, char** argv) {
#ifndef ANN_NO_MPI
    return RunMpi(argc, argv);
#else
    try {
        return RunNoMpi(argc, argv);
    } catch (const std::exception& ex) {
        std::cerr << ex.what() << "\n";
        return 1;
    }
#endif
}
