// std::thread vs Pthread vs OpenMP 三方对比 (Flat inter-query)
// 编译: g++ tools/sweep_stdthread.cc -o build/sweep_stdthread.exe -O2 -fopenmp -lpthread -std=c++11 -I.

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
#include "pthread/flat_scan_pthread.h"
#include "omp/flat_scan_omp.h"
#include "pthread/flat_scan_stdthread.h"

static double run_and_measure(
    const char* label,
    const float* base, const float* queries,
    size_t base_n, size_t query_n, size_t d, size_t k,
    int nthreads,
    const int* gt, size_t gt_dim)
{
    std::vector<std::priority_queue<std::pair<float, uint32_t>>> results;

    const auto t1 = std::chrono::high_resolution_clock::now();

    float* base_nc = const_cast<float*>(base);
    float* queries_nc = const_cast<float*>(queries);

    if (std::string(label).find("stdthread") != std::string::npos) {
        ann_stdthread::search_inter_dynamic(base, queries, base_n, query_n, d, k, nthreads, results);
    } else if (std::string(label).find("pthread") != std::string::npos) {
        flat_search_inter_dynamic(base_nc, queries_nc, base_n, query_n, d, k, nthreads, results);
    } else {
        flat_search_inter_omp(base_nc, queries_nc, base_n, query_n, d, k, nthreads, results);
    }

    const auto t2 = std::chrono::high_resolution_clock::now();
    const double us = std::chrono::duration<double, std::micro>(t2 - t1).count() / query_n;

    double total_recall = 0.0;
    for (size_t i = 0; i < query_n; ++i) {
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j)
            gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
        size_t hits = 0;
        auto& h = results[i];
        while (!h.empty()) { if (gtset.count(h.top().second)) ++hits; h.pop(); }
        total_recall += static_cast<double>(hits) / k;
    }

    std::cout << std::fixed << std::setprecision(5);
    std::cout << label << ",threads=" << nthreads
              << ",recall=" << total_recall / query_n
              << ",latency_us=" << us << "\n";
    return us;
}

int main(int argc, char** argv) {
    int nthreads = argc > 1 ? std::atoi(argv[1]) : 16;
    const size_t k = 10;

    size_t query_n = 0, query_d = 0, gt_n = 0, gt_dim = 0, base_n = 0, base_d = 0;
    const std::string dp = ann_bench::DefaultDataPath();
    auto queries = ann_bench::LoadData<float>(dp + "DEEP100K.query.fbin", query_n, query_d);
    auto gt = ann_bench::LoadData<int>(dp + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    auto base = ann_bench::LoadData<float>(dp + "DEEP100K.base.100k.fbin", base_n, base_d);
    query_n = std::min<size_t>(query_n, 2000);

    run_and_measure("flat_stdthread_inter", base.get(), queries.get(),
                    base_n, query_n, query_d, k, nthreads, gt.get(), gt_dim);
    run_and_measure("flat_pthread_dynamic_inter", base.get(), queries.get(),
                    base_n, query_n, query_d, k, nthreads, gt.get(), gt_dim);
    run_and_measure("flat_omp_inter", base.get(), queries.get(),
                    base_n, query_n, query_d, k, nthreads, gt.get(), gt_dim);
    return 0;
}
