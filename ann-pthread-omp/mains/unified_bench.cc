// Unified benchmark for Kunpeng server (single qsub run)
// 包含所有算法 × 所有调度策略 × 所有线程数的实验矩阵
// 用法: cp mains/unified_bench.cc main.cc && g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++17 && bash test.sh 2 1

#include <algorithm>
#include <chrono>
#include <cctype>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <memory>
#include <sstream>
#include <queue>
#include <set>
#include <string>
#include <utility>
#include <vector>

// 公共工具（并行头文件内部按平台条件包含 SIMD 内核）
#include "simd/ann_bench_common.h"

// Pthread 并行
#include "pthread/thread_pool.h"
#include "pthread/flat_scan_pthread.h"
#include "pthread/sq_scan_pthread.h"
#include "pthread/pq_scan_pthread.h"
#include "pthread/pq_fastscan_pthread.h"

// OpenMP 并行
#include "omp/flat_scan_omp.h"
#include "omp/sq_scan_omp.h"
#include "omp/pq_scan_omp.h"
#include "omp/pq_fastscan_omp.h"

// IVF
#include "ivf/ivf_index.h"
#include "ivf/ivf_scan_simd.h"
#include "ivf/ivf_scan_pthread.h"
#include "ivf/ivf_scan_omp.h"
#include "ivf/ivf_pq_simd.h"
#include "ivf/ivf_pq_pthread.h"
#include "ivf/ivf_pq_omp.h"

// HNSW
#include "hnsw/hnsw_graph_utils.h"
#include "hnsw/hnsw_search_pthread.h"
#include "hnsw/hnsw_search_omp.h"
#include "hnsw/hnsw_edge_parallel.h"
#include "hnsw/hnsw_layer0_parallel.h"
#include "hnsw/hnsw_ivf_nested.h"

#ifndef ANN_DEFAULT_PHASES
#define ANN_DEFAULT_PHASES ""
#endif

#ifndef ANN_DEFAULT_RESULTS_FILE
#define ANN_DEFAULT_RESULTS_FILE "results/kunpeng_results.txt"
#endif

#ifndef ANN_DEFAULT_CKPT_FILE
#define ANN_DEFAULT_CKPT_FILE "results/kunpeng_checkpoint.txt"
#endif

#ifndef ANN_DEFAULT_DISABLE_CHECKPOINT
#define ANN_DEFAULT_DISABLE_CHECKPOINT 0
#endif

// ============================================================
// 公共工具
// ============================================================
using FlatHeap   = std::priority_queue<std::pair<float, uint32_t>>;
using CoarseHeap = std::priority_queue<std::pair<uint32_t, uint32_t>>;
using IVFHeap    = ann_ivf::SearchHeap;
using HNSWHeap   = ann_hnsw::SearchHeap;

static constexpr size_t kK = 10;

struct DataCtx {
    std::unique_ptr<float[]> queries;
    std::unique_ptr<int[]>   gt;
    std::unique_ptr<float[]> base;
    size_t query_n = 0, base_n = 0, gt_dim = 0, d = 0;
};

static DataCtx LoadOnce() {
    DataCtx ctx;
    size_t gt_n = 0, qd = 0, bd = 0;
    std::string path = ann_bench::DefaultDataPath();
    ctx.queries = ann_bench::LoadData<float>(path + "DEEP100K.query.fbin", ctx.query_n, qd);
    ctx.gt      = ann_bench::LoadData<int>  (path + "DEEP100K.gt.query.100k.top100.bin", gt_n, ctx.gt_dim);
    ctx.base    = ann_bench::LoadData<float>(path + "DEEP100K.base.100k.fbin", ctx.base_n, bd);
    ctx.query_n = std::min<size_t>(ctx.query_n, 2000);
    ctx.d       = qd;  (void)bd;
    return ctx;
}

