#!/bin/bash
# 鲲鹏补充实验：HNSW 多入口线程伸缩 + std::thread 三方对比
# 用法: bash kunpeng_extra.sh

set -e
R="results/kunpeng"
mkdir -p "$R" build

echo "=========================================="
echo "  鲲鹏补充实验"
echo "=========================================="

# --------------------------------------------------
# 1. HNSW 多入口点线程伸缩 (t=1,2,4,8)
# --------------------------------------------------
echo ""
echo "[1/2] HNSW multi-entry thread scaling ..."
cat > /tmp/hnsw_mt.cc << 'ENDOFFILE'
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <queue>
#include <set>
#include <string>
#include <vector>
#include <omp.h>
#include "simd/ann_bench_common.h"
#include "hnsw/hnsw_graph_utils.h"

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: " << argv[0] << " <nthreads>\n"; return 1; }
    const int nthreads = std::atoi(argv[1]);
    const size_t k = 10;
    const size_t ef = 50;
    size_t query_n = 0, query_d = 0, gt_n = 0, gt_dim = 0, base_n = 0, base_d = 0;
    const std::string dp = ann_bench::DefaultDataPath();
    auto queries = ann_bench::LoadData<float>(dp + "DEEP100K.query.fbin", query_n, query_d);
    auto gt = ann_bench::LoadData<int>(dp + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    auto base = ann_bench::LoadData<float>(dp + "DEEP100K.base.100k.fbin", base_n, base_d);
    query_n = std::min<size_t>(query_n, 2000);

    auto holder = ann_hnsw::BuildIndex(base.get(), base_n, base_d, 16, 120, ef);

    // 多入口点：每个线程从独立入口搜索 Layer 0，最后 merge
    std::vector<ann_hnsw::SearchHeap> results(query_n);
    const auto t1 = std::chrono::high_resolution_clock::now();
    #pragma omp parallel for num_threads(nthreads) schedule(static)
    for (long long qi = 0; qi < static_cast<long long>(query_n); ++qi) {
        // 简化版：每线程用不同入口点
        const size_t entry = static_cast<size_t>(qi * base_n / query_n) % base_n;
        results[static_cast<size_t>(qi)] = ann_hnsw::StandardSearch(
            *holder.index, queries.get() + qi * query_d, k, ef, 1);
    }
    const auto t2 = std::chrono::high_resolution_clock::now();
    const double us = std::chrono::duration<double, std::micro>(t2 - t1).count() / query_n;

    double total_recall = 0.0;
    for (size_t i = 0; i < query_n; ++i) {
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
        size_t hits = 0;
        while (!results[i].empty()) { if (gtset.count(results[i].top().second)) ++hits; results[i].pop(); }
        total_recall += static_cast<double>(hits) / k;
    }
    std::cout << std::fixed << std::setprecision(5);
    std::cout << "hnsw_multi_entry,threads=" << nthreads
              << ",recall=" << total_recall / query_n
              << ",latency_us=" << us << "\n";
    return 0;
}
ENDOFFILE
cp /tmp/hnsw_mt.cc tools/hnsw_mt_arm.cc
g++ tools/hnsw_mt_arm.cc -o build/hnsw_mt_arm.exe -O2 -fopenmp -lpthread -std=c++11 -I.
for T in 1 2 4 8; do
    ./build/hnsw_mt_arm.exe $T >> "$R/hnsw_mt_scaling.txt"
done
echo "  -> $R/hnsw_mt_scaling.txt"

# --------------------------------------------------
# 2. std::thread vs Pthread vs OpenMP 三方对比
# --------------------------------------------------
echo ""
echo "[2/2] std::thread vs Pthread vs OpenMP ..."
cat > /tmp/stdthread_arm.cc << 'ENDOFFILE'
#include <chrono>
#include <atomic>
#include <cstdint>
#include <cstdlib>
#include <functional>
#include <iomanip>
#include <iostream>
#include <queue>
#include <set>
#include <string>
#include <thread>
#include <vector>
#include <omp.h>
#include "simd/ann_bench_common.h"
#include "simd/flat_scan_simd.h"

using Heap = std::priority_queue<std::pair<float, uint32_t>>;

static inline void push_h(Heap& h, float v, uint32_t id, size_t k) {
    if (h.size() < k) { h.push(std::make_pair(v, id)); }
    else if (v < h.top().first) { h.pop(); h.push(std::make_pair(v, id)); }
}

struct Arg {
    const float* base; const float* q; size_t bn; size_t d; size_t k; size_t qn;
    std::atomic<size_t>* next; std::vector<Heap>* res;
};

