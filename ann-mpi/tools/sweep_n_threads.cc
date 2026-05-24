// N×T sweep — Flat inter-query
// 通过 truncate base_n 测试不同问题规模下的多线程加速比
// 编译: g++ tools/sweep_n_threads.cc -o build/sweep_n_threads.exe -O2 -mavx2 -mfma -fopenmp -lpthread -std=c++17 -I.

#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <queue>
#include <set>
#include <string>
#include <utility>
#include <vector>
#include <omp.h>

#include "simd/ann_bench_common.h"
#include "simd/flat_scan_avx2.h"

using FlatHeap = std::priority_queue<std::pair<float, uint32_t>>;

static FlatHeap flat_search_one(const float* base, const float* query,
                                size_t base_n, size_t d, size_t k) {
    FlatHeap heap;
    for (size_t i = 0; i < base_n; ++i) {
        const float dist = ann_avx2::ip_distance_avx2(
            base + i * d, query, static_cast<int>(d));
        if (heap.size() < k) {
            heap.push({dist, static_cast<uint32_t>(i)});
        } else if (dist < heap.top().first) {
            heap.push({dist, static_cast<uint32_t>(i)});
            heap.pop();
        }
    }
    return heap;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: " << argv[0] << " <N> <T>\n";
        return 1;
    }
    const size_t N = static_cast<size_t>(std::atoll(argv[1]));
    const int    T = std::atoi(argv[2]);

    size_t query_n = 0, query_d = 0;
    size_t base_n = 0, base_d = 0;
    const std::string data_path = ann_bench::DefaultDataPath();
    auto queries = ann_bench::LoadData<float>(
        data_path + "DEEP100K.query.fbin", query_n, query_d);
    auto base = ann_bench::LoadData<float>(
        data_path + "DEEP100K.base.100k.fbin", base_n, base_d);
    if (N > base_n) {
        std::cerr << "N=" << N << " > base_n=" << base_n << "\n";
        return 1;
    }
    const size_t n_use = N;
    query_n = std::min<size_t>(query_n, 2000);
    const size_t k = 10;

    std::vector<FlatHeap> results(query_n);
    // 预热
    for (int rep = 0; rep < 2; ++rep) {
        results.assign(query_n, FlatHeap{});
        const auto begin = std::chrono::high_resolution_clock::now();
#pragma omp parallel for num_threads(T) schedule(static)
        for (long long i = 0; i < static_cast<long long>(query_n); ++i) {
            results[i] = flat_search_one(
                base.get(), queries.get() + i * query_d,
                n_use, query_d, k);
        }
        const auto end = std::chrono::high_resolution_clock::now();
        if (rep == 1) {
            const double us = std::chrono::duration<double, std::micro>(
                                  end - begin).count() / static_cast<double>(query_n);
            std::cout << "N=" << n_use << ", T=" << T
                      << ", latency_us=" << std::fixed << std::setprecision(3)
                      << us << "\n";
        }
    }
    return 0;
}
