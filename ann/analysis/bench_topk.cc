// Microbenchmark: std::priority_queue vs fixed-size top-k array for
// full-flat AVX2 search.
//
// Motivation: report 4.5 traced 18.6% Machine Clears on Flat-AVX2 to the
// store-load dependency inside priority_queue maintenance. This bench
// quantifies whether replacing the heap with a linear-insertion fixed
// array yields a measurable latency win (and, predicted, lower Machine
// Clears in the follow-up VTune rerun).
//
// Output: CSV on stdout.

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <memory>
#include <queue>
#include <random>
#include <string>
#include <vector>

#include "../flat_scan_avx2.h"
#include "../flat_scan_avx2_topkarr.h"

template <typename T>
static std::unique_ptr<T[]> LoadData(const std::string& path, size_t& n, size_t& d) {
    std::ifstream fin(path, std::ios::binary);
    uint32_t n32 = 0, d32 = 0;
    fin.read(reinterpret_cast<char*>(&n32), 4);
    fin.read(reinterpret_cast<char*>(&d32), 4);
    n = n32; d = d32;
    std::unique_ptr<T[]> data(new T[n * d]);
    fin.read(reinterpret_cast<char*>(data.get()),
             static_cast<std::streamsize>(n * d * sizeof(T)));
    return data;
}

int main(int argc, char** argv) {
    const size_t Q_max = (argc > 1) ? std::strtoull(argv[1], nullptr, 10) : 2000;
    const int repeat = (argc > 2) ? std::atoi(argv[2]) : 5;
    const size_t k = 10;

    size_t qN = 0, qD = 0, bN = 0, bD = 0;
    auto queries = LoadData<float>("./files/DEEP100K.query.fbin", qN, qD);
    auto base = LoadData<float>("./files/DEEP100K.base.100k.fbin", bN, bD);
    const size_t Q = std::min<size_t>(qN, Q_max);

    std::cout << "variant,repeat,total_ms,per_query_us\n";
    std::cout << std::fixed << std::setprecision(4);

    // Warmup
    for (size_t i = 0; i < 32; ++i) {
        auto r = flat_search(base.get(), queries.get() + i * bD, bN, bD, k);
        (void)r;
    }

    // priority_queue baseline
    for (int rep = 0; rep < repeat; ++rep) {
        auto t0 = std::chrono::high_resolution_clock::now();
        for (size_t i = 0; i < Q; ++i) {
            auto r = flat_search(base.get(), queries.get() + i * bD, bN, bD, k);
            (void)r;
        }
        auto t1 = std::chrono::high_resolution_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        std::cout << "priority_queue," << rep << "," << ms << ","
                  << (ms * 1000.0) / Q << "\n";
    }

    // Fixed-array top-k
    for (int rep = 0; rep < repeat; ++rep) {
        auto t0 = std::chrono::high_resolution_clock::now();
        for (size_t i = 0; i < Q; ++i) {
            auto r = ann_avx2_topk::flat_search_array(
                base.get(), queries.get() + i * bD, bN, bD, k);
            (void)r;
        }
        auto t1 = std::chrono::high_resolution_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        std::cout << "fixed_array," << rep << "," << ms << ","
                  << (ms * 1000.0) / Q << "\n";
    }

    return 0;
}
