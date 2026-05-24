// HNSW ef sweep — Recall-Latency trade-off
// 编译: g++ tools/sweep_hnsw_ef.cc -o build/sweep_hnsw_ef.exe -O2 -mavx2 -mfma -fopenmp -lpthread -std=c++17 -I.

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

#include "simd/ann_bench_common.h"
#include "hnsw/hnsw_graph_utils.h"

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: " << argv[0] << " <ef>\n";
        return 1;
    }
    const size_t ef = static_cast<size_t>(std::atoll(argv[1]));

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

    auto holder = ann_hnsw::BuildIndex(base.get(), base_n, base_d,
                                       /*M=*/16, /*ef_c=*/120, /*ef_s=*/ef);

    std::vector<ann_hnsw::SearchHeap> results(query_n);
    const auto t1 = std::chrono::high_resolution_clock::now();
    for (size_t i = 0; i < query_n; ++i) {
        results[i] = ann_hnsw::StandardSearch(*holder.index,
                                              queries.get() + i * query_d,
                                              k, ef, 1);
    }
    const auto t2 = std::chrono::high_resolution_clock::now();
    const double us = std::chrono::duration<double, std::micro>(t2 - t1).count()
                      / static_cast<double>(query_n);

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
    std::cout << "ef=" << ef
              << ", recall=" << total_recall / static_cast<double>(query_n)
              << ", latency_us=" << us << "\n";
    return 0;
}
