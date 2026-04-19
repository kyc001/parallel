// AVX-512 benchmark harness for Xeon 8358 (3090 docker host).
// Measures Flat-AVX-512 speed alongside a baseline reference that uses
// the repo's flat_scan.h serial kernel. Matches the report's
// 128-bit NEON -> 256-bit AVX2 -> 512-bit AVX-512 scaling story.
//
// Usage (from ann/ repo root after cloning, with DEEP100K data in ./files/):
//   g++ server_3090/main_3090_avx512.cc -o m_avx512.exe \
//       -O3 -mavx512f -mavx512bw -mavx512dq -mfma -std=c++17
//   ./m_avx512.exe baseline
//   ./m_avx512.exe flat_avx512
//
// Output is a CSV line per run.

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <memory>
#include <queue>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>

#define flat_search baseline_flat_search
#include "../flat_scan.h"
#undef flat_search

#include "flat_scan_avx512.h"

template <typename T>
std::unique_ptr<T[]> LoadData(const std::string& p, size_t& n, size_t& d) {
    std::ifstream fin(p, std::ios::binary);
    if (!fin) throw std::runtime_error("open: " + p);
    uint32_t n32 = 0, d32 = 0;
    fin.read(reinterpret_cast<char*>(&n32), 4);
    fin.read(reinterpret_cast<char*>(&d32), 4);
    n = n32; d = d32;
    std::unique_ptr<T[]> buf(new T[n * d]);
    fin.read(reinterpret_cast<char*>(buf.get()),
             static_cast<std::streamsize>(n * d * sizeof(T)));
    std::cerr << "load " << p << " n=" << n << " d=" << d << "\n";
    return buf;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: " << argv[0] << " baseline|flat_avx512 [k]\n";
        return 2;
    }
    const std::string mode = argv[1];
    const size_t k = (argc > 2) ? std::strtoull(argv[2], nullptr, 10) : 10;
    const std::string data_path = "./files/";

    size_t bN = 0, bD = 0, qN = 0, qD = 0, gN = 0, gD = 0;
    auto base = LoadData<float>(data_path + "DEEP100K.base.100k.fbin", bN, bD);
    auto queries = LoadData<float>(data_path + "DEEP100K.query.fbin", qN, qD);
    auto gt = LoadData<int>(data_path + "DEEP100K.gt.query.100k.top100.bin", gN, gD);
    const size_t Q = std::min<size_t>(qN, 2000);

    double total_recall = 0.0, total_us = 0.0;
    for (size_t i = 0; i < Q; ++i) {
        auto t0 = std::chrono::high_resolution_clock::now();
        std::priority_queue<std::pair<float, uint32_t>> res;
        if (mode == "baseline") {
            res = baseline_flat_search(base.get(), queries.get() + i * qD, bN, qD, k);
        } else if (mode == "flat_avx512") {
            res = flat_search_avx512(base.get(), queries.get() + i * qD, bN, qD, k);
        } else {
            std::cerr << "unknown mode\n"; return 2;
        }
        auto t1 = std::chrono::high_resolution_clock::now();
        total_us += std::chrono::duration<double, std::micro>(t1 - t0).count();

        std::set<int> gtset;
        for (size_t j = 0; j < k; ++j) gtset.insert(gt[i * gD + j]);
        size_t hit = 0;
        while (!res.empty()) {
            if (gtset.count(static_cast<int>(res.top().second))) ++hit;
            res.pop();
        }
        total_recall += static_cast<double>(hit) / static_cast<double>(k);
    }

    std::cout << std::fixed << std::setprecision(5);
    std::cout << "mode,k,recall,latency_us\n";
    std::cout << mode << "," << k << "," << total_recall / Q << ","
              << total_us / Q << "\n";
    return 0;
}
