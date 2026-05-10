// Extended benchmark harness supporting:
//   - variable top-k (for Recall@1 / Recall@10 / Recall@100)
//   - variable base subset N (for problem-size sweep)
//   - repeat count (for mean/std)
//   - per-query GT override file (so small N has its own GT, not 100K's)
// CSV output on stdout, one line per repeat; stderr is human-readable log.
//
// Usage:
//   main_win_ext <mode> --k=<k> [--p=<p>] [--N=<N>] [--repeat=<r>]
//                [--gt=<path>] [--tag=<label>]
//   mode: baseline | flat | flat_blocked | sq | pq

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
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#define flat_search baseline_flat_search
#include "flat_scan.h"
#undef flat_search

#include "flat_scan_avx2.h"
#include "flat_scan_avx2_blocked.h"
#include "sq_scan_avx2.h"
#include "pq_scan_avx2.h"

template <typename T>
std::unique_ptr<T[]> LoadData(const std::string& data_path, size_t& n, size_t& d) {
    std::ifstream fin(data_path.c_str(), std::ios::in | std::ios::binary);
    if (!fin) throw std::runtime_error("failed to open: " + data_path);
    uint32_t n32 = 0, d32 = 0;
    fin.read(reinterpret_cast<char*>(&n32), sizeof(uint32_t));
    fin.read(reinterpret_cast<char*>(&d32), sizeof(uint32_t));
    if (!fin) throw std::runtime_error("failed to read header: " + data_path);
    n = n32;
    d = d32;
    std::unique_ptr<T[]> data(new T[n * d]);
    fin.read(reinterpret_cast<char*>(data.get()),
             static_cast<std::streamsize>(n * d * sizeof(T)));
    if (!fin) throw std::runtime_error("failed to read body: " + data_path);
    std::cerr << "load " << data_path << " n=" << n << " d=" << d << "\n";
    return data;
}

struct Args {
    std::string mode;
    size_t k = 10;
    size_t p = 0;          // 0 = use method default
    size_t N = 0;          // 0 = full dataset
    size_t repeat = 1;
    std::string gt_path;   // optional custom gt
    std::string tag;
};

static std::string GetOpt(int argc, char** argv, const std::string& key) {
    const std::string prefix = "--" + key + "=";
    for (int i = 1; i < argc; ++i) {
        std::string a = argv[i];
        if (a.rfind(prefix, 0) == 0) return a.substr(prefix.size());
    }
    return "";
}

static size_t ToSize(const std::string& s, size_t def) {
    if (s.empty()) return def;
    return static_cast<size_t>(std::strtoull(s.c_str(), nullptr, 10));
}

// Compute ground truth (top-gt_k indices) for a subset of base vectors.
// Used when N < 100000 and the 100K ground truth is no longer valid.
static std::vector<int> ComputeGroundTruth(const float* base, size_t N,
                                           size_t d, const float* queries,
                                           size_t Q, size_t gt_k) {
    std::vector<int> gt(Q * gt_k);
    for (size_t q = 0; q < Q; ++q) {
        std::vector<std::pair<float, int>> dists(N);
        for (size_t i = 0; i < N; ++i) {
            float dot = 0.0f;
            for (size_t j = 0; j < d; ++j) dot += base[i * d + j] * queries[q * d + j];
            dists[i] = {1.0f - dot, static_cast<int>(i)};
        }
        std::partial_sort(dists.begin(), dists.begin() + gt_k, dists.end());
        for (size_t t = 0; t < gt_k; ++t) gt[q * gt_k + t] = dists[t].second;
    }
    return gt;
}

struct BenchmarkResult {
    double recall;
    double latency_us;
};

