#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <queue>
#include <set>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#include "simd/ann_bench_common.h"
#include "simd/pq_scan_avx2.h"
#include "gpu_ann_search.cuh"

namespace {

using SearchHeap = std::priority_queue<std::pair<float, uint32_t> >;

struct Config {
    std::vector<size_t> query_ns;
    std::vector<size_t> candidate_ps;
    size_t chunk = 64;
    std::string output_csv = "report/results/gpu_hybrid.csv";
};

struct Dataset {
    std::unique_ptr<float[]> base;
    std::unique_ptr<float[]> queries;
    std::unique_ptr<int[]> gt;
    size_t base_n = 0;
    size_t base_d = 0;
    size_t query_n = 0;
    size_t query_d = 0;
    size_t gt_n = 0;
    size_t gt_d = 0;
};

struct HybridStats {
    std::string method;
    size_t query_n = 0;
    size_t candidate_p = 0;
    double recall_at_10 = 0.0;
    double recall_at_100 = 0.0;
    double online_latency_us = 0.0;
    double wall_latency_us = 0.0;
    double h2d_ms = 0.0;
    double score_ms = 0.0;
    double score_d2h_ms = 0.0;
    double candidate_select_ms = 0.0;
    double cpu_rerank_ms = 0.0;
    double qps = 0.0;
};

static std::vector<size_t> ParseSizeList(const std::string& text) {
    std::vector<size_t> out;
    size_t start = 0;
    while (start <= text.size()) {
        const size_t comma = text.find(',', start);
        const std::string token = text.substr(
            start, comma == std::string::npos ? std::string::npos : comma - start);
        if (!token.empty()) {
            out.push_back(static_cast<size_t>(std::strtoull(token.c_str(), NULL, 10)));
        }
        if (comma == std::string::npos) {
            break;
        }
        start = comma + 1;
    }
    return out;
}

static Config ParseArgs(int argc, char** argv) {
    Config cfg;
    cfg.query_ns.push_back(1);
    cfg.query_ns.push_back(128);
    cfg.query_ns.push_back(512);
    cfg.query_ns.push_back(2000);
    cfg.candidate_ps.push_back(100);
    cfg.candidate_ps.push_back(300);
    cfg.candidate_ps.push_back(500);
    cfg.candidate_ps.push_back(1000);

    for (int i = 1; i < argc; ++i) {
        const std::string arg = argv[i];
        const size_t eq = arg.find('=');
        if (eq == std::string::npos || arg.substr(0, 2) != "--") {
            throw std::runtime_error("invalid argument: " + arg);
        }
        const std::string key = arg.substr(2, eq - 2);
        const std::string value = arg.substr(eq + 1);
        if (key == "query_n") {
            cfg.query_ns = ParseSizeList(value);
        } else if (key == "candidate_p") {
            cfg.candidate_ps = ParseSizeList(value);
        } else if (key == "chunk") {
            cfg.chunk = static_cast<size_t>(std::strtoull(value.c_str(), NULL, 10));
        } else if (key == "out") {
            cfg.output_csv = value;
        } else {
            throw std::runtime_error("unknown argument: " + key);
        }
    }
    if (cfg.query_ns.empty() || cfg.candidate_ps.empty() || cfg.chunk == 0) {
        throw std::runtime_error("empty gpu hybrid configuration");
    }
    return cfg;
}

static Dataset LoadDataset(size_t max_query_n) {
    Dataset data;
    const std::string path = ann_bench::DefaultDataPath();
    data.queries = ann_bench::LoadData<float>(
        path + "DEEP100K.query.fbin", data.query_n, data.query_d);
    data.gt = ann_bench::LoadData<int>(
        path + "DEEP100K.gt.query.100k.top100.bin", data.gt_n, data.gt_d);
    data.base = ann_bench::LoadData<float>(
        path + "DEEP100K.base.100k.fbin", data.base_n, data.base_d);
    if (data.base_d != data.query_d) {
        throw std::runtime_error("base/query dimension mismatch");
    }
    data.query_n = std::min(data.query_n, data.gt_n);
    data.query_n = std::min(data.query_n, max_query_n);
    return data;
}

static void EnsureParentDir(const std::string& file_path) {
    const size_t pos = file_path.find_last_of("/\\");
    if (pos == std::string::npos) {
        return;
    }
    ann_bench::EnsureDirectory(file_path.substr(0, pos));
}

static void PushTopK(SearchHeap& heap, float dist, uint32_t id, size_t k) {
    if (heap.size() < k) {
        heap.push(std::make_pair(dist, id));
    } else if (dist < heap.top().first) {
        heap.push(std::make_pair(dist, id));
        heap.pop();
    }
}

static SearchHeap RerankCandidates(const float* base, const float* query,
                                   size_t dim,
                                   const std::vector<uint32_t>& candidates,
                                   size_t k) {
    SearchHeap result;
    for (size_t i = 0; i < candidates.size(); ++i) {
        const uint32_t id = candidates[i];
        const float dist = ann_avx2::ip_distance_avx2(
            base + static_cast<size_t>(id) * dim, query, static_cast<int>(dim));
        PushTopK(result, dist, id, k);
    }
    return result;
}

static double RecallAtK(SearchHeap heap, const int* gt, size_t k) {
    std::set<uint32_t> truth;
    for (size_t i = 0; i < k; ++i) {
        truth.insert(static_cast<uint32_t>(gt[i]));
    }
    std::vector<std::pair<float, uint32_t> > returned;
    returned.reserve(heap.size());
    while (!heap.empty()) {
        returned.push_back(heap.top());
        heap.pop();
    }
    std::sort(returned.begin(), returned.end());
    size_t hits = 0;
    const size_t limit = std::min(k, returned.size());
    for (size_t i = 0; i < limit; ++i) {
        const uint32_t id = returned[i].second;
        if (truth.find(id) != truth.end()) {
            ++hits;
        }
    }
    return static_cast<double>(hits) / static_cast<double>(k);
}

static std::vector<uint32_t> SelectTopPFromScores(const float* scores,
                                                  size_t base_n,
                                                  size_t candidate_p) {
    SearchHeap heap;
    candidate_p = std::min(candidate_p, base_n);
    for (size_t i = 0; i < base_n; ++i) {
        const float dist = 1.0f - scores[i];
        PushTopK(heap, dist, static_cast<uint32_t>(i), candidate_p);
    }
    std::vector<uint32_t> candidates;
    candidates.reserve(candidate_p);
    while (!heap.empty()) {
        candidates.push_back(heap.top().second);
        heap.pop();
    }
    return candidates;
}

static HybridStats RunHybrid(const Dataset& data, size_t query_n,
                             size_t candidate_p, size_t chunk_size) {
    HybridStats stats;
    stats.method = "gpu_cublas_coarse_cpu_avx2_rerank";
    stats.query_n = query_n;
    stats.candidate_p = candidate_p;

    float* d_base = NULL;
    float* d_queries = NULL;
    float* d_scores = NULL;
    cublasHandle_t handle = NULL;
    cudaEvent_t ev_a, ev_b, ev_c, ev_d;

    const size_t base_bytes = data.base_n * data.base_d * sizeof(float);
    const size_t max_score_bytes = chunk_size * data.base_n * sizeof(float);
    ANN_GPU_CHECK(cudaMalloc(&d_base, base_bytes));
    ANN_GPU_CHECK(cudaMalloc(&d_queries, chunk_size * data.base_d * sizeof(float)));
    ANN_GPU_CHECK(cudaMalloc(&d_scores, max_score_bytes));
    ANN_CUBLAS_CHECK(cublasCreate(&handle));
    ANN_GPU_CHECK(cudaEventCreate(&ev_a));
    ANN_GPU_CHECK(cudaEventCreate(&ev_b));
    ANN_GPU_CHECK(cudaEventCreate(&ev_c));
    ANN_GPU_CHECK(cudaEventCreate(&ev_d));

    const auto wall_begin = std::chrono::high_resolution_clock::now();
    ANN_GPU_CHECK(cudaEventRecord(ev_a));
    ANN_GPU_CHECK(cudaMemcpy(d_base, data.base.get(), base_bytes,
                             cudaMemcpyHostToDevice));
    ANN_GPU_CHECK(cudaEventRecord(ev_b));
    ANN_GPU_CHECK(cudaEventSynchronize(ev_b));
    stats.h2d_ms += ann_gpu::ElapsedMs(ev_a, ev_b);

    std::vector<float> host_scores(chunk_size * data.base_n);
    double total_recall10 = 0.0;
    double total_recall100 = 0.0;

    for (size_t begin = 0; begin < query_n; begin += chunk_size) {
        const size_t chunk = std::min(chunk_size, query_n - begin);
        const size_t query_bytes = chunk * data.base_d * sizeof(float);
        const size_t score_bytes = chunk * data.base_n * sizeof(float);

        ANN_GPU_CHECK(cudaEventRecord(ev_a));
        ANN_GPU_CHECK(cudaMemcpy(d_queries, data.queries.get() + begin * data.base_d,
                                 query_bytes, cudaMemcpyHostToDevice));
        ANN_GPU_CHECK(cudaEventRecord(ev_b));
        const float alpha = 1.0f;
        const float beta = 0.0f;
        ANN_CUBLAS_CHECK(cublasSgemm(
            handle, CUBLAS_OP_T, CUBLAS_OP_N,
            static_cast<int>(data.base_n), static_cast<int>(chunk),
            static_cast<int>(data.base_d), &alpha, d_base,
            static_cast<int>(data.base_d), d_queries,
            static_cast<int>(data.base_d), &beta, d_scores,
            static_cast<int>(data.base_n)));
        ANN_GPU_CHECK(cudaEventRecord(ev_c));
        ANN_GPU_CHECK(cudaMemcpy(host_scores.data(), d_scores, score_bytes,
                                 cudaMemcpyDeviceToHost));
        ANN_GPU_CHECK(cudaEventRecord(ev_d));
        ANN_GPU_CHECK(cudaEventSynchronize(ev_d));
        stats.h2d_ms += ann_gpu::ElapsedMs(ev_a, ev_b);
        stats.score_ms += ann_gpu::ElapsedMs(ev_b, ev_c);
        stats.score_d2h_ms += ann_gpu::ElapsedMs(ev_c, ev_d);

        const auto select_begin = std::chrono::high_resolution_clock::now();
        std::vector<std::vector<uint32_t> > all_candidates(chunk);
        for (size_t q = 0; q < chunk; ++q) {
            all_candidates[q] = SelectTopPFromScores(
                host_scores.data() + q * data.base_n, data.base_n, candidate_p);
        }
        const auto select_end = std::chrono::high_resolution_clock::now();
        stats.candidate_select_ms += std::chrono::duration<double, std::milli>(
            select_end - select_begin).count();

        const auto rerank_begin = std::chrono::high_resolution_clock::now();
        for (size_t q = 0; q < chunk; ++q) {
            const size_t qid = begin + q;
            SearchHeap result = RerankCandidates(
                data.base.get(), data.queries.get() + qid * data.base_d,
                data.base_d, all_candidates[q], 100);
            total_recall10 += RecallAtK(result, data.gt.get() + qid * data.gt_d, 10);
            total_recall100 += RecallAtK(result, data.gt.get() + qid * data.gt_d, 100);
        }
        const auto rerank_end = std::chrono::high_resolution_clock::now();
        stats.cpu_rerank_ms += std::chrono::duration<double, std::milli>(
            rerank_end - rerank_begin).count();
    }

    const auto wall_end = std::chrono::high_resolution_clock::now();
    const double wall_ms = std::chrono::duration<double, std::milli>(
        wall_end - wall_begin).count();
    const double online_ms = stats.h2d_ms + stats.score_ms + stats.score_d2h_ms +
                             stats.candidate_select_ms + stats.cpu_rerank_ms;
    stats.recall_at_10 = total_recall10 / static_cast<double>(query_n);
    stats.recall_at_100 = total_recall100 / static_cast<double>(query_n);
    stats.online_latency_us = online_ms * 1000.0 / static_cast<double>(query_n);
    stats.wall_latency_us = wall_ms * 1000.0 / static_cast<double>(query_n);
    stats.qps = static_cast<double>(query_n) / (online_ms / 1000.0);

    ANN_GPU_CHECK(cudaEventDestroy(ev_a));
    ANN_GPU_CHECK(cudaEventDestroy(ev_b));
    ANN_GPU_CHECK(cudaEventDestroy(ev_c));
    ANN_GPU_CHECK(cudaEventDestroy(ev_d));
    ANN_CUBLAS_CHECK(cublasDestroy(handle));
    ANN_GPU_CHECK(cudaFree(d_base));
    ANN_GPU_CHECK(cudaFree(d_queries));
    ANN_GPU_CHECK(cudaFree(d_scores));
    return stats;
}

static HybridStats RunGpuOnly(const Dataset& data, size_t query_n) {
    HybridStats stats;
    stats.method = "gpu_cublas_tree_top10";
    stats.query_n = query_n;
    stats.candidate_p = 10;

    ann_gpu::GpuSearchStats gpu_stats;
    const auto begin = std::chrono::high_resolution_clock::now();
    std::vector<ann_gpu::SearchHeap> heaps = ann_gpu::gpu_gemm_search(
        data.base.get(), data.queries.get(), data.base_n, query_n, data.base_d,
        10, &gpu_stats, 128, 256, true, true);
    const auto end = std::chrono::high_resolution_clock::now();
    double recall10 = 0.0;
    for (size_t q = 0; q < query_n; ++q) {
        recall10 += RecallAtK(heaps[q], data.gt.get() + q * data.gt_d, 10);
    }
    const double wall_ms = std::chrono::duration<double, std::milli>(end - begin).count();
    stats.recall_at_10 = recall10 / static_cast<double>(query_n);
    stats.recall_at_100 = 0.0;
    stats.h2d_ms = gpu_stats.base_copy_ms + gpu_stats.query_copy_ms;
    stats.score_ms = gpu_stats.score_ms;
    stats.score_d2h_ms = gpu_stats.result_copy_ms;
    stats.cpu_rerank_ms = 0.0;
    stats.online_latency_us = gpu_stats.online_ms * 1000.0 / static_cast<double>(query_n);
    stats.wall_latency_us = wall_ms * 1000.0 / static_cast<double>(query_n);
    stats.qps = static_cast<double>(query_n) / (gpu_stats.online_ms / 1000.0);
    return stats;
}

static void WriteHeader(std::ofstream* out) {
    *out << "method,query_n,candidate_p,recall_at_10,recall_at_100,"
            "online_latency_us,wall_latency_us,h2d_ms,score_ms,score_d2h_ms,"
            "candidate_select_ms,cpu_rerank_ms,qps\n";
}

static void WriteRow(std::ofstream* out, const HybridStats& s) {
    *out << std::fixed << std::setprecision(5)
         << s.method << ','
         << s.query_n << ','
         << s.candidate_p << ','
         << s.recall_at_10 << ','
         << s.recall_at_100 << ','
         << s.online_latency_us << ','
         << s.wall_latency_us << ','
         << s.h2d_ms << ','
         << s.score_ms << ','
         << s.score_d2h_ms << ','
         << s.candidate_select_ms << ','
         << s.cpu_rerank_ms << ','
         << s.qps << '\n';
}

}  // namespace

