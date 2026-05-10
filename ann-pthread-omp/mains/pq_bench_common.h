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

namespace ann_pq_main {

using SearchHeap = std::priority_queue<std::pair<float, uint32_t>>;
using InterSearchFn = void (*)(float*, float*, size_t, size_t, size_t, size_t,
                               const PQIndex&, size_t, int,
                               std::vector<SearchHeap>&);
using IntraSearchFn = SearchHeap (*)(float*, float*, size_t, size_t, size_t,
                                     const PQIndex&, size_t, int);

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
    return 100;
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
        SearchHeap& heap = results[i];
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
                               size_t rerank_p, double recall,
                               double latency_us) {
    std::cout << std::fixed << std::setprecision(5);
    std::cout << label << ", nthreads=" << nthreads
              << ", p=" << rerank_p << "\n";
    std::cout << "average recall: " << recall << "\n";
    std::cout << "average latency (us): " << latency_us << "\n";
}

static inline void BuildIndex(PQIndex& pq_index, const float* base,
                              size_t base_n, size_t d) {
    pq_index.build(base, base_n, d, 8, 256, 20);
}

static inline int RunInter(int argc, char** argv, const std::string& label,
                           InterSearchFn search) {
    const int nthreads = ParseThreads(argc, argv);
    size_t rerank_p = ParseRerankP(argc, argv);
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
    rerank_p = std::min(rerank_p, base_n);

    if (base_d != query_d) {
        std::cerr << "dimension mismatch: base_d=" << base_d
                  << " query_d=" << query_d << "\n";
        return 2;
    }

    PQIndex pq_index;
    BuildIndex(pq_index, base.get(), base_n, base_d);

    std::vector<SearchHeap> results;
    const auto begin = std::chrono::high_resolution_clock::now();
    search(base.get(), queries.get(), base_n, query_n, query_d, k,
           pq_index, rerank_p, nthreads, results);
    const auto end = std::chrono::high_resolution_clock::now();

    const double total_us =
        std::chrono::duration<double, std::micro>(end - begin).count();
    const double recall = RecallAtK(results, gt.get(), query_n, gt_dim, k);
    PrintResult(label, nthreads, rerank_p, recall,
                total_us / static_cast<double>(query_n));
    return 0;
}

static inline int RunIntra(int argc, char** argv, const std::string& label,
                           IntraSearchFn search) {
    const int nthreads = ParseThreads(argc, argv);
    size_t rerank_p = ParseRerankP(argc, argv);
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
    rerank_p = std::min(rerank_p, base_n);

    if (base_d != query_d) {
        std::cerr << "dimension mismatch: base_d=" << base_d
                  << " query_d=" << query_d << "\n";
        return 2;
    }

    PQIndex pq_index;
    BuildIndex(pq_index, base.get(), base_n, base_d);

    std::vector<SearchHeap> results(query_n);
    const auto begin = std::chrono::high_resolution_clock::now();
    for (size_t i = 0; i < query_n; ++i) {
        results[i] = search(base.get(), queries.get() + i * query_d,
                            base_n, query_d, k, pq_index, rerank_p, nthreads);
    }
    const auto end = std::chrono::high_resolution_clock::now();

    const double total_us =
        std::chrono::duration<double, std::micro>(end - begin).count();
    const double recall = RecallAtK(results, gt.get(), query_n, gt_dim, k);
    PrintResult(label, nthreads, rerank_p, recall,
                total_us / static_cast<double>(query_n));
    return 0;
}

}  // namespace ann_pq_main
