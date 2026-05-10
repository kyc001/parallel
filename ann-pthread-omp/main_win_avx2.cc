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
#include <utility>
#include <vector>

#define flat_search baseline_flat_search
#include "flat_scan.h"
#undef flat_search

#include "flat_scan_avx2.h"
#include "sq_scan_avx2.h"
#include "pq_scan_avx2.h"

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

    n = n32;
    d = d32;
    std::unique_ptr<T[]> data(new T[n * d]);
    fin.read(reinterpret_cast<char*>(data.get()),
             static_cast<std::streamsize>(n * d * sizeof(T)));
    if (!fin) {
        throw std::runtime_error("failed to read payload from: " + data_path);
    }

    std::cerr << "load data " << data_path << "\n";
    std::cerr << "dimension: " << d << "  number:" << n
              << "  size_per_element:" << sizeof(T) << "\n";
    return data;
}

struct BenchmarkResult {
    double recall;
    double latency_us;
};

template <typename SearchFn>
BenchmarkResult RunBenchmark(float* base, float* queries, int* gt,
                             size_t base_number, size_t query_number,
                             size_t gt_dim, size_t vecdim, size_t k,
                             SearchFn search_fn) {
    double total_recall = 0.0;
    double total_latency = 0.0;

    for (size_t i = 0; i < query_number; ++i) {
        auto start = std::chrono::high_resolution_clock::now();
        auto res = search_fn(queries + i * vecdim);
        auto stop = std::chrono::high_resolution_clock::now();

        total_latency += static_cast<double>(
            std::chrono::duration_cast<std::chrono::microseconds>(
                stop - start).count());

        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) {
            gtset.insert(static_cast<uint32_t>(gt[j + i * gt_dim]));
        }

        size_t acc = 0;
        while (!res.empty()) {
            uint32_t idx = res.top().second;
            if (gtset.find(idx) != gtset.end()) {
                ++acc;
            }
            res.pop();
        }

        total_recall += static_cast<double>(acc) / static_cast<double>(k);
    }

    BenchmarkResult result;
    result.recall = total_recall / static_cast<double>(query_number);
    result.latency_us = total_latency / static_cast<double>(query_number);
    (void)base;
    (void)base_number;
    return result;
}

size_t ParseRerankOrDefault(int argc, char* argv[], size_t default_value) {
    if (argc < 3) {
        return default_value;
    }
    return static_cast<size_t>(std::strtoull(argv[2], NULL, 10));
}

void PrintUsage(const char* program) {
    std::cerr << "usage: " << program
              << " baseline|flat|sq|pq [rerank_p_for_sq_or_pq]\n";
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        PrintUsage(argv[0]);
        return 2;
    }

    const std::string mode = argv[1];
    const std::string data_path = "./files/";
    const size_t requested_queries = 2000;
    const size_t k = 10;

    try {
        size_t query_number = 0;
        size_t base_number = 0;
        size_t gt_number = 0;
        size_t gt_dim = 0;
        size_t vecdim = 0;
        size_t base_dim = 0;

        auto queries = LoadData<float>(
            data_path + "DEEP100K.query.fbin", query_number, vecdim);
        auto gt = LoadData<int>(
            data_path + "DEEP100K.gt.query.100k.top100.bin", gt_number, gt_dim);
        auto base = LoadData<float>(
            data_path + "DEEP100K.base.100k.fbin", base_number, base_dim);

        if (base_dim != vecdim) {
            throw std::runtime_error("base/query dimensions do not match");
        }
        if (gt_number < query_number) {
            query_number = gt_number;
        }
        query_number = std::min(query_number, requested_queries);
        if (query_number == 0 || base_number == 0 || gt_dim < k) {
            throw std::runtime_error("invalid empty data set or ground truth");
        }

        BenchmarkResult result;
        std::string label;

        if (mode == "baseline") {
            label = "baseline_serial_flat";
            result = RunBenchmark(
                base.get(), queries.get(), gt.get(), base_number, query_number,
                gt_dim, vecdim, k,
                [&](float* query) {
                    return baseline_flat_search(
                        base.get(), query, base_number, vecdim, k);
                });
        } else if (mode == "flat") {
            label = "flat_avx2";
            result = RunBenchmark(
                base.get(), queries.get(), gt.get(), base_number, query_number,
                gt_dim, vecdim, k,
                [&](float* query) {
                    return flat_search(base.get(), query, base_number, vecdim, k);
                });
        } else if (mode == "sq") {
            const size_t rerank_p = std::min(
                ParseRerankOrDefault(argc, argv, 100), base_number);
            label = "sq_avx2, p=" + std::to_string(rerank_p);
            SQIndex sq_index;
            sq_index.build(base.get(), base_number, vecdim);
            result = RunBenchmark(
                base.get(), queries.get(), gt.get(), base_number, query_number,
                gt_dim, vecdim, k,
                [&](float* query) {
                    return sq_search(base.get(), query, base_number, vecdim, k,
                                     sq_index, rerank_p);
                });
        } else if (mode == "pq") {
            const size_t rerank_p = std::min(
                ParseRerankOrDefault(argc, argv, 1000), base_number);
            label = "pq_avx2, p=" + std::to_string(rerank_p);
            PQIndex pq_index;
            pq_index.build(base.get(), base_number, vecdim, 8, 256, 20);
            result = RunBenchmark(
                base.get(), queries.get(), gt.get(), base_number, query_number,
                gt_dim, vecdim, k,
                [&](float* query) {
                    return pq_search(base.get(), query, base_number, vecdim, k,
                                     pq_index, rerank_p);
                });
        } else {
            PrintUsage(argv[0]);
            return 2;
        }

        std::cout << std::fixed << std::setprecision(5);
        std::cout << label << "\n";
        std::cout << "average recall: " << result.recall << "\n";
        std::cout << "average latency (us): " << result.latency_us << "\n";
    } catch (const std::exception& ex) {
        std::cerr << "error: " << ex.what() << "\n";
        return 1;
    }

    return 0;
}
