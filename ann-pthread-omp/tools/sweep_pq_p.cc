// PQ p-sweep: fixed pthread_dynamic_inter, t=16, sweep p
// 编译: g++ tools/sweep_pq_p.cc -o build/sweep_pq_p.exe -O2 -mavx2 -mfma -fopenmp -lpthread -std=c++11 -I.

#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <queue>
#include <set>
#include <string>
#include <vector>

#include "simd/ann_bench_common.h"
#include "simd/pq_scan_avx2.h"
#include "pthread/pq_scan_pthread.h"

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: " << argv[0] << " <p>\n"; return 1; }
    const size_t p = static_cast<size_t>(std::atoll(argv[1]));
    const int nthreads = 16;
    const size_t k = 10;

    size_t query_n = 0, query_d = 0, gt_n = 0, gt_dim = 0, base_n = 0, base_d = 0;
    const std::string dp = ann_bench::DefaultDataPath();
    auto queries = ann_bench::LoadData<float>(dp + "DEEP100K.query.fbin", query_n, query_d);
    auto gt = ann_bench::LoadData<int>(dp + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    auto base = ann_bench::LoadData<float>(dp + "DEEP100K.base.100k.fbin", base_n, base_d);
    query_n = std::min<size_t>(query_n, 2000);

    PQIndex pq;
    pq.build(base.get(), base_n, base_d, 8, 256, 8);

    std::vector<std::priority_queue<std::pair<float, uint32_t>>> results;
    const auto t1 = std::chrono::high_resolution_clock::now();
    pq_search_inter_dynamic(base.get(), queries.get(), base_n, query_n,
                            base_d, k, pq, p, nthreads, results);
    const auto t2 = std::chrono::high_resolution_clock::now();
    const double us = std::chrono::duration<double, std::micro>(t2 - t1).count() / query_n;

    double total_recall = 0.0;
    for (size_t i = 0; i < query_n; ++i) {
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
        size_t hits = 0;
        auto& h = results[i];
        while (!h.empty()) { if (gtset.count(h.top().second)) ++hits; h.pop(); }
        total_recall += static_cast<double>(hits) / k;
    }
    std::cout << std::fixed << std::setprecision(5);
    std::cout << "pq,p=" << p << ",recall=" << total_recall / query_n << ",latency_us=" << us << "\n";
    return 0;
}
