#pragma once

#include <algorithm>
#include <cstdint>
#include <queue>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#include <cuda_runtime.h>
#include <cublas_v2.h>

namespace ann_gpu {

static const int kGpuTopK = 10;
static const uint32_t kInvalidId = 0xffffffffu;

#ifndef ANN_GPU_NEG_INFINITY
#define ANN_GPU_NEG_INFINITY (-3.4028234663852886e+38F)
#endif

using SearchHeap = std::priority_queue<std::pair<float, uint32_t> >;

struct GpuSearchStats {
    std::string mode;
    size_t query_n;
    size_t base_n;
    size_t dim;
    size_t nlist;
    size_t nprobe;
    float build_ms;
    float base_copy_ms;
    float query_copy_ms;
    float score_ms;
    float topk_ms;
    float result_copy_ms;
    float online_ms;

    GpuSearchStats()
        : query_n(0), base_n(0), dim(0), nlist(0), nprobe(0),
          build_ms(0.0f), base_copy_ms(0.0f), query_copy_ms(0.0f),
          score_ms(0.0f), topk_ms(0.0f), result_copy_ms(0.0f),
          online_ms(0.0f) {}
};

inline void CheckCuda(cudaError_t status, const char* call,
                      const char* file, int line) {
    if (status != cudaSuccess) {
        throw std::runtime_error(std::string(file) + ":" +
                                 std::to_string(line) +
                                 " CUDA call failed: " + call + " -> " +
                                 cudaGetErrorString(status));
    }
}

#define ANN_GPU_CHECK(call) ::ann_gpu::CheckCuda((call), #call, __FILE__, __LINE__)

inline void CheckCublas(cublasStatus_t status, const char* call,
                        const char* file, int line) {
    if (status != CUBLAS_STATUS_SUCCESS) {
        throw std::runtime_error(std::string(file) + ":" +
                                 std::to_string(line) +
                                 " cuBLAS call failed: " + call +
                                 " -> status " + std::to_string(status));
    }
}

#define ANN_CUBLAS_CHECK(call) \
    ::ann_gpu::CheckCublas((call), #call, __FILE__, __LINE__)

inline int DivUp(size_t a, int b) {
    return static_cast<int>((a + static_cast<size_t>(b) - 1) /
                            static_cast<size_t>(b));
}

inline float ElapsedMs(cudaEvent_t begin, cudaEvent_t end) {
    float ms = 0.0f;
    ANN_GPU_CHECK(cudaEventElapsedTime(&ms, begin, end));
    return ms;
}

inline std::vector<SearchHeap> BuildHeaps(const std::vector<float>& distances,
                                          const std::vector<uint32_t>& ids,
                                          size_t query_n, size_t k) {
    std::vector<SearchHeap> heaps(query_n);
    for (size_t qi = 0; qi < query_n; ++qi) {
        for (size_t j = 0; j < k; ++j) {
            const uint32_t id = ids[qi * k + j];
            if (id != kInvalidId) {
                heaps[qi].push(std::make_pair(distances[qi * k + j], id));
            }
        }
    }
    return heaps;
}

inline int ClampThreads(int requested) {
    cudaDeviceProp prop;
    ANN_GPU_CHECK(cudaGetDeviceProperties(&prop, 0));
    const int bytes_per_thread =
        kGpuTopK * static_cast<int>(sizeof(float) + sizeof(uint32_t));
    const int by_shared = std::max(
        32, static_cast<int>(prop.sharedMemPerBlock / bytes_per_thread));
    int threads = std::max(32, requested);
    threads = std::min(threads, 1024);
    threads = std::min(threads, by_shared);
    threads = (threads / 32) * 32;
    return std::max(32, threads);
}

}  // namespace ann_gpu