static double RecallAtK_Float(std::vector<FlatHeap>& results, const int* gt,
                               size_t query_n, size_t gt_dim) {
    double total = 0.0;
    for (size_t i = 0; i < query_n; ++i) {
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < kK; ++j) gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
        size_t hits = 0;
        while (!results[i].empty()) { if (gtset.count(results[i].top().second)) ++hits; results[i].pop(); }
        total += static_cast<double>(hits) / static_cast<double>(kK);
    }
    return total / static_cast<double>(query_n);
}

static double RecallAtK_IVF(std::vector<IVFHeap>& results, const int* gt,
                             size_t query_n, size_t gt_dim) {
    double total = 0.0;
    for (size_t i = 0; i < query_n; ++i) {
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < kK; ++j) gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
        size_t hits = 0;
        while (!results[i].empty()) { if (gtset.count(results[i].top().second)) ++hits; results[i].pop(); }
        total += static_cast<double>(hits) / static_cast<double>(kK);
    }
    return total / static_cast<double>(query_n);
}

static double RecallAtK_HNSW(std::vector<HNSWHeap>& results, const int* gt,
                              size_t query_n, size_t gt_dim) {
    double total = 0.0;
    for (size_t i = 0; i < query_n; ++i) {
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < kK; ++j) gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
        size_t hits = 0;
        while (!results[i].empty()) { if (gtset.count(results[i].top().second)) ++hits; results[i].pop(); }
        total += static_cast<double>(hits) / static_cast<double>(kK);
    }
    return total / static_cast<double>(query_n);
}

// ---- 续跑 checkpoint ----
static const char* EnvOrDefault(const char* name, const char* fallback) {
    const char* value = std::getenv(name);
    return (value && value[0]) ? value : fallback;
}

static bool CheckpointDisabled() {
    const char* value = std::getenv("ANN_DISABLE_CHECKPOINT");
    if (value && std::string(value) == "1") {
        return true;
    }
    return ANN_DEFAULT_DISABLE_CHECKPOINT != 0;
}

static bool PhaseRequested(const char* phase) {
    const char* phases = std::getenv("ANN_PHASES");
    if (!phases || !phases[0]) {
        phases = ANN_DEFAULT_PHASES;
    }
    if (!phases || !phases[0]) {
        return true;
    }

    std::stringstream ss(phases);
    std::string token;
    while (std::getline(ss, token, ',')) {
        token.erase(std::remove_if(token.begin(), token.end(),
                                   [](unsigned char c) { return std::isspace(c); }),
                    token.end());
        if (token == phase) {
            return true;
        }
    }
    return false;
}

static void CkptWrite(const char* phase) {
    if (CheckpointDisabled()) {
        return;
    }
    const char* ckpt_file = EnvOrDefault("ANN_CKPT_FILE", ANN_DEFAULT_CKPT_FILE);
    std::ofstream of(ckpt_file, std::ios::trunc);
    of << phase << "\n";
}

static void LogFile(const std::string& line) {
    const char* results_file = EnvOrDefault("ANN_RESULTS_FILE", ANN_DEFAULT_RESULTS_FILE);
    std::ofstream of(results_file, std::ios::app);
    of << line << "\n";
    of.close();
}

static bool CkptDone(const char* phase) {
    if (CheckpointDisabled()) {
        return false;
    }
    const char* ckpt_file = EnvOrDefault("ANN_CKPT_FILE", ANN_DEFAULT_CKPT_FILE);
    std::ifstream in(ckpt_file);
    std::string last;
    std::getline(in, last);
    if (last.empty()) return false;
    const char* order[] = {"flat","sq","pq","fastscan","ivf","ivfpq_global","ivfpq_local","hnsw","hnsw_nested",nullptr};
    int idx_last = -1, idx_cur = -1;
    for (int i = 0; order[i]; ++i) {
        if (last == order[i]) idx_last = i;
        if (phase == order[i]) idx_cur = i;
    }
    return idx_cur <= idx_last;
}

static void Print(const char* algo, const char* strat, int nthr,
                  double recall, double lat_us, const char* extra = "") {
    std::ostringstream oss;
    oss << std::fixed << std::setprecision(5);
    oss << "RESULT " << algo << " " << strat
        << " t=" << nthr
        << " recall=" << recall
        << " latency_us=" << lat_us;
    if (extra[0]) oss << " " << extra;
    std::string line = oss.str();
    std::cout << line << std::endl;
    LogFile(line);  // 同时写入文件，方便实时监控
}

