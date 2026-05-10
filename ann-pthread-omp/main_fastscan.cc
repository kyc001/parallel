#include <algorithm>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

#include "ann_bench_common.h"
#include "pq_fastscan_simd.h"

namespace {

struct Args {
    std::string data_path = ann_bench::DefaultDataPath();
    std::string output_dir = ann_bench::DefaultFastScanResultsDir();
    size_t query_limit = 2000;
    size_t k = 10;
    std::vector<size_t> rerank_ps = {40, 100, 500, 1000, 2000, 5000};
};

std::string FastScanLabel() {
#if defined(__AVX2__)
    return "fastscan_avx2";
#elif defined(__aarch64__) || defined(__ARM_NEON)
    return "fastscan_neon";
#else
    return "fastscan_unknown";
#endif
}

Args ParseArgs(int argc, char** argv) {
    Args args;
    for (int i = 1; i < argc; ++i) {
        const std::string arg = argv[i];
        if (arg.rfind("--data_path=", 0) == 0) {
            args.data_path = arg.substr(std::string("--data_path=").size());
        } else if (arg.rfind("--output_dir=", 0) == 0) {
            args.output_dir = arg.substr(std::string("--output_dir=").size());
        } else if (arg.rfind("--queries=", 0) == 0) {
            args.query_limit = static_cast<size_t>(
                std::strtoull(arg.substr(std::string("--queries=").size()).c_str(), NULL, 10));
        } else if (arg.rfind("--k=", 0) == 0) {
            args.k = static_cast<size_t>(
                std::strtoull(arg.substr(std::string("--k=").size()).c_str(), NULL, 10));
        } else if (arg.rfind("--p=", 0) == 0) {
            args.rerank_ps = ann_bench::ParseSizeList(arg.substr(std::string("--p=").size()));
        } else {
            throw std::runtime_error("unknown argument: " + arg);
        }
    }
    if (args.rerank_ps.empty()) {
        throw std::runtime_error("rerank p list is empty");
    }
    return args;
}

void PrintUsage(const char* program) {
    std::cerr << "usage: " << program
              << " [--data_path=PATH] [--output_dir=DIR] [--queries=N]"
              << " [--k=10] [--p=40,100,500,1000,2000,5000]\n";
}

}  // namespace

int main(int argc, char** argv) {
    try {
        const Args args = ParseArgs(argc, argv);

        size_t base_number = 0;
        size_t query_number = 0;
        size_t gt_number = 0;
        size_t gt_dim = 0;
        size_t vecdim = 0;
        size_t base_dim = 0;

        auto base = ann_bench::LoadData<float>(
            args.data_path + "DEEP100K.base.100k.fbin", base_number, base_dim);
        auto queries = ann_bench::LoadData<float>(
            args.data_path + "DEEP100K.query.fbin", query_number, vecdim);
        auto gt = ann_bench::LoadData<int>(
            args.data_path + "DEEP100K.gt.query.100k.top100.bin", gt_number, gt_dim);

        if (base_dim != vecdim) {
            throw std::runtime_error("base/query dimensions do not match");
        }
        if (vecdim != 96) {
            throw std::runtime_error("current FastScan setup expects DEEP100K d=96");
        }
        if (gt_number < query_number) {
            query_number = gt_number;
        }
        query_number = std::min(query_number, args.query_limit);
        if (query_number == 0 || base_number == 0 || gt_dim < args.k) {
            throw std::runtime_error("invalid empty data set or ground truth");
        }

        ann_fs::FastScanIndex idx;
        std::cerr << "[" << FastScanLabel() << "] training ...\n";
        ann_fs::train_fastscan(idx, base.get(), static_cast<int>(base_number), static_cast<int>(vecdim));
        ann_fs::encode_fastscan(idx, base.get());
        std::cerr << "[" << FastScanLabel() << "] training done, packed bytes="
                  << idx.codes_packed.size() << "\n";

        std::cout << std::fixed << std::setprecision(5);
        for (size_t rerank_p : args.rerank_ps) {
            const size_t candidate_count = std::min(rerank_p, base_number);
            const ann_bench::BenchmarkResult result = ann_bench::RunBenchmark(
                base.get(), queries.get(), gt.get(), query_number, gt_dim, vecdim, args.k,
                [&](float* query) {
                    return ann_fs::fastscan_search(
                        idx, base.get(), query, args.k, static_cast<int>(candidate_count));
                });

            std::cout << FastScanLabel() << ", p=" << candidate_count << "\n";
            std::cout << "average recall: " << result.recall << "\n";
            std::cout << "average latency (us): " << result.latency_us << "\n";

            ann_bench::WriteFastScanResult(args.output_dir, FastScanLabel(), candidate_count, result);
        }
    } catch (const std::exception& ex) {
        PrintUsage(argv[0]);
        std::cerr << "error: " << ex.what() << "\n";
        return 1;
    }

    return 0;
}
