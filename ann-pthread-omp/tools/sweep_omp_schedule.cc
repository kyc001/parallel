// OMP schedule × chunk_size sweep — Flat inter-query
// 通过 schedule(runtime) + OMP_SCHEDULE 环境变量在运行时切换 schedule 策略.
// 编译: g++ tools/sweep_omp_schedule.cc -o build/sweep_omp_schedule.exe -O2 -mavx2 -mfma -fopenmp -lpthread -std=c++17 -I.

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

static FlatHeap flat_search_one(float* base, float* query, size_t base_n,
                                size_t d, size_t k) {
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
    const int nthreads = (argc > 1) ? std::atoi(argv[1]) : 16;

    size_t query_n = 0, query_d = 0;
    size_t gt_n = 0, gt_dim = 0;
    size_t base_n = 0, base_d = 0;
    const std::string data_path = ann_bench::DefaultDataPath();
    auto queries = ann_bench::LoadData<float>(
        data_path + "DEEP100K.query.fbin", query_n, query_d);
    auto gt = ann_bench::LoadData<int>(
        data_path + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    auto base = ann_bench::LoadData<float>(
        data_path + "DEEP100K.base.100k.fbin", base_n, base_d);
    query_n = std::min<size_t>(query_n, 2000);
    const size_t k = 10;

    // 跑两次平均（第一次预热）
    std::vector<FlatHeap> results(query_n);
    for (int rep = 0; rep < 2; ++rep) {
        results.assign(query_n, FlatHeap{});
        const auto begin = std::chrono::high_resolution_clock::now();

#pragma omp parallel for num_threads(nthreads) schedule(runtime)
        for (long long i = 0; i < static_cast<long long>(query_n); ++i) {
            results[i] = flat_search_one(
                base.get(), queries.get() + i * query_d,
                base_n, query_d, k);
        }
        const auto end = std::chrono::high_resolution_clock::now();
        if (rep == 1) {
            const double us = std::chrono::duration<double, std::micro>(
                                  end - begin).count() / static_cast<double>(query_n);
            const char* env = std::getenv("OMP_SCHEDULE");
            // recall
            double total_recall = 0.0;
            for (size_t i = 0; i < query_n; ++i) {
                std::set<uint32_t> gtset;
                for (size_t j = 0; j < k; ++j) {
                    gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
                }
                size_t hits = 0;
                while (!results[i].empty()) {
                    if (gtset.count(results[i].top().second)) ++hits;
                    results[i].pop();
                }
                total_recall += static_cast<double>(hits) / static_cast<double>(k);
            }
            std::cout << std::fixed << std::setprecision(5);
            std::cout << "schedule=" << (env ? env : "default")
                      << ", threads=" << nthreads
                      << ", recall=" << total_recall / static_cast<double>(query_n)
                      << ", latency_us=" << us << "\n";
        }
    }
    return 0;
}