template<typename F>
static double TimeOnce_us(F&& fn) {
    auto t0 = std::chrono::high_resolution_clock::now();
    fn();
    auto t1 = std::chrono::high_resolution_clock::now();
    return std::chrono::duration<double, std::micro>(t1 - t0).count();
}

static void Section(const char* name) {
    std::cerr << "=== " << name << " ===\n";
}

// ============================================================
// Flat 实验
// ============================================================
static void RunFlat(const DataCtx& ctx) {
    Section("Flat");
    for (int nthr : {1, 2, 4, 8, 16}) {
        // OMP inter
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ flat_search_inter_omp(ctx.base.get(), ctx.queries.get(), ctx.base_n, ctx.query_n, ctx.d, kK, nthr, res); });
          Print("flat","omp_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n); }
        // OMP intra
        { std::vector<FlatHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=flat_search_intra_omp(ctx.base.get(),ctx.queries.get()+i*ctx.d,ctx.base_n,ctx.d,kK,nthr); });
          Print("flat","omp_intra",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n); }
        // pthread static inter
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ flat_search_inter_static(ctx.base.get(),ctx.queries.get(),ctx.base_n,ctx.query_n,ctx.d,kK,nthr,res); });
          Print("flat","pthread_static_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n); }
        // pthread dynamic inter
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ flat_search_inter_dynamic(ctx.base.get(),ctx.queries.get(),ctx.base_n,ctx.query_n,ctx.d,kK,nthr,res); });
          Print("flat","pthread_dynamic_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n); }
        // pthread pool inter
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ flat_search_inter_pool(ctx.base.get(),ctx.queries.get(),ctx.base_n,ctx.query_n,ctx.d,kK,nthr,res); });
          Print("flat","pthread_pool_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n); }
        // pthread static intra
        { std::vector<FlatHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=flat_search_intra_static(ctx.base.get(),ctx.queries.get()+i*ctx.d,ctx.base_n,ctx.d,kK,nthr); });
          Print("flat","pthread_static_intra",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n); }
        // pthread dynamic intra
        { std::vector<FlatHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=flat_search_intra_dynamic(ctx.base.get(),ctx.queries.get()+i*ctx.d,ctx.base_n,ctx.d,kK,nthr); });
          Print("flat","pthread_dynamic_intra",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n); }
        // pthread pool intra
        { std::vector<FlatHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=flat_search_intra_pool(ctx.base.get(),ctx.queries.get()+i*ctx.d,ctx.base_n,ctx.d,kK,nthr); });
          Print("flat","pthread_pool_intra",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n); }
    }
}

// ============================================================
// SQ 实验
// ============================================================
static void RunSQ(const DataCtx& ctx) {
    Section("SQ");
    SQIndex sq_idx; sq_idx.build(ctx.base.get(), ctx.base_n, ctx.d);
    for (int nthr : {1, 4, 8, 16}) {
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ sq_search_inter_omp(ctx.base.get(),ctx.queries.get(),ctx.base_n,ctx.query_n,ctx.d,kK,sq_idx,100,nthr,res); });
          Print("sq","omp_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=100"); }
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ sq_search_inter_static(ctx.base.get(),ctx.queries.get(),ctx.base_n,ctx.query_n,ctx.d,kK,sq_idx,100,nthr,res); });
          Print("sq","pthread_static_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=100"); }
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ sq_search_inter_dynamic(ctx.base.get(),ctx.queries.get(),ctx.base_n,ctx.query_n,ctx.d,kK,sq_idx,100,nthr,res); });
          Print("sq","pthread_dynamic_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=100"); }
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ sq_search_inter_pool(ctx.base.get(),ctx.queries.get(),ctx.base_n,ctx.query_n,ctx.d,kK,sq_idx,100,nthr,res); });
          Print("sq","pthread_pool_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=100"); }
        // intra
        { std::vector<FlatHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=sq_search_intra_omp(ctx.base.get(),ctx.queries.get()+i*ctx.d,ctx.base_n,ctx.d,kK,sq_idx,100,nthr); });
          Print("sq","omp_intra",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=100"); }
        { std::vector<FlatHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=sq_search_intra_static(ctx.base.get(),ctx.queries.get()+i*ctx.d,ctx.base_n,ctx.d,kK,sq_idx,100,nthr); });
          Print("sq","pthread_static_intra",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=100"); }
        { std::vector<FlatHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=sq_search_intra_dynamic(ctx.base.get(),ctx.queries.get()+i*ctx.d,ctx.base_n,ctx.d,kK,sq_idx,100,nthr); });
          Print("sq","pthread_dynamic_intra",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=100"); }
        { std::vector<FlatHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=sq_search_intra_pool(ctx.base.get(),ctx.queries.get()+i*ctx.d,ctx.base_n,ctx.d,kK,sq_idx,100,nthr); });
          Print("sq","pthread_pool_intra",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=100"); }
    }
}

