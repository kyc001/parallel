// Flat scan SYCL 实现 — 与 Pthread/OpenMP/std::thread 对比
// 编译 (Intel oneAPI): icpx -fsycl -O2 -std=c++17 -I. tools/flat_scan_sycl.cpp -o build/flat_scan_sycl.exe
// 运行: build/flat_scan_sycl.exe [threads]

#include <CL/sycl.hpp>
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

// top-k 辅助 (host side)
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

    // 选择设备: 优先 GPU, 回退 CPU
    sycl::queue q;
    try {
        q = sycl::queue{sycl::gpu_selector_v};
        std::cout << "SYCL device: " << q.get_device().get_info<sycl::info::device::name>() << "\n";
    } catch (...) {
        q = sycl::queue{sycl::cpu_selector_v};
        std::cout << "SYCL device (fallback CPU): " << q.get_device().get_info<sycl::info::device::name>() << "\n";
    }

    // 设备内存分配
    auto* d_base = sycl::malloc_device<float>((size_t)bn * d, q);
    auto* d_queries = sycl::malloc_device<float>((size_t)qn * d, q);
    auto* d_dist = sycl::malloc_device<float>((size_t)qn * bn, q);

    // 传输 base + queries 到设备
    q.memcpy(d_base, base.get(), (size_t)bn * d * sizeof(float)).wait();
    q.memcpy(d_queries, queries.get(), (size_t)qn * d * sizeof(float)).wait();

    // 计时
    q.wait();
    auto t1 = std::chrono::high_resolution_clock::now();

    // SYCL kernel: 每个 work-item 计算一个 (query, base) 的内积距离
    q.parallel_for(sycl::range<2>((size_t)qn, (size_t)bn),
        [=](sycl::id<2> idx) {
            int qi = (int)idx[0];
            int bi = (int)idx[1];
            float sum = 0.0f;
            const float* b = d_base + (size_t)bi * d;
            const float* qu = d_queries + (size_t)qi * d;
            for (int j = 0; j < d; ++j) {
                sum += b[j] * qu[j];
            }
            d_dist[(size_t)qi * bn + bi] = sum;
        }
    ).wait();

    auto t2 = std::chrono::high_resolution_clock::now();
    double kernel_us = std::chrono::duration<double, std::micro>(t2 - t1).count();

    // 取回距离
    std::vector<float> host_dist((size_t)qn * bn);
    q.memcpy(host_dist.data(), d_dist, (size_t)qn * bn * sizeof(float)).wait();

    // CPU 侧 top-k + recall
    double total_recall = 0.0;
    for (int i = 0; i < qn; ++i) {
        Heap heap;
        const float* row = host_dist.data() + (size_t)i * bn;
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
    std::cout << "flat_sycl, recall=" << total_recall / qn
              << ", latency_us=" << total_us / qn << "\n";
    std::cout << "kernel_only_us=" << kernel_us / qn << "\n";

    sycl::free(d_base, q);
    sycl::free(d_queries, q);
    sycl::free(d_dist, q);
    return 0;
}
