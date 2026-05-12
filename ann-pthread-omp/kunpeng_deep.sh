#!/bin/bash
# 鲲鹏 920 深度实验一键脚本
# 用法: bash kunpeng_deep.sh
# 前提: 已运行 bash run_all_kunpeng_part1.sh && bash run_all_kunpeng_part2.sh
# 输出: results/kunpeng/ 下各实验结果文件

set -e
R="results/kunpeng"
mkdir -p "$R" build

echo "=========================================="
echo "  鲲鹏 920 深度实验"
echo "=========================================="

# --------------------------------------------------
# 1. OMP schedule × chunk_size sweep (Flat inter-query, t=16)
# --------------------------------------------------
echo ""
echo "[1/4] OMP schedule × chunk_size sweep ..."
cat > /tmp/sweep_sched.cc << 'ENDOFFILE'
#include <chrono>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <queue>
#include <string>
#include <vector>
#include <omp.h>
#include "../simd/ann_bench_common.h"
#include "../omp/flat_scan_omp.h"

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: " << argv[0] << " <nthreads>\n"; return 1; }
    const int nthreads = std::atoi(argv[1]);
    const size_t k = 10;
    size_t query_n = 0, query_d = 0, gt_n = 0, gt_dim = 0, base_n = 0, base_d = 0;
    const std::string dp = ann_bench::DefaultDataPath();
    auto queries = ann_bench::LoadData<float>(dp + "DEEP100K.query.fbin", query_n, query_d);
    auto gt = ann_bench::LoadData<int>(dp + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    auto base = ann_bench::LoadData<float>(dp + "DEEP100K.base.100k.fbin", base_n, base_d);
    query_n = std::min<size_t>(query_n, 2000);

    std::vector<std::priority_queue<std::pair<float, uint32_t>>> results(query_n);
    const auto t1 = std::chrono::high_resolution_clock::now();
    #pragma omp parallel for num_threads(nthreads) schedule(runtime)
    for (long long i = 0; i < static_cast<long long>(query_n); ++i) {
        results[static_cast<size_t>(i)] = flat_search(
            base.get(), queries.get() + static_cast<size_t>(i) * query_d,
            base_n, query_d, k);
    }
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
    const char* sched = std::getenv("OMP_SCHEDULE");
    std::cout << std::fixed << std::setprecision(5);
    std::cout << "flat,schedule=" << (sched ? sched : "default")
              << ",threads=" << nthreads
              << ",recall=" << total_recall / query_n
              << ",latency_us=" << us << "\n";
    return 0;
}
ENDOFFILE
cp /tmp/sweep_sched.cc tools/sweep_sched_arm.cc
g++ tools/sweep_sched_arm.cc -o build/sweep_sched_arm.exe -O2 -fopenmp -lpthread -std=c++11 -I.
for sched in "static" "static,1" "static,8" "static,64" "static,256" \
             "dynamic,1" "dynamic,8" "dynamic,64" "dynamic,256" \
             "guided,1" "guided,8" "guided,64"; do
    OMP_SCHEDULE="$sched" ./build/sweep_sched_arm.exe 16 >> "$R/omp_schedule_sweep.txt"
done
echo "  -> $R/omp_schedule_sweep.txt"

# --------------------------------------------------
# 2. N × T 交叉表 (Flat inter-query, OMP schedule(static))
# --------------------------------------------------
echo ""
echo "[2/4] N × T cross-table ..."
cat > /tmp/sweep_nt.cc << 'ENDOFFILE'
#include <chrono>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <queue>
#include <string>
#include <vector>
#include <omp.h>
#include "../simd/ann_bench_common.h"
#include "../omp/flat_scan_omp.h"

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: " << argv[0] << " <N> <T>\n"; return 1; }
    const size_t N = static_cast<size_t>(std::atoll(argv[1]));
    const int T = std::atoi(argv[2]);
    const size_t k = 10;
    size_t query_n = 0, query_d = 0, gt_n = 0, gt_dim = 0, base_n = 0, base_d = 0;
    const std::string dp = ann_bench::DefaultDataPath();
    auto queries = ann_bench::LoadData<float>(dp + "DEEP100K.query.fbin", query_n, query_d);
    auto gt = ann_bench::LoadData<int>(dp + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    auto base = ann_bench::LoadData<float>(dp + "DEEP100K.base.100k.fbin", base_n, base_d);
    query_n = std::min<size_t>(query_n, 2000);
    const size_t use_n = std::min(N, base_n);

    std::vector<std::priority_queue<std::pair<float, uint32_t>>> results(query_n);
    const auto t1 = std::chrono::high_resolution_clock::now();
    #pragma omp parallel for num_threads(T) schedule(static)
    for (long long i = 0; i < static_cast<long long>(query_n); ++i) {
        results[static_cast<size_t>(i)] = flat_search(
            base.get(), queries.get() + static_cast<size_t>(i) * query_d,
            use_n, query_d, k);
    }
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
    std::cout << "flat,N=" << N << ",T=" << T
              << ",recall=" << total_recall / query_n
              << ",latency_us=" << us << "\n";
    return 0;
}
ENDOFFILE
cp /tmp/sweep_nt.cc tools/sweep_nt_arm.cc
g++ tools/sweep_nt_arm.cc -o build/sweep_nt_arm.exe -O2 -fopenmp -lpthread -std=c++11 -I.
for N in 10000 50000 100000; do
    for T in 1 2 4 8 16; do
        ./build/sweep_nt_arm.exe $N $T >> "$R/n_t_sweep.txt"
    done