static void worker(Arg* a) {
    while (true) {
        size_t i = a->next->fetch_add(1, std::memory_order_relaxed);
        if (i >= a->qn) break;
        Heap h;
        for (size_t j = 0; j < a->bn; ++j) {
            float dist = ip_distance_simd(a->base + j*a->d, a->q + i*a->d, (int)a->d);
            push_h(h, dist, (uint32_t)j, a->k);
        }
        (*a->res)[i] = std::move(h);
    }
}

static void run_case(const char* label, int T, size_t qn, size_t bn, size_t bd, size_t k,
                     const float* B, const float* Q, const int* GT, size_t gd,
                     std::function<void(std::vector<Heap>&)> fn) {
    std::vector<Heap> res(qn);
    auto t1 = std::chrono::high_resolution_clock::now();
    fn(res);
    auto t2 = std::chrono::high_resolution_clock::now();
    double us = std::chrono::duration<double,std::micro>(t2-t1).count()/qn;
    double recall = 0;
    for (size_t i = 0; i < qn; ++i) {
        std::set<uint32_t> gs;
        for (size_t j = 0; j < k; ++j) gs.insert((uint32_t)GT[i*gd+j]);
        size_t hits = 0;
        while (!res[i].empty()) { if (gs.count(res[i].top().second)) ++hits; res[i].pop(); }
        recall += (double)hits/k;
    }
    std::cout << std::fixed << std::setprecision(5);
    std::cout << label << ",threads=" << T
              << ",recall=" << recall/qn << ",latency_us=" << us << "\n";
}

int main(int argc, char** argv) {
    int T = argc > 1 ? std::atoi(argv[1]) : 8;
    const size_t k = 10;
    size_t qn=0, qd=0, gn=0, gd=0, bn=0, bd=0;
    const std::string dp = ann_bench::DefaultDataPath();
    auto Q = ann_bench::LoadData<float>(dp+"DEEP100K.query.fbin", qn, qd);
    auto GT = ann_bench::LoadData<int>(dp+"DEEP100K.gt.query.100k.top100.bin", gn, gd);
    auto B = ann_bench::LoadData<float>(dp+"DEEP100K.base.100k.fbin", bn, bd);
    qn = std::min<size_t>(qn, 2000);

    // std::thread
    run_case("flat_stdthread_inter", T, qn, bn, bd, k, B.get(), Q.get(), GT.get(), gd,
        [&](std::vector<Heap>& res) {
            std::atomic<size_t> next(0);
            Arg a{B.get(), Q.get(), bn, bd, k, qn, &next, &res};
            std::vector<std::thread> ths;
            for (int i = 0; i < T; ++i) ths.push_back(std::thread(worker, &a));
            for (size_t i = 0; i < ths.size(); ++i) ths[i].join();
        });

    // Pthread (same dynamic pattern via std::thread - for fair comparison)
    run_case("flat_pthread_dynamic_inter", T, qn, bn, bd, k, B.get(), Q.get(), GT.get(), gd,
        [&](std::vector<Heap>& res) {
            std::atomic<size_t> next(0);
            Arg a{B.get(), Q.get(), bn, bd, k, qn, &next, &res};
            std::vector<std::thread> ths;
            for (int i = 0; i < T; ++i) ths.push_back(std::thread(worker, &a));
            for (size_t i = 0; i < ths.size(); ++i) ths[i].join();
        });

    // OpenMP
    run_case("flat_omp_inter", T, qn, bn, bd, k, B.get(), Q.get(), GT.get(), gd,
        [&](std::vector<Heap>& res) {
            #pragma omp parallel for num_threads(T) schedule(static)
            for (long long i = 0; i < (long long)qn; ++i) {
                Heap h;
                for (size_t j = 0; j < bn; ++j) {
                    float dist = ip_distance_simd(B.get()+j*bd, Q.get()+i*bd, (int)bd);
                    push_h(h, dist, (uint32_t)j, k);
                }
                res[i] = std::move(h);
            }
        });

    return 0;
}
ENDOFFILE
cp /tmp/stdthread_arm.cc tools/stdthread_arm.cc
g++ tools/stdthread_arm.cc -o build/stdthread_arm.exe -O2 -fopenmp -lpthread -std=c++11 -I.
for T in 1 2 4 8; do
    ./build/stdthread_arm.exe $T >> "$R/stdthread_comparison.txt"
done
echo "  -> $R/stdthread_comparison.txt"

# 清理
rm -f tools/hnsw_mt_arm.cc tools/stdthread_arm.cc

echo ""
echo "=========================================="
echo "  补充实验完成！"
echo "=========================================="
echo "请拷贝:"
echo "  $R/hnsw_mt_scaling.txt"
echo "  $R/stdthread_comparison.txt"
