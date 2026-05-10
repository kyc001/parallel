#pragma once

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <memory>
#include <queue>
#include <set>
#include <string>
#include <utility>
#include <vector>

#include "simd/ann_bench_common.h"

namespace ann_flat_main {

using FlatHeap = std::priority_queue<std::pair<float, uint32_t>>;
using InterSearchFn = void (*)(float*, float*, size_t, size_t, size_t, size_t,
                               int, std::vector<FlatHeap>&);
using IntraSearchFn = FlatHeap (*)(float*, float*, size_t, size_t, size_t, int);

static inline int ParseThreads(int argc, char** argv) {
    int nthreads = 4;
    if (argc > 1) {
        nthreads = std::atoi(argv[1]);
    }
    return nthreads < 1 ? 1 : nthreads;
}

static inline double RecallAtK(std::vector<FlatHeap>& results, const int* gt,
                               size_t query_n, size_t gt_dim, size_t k) {
    double total = 0.0;
    for (size_t i = 0; i < query_n; ++i) {
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) {
            gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
        }

        size_t hits = 0;
        FlatHeap& heap = results[i];
        while (!heap.empty()) {
            const uint32_t id = heap.top().second;
            if (gtset.find(id) != gtset.end()) {
                ++hits;
            }
            heap.pop();
        }
        total += static_cast<double>(hits) / static_cast<double>(k);
    }
    return total / static_cast<double>(query_n);
}

static inline void PrintResult(const std::string& label, int nthreads,
                               double recall, double latency_us) {
    std::cout << std::fixed << std::setprecision(5);
    std::cout << label << ", nthreads=" << nthreads << "\n";
    std::cout << "average recall: " << recall << "\n";
    std::cout << "average latency (us): " << latency_us << "\n";
}

static inline int RunInter(int argc, char** argv, const std::string& label,
                           InterSearchFn search) {
    const int nthreads = ParseThreads(argc, argv);
    const size_t k = 10;

    std::string data_path = ann_bench::DefaultDataPath();
    size_t query_n = 0, base_n = 0, gt_n = 0;
    size_t query_d = 0, base_d = 0, gt_dim = 0;
    std::unique_ptr<float[]> queries =
        ann_bench::LoadData<float>(data_path + "DEEP100K.query.fbin", query_n, query_d);
    std::unique_ptr<int[]> gt =
        ann_bench::LoadData<int>(data_path + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    std::unique_ptr<float[]> base =
        ann_bench::LoadData<float>(data_path + "DEEP100K.base.100k.fbin", base_n, base_d);

    query_n = std::min<size_t>(query_n, 2000);
    if (base_d != query_d) {
        std::cerr << "dimension mismatch: base_d=" << base_d
                  << " query_d=" << query_d << "\n";
        return 2;
    }

    std::vector<FlatHeap> results;
    const auto begin = std::chrono::high_resolution_clock::now();
    search(base.get(), queries.get(), base_n, query_n, query_d, k, nthreads, results);
    const auto end = std::chrono::high_resolution_clock::now();

    const double total_us =
        std::chrono::duration<double, std::micro>(end - begin).count();
    const double recall = RecallAtK(results, gt.get(), query_n, gt_dim, k);
    PrintResult(label, nthreads, recall, total_us / static_cast<double>(query_n));
    return 0;
}

static inline int RunIntra(int argc, char** argv, const std::string& label,
                           IntraSearchFn search) {
    const int nthreads = ParseThreads(argc, argv);
    const size_t k = 10;

    std::string data_path = ann_bench::DefaultDataPath();
    size_t query_n = 0, base_n = 0, gt_n = 0;
    size_t query_d = 0, base_d = 0, gt_dim = 0;
    std::unique_ptr<float[]> queries =
        ann_bench::LoadData<float>(data_path + "DEEP100K.query.fbin", query_n, query_d);
    std::unique_ptr<int[]> gt =
        ann_bench::LoadData<int>(data_path + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    std::unique_ptr<float[]> base =
        ann_bench::LoadData<float>(data_path + "DEEP100K.base.100k.fbin", base_n, base_d);

    query_n = std::min<size_t>(query_n, 2000);
    if (base_d != query_d) {
        std::cerr << "dimension mismatch: base_d=" << base_d
                  << " query_d=" << query_d << "\n";
        return 2;
    }

    std::vector<FlatHeap> results(query_n);
    const auto begin = std::chrono::high_resolution_clock::now();
    for (size_t i = 0; i < query_n; ++i) {
        results[i] = search(base.get(), queries.get() + i * query_d,
                            base_n, query_d, k, nthreads);
    }
    const auto end = std::chrono::high_resolution_clock::now();

    const double total_us =
        std::chrono::duration<double, std::micro>(end - begin).count();
    const double recall = RecallAtK(results, gt.get(), query_n, gt_dim, k);
    PrintResult(label, nthreads, recall, total_us / static_cast<double>(query_n));
    return 0;
}

}  // namespace ann_flat_main
