// ===========================================================================
// ANN GPU submission entry
//
// Keep the original ANN coursework frame:
//   load DEEP100K -> call one search function -> compute Recall@10/latency.
// GPU implementations are header-only in gpu_ann_search.cuh.
//
// Default mode:
//   gpu_gemm_search: base[n*d] * query[d*m] -> score[n*m], then GPU Top-k.
// Optional:
//   ./main ivf 2000 16 4
//   ./main ivf_grouped 2000 16 4
//   ./main gemm_tree 2000
//   ./main cublas 2000
//   builds a lightweight IVF index and runs GPU batch probe/search/top-k.
// ===========================================================================

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <queue>
#include <set>
#include <string>
#include <stdexcept>
#include <utility>
#include <vector>

#ifdef _WIN32
#include <io.h>
#define ACCESS _access
#define F_OK 0
#else
#include <unistd.h>
#define ACCESS access
#endif

#include "flat_scan.h"
#include "gpu_ann_search.cuh"

template <typename T>
T* LoadData(const std::string& data_path, size_t& n, size_t& d) {
    std::ifstream fin(data_path.c_str(), std::ios::in | std::ios::binary);
    if (!fin) {
        throw std::runtime_error("failed to open data file: " + data_path);
    }

    uint32_t n32 = 0;
    uint32_t d32 = 0;
    fin.read(reinterpret_cast<char*>(&n32), sizeof(uint32_t));
    fin.read(reinterpret_cast<char*>(&d32), sizeof(uint32_t));
    n = static_cast<size_t>(n32);
    d = static_cast<size_t>(d32);

    T* data = new T[n * d];
    fin.read(reinterpret_cast<char*>(data), n * d * sizeof(T));
    if (!fin) {
        delete[] data;
        throw std::runtime_error("failed to read payload from: " + data_path);
    }

    std::cerr << "load data " << data_path << "\n";
    std::cerr << "dimension: " << d << "  number:" << n
              << "  size_per_element:" << sizeof(T) << "\n";
    return data;
}

struct SearchResult {
    float recall;
    int64_t latency;
};

std::string WithTrailingSlash(std::string path) {
    if (!path.empty() && path.back() != '/' && path.back() != '\\') {
#ifdef _WIN32
        path.push_back('\\');
#else
        path.push_back('/');
#endif
    }
    return path;
}

std::string DefaultDataPath() {
    const char* env = std::getenv("ANN_DATA_PATH");
    if (env && env[0]) {
        return WithTrailingSlash(env);
    }
#ifdef _WIN32
    if (ACCESS("..\\files\\DEEP100K.query.fbin", F_OK) == 0) {
        return "..\\files\\";
    }
    return "files\\";
#else
    if (ACCESS("/anndata/DEEP100K.query.fbin", F_OK) == 0) {
        return "/anndata/";
    }
    if (ACCESS("../files/DEEP100K.query.fbin", F_OK) == 0) {
        return "../files/";
    }
    return "files/";
#endif
}

size_t ParseSizeArg(int argc, char** argv, int index, size_t fallback) {
    if (argc <= index) {
        return fallback;
    }
    const long long parsed = std::atoll(argv[index]);
    return parsed > 0 ? static_cast<size_t>(parsed) : fallback;
}

bool IsModeArg(const std::string& value) {
    return value == "gemm" || value == "gemm_tree" ||
           value == "cublas" || value == "cublas_tree" ||
           value == "ivf" || value == "ivf_grouped";
}

