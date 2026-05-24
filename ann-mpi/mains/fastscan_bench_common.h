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

#include "../simd/ann_bench_common.h"

namespace ann_fastscan_main {

using SearchHeap = std::priority_queue<std::pair<float, uint32_t>>;
using InterSearchFn = void (*)(const ann_fs::FastScanIndex&, const float*, const float*,
                               size_t, size_t, size_t, int,
                               std::vector<SearchHeap>&);
using IntraSearchFn = SearchHeap (*)(const ann_fs::FastScanIndex&, const float*,
                                     const float*, size_t, size_t, int);

static inline int ParseThreads(int argc, char** argv) {
    int nthreads = 4;
    if (argc > 1) {
        nthreads = std::atoi(argv[1]);
    }
    return nthreads < 1 ? 1 : nthreads;
}

static inline size_t ParseRerankP(int argc, char** argv) {
    if (argc > 2) {
        const long long value = std::atoll(argv[2]);
        if (value > 0) {
            return static_cast<size_t>(value);
        }
    }
    return 1000;
}

static inline double RecallAtK(std::vector<SearchHeap>& results, const int* gt,
                               size_t query_n, size_t gt_dim, size_t k) {
    double total = 0.0;
    for (size_t i = 0; i < query_n; ++i) {
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) {
            gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
        }
        size_t hits = 0;
        while (!results[i].empty()) {
            const uint32_t id = results[i].top().second;
            if (gtset.find(id) != gtset.end()) {
                ++hits;
            }
            results[i].pop();
        }
        total += static_cast<double>(hits) / static_cast<double>(k);
    }
    return total / static_cast<double>(query_n);
}

static inline void PrintResult(const std::string& label, int nthreads,
                               size_t rerank_p, double recall,
                               double latency_us) {
    std::cout << std::fixed << std::setprecision(5);
    std::cout << label << ", nthreads=" << nthreads
              << ", p=" << rerank_p << "\n";
    std::cout << "average recall: " << recall << "\n";
    std::cout << "average latency (us): " << latency_us << "\n";
}

struct DataBundle {
    std::unique_ptr<float[]> queries;
    std::unique_ptr<int[]> gt;
    std::unique_ptr<float[]> base;
    size_t query_n = 0;
    size_t base_n = 0;
    size_t gt_dim = 0;
    size_t d = 0;
};

static inline DataBundle LoadData() {
    DataBundle data;
    size_t gt_n = 0, query_d = 0, base_d = 0;
    const std::string data_path = ann_bench::DefaultDataPath();
    data.base = ann_bench::LoadData<float>(data_path + "DEEP100K.base.100k.fbin",
                                           data.base_n, base_d);
    data.queries = ann_bench::LoadData<float>(data_path + "DEEP100K.query.fbin",
                                              data.query_n, query_d);
    data.gt = ann_bench::LoadData<int>(data_path + "DEEP100K.gt.query.100k.top100.bin",
                                       gt_n, data.gt_dim);
    data.query_n = std::min<size_t>(data.query_n, 2000);
    data.d = query_d;
    if (base_d != query_d || data.d != 96) {
        throw std::runtime_error("FastScan expects matching DEEP100K d=96 data");
    }
    return data;
}

static inline void BuildIndex(ann_fs::FastScanIndex& index, const DataBundle& data) {
    ann_fs::train_fastscan(index, data.base.get(),
                           static_cast<int>(data.base_n), static_cast<int>(data.d));
    ann_fs::encode_fastscan(index, data.base.get());
}

static inline int RunInter(int argc, char** argv, const std::string& label,
                           InterSearchFn search) {
    const int nthreads = ParseThreads(argc, argv);
    const size_t rerank_p = ParseRerankP(argc, argv);
    const size_t k = 10;
    DataBundle data = LoadData();

    ann_fs::FastScanIndex index;
    BuildIndex(index, data);

    std::vector<SearchHeap> results;
    const auto begin = std::chrono::high_resolution_clock::now();
    search(index, data.base.get(), data.queries.get(), data.query_n,
           k, rerank_p, nthreads, results);
    const auto end = std::chrono::high_resolution_clock::now();

    const double total_us = std::chrono::duration<double, std::micro>(end - begin).count();
    const double recall = RecallAtK(results, data.gt.get(), data.query_n, data.gt_dim, k);
    PrintResult(label, nthreads, rerank_p, recall, total_us / static_cast<double>(data.query_n));
    return 0;
}

static inline int RunIntra(int argc, char** argv, const std::string& label,
                           IntraSearchFn search) {
    const int nthreads = ParseThreads(argc, argv);
    const size_t rerank_p = ParseRerankP(argc, argv);
    const size_t k = 10;
    DataBundle data = LoadData();

    ann_fs::FastScanIndex index;
    BuildIndex(index, data);

    std::vector<SearchHeap> results(data.query_n);
    const auto begin = std::chrono::high_resolution_clock::now();
    for (size_t i = 0; i < data.query_n; ++i) {
        results[i] = search(index, data.base.get(), data.queries.get() + i * data.d,
                            k, rerank_p, nthreads);
    }
    const auto end = std::chrono::high_resolution_clock::now();

    const double total_us = std::chrono::duration<double, std::micro>(end - begin).count();
    const double recall = RecallAtK(results, data.gt.get(), data.query_n, data.gt_dim, k);
    PrintResult(label, nthreads, rerank_p, recall, total_us / static_cast<double>(data.query_n));
    return 0;
}

}  // namespace ann_fastscan_main
