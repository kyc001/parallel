#pragma once

#include <limits>
#include <stdexcept>
#include <string>

#include "common.h"
#include "data.h"

#ifndef ANN_NO_MPI
#include "mpi.h"
#endif

namespace ann_mpi {

#ifndef ANN_NO_MPI

static inline int CheckedMpiCount(size_t count, const char* label) {
    if (count > static_cast<size_t>(std::numeric_limits<int>::max())) {
        throw std::runtime_error(std::string(label) + " exceeds MPI int count");
    }
    return static_cast<int>(count);
}

static inline const char* MpiThreadLevelName(int level) {
    switch (level) {
    case MPI_THREAD_SINGLE:
        return "single";
    case MPI_THREAD_FUNNELED:
        return "funneled";
    case MPI_THREAD_SERIALIZED:
        return "serialized";
    case MPI_THREAD_MULTIPLE:
        return "multiple";
    default:
        return "unknown";
    }
}

class MpiSession {
public:
    MpiSession(int* argc, char*** argv, bool request_thread_multiple)
        : rank_(0), world_size_(1), provided_thread_level_(MPI_THREAD_SINGLE) {
        requested_thread_level_ =
            request_thread_multiple ? MPI_THREAD_MULTIPLE : MPI_THREAD_FUNNELED;
        MPI_Init_thread(argc, argv, requested_thread_level_,
                        &provided_thread_level_);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank_);
        MPI_Comm_size(MPI_COMM_WORLD, &world_size_);
    }

    ~MpiSession() {
        MPI_Finalize();
    }

    int rank() const { return rank_; }
    int world_size() const { return world_size_; }
    int requested_thread_level() const { return requested_thread_level_; }
    int provided_thread_level() const { return provided_thread_level_; }

    void Abort(int code) const {
        MPI_Abort(MPI_COMM_WORLD, code);
    }

private:
    int rank_;
    int world_size_;
    int requested_thread_level_;
    int provided_thread_level_;
};

static inline void BroadcastSize(size_t& value) {
    uint64_t tmp = static_cast<uint64_t>(value);
    MPI_Bcast(&tmp, 1, MPI_UNSIGNED_LONG_LONG, 0, MPI_COMM_WORLD);
    value = static_cast<size_t>(tmp);
}

static inline void BroadcastShape(ProblemShape& shape) {
    BroadcastSize(shape.query_n);
    BroadcastSize(shape.query_d);
    BroadcastSize(shape.gt_dim);
    BroadcastSize(shape.base_n);
    BroadcastSize(shape.base_d);
}

static inline void BuildScatterLayout(size_t base_n, size_t base_d,
                                      int world_size,
                                      std::vector<int>& base_counts,
                                      std::vector<int>& base_displs,
                                      std::vector<int>& id_counts,
                                      std::vector<int>& id_displs) {
    base_counts.resize(static_cast<size_t>(world_size));
    base_displs.resize(static_cast<size_t>(world_size));
    id_counts.resize(static_cast<size_t>(world_size));
    id_displs.resize(static_cast<size_t>(world_size));
    for (int r = 0; r < world_size; ++r) {
        const Range range = PartitionRange(base_n, r, world_size);
        base_counts[static_cast<size_t>(r)] =
            CheckedMpiCount((range.end - range.begin) * base_d,
                            "base scatter count");
        base_displs[static_cast<size_t>(r)] =
            CheckedMpiCount(range.begin * base_d,
                            "base scatter displacement");
        id_counts[static_cast<size_t>(r)] =
            CheckedMpiCount(range.end - range.begin, "id scatter count");
        id_displs[static_cast<size_t>(r)] =
            CheckedMpiCount(range.begin, "id scatter displacement");
    }
}

static inline void ScatterBaseShard(const DataBundle& root_data,
                                    const std::vector<uint64_t>& root_ids,
                                    const ProblemShape& shape,
                                    int rank, int world_size,
                                    std::vector<float>& local_base,
                                    std::vector<uint64_t>& local_ids) {
    const Range local_range = PartitionRange(shape.base_n, rank, world_size);
    const size_t local_n = local_range.end - local_range.begin;
    if (local_n == 0) {
        throw std::runtime_error("more MPI ranks than base vectors");
    }

    local_base.resize(local_n * shape.base_d);
    local_ids.resize(local_n);

    std::vector<int> base_counts;
    std::vector<int> base_displs;
    std::vector<int> id_counts;
    std::vector<int> id_displs;
    if (rank == 0) {
        BuildScatterLayout(shape.base_n, shape.base_d, world_size,
                           base_counts, base_displs, id_counts, id_displs);
    }

    MPI_Scatterv(rank == 0 ? root_data.base.get() : NULL,
                 rank == 0 ? base_counts.data() : NULL,
                 rank == 0 ? base_displs.data() : NULL,
                 MPI_FLOAT,
                 local_base.data(),
                 CheckedMpiCount(local_base.size(), "local base count"),
                 MPI_FLOAT, 0, MPI_COMM_WORLD);
    MPI_Scatterv(rank == 0 ? root_ids.data() : NULL,
                 rank == 0 ? id_counts.data() : NULL,
                 rank == 0 ? id_displs.data() : NULL,
                 MPI_UNSIGNED_LONG_LONG,
                 local_ids.data(),
                 CheckedMpiCount(local_ids.size(), "local id count"),
                 MPI_UNSIGNED_LONG_LONG, 0, MPI_COMM_WORLD);
}

static inline void BroadcastQueries(float* data, size_t count,
                                    bool nonblocking) {
    if (nonblocking) {
        MPI_Request req;
        MPI_Ibcast(data, CheckedMpiCount(count, "query broadcast count"),
                   MPI_FLOAT, 0, MPI_COMM_WORLD, &req);
        MPI_Wait(&req, MPI_STATUS_IGNORE);
    } else {
        MPI_Bcast(data, CheckedMpiCount(count, "query broadcast count"),
                  MPI_FLOAT, 0, MPI_COMM_WORLD);
    }
}

static inline void GatherFloat(float* send_buf, int send_count,
                               float* recv_buf, int recv_count,
                               bool nonblocking) {
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

static inline void GatherUint64(uint64_t* send_buf, int send_count,
                                uint64_t* recv_buf, int recv_count,
                                bool nonblocking) {
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

static inline void GatherDouble(double* send_buf, int send_count,
                                double* recv_buf, int recv_count,
                                bool nonblocking) {
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

#endif  // ANN_NO_MPI

}  // namespace ann_mpi
