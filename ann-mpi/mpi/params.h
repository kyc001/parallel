#pragma once

#include <algorithm>
#include <cstdlib>
#include <string>

#include "common.h"

namespace ann_mpi {

static inline int EnvInt(const char* name, int fallback) {
    const char* value = std::getenv(name);
    if (!value || !value[0]) {
        return fallback;
    }
    const int parsed = std::atoi(value);
    return parsed > 0 ? parsed : fallback;
}

static inline uint64_t EnvUint64(const char* name, uint64_t fallback) {
    const char* value = std::getenv(name);
    if (!value || !value[0]) {
        return fallback;
    }
    char* end = NULL;
    const unsigned long long parsed = std::strtoull(value, &end, 10);
    return end != value ? static_cast<uint64_t>(parsed) : fallback;
}

static inline int ParseIntArg(int argc, char** argv, int index, int fallback) {
    if (argc <= index) {
        return fallback;
    }
    const int parsed = std::atoi(argv[index]);
    return parsed > 0 ? parsed : fallback;
}

static inline size_t ParseSizeArg(int argc, char** argv, int index,
                                  size_t fallback) {
    if (argc <= index) {
        return fallback;
    }
    const long long parsed = std::atoll(argv[index]);
    return parsed > 0 ? static_cast<size_t>(parsed) : fallback;
}

static inline ann_ivfpq::BuildMode ParseMode(
    int argc, char** argv, int index, ann_ivfpq::BuildMode fallback) {
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

static inline bool IsHnswArg(const std::string& value) {
    return value == "hnsw" || value == "block-hnsw" || value == "graph";
}

static inline bool IsNestedHnswArg(const std::string& value) {
    return value == "ivf-hnsw" || value == "nested-hnsw" ||
           value == "hnsw-ivf" || value == "nested";
}

static inline bool IsHnswOnHnswArg(const std::string& value) {
    return value == "hnsw-on-hnsw" || value == "hnsw-hnsw" ||
           value == "hier-hnsw" || value == "hierarchical-hnsw";
}

static inline Params ParseParams(int argc, char** argv) {
    const bool representative_default = (argc <= 1);
    Params params;
    params.nthreads = ParseIntArg(argc, argv, 1, EnvInt("OMP_NUM_THREADS", 2));
    params.nthreads = std::max(1, params.nthreads);
    params.nlist = ParseSizeArg(argc, argv, 2, 16);
    params.nprobe = ParseSizeArg(argc, argv, 3,
                                 representative_default ? 50 : 4);
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
    if (representative_default) {
        params.use_hnsw = true;
    }
    if (params.use_nested_hnsw || params.use_hnsw_on_hnsw) {
        params.use_hnsw = false;
    }
    if (params.use_hnsw_on_hnsw) {
        params.use_nested_hnsw = false;
    }
    return params;
}

static inline RuntimeOptions ReadRuntimeOptions() {
    RuntimeOptions options;
    options.use_nonblocking = (std::getenv("USE_NONBLOCKING_MPI") != NULL);
    options.use_shuffled_base = (std::getenv("USE_SHUFFLED_BASE") != NULL);
    options.shuffle_seed = EnvUint64("BASE_SHUFFLE_SEED", 20260525ULL);
    return options;
}

static inline const char* ModeName(ann_ivfpq::BuildMode mode) {
    return mode == ann_ivfpq::BuildMode::IVFLocalPQ ? "local" : "global";
}

}  // namespace ann_mpi