int main(int argc, char** argv) {
    try {
        Config cfg = ParseArgs(argc, argv);
        size_t max_query = 0;
        for (size_t i = 0; i < cfg.query_ns.size(); ++i) {
            max_query = std::max(max_query, cfg.query_ns[i]);
        }
        Dataset data = LoadDataset(max_query);
        EnsureParentDir(cfg.output_csv);
        std::ofstream csv(cfg.output_csv.c_str());
        if (!csv) {
            throw std::runtime_error("failed to open output csv: " + cfg.output_csv);
        }
        WriteHeader(&csv);
        cudaDeviceProp prop;
        ANN_GPU_CHECK(cudaGetDeviceProperties(&prop, 0));
        std::cerr << "gpu_hybrid experiment: device=\"" << prop.name
                  << "\", base_n=" << data.base_n
                  << ", max_query_n=" << data.query_n
                  << ", dim=" << data.base_d << "\n";

        for (size_t qi = 0; qi < cfg.query_ns.size(); ++qi) {
            const size_t qn = std::min(cfg.query_ns[qi], data.query_n);
            HybridStats gpu_only = RunGpuOnly(data, qn);
            WriteRow(&csv, gpu_only);
            std::cout << gpu_only.method << ", query_n=" << qn
                      << ", recall@10=" << gpu_only.recall_at_10
                      << ", latency_us=" << gpu_only.online_latency_us << "\n";

            for (size_t pi = 0; pi < cfg.candidate_ps.size(); ++pi) {
                HybridStats hybrid = RunHybrid(data, qn, cfg.candidate_ps[pi],
                                               cfg.chunk);
                WriteRow(&csv, hybrid);
                std::cout << hybrid.method << ", query_n=" << qn
                          << ", p=" << hybrid.candidate_p
                          << ", recall@10=" << hybrid.recall_at_10
                          << ", recall@100=" << hybrid.recall_at_100
                          << ", latency_us=" << hybrid.online_latency_us << "\n";
            }
        }
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "gpu_hybrid failed: " << ex.what() << "\n";
        return 1;
    }
}
