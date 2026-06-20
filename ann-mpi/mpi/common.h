#pragma once

#include <cstddef>
#include <cstdint>
#include <limits>
#include <memory>
#include <vector>

#include "../ivf/ivf_pq_simd.h"

namespace ann_mpi {

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

struct RuntimeOptions {
    bool use_nonblocking;
    bool use_shuffled_base;
    uint64_t shuffle_seed;
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

struct ProblemShape {
    size_t query_n;
    size_t query_d;
    size_t gt_dim;
    size_t base_n;
    size_t base_d;

    ProblemShape()
        : query_n(0), query_d(0), gt_dim(0), base_n(0), base_d(0) {}
};

struct Range {
    size_t begin;
    size_t end;
};

}  // namespace ann_mpi
