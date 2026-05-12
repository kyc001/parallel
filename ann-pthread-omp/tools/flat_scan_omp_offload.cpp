// Flat scan OpenMP offload 实现 — 与 Pthread/SYCL/std::thread 对比
// 编译 (Intel oneAPI): icpx -fiopenmp -fopenmp-targets=spir64 -O2 -std=c++17 -I. tools/flat_scan_omp_offload.cpp -o build/flat_scan_omp_offload.exe
// 编译 (fallback CPU): icpx -fiopenmp -O2 -std=c++17 -I. tools/flat_scan_omp_offload.cpp -o build/flat_scan_omp_offload.exe
// 运行: build/flat_scan_omp_offload.exe [threads]

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

using Heap = std::priority_queue<std::pair<float, uint32_t>>;
static inline void push_h(Heap& h, float v, uint32_t id, size_t k) {
    if (h.size() < k) h.push({v, id});
    else if (v < h.top().first) { h.pop(); h.push({v, id}); }
}

int main(int argc, char** argv) {
    const size_t k = 10;
    size_t query_n = 0, query_d = 0, gt_n = 0, gt_dim = 0, base_n = 0, base_d = 0;
    const std::string dp = ann_bench::DefaultDataPath();
    auto queries = ann_bench::LoadData<float>(dp + "DEEP100K.query.fbin", query_n, query_d);
    auto gt = ann_bench::LoadData<int>(dp + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    auto base = ann_bench::LoadData<float>(dp + "DEEP100K.base.100k.fbin", base_n, base_d);
    query_n = std::min<size_t>(query_n, 2000);

    const int bn = (int)base_n, qn = (int)query_n, d = (int)query_d;

    // 距离矩阵 (host pinned memory for faster transfers)
    std::vector<float> dist((size_t)qn * bn);

    // 检测 offload 设备
    #pragma omp target map(from: dist[0:0])
    {
        // 空 kernel 触发设备初始化
    }
    int dev_id = omp_get_default_device();
    std::cout << "OpenMP offload device: " << dev_id
              << " (" << omp_get_device_type_name(omp_get_device_type()) << ")\n";

    // 计时
    auto t1 = std::chrono::high_resolution_clock::now();

    // OpenMP target offload: 计算所有 (query, base) 的内积距离
    const float* base_ptr = base.get();
    const float* query_ptr = queries.get();

    #pragma omp target data map(to: base_ptr[0:(size_t)bn*d], query_ptr[0:(size_t)qn*d]) \
                            map(from: dist[0:(size_t)qn*bn])
    {
        #pragma omp target teams distribute parallel for collapse(2) \
                schedule(static) thread_limit(256)
        for (int qi = 0; qi < qn; ++qi) {
            for (int bi = 0; bi < bn; ++bi) {
                float sum = 0.0f;
                const float* b = base_ptr + (size_t)bi * d;
                const float* q = query_ptr + (size_t)qi * d;
                for (int j = 0; j < d; ++j) {
                    sum += b[j] * q[j];
                }
                dist[(size_t)qi * bn + bi] = sum;
            }
        }
    }

    auto t2 = std::chrono::high_resolution_clock::now();
    double compute_us = std::chrono::duration<double, std::micro>(t2 - t1).count();

    // CPU 侧 top-k + recall
    double total_recall = 0.0;
    for (int i = 0; i < qn; ++i) {
        Heap heap;
        const float* row = dist.data() + (size_t)i * bn;
        for (int j = 0; j < bn; ++j) push_h(heap, row[j], (uint32_t)j, k);
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) gtset.insert((uint32_t)gt[(size_t)i * gt_dim + j]);
        size_t hits = 0;
        while (!heap.empty()) { if (gtset.count(heap.top().second)) ++hits; heap.pop(); }
        total_recall += (double)hits / k;
    }

    auto t3 = std::chrono::high_resolution_clock::now();
    double total_us = std::chrono::duration<double, std::micro>(t3 - t1).count();

    std::cout << std::fixed << std::setprecision(5);
    std::cout << "flat_omp_offload, recall=" << total_recall / qn
              << ", latency_us=" << total_us / qn << "\n";
    std::cout << "compute_only_us=" << compute_us / qn << "\n";

    return 0;
}
