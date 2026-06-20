#pragma once

#include <algorithm>
#include <cstring>
#include <random>
#include <stdexcept>
#include <string>

#include "common.h"
#include "../simd/ann_bench_common.h"

namespace ann_mpi {

static inline Range PartitionRange(size_t n, int rank, int world_size) {
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

static inline ProblemShape ShapeFromData(const DataBundle& data) {
    ProblemShape shape;
    shape.query_n = data.query_n;
    shape.query_d = data.query_d;
    shape.gt_dim = data.gt_dim;
    shape.base_n = data.base_n;
    shape.base_d = data.base_d;
    return shape;
}

static inline DataBundle LoadAllData(size_t query_limit) {
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

static inline void FillIdentityIds(size_t n, std::vector<uint64_t>& global_ids) {
    global_ids.resize(n);
    for (size_t i = 0; i < n; ++i) {
        global_ids[i] = static_cast<uint64_t>(i);
    }
}

static inline void ApplyBasePermutation(DataBundle& data,
                                        std::vector<uint64_t>& global_ids,
                                        uint64_t seed) {
    global_ids.resize(data.base_n);
    std::vector<size_t> permutation(data.base_n);
    for (size_t i = 0; i < data.base_n; ++i) {
        permutation[i] = i;
    }

    std::mt19937_64 rng(seed);
    std::shuffle(permutation.begin(), permutation.end(), rng);

    std::vector<float> shuffled(data.base_n * data.base_d);
    for (size_t dst = 0; dst < data.base_n; ++dst) {
        const size_t src = permutation[dst];
        std::memcpy(shuffled.data() + dst * data.base_d,
                    data.base.get() + src * data.base_d,
                    data.base_d * sizeof(float));
        global_ids[dst] = static_cast<uint64_t>(src);
    }
    std::memcpy(data.base.get(), shuffled.data(),
                shuffled.size() * sizeof(float));
}

static inline void PrepareGlobalIds(DataBundle& data,
                                    const RuntimeOptions& options,
                                    std::vector<uint64_t>& global_ids) {
    if (options.use_shuffled_base) {
        ApplyBasePermutation(data, global_ids, options.shuffle_seed);
    } else {
        FillIdentityIds(data.base_n, global_ids);
    }
}

}  // namespace ann_mpi
