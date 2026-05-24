// IVF nlist sweep: fixed pthread_pool_inter, t=16, nprobe=nlist/4, sweep nlist
// 编译: g++ tools/sweep_ivf_nlist.cc -o build/sweep_ivf_nlist.exe -O2 -mavx2 -mfma -fopenmp -lpthread -std=c++11 -I.

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
#include "ivf/ivf_index.h"
#include "ivf/ivf_scan_pthread.h"

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: " << argv[0] << " <nlist>\n"; return 1; }
    const size_t nlist = static_cast<size_t>(std::atoll(argv[1]));
    const size_t nprobe = std::max<size_t>(1, nlist / 4);
    const int nthreads = 16;
    const size_t k = 10;

    size_t query_n = 0, query_d = 0, gt_n = 0, gt_dim = 0, base_n = 0, base_d = 0;
    const std::string dp = ann_bench::DefaultDataPath();
    auto queries = ann_bench::LoadData<float>(dp + "DEEP100K.query.fbin", query_n, query_d);
    auto gt = ann_bench::LoadData<int>(dp + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    auto base = ann_bench::LoadData<float>(dp + "DEEP100K.base.100k.fbin", base_n, base_d);
    query_n = std::min<size_t>(query_n, 2000);

    ann_ivf::IVFIndex idx;
    idx.build(base.get(), base_n, base_d, nlist, 8);

    std::vector<ann_ivf::SearchHeap> results;
    const auto t1 = std::chrono::high_resolution_clock::now();
    ivf_search_inter_pool(idx, queries.get(), query_n, k, nprobe, nthreads, results);
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
    std::cout << "ivf,nlist=" << nlist << ",nprobe=" << nprobe
              << ",recall=" << total_recall / query_n << ",latency_us=" << us << "\n";
    return 0;
}
