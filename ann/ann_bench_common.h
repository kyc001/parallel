#pragma once

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <memory>
#include <queue>
#include <set>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace ann_bench {

template <typename T>
std::unique_ptr<T[]> LoadData(const std::string& data_path, size_t& n, size_t& d) {
    std::ifstream fin(data_path.c_str(), std::ios::in | std::ios::binary);
    if (!fin) {
        throw std::runtime_error("failed to open data file: " + data_path);
    }

    uint32_t n32 = 0;
    uint32_t d32 = 0;
    fin.read(reinterpret_cast<char*>(&n32), sizeof(uint32_t));
    fin.read(reinterpret_cast<char*>(&d32), sizeof(uint32_t));
    if (!fin) {
        throw std::runtime_error("failed to read header from: " + data_path);
    }

    n = static_cast<size_t>(n32);
    d = static_cast<size_t>(d32);
    std::unique_ptr<T[]> data(new T[n * d]);
    fin.read(reinterpret_cast<char*>(data.get()),
             static_cast<std::streamsize>(n * d * sizeof(T)));
    if (!fin) {
        throw std::runtime_error("failed to read payload from: " + data_path);
    }

    return data;
}

inline std::string DefaultDataPath() {
#ifdef _WIN32
    return "./files/";
#else
    return "/anndata/";
#endif
}

inline std::string DefaultFastScanResultsDir() {
#ifdef _WIN32
    return "bench_results/windows_i9_13900h/fastscan";
#elif defined(__aarch64__) || defined(__ARM_NEON)
    return "bench_results/kunpeng_server/fastscan";
#else
    return "bench_results/fastscan";
#endif
}

inline void EnsureDirectory(const std::string& dir) {
    std::filesystem::create_directories(std::filesystem::path(dir));
}

inline std::vector<size_t> ParseSizeList(const std::string& csv) {
    std::vector<size_t> values;
    size_t start = 0;
    while (start < csv.size()) {
        size_t end = csv.find(',', start);
        const std::string token = csv.substr(start, end == std::string::npos
                                                        ? std::string::npos
                                                        : end - start);
        if (!token.empty()) {
            values.push_back(static_cast<size_t>(std::stoull(token)));
        }
        if (end == std::string::npos) {
            break;
        }
        start = end + 1;
    }
    return values;
}

struct BenchmarkResult {
    double recall = 0.0;
    double latency_us = 0.0;
};

template <typename SearchFn>
BenchmarkResult RunBenchmark(float* base, float* queries, int* gt,
                             size_t query_number, size_t gt_dim,
                             size_t vecdim, size_t k, SearchFn search_fn) {
    double total_recall = 0.0;
    double total_latency = 0.0;

    for (size_t i = 0; i < query_number; ++i) {
        const auto start = std::chrono::high_resolution_clock::now();
        auto res = search_fn(queries + i * vecdim);
        const auto stop = std::chrono::high_resolution_clock::now();

        total_latency += std::chrono::duration<double, std::micro>(stop - start).count();

        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) {
            gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
        }

        size_t hits = 0;
        while (!res.empty()) {
            const uint32_t idx = res.top().second;
            if (gtset.find(idx) != gtset.end()) {
                ++hits;
            }
            res.pop();
        }
        total_recall += static_cast<double>(hits) / static_cast<double>(k);
    }

    BenchmarkResult result;
    result.recall = total_recall / static_cast<double>(query_number);
    result.latency_us = total_latency / static_cast<double>(query_number);
    (void)base;
    return result;
}

inline void WriteFastScanResult(const std::string& output_dir,
                                const std::string& label,
                                size_t rerank_p,
                                const BenchmarkResult& result) {
    EnsureDirectory(output_dir);
    const std::filesystem::path file_path =
        std::filesystem::path(output_dir) /
        ("speed_fastscan_p" + std::to_string(rerank_p) + ".txt");
    std::ofstream out(file_path.string().c_str());
    out << std::fixed << std::setprecision(5);
    out << "mode=" << label
        << " p=" << rerank_p
        << " recall=" << result.recall
        << " latency_us=" << result.latency_us << "\n";
}

}  // namespace ann_bench
