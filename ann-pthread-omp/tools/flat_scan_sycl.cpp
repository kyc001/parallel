// Flat scan SYCL implementation - for comparison with Pthread/OpenMP/std::thread
// Build (Intel oneAPI): icpx -fsycl -O2 -std=c++17 -I. tools/flat_scan_sycl.cpp -o build/flat_scan_sycl.exe
// Run: build/flat_scan_sycl.exe

#if __has_include(<sycl/sycl.hpp>)
#include <sycl/sycl.hpp>
namespace syclx = sycl;
#elif __has_include(<CL/sycl.hpp>)
#include <CL/sycl.hpp>
namespace syclx = sycl;
#else
#error "No SYCL header found. Install Intel oneAPI DPC++ or another SYCL compiler/runtime."
#endif

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
    if (h.size() < k) {
        h.push({v, id});
    } else if (v < h.top().first) {
        h.pop();
        h.push({v, id});
    }
}

int main(int argc, char** argv) {
    (void)argc;
    (void)argv;

    const size_t k = 10;
    size_t query_n = 0, query_d = 0, gt_n = 0, gt_dim = 0, base_n = 0, base_d = 0;
    const std::string dp = ann_bench::DefaultDataPath();
    auto queries = ann_bench::LoadData<float>(dp + "DEEP100K.query.fbin", query_n, query_d);
    auto gt = ann_bench::LoadData<int>(dp + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    auto base = ann_bench::LoadData<float>(dp + "DEEP100K.base.100k.fbin", base_n, base_d);
    query_n = std::min<size_t>(query_n, 2000);

    const int bn = static_cast<int>(base_n);
    const int qn = static_cast<int>(query_n);
    const int d = static_cast<int>(query_d);

    syclx::queue q;
    try {
        q = syclx::queue{syclx::gpu_selector_v};
    } catch (...) {
        q = syclx::queue{syclx::cpu_selector_v};
    }
    std::cout << "SYCL device: "
              << q.get_device().get_info<syclx::info::device::name>() << "\n";

    auto* d_base = syclx::malloc_device<float>((size_t)bn * d, q);
    auto* d_queries = syclx::malloc_device<float>((size_t)qn * d, q);
    auto* d_dist = syclx::malloc_device<float>((size_t)qn * bn, q);
    q.memcpy(d_base, base.get(), (size_t)bn * d * sizeof(float)).wait();
    q.memcpy(d_queries, queries.get(), (size_t)qn * d * sizeof(float)).wait();

    q.wait();
    auto t1 = std::chrono::high_resolution_clock::now();

    q.parallel_for(syclx::range<2>((size_t)qn, (size_t)bn),
                   [=](syclx::id<2> idx) {
                       int qi = static_cast<int>(idx[0]);
                       int bi = static_cast<int>(idx[1]);
                       float sum = 0.0f;
                       const float* b = d_base + (size_t)bi * d;
                       const float* qu = d_queries + (size_t)qi * d;
                       for (int j = 0; j < d; ++j) {
                           sum += b[j] * qu[j];
                       }
                       d_dist[(size_t)qi * bn + bi] = 1.0f - sum;
                   }).wait();

    auto t2 = std::chrono::high_resolution_clock::now();
    double kernel_us = std::chrono::duration<double, std::micro>(t2 - t1).count();

    std::vector<float> host_dist((size_t)qn * bn);
    q.memcpy(host_dist.data(), d_dist, (size_t)qn * bn * sizeof(float)).wait();

    double total_recall = 0.0;
    for (int i = 0; i < qn; ++i) {
        Heap heap;
        const float* row = host_dist.data() + (size_t)i * bn;
        for (int j = 0; j < bn; ++j) {
            push_h(heap, row[j], (uint32_t)j, k);
        }
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) {
            gtset.insert((uint32_t)gt[(size_t)i * gt_dim + j]);
        }
        size_t hits = 0;
        while (!heap.empty()) {
            if (gtset.count(heap.top().second)) {
                ++hits;
            }
            heap.pop();
        }
        total_recall += (double)hits / k;
    }

    auto t3 = std::chrono::high_resolution_clock::now();
    double total_us = std::chrono::duration<double, std::micro>(t3 - t1).count();

    std::cout << std::fixed << std::setprecision(5);
    std::cout << "flat_sycl, recall=" << total_recall / qn
              << ", latency_us=" << total_us / qn << "\n";
    std::cout << "kernel_only_us=" << kernel_us / qn << "\n";

    syclx::free(d_base, q);
    syclx::free(d_queries, q);
    syclx::free(d_dist, q);
    return 0;
}