done
echo "  -> $R/n_t_sweep.txt"

# --------------------------------------------------
# 3. HNSW ef sweep (单线程)
# --------------------------------------------------
echo ""
echo "[3/4] HNSW ef sweep ..."
cat > /tmp/sweep_hnsw.cc << 'ENDOFFILE'
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
#include "hnsw/hnsw_graph_utils.h"

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: " << argv[0] << " <ef>\n"; return 1; }
    const size_t ef = static_cast<size_t>(std::atoll(argv[1]));
    const size_t k = 10;
    size_t query_n = 0, query_d = 0, gt_n = 0, gt_dim = 0, base_n = 0, base_d = 0;
    const std::string dp = ann_bench::DefaultDataPath();
    auto queries = ann_bench::LoadData<float>(dp + "DEEP100K.query.fbin", query_n, query_d);
    auto gt = ann_bench::LoadData<int>(dp + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    auto base = ann_bench::LoadData<float>(dp + "DEEP100K.base.100k.fbin", base_n, base_d);
    query_n = std::min<size_t>(query_n, 2000);

    auto holder = ann_hnsw::BuildIndex(base.get(), base_n, base_d, 16, 120, ef);

    std::vector<ann_hnsw::SearchHeap> results(query_n);
    const auto t1 = std::chrono::high_resolution_clock::now();
    for (size_t i = 0; i < query_n; ++i) {
        results[i] = ann_hnsw::StandardSearch(*holder.index, queries.get() + i * query_d, k, ef, 1);
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
    std::cout << "hnsw,ef=" << ef
              << ",recall=" << total_recall / query_n
              << ",latency_us=" << us << "\n";
    return 0;
}
ENDOFFILE
cp /tmp/sweep_hnsw.cc tools/sweep_hnsw_arm.cc
g++ tools/sweep_hnsw_arm.cc -o build/sweep_hnsw_arm.exe -O2 -fopenmp -lpthread -std=c++11 -I.
for ef in 10 25 50 100 200 400; do
    ./build/sweep_hnsw_arm.exe $ef >> "$R/hnsw_ef_sweep.txt"
done
echo "  -> $R/hnsw_ef_sweep.txt"

# --------------------------------------------------
# 4. 虚假共享对照实验
# --------------------------------------------------
echo ""
echo "[4/4] False sharing demo ..."
g++ tools/false_sharing_demo.cc -o build/false_sharing_demo_arm.exe -O2 -fopenmp -lpthread -std=c++11
for T in 2 4 8; do
    ./build/false_sharing_demo_arm.exe $T 30000000 >> "$R/false_sharing.txt"
done
echo "  -> $R/false_sharing.txt"

# --------------------------------------------------
# 清理临时文件
# --------------------------------------------------
rm -f tools/sweep_sched_arm.cc tools/sweep_nt_arm.cc tools/sweep_hnsw_arm.cc

echo ""
echo "=========================================="
echo "  鲲鹏深度实验完成！"
echo "=========================================="
echo ""
echo "请将以下文件拷贝回本地:"
echo "  $R/omp_schedule_sweep.txt"
echo "  $R/n_t_sweep.txt"
echo "  $R/hnsw_ef_sweep.txt"
echo "  $R/false_sharing.txt"
echo ""
echo "以及之前的:"
echo "  $R/sysinfo.txt"
echo "  $R/ivf_nlist_sweep.txt"