// ============================================================
// PQ 实验
// ============================================================
static void RunPQ(const DataCtx& ctx) {
    Section("PQ");
    PQIndex pq_idx; pq_idx.build(ctx.base.get(), ctx.base_n, ctx.d, 8, 256, 20);
    for (int nthr : {1, 2, 4, 8, 16}) {
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ pq_search_inter_omp(ctx.base.get(),ctx.queries.get(),ctx.base_n,ctx.query_n,ctx.d,kK,pq_idx,1000,nthr,res); });
          Print("pq","omp_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=1000"); }
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ pq_search_inter_static(ctx.base.get(),ctx.queries.get(),ctx.base_n,ctx.query_n,ctx.d,kK,pq_idx,1000,nthr,res); });
          Print("pq","pthread_static_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=1000"); }
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ pq_search_inter_dynamic(ctx.base.get(),ctx.queries.get(),ctx.base_n,ctx.query_n,ctx.d,kK,pq_idx,1000,nthr,res); });
          Print("pq","pthread_dynamic_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=1000"); }
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ pq_search_inter_pool(ctx.base.get(),ctx.queries.get(),ctx.base_n,ctx.query_n,ctx.d,kK,pq_idx,1000,nthr,res); });
          Print("pq","pthread_pool_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=1000"); }
        // intra
        { std::vector<FlatHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=pq_search_intra_omp(ctx.base.get(),ctx.queries.get()+i*ctx.d,ctx.base_n,ctx.d,kK,pq_idx,1000,nthr); });
          Print("pq","omp_intra",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=1000"); }
        { std::vector<FlatHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=pq_search_intra_static(ctx.base.get(),ctx.queries.get()+i*ctx.d,ctx.base_n,ctx.d,kK,pq_idx,1000,nthr); });
          Print("pq","pthread_static_intra",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=1000"); }
        { std::vector<FlatHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=pq_search_intra_dynamic(ctx.base.get(),ctx.queries.get()+i*ctx.d,ctx.base_n,ctx.d,kK,pq_idx,1000,nthr); });
          Print("pq","pthread_dynamic_intra",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=1000"); }
        { std::vector<FlatHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=pq_search_intra_pool(ctx.base.get(),ctx.queries.get()+i*ctx.d,ctx.base_n,ctx.d,kK,pq_idx,1000,nthr); });
          Print("pq","pthread_pool_intra",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=1000"); }
    }
}

