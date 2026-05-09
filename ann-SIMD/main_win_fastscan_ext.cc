// FastScan benchmark with configurable p list and k.
// Supports Recall@1 / Recall@10 / Recall@100 and very large p values
// for the full tradeoff curve.

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <memory>
#include <queue>
#include <set>
#include <string>
#include <vector>

#include "pq_fastscan_avx2.h"

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

static std::string GetOpt(int argc, char** argv, const std::string& key) {
    const std::string prefix = "--" + key + "=";
    for (int i = 1; i < argc; ++i) {
        std::string a = argv[i];
        if (a.rfind(prefix, 0) == 0) return a.substr(prefix.size());
    }
    return "";
}

int main(int argc, char** argv) {
    const std::string p_csv = GetOpt(argc, argv, "p");
    const std::string k_str = GetOpt(argc, argv, "k");
    const std::string repeat_str = GetOpt(argc, argv, "repeat");
    const size_t k = k_str.empty() ? 10 : static_cast<size_t>(std::atoi(k_str.c_str()));
    const int repeat = repeat_str.empty() ? 1 : std::atoi(repeat_str.c_str());

    std::vector<int> p_list;
    if (!p_csv.empty()) {
        std::string s = p_csv;
        for (char& c : s) if (c == ',') c = ' ';
        std::stringstream ss(s);
        int x;
        while (ss >> x) p_list.push_back(x);
    } else {
        p_list = {40, 100, 500, 1000, 2000, 5000, 10000, 50000, 100000};
    }

    const std::string data_path = "./files/";
    size_t bN = 0, bD = 0, qN = 0, qD = 0, gN = 0, gD = 0;
    auto base = LoadData<float>(data_path + "DEEP100K.base.100k.fbin", bN, bD);
    auto queries = LoadData<float>(data_path + "DEEP100K.query.fbin", qN, qD);
    auto gt = LoadData<int>(data_path + "DEEP100K.gt.query.100k.top100.bin", gN, gD);

    const size_t Q = std::min<size_t>(qN, 2000);
    if (k > gD) { std::cerr << "k exceeds GT dim\n"; return 1; }

    ann_fs::FastScanIndex idx;
    std::cerr << "[FastScan] training...\n";
    ann_fs::train_fastscan(idx, base.get(), static_cast<int>(bN),
                           static_cast<int>(bD));
    ann_fs::encode_fastscan(idx, base.get());
    std::cerr << "[FastScan] trained.\n";

    std::cout << "mode,k,p,rep,recall,latency_us\n";
    std::cout << std::fixed << std::setprecision(5);

    for (int p : p_list) {
        for (int rep = 0; rep < repeat; ++rep) {
            double sum_rc = 0, sum_us = 0;
            for (size_t qi = 0; qi < Q; ++qi) {
                auto t0 = std::chrono::high_resolution_clock::now();
                auto heap = ann_fs::fastscan_search(
                    idx, base.get(), queries.get() + qi * bD, k, p);
                auto t1 = std::chrono::high_resolution_clock::now();
                sum_us += std::chrono::duration<double, std::micro>(t1 - t0).count();

                std::set<int> gtset;
                for (size_t j = 0; j < k; ++j)
                    gtset.insert(gt[qi * gD + j]);
                size_t hit = 0;
                while (!heap.empty()) {
                    if (gtset.count(static_cast<int>(heap.top().second))) ++hit;
                    heap.pop();
                }
                sum_rc += static_cast<double>(hit) / static_cast<double>(k);
            }
            std::cout << "fastscan," << k << "," << p << "," << rep << ","
                      << sum_rc / Q << "," << sum_us / Q << "\n";
            std::cout.flush();
        }
    }
    return 0;
}