int main(int argc, char* argv[]) {
    try {
        std::string mode = "gemm";
        int first_param = 1;
        if (argc > 1 && IsModeArg(std::string(argv[1]))) {
            mode = std::string(argv[1]);
            first_param = 2;
        }
        const size_t query_limit = ParseSizeArg(argc, argv, first_param, 2000);
        const size_t nlist = ParseSizeArg(argc, argv, first_param + 1, 16);
        const size_t nprobe = ParseSizeArg(argc, argv, first_param + 2, 4);
        const size_t k = 10;

        size_t test_number = 0;
        size_t query_dim = 0;
        size_t base_number = 0;
        size_t base_dim = 0;
        size_t gt_number = 0;
        size_t test_gt_d = 0;

        const std::string data_path = DefaultDataPath();
        float* test_query =
            LoadData<float>(data_path + "DEEP100K.query.fbin",
                            test_number, query_dim);
        int* test_gt =
            LoadData<int>(data_path + "DEEP100K.gt.query.100k.top100.bin",
                          gt_number, test_gt_d);
        float* base =
            LoadData<float>(data_path + "DEEP100K.base.100k.fbin",
                            base_number, base_dim);

        if (base_dim != query_dim) {
            throw std::runtime_error("base/query dimension mismatch");
        }

        test_number = std::min(test_number, query_limit);
        test_number = std::min(test_number, gt_number);

        std::vector<SearchResult> results(test_number);
        ann_gpu::GpuSearchStats stats;
        std::vector<ann_gpu::SearchHeap> search_results;

        const auto t_begin = std::chrono::high_resolution_clock::now();
        if (mode == "ivf") {
            search_results = ann_gpu::gpu_ivf_search(
                base, test_query, base_number, test_number, query_dim, k,
                nlist, nprobe, &stats);
        } else if (mode == "ivf_grouped") {
            search_results = ann_gpu::gpu_ivf_grouped_search(
                base, test_query, base_number, test_number, query_dim, k,
                nlist, nprobe, &stats);
        } else {
            const bool use_tree_topk =
                (mode == "gemm_tree" || mode == "cublas_tree");
            const bool use_cublas_score =
                (mode == "cublas" || mode == "cublas_tree");
            search_results = ann_gpu::gpu_gemm_search(
                base, test_query, base_number, test_number, query_dim, k,
                &stats, 128, 256, use_tree_topk, use_cublas_score);
        }
        const auto t_end = std::chrono::high_resolution_clock::now();
        const double wall_us =
            std::chrono::duration<double, std::micro>(t_end - t_begin).count();

        double avg_recall = 0.0;
        for (size_t i = 0; i < test_number; ++i) {
            std::set<uint32_t> gtset;
            for (size_t j = 0; j < k; ++j) {
                gtset.insert(static_cast<uint32_t>(test_gt[j + i * test_gt_d]));
            }

            size_t acc = 0;
            ann_gpu::SearchHeap& heap = search_results[i];
            while (!heap.empty()) {
                const uint32_t x = heap.top().second;
                if (gtset.find(x) != gtset.end()) {
                    ++acc;
                }
                heap.pop();
            }
            const float recall = static_cast<float>(acc) / static_cast<float>(k);
            results[i] = {recall, static_cast<int64_t>(wall_us / test_number)};
            avg_recall += recall;
        }

        cudaDeviceProp prop;
        ANN_GPU_CHECK(cudaGetDeviceProperties(&prop, 0));

        std::cout << std::fixed << std::setprecision(5);
        std::cout << stats.mode
                  << ", device=\"" << prop.name << "\""
                  << ", query_n=" << test_number
                  << ", base_n=" << base_number
                  << ", dim=" << query_dim;
        if (mode == "ivf" || mode == "ivf_grouped") {
            std::cout << ", nlist=" << stats.nlist
                      << ", nprobe=" << stats.nprobe;
        }
        std::cout << "\n";
        std::cout << "average recall: "
                  << avg_recall / static_cast<double>(test_number) << "\n";
        std::cout << "average latency (us): "
                  << stats.online_ms * 1000.0 /
                         static_cast<double>(test_number) << "\n";
        std::cout << "wall latency including setup (us): "
                  << wall_us / static_cast<double>(test_number) << "\n";
        std::cout << "base/index copy or build (ms): "
                  << stats.build_ms + stats.base_copy_ms << "\n";
        std::cout << "query copy (ms): " << stats.query_copy_ms << "\n";
        std::cout << "score/probe compute (ms): " << stats.score_ms << "\n";
        std::cout << "topk/search compute (ms): " << stats.topk_ms << "\n";
        std::cout << "result copy (ms): " << stats.result_copy_ms << "\n";

        delete[] test_query;
        delete[] test_gt;
        delete[] base;
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "ann-gpu failed: " << ex.what() << "\n";
        return 1;
    }
}