// ============================================================
// FastScan 实验（ARM NEON 上有 segfault，待调试，暂时跳过）
// ============================================================
static void RunFastScan(const DataCtx& ctx) {
    Section("FastScan");
    ann_fs::FastScanIndex fs_idx;
    ann_fs::train_fastscan(fs_idx, ctx.base.get(), static_cast<int>(ctx.base_n), static_cast<int>(ctx.d));
    ann_fs::encode_fastscan(fs_idx, ctx.base.get());
    for (int nthr : {1, 4, 8, 16}) {
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ fastscan_search_inter_omp(fs_idx,ctx.base.get(),ctx.queries.get(),ctx.query_n,kK,1000,nthr,res); });
          Print("fastscan","omp_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=1000"); }
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ fastscan_search_inter_static(fs_idx,ctx.base.get(),ctx.queries.get(),ctx.query_n,kK,1000,nthr,res); });
          Print("fastscan","pthread_static_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=1000"); }
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ fastscan_search_inter_dynamic(fs_idx,ctx.base.get(),ctx.queries.get(),ctx.query_n,kK,1000,nthr,res); });
          Print("fastscan","pthread_dynamic_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=1000"); }
        { std::vector<FlatHeap> res;
          double us = TimeOnce_us([&]{ fastscan_search_inter_pool(fs_idx,ctx.base.get(),ctx.queries.get(),ctx.query_n,kK,1000,nthr,res); });
          Print("fastscan","pthread_pool_inter",nthr, RecallAtK_Float(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "p=1000"); }
    }
}

