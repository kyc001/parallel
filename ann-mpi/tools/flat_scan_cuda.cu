// Flat scan CUDA kernel — 内积距离 top-k
// 编译: nvcc tools/flat_scan_cuda.cu -o build/flat_scan_cuda.exe -O2 -std=c++14 -I.
// 运行: build/flat_scan_cuda.exe [query_limit]

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iomanip>
#include <iostream>
#include <queue>
#include <set>
#include <string>
#include <thrust/device_vector.h>
#include <thrust/sort.h>
#include <vector>

#include "simd/ann_bench_common.h"

// 每个 block 处理一个 query，每个 thread 处理 base 的一个子集
// 使用 shared memory 做 block 内 reduction 找 top-k
// 简化方案：先算全部距离，再 thrust::sort 取前 k 个

static __global__ void ip_distance_kernel(
    const float* __restrict__ base,   // [base_n × d]
    const float* __restrict__ query,  // [query_n × d]
    float* __restrict__ dist,         // [query_n × base_n]
    int base_n, int d)
{
    int qi = blockIdx.x;           // query index
    int bi = blockIdx.y * blockDim.x + threadIdx.x; // base index
    if (bi >= base_n) return;

    float sum = 0.0f;
    const float* b = base + (size_t)bi * d;
    const float* q = query + (size_t)qi * d;
    for (int j = 0; j < d; ++j) {
        sum += b[j] * q[j];
    }
    dist[(size_t)qi * base_n + bi] = 1.0f - sum;
}

struct CudaDeleter { void operator()(float* p) const { cudaFree(p); } };

int main(int argc, char** argv) {
    const int query_limit = argc > 1 ? std::atoi(argv[1]) : 2000;
    const size_t k = 10;

    // 加载数据
    size_t query_n = 0, query_d = 0, gt_n = 0, gt_dim = 0, base_n = 0, base_d = 0;
    const std::string dp = ann_bench::DefaultDataPath();
    auto queries = ann_bench::LoadData<float>(dp + "DEEP100K.query.fbin", query_n, query_d);
    auto gt = ann_bench::LoadData<int>(dp + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
    auto base = ann_bench::LoadData<float>(dp + "DEEP100K.base.100k.fbin", base_n, base_d);
    query_n = std::min<size_t>(query_n, (size_t)query_limit);

    const int bn = (int)base_n, qn = (int)query_n, d = (int)query_d;

    // GPU 分配 + 传输 base（一次性）
    float *d_base = nullptr, *d_query = nullptr, *d_dist = nullptr;
    cudaMalloc(&d_base, (size_t)bn * d * sizeof(float));
    cudaMalloc(&d_query, (size_t)qn * d * sizeof(float));
    cudaMalloc(&d_dist, (size_t)qn * bn * sizeof(float));
    cudaMemcpy(d_base, base.get(), (size_t)bn * d * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_query, queries.get(), (size_t)qn * d * sizeof(float), cudaMemcpyHostToDevice);

    // kernel launch: grid(qn, ceil(bn/256)), block(256)
    dim3 block(256);
    dim3 grid(qn, (bn + block.x - 1) / block.x);

    // 预热 + 计时
    cudaDeviceSynchronize();
    auto t1 = std::chrono::high_resolution_clock::now();

    ip_distance_kernel<<<grid, block>>>(d_base, d_query, d_dist, bn, d);
    cudaDeviceSynchronize();

    auto t2 = std::chrono::high_resolution_clock::now();
    double kernel_us = std::chrono::duration<double, std::micro>(t2 - t1).count();

    // 取回距离矩阵
    std::vector<float> host_dist((size_t)qn * bn);
    cudaMemcpy(host_dist.data(), d_dist, (size_t)qn * bn * sizeof(float), cudaMemcpyDeviceToHost);

    // CPU 侧 top-k + recall
    double total_recall = 0.0;
    for (int i = 0; i < qn; ++i) {
        // nth_element 取 top-k (内积越大越好 → 用 max-heap)
        std::priority_queue<std::pair<float, uint32_t>> heap;
        const float* row = host_dist.data() + (size_t)i * bn;
        for (int j = 0; j < bn; ++j) {
            if (heap.size() < k) heap.push({row[j], (uint32_t)j});
            else if (row[j] < heap.top().first) { heap.pop(); heap.push({row[j], (uint32_t)j}); }
        }
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) gtset.insert((uint32_t)gt[(size_t)i * gt_dim + j]);
        size_t hits = 0;
        while (!heap.empty()) { if (gtset.count(heap.top().second)) ++hits; heap.pop(); }
        total_recall += (double)hits / k;
    }

    // 端到端计时（含 top-k）
    // End-to-end timing includes the host-side top-k pass.
    auto t3 = std::chrono::high_resolution_clock::now();
    double total_us = std::chrono::duration<double, std::micro>(t3 - t1).count();

    std::cout << std::fixed << std::setprecision(5);
    std::cout << "flat_cuda, threads=1, recall=" << total_recall / qn
              << ", latency_us=" << total_us / qn << "\n";
    std::cout << "kernel_only_us=" << kernel_us / qn << "\n";

    cudaFree(d_base);
    cudaFree(d_query);
    cudaFree(d_dist);
    return 0;
}