template <typename SearchFn>
BenchmarkResult RunOne(const int* gt, size_t Q, size_t gt_dim, size_t k,
                       SearchFn search_fn) {
    double total_recall = 0.0;
    double total_latency = 0.0;
    for (size_t i = 0; i < Q; ++i) {
        auto t0 = std::chrono::high_resolution_clock::now();
        auto res = search_fn(i);
        auto t1 = std::chrono::high_resolution_clock::now();
        total_latency += static_cast<double>(
            std::chrono::duration_cast<std::chrono::microseconds>(t1 - t0).count());

        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j)
            gtset.insert(static_cast<uint32_t>(gt[j + i * gt_dim]));

        size_t hit = 0;
        while (!res.empty()) {
            if (gtset.count(res.top().second)) ++hit;
            res.pop();
        }
        total_recall += static_cast<double>(hit) / static_cast<double>(k);
    }
    return {total_recall / static_cast<double>(Q), total_latency / static_cast<double>(Q)};
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: " << argv[0]
                  << " baseline|flat|flat_blocked|sq|pq "
                     "[--k=10] [--p=P] [--N=N] [--repeat=R] [--gt=PATH] [--tag=X]\n";
        return 2;
    }

    Args args;
    args.mode = argv[1];
    args.k = ToSize(GetOpt(argc, argv, "k"), 10);
    args.p = ToSize(GetOpt(argc, argv, "p"), 0);
    args.N = ToSize(GetOpt(argc, argv, "N"), 0);
    args.repeat = ToSize(GetOpt(argc, argv, "repeat"), 1);
    args.gt_path = GetOpt(argc, argv, "gt");
    args.tag = GetOpt(argc, argv, "tag");

    const std::string data_path = "./files/";
    const size_t requested_queries = 2000;

    try {
        size_t qN = 0, bN = 0, gN = 0, gD = 0, vd = 0, bd = 0;
        auto queries = LoadData<float>(data_path + "DEEP100K.query.fbin", qN, vd);
        auto base_full = LoadData<float>(data_path + "DEEP100K.base.100k.fbin", bN, bd);
        if (bd != vd) throw std::runtime_error("base/query dim mismatch");

        const size_t N = (args.N == 0) ? bN : std::min(args.N, bN);
        const size_t Q = std::min(qN, requested_queries);

        // Ground truth: custom file, or auto-compute when subset, or 100K default.
        std::vector<int> gt_buf;
        const int* gt_ptr = nullptr;
        size_t gt_dim = 0;

        if (!args.gt_path.empty()) {
            auto gtp = LoadData<int>(args.gt_path, gN, gD);
            gt_buf.assign(gtp.get(), gtp.get() + gN * gD);
            gt_ptr = gt_buf.data();
            gt_dim = gD;
            std::cerr << "use custom GT (N=" << gN << " d=" << gD << ")\n";
        } else if (args.N != 0 && args.N < bN) {
            std::cerr << "computing GT for subset N=" << N << " k=" << args.k << "\n";
            gt_buf = ComputeGroundTruth(base_full.get(), N, vd, queries.get(),
                                        Q, std::max<size_t>(args.k, 10));
            gt_ptr = gt_buf.data();
            gt_dim = std::max<size_t>(args.k, 10);
        } else {
            auto gtp = LoadData<int>(data_path + "DEEP100K.gt.query.100k.top100.bin", gN, gD);
            gt_buf.assign(gtp.get(), gtp.get() + gN * gD);
            gt_ptr = gt_buf.data();
            gt_dim = gD;
        }

        if (args.k > gt_dim)
            throw std::runtime_error("k exceeds available GT dim");

        std::cout << "tag,mode,k,p,N,rep,recall,latency_us\n";

        for (size_t rep = 0; rep < args.repeat; ++rep) {
            BenchmarkResult r{0, 0};
            std::string label = args.mode;

            if (args.mode == "baseline") {
                r = RunOne(gt_ptr, Q, gt_dim, args.k,
                    [&](size_t qi) {
                        return baseline_flat_search(
                            base_full.get(), queries.get() + qi * vd, N, vd, args.k);
                    });
            } else if (args.mode == "flat") {
                r = RunOne(gt_ptr, Q, gt_dim, args.k,
                    [&](size_t qi) {
                        return flat_search(
                            base_full.get(), queries.get() + qi * vd, N, vd, args.k);
                    });
            } else if (args.mode == "flat_blocked") {
                r = RunOne(gt_ptr, Q, gt_dim, args.k,
                    [&](size_t qi) {
                        return ann_avx2_blocked::flat_search_blocked(
                            base_full.get(), queries.get() + qi * vd, N, vd, args.k);
                    });
            } else if (args.mode == "sq") {
                size_t p = args.p ? args.p : 100;
                p = std::min(p, N);
                SQIndex idx;
                idx.build(base_full.get(), N, vd);
                r = RunOne(gt_ptr, Q, gt_dim, args.k,
                    [&](size_t qi) {
                        return sq_search(base_full.get(), queries.get() + qi * vd,
                                         N, vd, args.k, idx, p);
                    });
                label += "_p" + std::to_string(p);
            } else if (args.mode == "pq") {
                size_t p = args.p ? args.p : 1000;
                p = std::min(p, N);
                PQIndex idx;
                idx.build(base_full.get(), N, vd, 8, 256, 20);
                r = RunOne(gt_ptr, Q, gt_dim, args.k,
                    [&](size_t qi) {
                        return pq_search(base_full.get(), queries.get() + qi * vd,
                                         N, vd, args.k, idx, p);
                    });
                label += "_p" + std::to_string(p);
            } else {
                throw std::runtime_error("unknown mode: " + args.mode);
            }

            std::cout << std::fixed << std::setprecision(5)
                      << (args.tag.empty() ? label : args.tag) << ","
                      << args.mode << "," << args.k << "," << args.p << ","
                      << N << "," << rep << "," << r.recall << ","
                      << r.latency_us << "\n";
            std::cout.flush();
        }
    } catch (const std::exception& ex) {
        std::cerr << "error: " << ex.what() << "\n";
        return 1;
    }
    return 0;
}