// ============================================================
// IVF 实验
// ============================================================
static void RunIVF(const DataCtx& ctx) {
    Section("IVF");
    const size_t nlist = 16, nprobe = 4;
    ann_ivf::IVFIndex ivf_idx; ivf_idx.build(ctx.base.get(), ctx.base_n, ctx.d, nlist, 8);
    for (int nthr : {1, 2, 4, 8, 16}) {
        // SIMD serial
        if (nthr == 1) {
            std::vector<IVFHeap> res(ctx.query_n);
            double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_search(ivf_idx,ctx.queries.get()+i*ctx.d,kK,nprobe); });
            Print("ivf","simd_serial",1, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4"); }
        // OMP inter
        { std::vector<IVFHeap> res;
          double us = TimeOnce_us([&]{ ivf_search_inter_omp(ivf_idx,ctx.queries.get(),ctx.query_n,kK,nprobe,nthr,res); });
          Print("ivf","omp_inter",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4"); }
        // pthread static inter
        { std::vector<IVFHeap> res;
          double us = TimeOnce_us([&]{ ivf_search_inter_static(ivf_idx,ctx.queries.get(),ctx.query_n,kK,nprobe,nthr,res); });
          Print("ivf","pthread_static_inter",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4"); }
        // pthread dynamic inter
        { std::vector<IVFHeap> res;
          double us = TimeOnce_us([&]{ ivf_search_inter_dynamic(ivf_idx,ctx.queries.get(),ctx.query_n,kK,nprobe,nthr,res); });
          Print("ivf","pthread_dynamic_inter",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4"); }
        // pthread pool inter
        { std::vector<IVFHeap> res;
          double us = TimeOnce_us([&]{ ivf_search_inter_pool(ivf_idx,ctx.queries.get(),ctx.query_n,kK,nprobe,nthr,res); });
          Print("ivf","pthread_pool_inter",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4"); }
        // intra
        { std::vector<IVFHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_search_intra_omp(ivf_idx,ctx.queries.get()+i*ctx.d,kK,nprobe,nthr); });
          Print("ivf","omp_intra",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4"); }
        { std::vector<IVFHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_search_intra_static(ivf_idx,ctx.queries.get()+i*ctx.d,kK,nprobe,nthr); });
          Print("ivf","pthread_static_intra",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4"); }
        { std::vector<IVFHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_search_intra_dynamic(ivf_idx,ctx.queries.get()+i*ctx.d,kK,nprobe,nthr); });
          Print("ivf","pthread_dynamic_intra",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4"); }
    }
}

// ============================================================
// IVF-PQ 实验
// ============================================================
static void RunIVFPQ(const DataCtx& ctx) {
    if (PhaseRequested("ivfpq_global") && !CkptDone("ivfpq_global")) {
        Section("IVF-PQ global");
        {
            ann_ivfpq::IVFPQIndex idx;
            idx.build(ctx.base.get(), ctx.base_n, ctx.d, 16, ann_ivfpq::BuildMode::GlobalPQFirst, 8, 8);
            for (int nthr : {1, 2, 4, 8, 16}) {
                { std::vector<IVFHeap> res(ctx.query_n);
                  double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_pq_search(idx,ctx.queries.get()+i*ctx.d,kK,4,2000); });
                  Print("ivfpq_global","simd_serial",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=2000"); }
                { std::vector<IVFHeap> res;
                  double us = TimeOnce_us([&]{ ivf_pq_search_inter_omp(idx,ctx.queries.get(),ctx.query_n,kK,4,2000,nthr,res); });
                  Print("ivfpq_global","omp_inter",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=2000"); }
                { std::vector<IVFHeap> res;
                  double us = TimeOnce_us([&]{ ivf_pq_search_inter_static(idx,ctx.queries.get(),ctx.query_n,kK,4,2000,nthr,res); });
                  Print("ivfpq_global","pthread_static_inter",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=2000"); }
                { std::vector<IVFHeap> res;
                  double us = TimeOnce_us([&]{ ivf_pq_search_inter_dynamic(idx,ctx.queries.get(),ctx.query_n,kK,4,2000,nthr,res); });
                  Print("ivfpq_global","pthread_dynamic_inter",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=2000"); }
                { std::vector<IVFHeap> res;
                  double us = TimeOnce_us([&]{ ivf_pq_search_inter_pool(idx,ctx.queries.get(),ctx.query_n,kK,4,2000,nthr,res); });
                  Print("ivfpq_global","pthread_pool_inter",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=2000"); }
                // intra
                { std::vector<IVFHeap> res(ctx.query_n);
                  double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_pq_search_intra_omp(idx,ctx.queries.get()+i*ctx.d,kK,4,2000,nthr); });
                  Print("ivfpq_global","omp_intra",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=2000"); }
                { std::vector<IVFHeap> res(ctx.query_n);
                  double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_pq_search_intra_static(idx,ctx.queries.get()+i*ctx.d,kK,4,2000,nthr); });
                  Print("ivfpq_global","pthread_static_intra",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=2000"); }
                { std::vector<IVFHeap> res(ctx.query_n);
                  double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_pq_search_intra_dynamic(idx,ctx.queries.get()+i*ctx.d,kK,4,2000,nthr); });
                  Print("ivfpq_global","pthread_dynamic_intra",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=2000"); }
                { std::vector<IVFHeap> res(ctx.query_n);
                  double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_pq_search_intra_pool(idx,ctx.queries.get()+i*ctx.d,kK,4,2000,nthr); });
                  Print("ivfpq_global","pthread_pool_intra",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=2000"); }
            }
        }
        CkptWrite("ivfpq_global");
    } else { std::cerr << "[skip] ivfpq_global\n"; }

    if (PhaseRequested("ivfpq_local") && !CkptDone("ivfpq_local")) {
        Section("IVF-PQ local");
        {
            ann_ivfpq::IVFPQIndex idx;
            idx.build(ctx.base.get(), ctx.base_n, ctx.d, 16, ann_ivfpq::BuildMode::IVFLocalPQ, 8, 8);
            for (int nthr : {1, 2, 4, 8, 16}) {
                { std::vector<IVFHeap> res(ctx.query_n);
                  double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_pq_search(idx,ctx.queries.get()+i*ctx.d,kK,4,1000); });
                  Print("ivfpq_local","simd_serial",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=1000"); }
                { std::vector<IVFHeap> res;
                  double us = TimeOnce_us([&]{ ivf_pq_search_inter_omp(idx,ctx.queries.get(),ctx.query_n,kK,4,1000,nthr,res); });
                  Print("ivfpq_local","omp_inter",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=1000"); }
                { std::vector<IVFHeap> res;
                  double us = TimeOnce_us([&]{ ivf_pq_search_inter_static(idx,ctx.queries.get(),ctx.query_n,kK,4,1000,nthr,res); });
                  Print("ivfpq_local","pthread_static_inter",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=1000"); }
                { std::vector<IVFHeap> res;
                  double us = TimeOnce_us([&]{ ivf_pq_search_inter_dynamic(idx,ctx.queries.get(),ctx.query_n,kK,4,1000,nthr,res); });
                  Print("ivfpq_local","pthread_dynamic_inter",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=1000"); }
                { std::vector<IVFHeap> res;
                  double us = TimeOnce_us([&]{ ivf_pq_search_inter_pool(idx,ctx.queries.get(),ctx.query_n,kK,4,1000,nthr,res); });
                  Print("ivfpq_local","pthread_pool_inter",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=1000"); }
                // intra
                { std::vector<IVFHeap> res(ctx.query_n);
                  double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_pq_search_intra_omp(idx,ctx.queries.get()+i*ctx.d,kK,4,1000,nthr); });
                  Print("ivfpq_local","omp_intra",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=1000"); }
                { std::vector<IVFHeap> res(ctx.query_n);
                  double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_pq_search_intra_static(idx,ctx.queries.get()+i*ctx.d,kK,4,1000,nthr); });
                  Print("ivfpq_local","pthread_static_intra",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=1000"); }
                { std::vector<IVFHeap> res(ctx.query_n);
                  double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_pq_search_intra_dynamic(idx,ctx.queries.get()+i*ctx.d,kK,4,1000,nthr); });
                  Print("ivfpq_local","pthread_dynamic_intra",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=1000"); }
                { std::vector<IVFHeap> res(ctx.query_n);
                  double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ivf_pq_search_intra_pool(idx,ctx.queries.get()+i*ctx.d,kK,4,1000,nthr); });
                  Print("ivfpq_local","pthread_pool_intra",nthr, RecallAtK_IVF(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "nprobe=4,p=1000"); }
            }
        }
        CkptWrite("ivfpq_local");
    } else { std::cerr << "[skip] ivfpq_local\n"; }
}

// ============================================================
// HNSW 实验
// ============================================================
static void RunHNSW(const DataCtx& ctx) {
    const size_t ef = 50;
    if (PhaseRequested("hnsw") && !CkptDone("hnsw")) {
        Section("HNSW");
        ann_hnsw::HnswHolder holder = ann_hnsw::BuildIndex(ctx.base.get(), ctx.base_n, ctx.d, 16, 120, ef);
        { std::vector<HNSWHeap> res(ctx.query_n);
          double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=ann_hnsw::StandardSearch(*holder.index,ctx.queries.get()+i*ctx.d,kK,ef,1); });
          Print("hnsw","baseline",1, RecallAtK_HNSW(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "ef=50"); }
        for (int nthr : {1, 4, 8, 16}) {
            { std::vector<HNSWHeap> res(ctx.query_n);
              double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=hnsw_search_multi_entry_omp(*holder.index,ctx.queries.get()+i*ctx.d,kK,ef,nthr); });
              Print("hnsw","multi_entry_omp",nthr, RecallAtK_HNSW(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "ef=50"); }
            { std::vector<HNSWHeap> res(ctx.query_n);
              double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=hnsw_search_multi_entry_static(*holder.index,ctx.queries.get()+i*ctx.d,kK,ef,nthr); });
              Print("hnsw","multi_entry_static",nthr, RecallAtK_HNSW(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "ef=50"); }
            { std::vector<HNSWHeap> res(ctx.query_n);
              double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=hnsw_search_multi_entry_dynamic(*holder.index,ctx.queries.get()+i*ctx.d,kK,ef,nthr); });
              Print("hnsw","multi_entry_dynamic",nthr, RecallAtK_HNSW(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "ef=50"); }
            { std::vector<HNSWHeap> res(ctx.query_n);
              double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=hnsw_search_multi_entry_pool(*holder.index,ctx.queries.get()+i*ctx.d,kK,ef,nthr); });
              Print("hnsw","multi_entry_pool",nthr, RecallAtK_HNSW(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "ef=50"); }
            { std::vector<HNSWHeap> res(ctx.query_n);
              double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=hnsw_edge_search_omp(*holder.index,ctx.queries.get()+i*ctx.d,kK,ef,nthr); });
              Print("hnsw","edge_omp",nthr, RecallAtK_HNSW(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "ef=50"); }
            { std::vector<HNSWHeap> res(ctx.query_n);
              double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=hnsw_edge_search_static(*holder.index,ctx.queries.get()+i*ctx.d,kK,ef,nthr); });
              Print("hnsw","edge_static",nthr, RecallAtK_HNSW(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "ef=50"); }
            { std::vector<HNSWHeap> res(ctx.query_n);
              double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=hnsw_layer0_search_omp(*holder.index,ctx.queries.get()+i*ctx.d,kK,ef,nthr); });
              Print("hnsw","layer0_omp",nthr, RecallAtK_HNSW(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "ef=50"); }
            { std::vector<HNSWHeap> res(ctx.query_n);
              double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=hnsw_layer0_search_static(*holder.index,ctx.queries.get()+i*ctx.d,kK,ef,nthr); });
              Print("hnsw","layer0_static",nthr, RecallAtK_HNSW(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "ef=50"); }
        }
        CkptWrite("hnsw");
    } else { std::cerr << "[skip] hnsw\n"; }

    if (PhaseRequested("hnsw_nested") && !CkptDone("hnsw_nested")) {
        Section("HNSW-IVF-nested");
        ann_hnsw_nested::NestedIndex nested;
        nested.build(ctx.base.get(), ctx.base_n, ctx.d, 16, 12, 80, 6);
        for (int nthr : {1, 4, 8, 16}) {
            { std::vector<HNSWHeap> res(ctx.query_n);
              double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=hnsw_ivf_nested_search_omp(nested,ctx.queries.get()+i*ctx.d,kK,ef,8,nthr); });
              Print("hnsw_ivf_nested","omp",nthr, RecallAtK_HNSW(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "ef=50,nprobe=8"); }
            { std::vector<HNSWHeap> res(ctx.query_n);
              double us = TimeOnce_us([&]{ for(size_t i=0;i<ctx.query_n;++i) res[i]=hnsw_ivf_nested_search_static(nested,ctx.queries.get()+i*ctx.d,kK,ef,8,1); });
              Print("hnsw_ivf_nested","static",nthr, RecallAtK_HNSW(res,ctx.gt.get(),ctx.query_n,ctx.gt_dim), us/ctx.query_n, "ef=50,nprobe=8"); }
        }
        CkptWrite("hnsw_nested");
    } else { std::cerr << "[skip] hnsw_nested\n"; }
}

// ============================================================
// Main
// ============================================================
int main() {
    std::cerr << "[unified_bench] Loading data...\n";
    DataCtx ctx = LoadOnce();
    std::cerr << "[unified_bench] base=" << ctx.base_n << " d=" << ctx.d
              << " queries=" << ctx.query_n << "\n";

#define RUN_IF_NEEDED(phase, fn) do {              \
    if (!PhaseRequested(phase)) {                  \
        std::cerr << "[skip] " phase "\n";        \
    } else if (!CkptDone(phase)) {                 \
        fn(ctx);                                   \
        CkptWrite(phase);                          \
    } else {                                       \
        std::cerr << "[skip] " phase "\n";        \
    }                                              \
} while(0)

    RUN_IF_NEEDED("flat",     RunFlat);
    RUN_IF_NEEDED("sq",       RunSQ);
    RUN_IF_NEEDED("pq",       RunPQ);
    RUN_IF_NEEDED("fastscan", RunFastScan);
    RUN_IF_NEEDED("ivf",      RunIVF);
    if (PhaseRequested("ivfpq_global") || PhaseRequested("ivfpq_local")) {
        RunIVFPQ(ctx);   // 内部有 checkpoint: ivfpq_global -> ivfpq_local
    } else {
        std::cerr << "[skip] ivfpq_global\n";
        std::cerr << "[skip] ivfpq_local\n";
    }
    if (PhaseRequested("hnsw") || PhaseRequested("hnsw_nested")) {
        RunHNSW(ctx);    // 内部有 checkpoint: hnsw -> hnsw_nested
    } else {
        std::cerr << "[skip] hnsw\n";
        std::cerr << "[skip] hnsw_nested\n";
    }

    std::cerr << "[unified_bench] Done.\n";
    return 0;
}
