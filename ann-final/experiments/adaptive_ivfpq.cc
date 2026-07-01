#include <algorithm>
#include <atomic>
#include <chrono>
#include <cstdlib>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <queue>
#include <set>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#include <pthread.h>

#include "simd/ann_bench_common.h"
#include "ivf/ivf_index.h"
#include "ivf/ivf_pq_simd.h"

using SearchHeap = ann_ivf::SearchHeap;

namespace {

struct Budget {
    const char* tier;
    size_t nprobe;
    size_t rerank_p;
};

struct ProbeSelection {
    std::vector<uint32_t> probes;
    float best_dist;
    float second_dist;
    float margin;
};

struct ExperimentConfig {
    std::string label;
    bool adaptive;
    bool grouped_order;
    bool static_schedule;
    Budget fixed;
    Budget low;
    Budget mid;
    Budget high;
    float tau_low;
    float tau_high;
};

struct BinSummary {
    size_t count = 0;
    double recall = 0.0;
    double query_us = 0.0;
    double scanned = 0.0;
};

struct ExperimentResult {
    std::string label;
    std::string schedule;
    std::string order;
    double recall = 0.0;
    double latency_us = 0.0;
    size_t count_low = 0;
    size_t count_mid = 0;
    size_t count_high = 0;
    double avg_nprobe = 0.0;
    double avg_rerank_p = 0.0;
    double avg_scanned = 0.0;
    BinSummary hard;
    BinSummary medium;
    BinSummary easy;
};

struct SearchStats {
    int tier = 1;
    float margin = 0.0f;
    size_t nprobe = 0;
    size_t rerank_p = 0;
    size_t scanned = 0;
};

static bool FileExists(const std::string& path) {
    std::ifstream fin(path.c_str(), std::ios::binary);
    return fin.good();
}

static std::string ResolveDataPath() {
    const std::string helper_path = ann_bench::DefaultDataPath();
    if (FileExists(helper_path + "DEEP100K.query.fbin")) {
        return helper_path;
    }

    const char* candidates[] = {"files/", "../files/", "../../files/"};
    for (size_t i = 0; i < sizeof(candidates) / sizeof(candidates[0]); ++i) {
        const std::string path = candidates[i];
        if (FileExists(path + "DEEP100K.query.fbin")) {
            return path;
        }
    }
    return helper_path;
}

static size_t ParseSizeArg(int argc, char** argv, int index, size_t fallback) {
    if (argc <= index) {
        return fallback;
    }
    const long long parsed = std::atoll(argv[index]);
    if (parsed <= 0) {
        return fallback;
    }
    return static_cast<size_t>(parsed);
}

static int ParseIntArg(int argc, char** argv, int index, int fallback) {
    if (argc <= index) {
        return fallback;
    }
    const int parsed = std::atoi(argv[index]);
    return parsed > 0 ? parsed : fallback;
}

static std::string ParseStringArg(int argc, char** argv, int index,
                                  const std::string& fallback) {
    if (argc <= index || argv[index] == nullptr || argv[index][0] == '\0') {
        return fallback;
    }
    return argv[index];
}

static ProbeSelection SelectProbesWithMargin(
    const ann_ivfpq::IVFPQIndex& index, const float* query, size_t nprobe) {
    nprobe = std::max<size_t>(1, std::min(nprobe, index.ivf.nlist));

    std::vector<std::pair<float, uint32_t>> distances;
    distances.reserve(index.ivf.nlist);
    for (size_t c = 0; c < index.ivf.nlist; ++c) {
        const float dist = ann_ivf::Distance(
            query, index.ivf.centroids.data() + c * index.ivf.d, index.ivf.d);
        distances.push_back(std::make_pair(dist, static_cast<uint32_t>(c)));
    }
    std::sort(distances.begin(), distances.end());

    ProbeSelection selection;
    selection.probes.reserve(nprobe);
    for (size_t i = 0; i < nprobe; ++i) {
        selection.probes.push_back(distances[i].second);
    }
    selection.best_dist = distances.empty() ? 0.0f : distances[0].first;
    selection.second_dist = distances.size() < 2 ? selection.best_dist
                                                 : distances[1].first;
    selection.margin = selection.second_dist - selection.best_dist;
    return selection;
}

static const Budget& ChooseAdaptiveBudget(float margin,
                                          const ExperimentConfig& config) {
    if (margin <= config.tau_low) {
        return config.high;
    }
    if (margin <= config.tau_high) {
        return config.mid;
    }
    return config.low;
}

static SearchHeap SearchWithProbeSelection(const ann_ivfpq::IVFPQIndex& index,
                                           const float* query, size_t k,
                                           const ProbeSelection& selection,
                                           const Budget& budget,
                                           SearchStats* stats) {
    const size_t rerank_p =
        ann_ivfpq::NormalizeRerankP(budget.rerank_p, index.n, k);

    std::vector<float> global_lut;
    const float* global_lut_ptr = nullptr;
    if (index.mode == ann_ivfpq::BuildMode::GlobalPQFirst) {
        global_lut.resize(static_cast<size_t>(index.global_pq.M) * 256);
        index.global_pq.build_lut(query, global_lut.data());
        global_lut_ptr = global_lut.data();
    }

    SearchHeap coarse;
    const size_t probe_count = std::min(selection.probes.size(), budget.nprobe);
    size_t scanned = 0;
    for (size_t i = 0; i < probe_count; ++i) {
        const uint32_t list_id = selection.probes[i];
        scanned += index.ivf.list_offsets[static_cast<size_t>(list_id) + 1] -
                   index.ivf.list_offsets[list_id];
        ann_ivfpq::ScanList(index, query, global_lut_ptr,
                            list_id, rerank_p, coarse);
    }
    if (stats != nullptr) {
        stats->margin = selection.margin;
        stats->nprobe = probe_count;
        stats->rerank_p = rerank_p;
        stats->scanned = scanned;
    }
    return ann_ivfpq::Rerank(index, query, k, coarse);
}

static SearchHeap SearchOne(const ann_ivfpq::IVFPQIndex& index,
                            const float* query, size_t k,
                            const ExperimentConfig& config,
                            SearchStats* stats) {
    if (!config.adaptive) {
        ProbeSelection selection =
            SelectProbesWithMargin(index, query, config.fixed.nprobe);
        if (stats != nullptr) {
            stats->tier = 1;
        }
        return SearchWithProbeSelection(index, query, k, selection,
                                        config.fixed, stats);
    }

    const size_t max_nprobe =
        std::max(config.high.nprobe,
                 std::max(config.mid.nprobe, config.low.nprobe));
    ProbeSelection selection = SelectProbesWithMargin(index, query, max_nprobe);
    const Budget& budget = ChooseAdaptiveBudget(selection.margin, config);
    if (stats != nullptr) {
        if (budget.nprobe == config.high.nprobe &&
            budget.rerank_p == config.high.rerank_p) {
            stats->tier = 2;
        } else if (budget.nprobe == config.mid.nprobe &&
                   budget.rerank_p == config.mid.rerank_p) {
            stats->tier = 1;
        } else {
            stats->tier = 0;
        }
    }
    return SearchWithProbeSelection(index, query, k, selection, budget, stats);
}

struct WorkerArgs {
    const ann_ivfpq::IVFPQIndex* index;
    const float* queries;
    size_t query_n;
    size_t k;
    const ExperimentConfig* config;
    std::atomic<size_t>* next_query;
    size_t q_start;
    size_t q_end;
    std::vector<SearchHeap>* results;
    std::vector<int>* tiers;
    std::vector<float>* margins;
    std::vector<size_t>* nprobes;
    std::vector<size_t>* rerank_ps;
    std::vector<size_t>* scanned;
    std::vector<double>* query_us;
    const std::vector<size_t>* order;
};

static void RunOneQuery(WorkerArgs* args, size_t ordered_pos) {
    const size_t qid = args->order == nullptr ? ordered_pos
                                              : (*(args->order))[ordered_pos];
    SearchStats stats;
    const auto start = std::chrono::high_resolution_clock::now();
    (*args->results)[qid] =
        SearchOne(*args->index, args->queries + qid * args->index->d,
                  args->k, *args->config, &stats);
    const auto stop = std::chrono::high_resolution_clock::now();
    (*args->tiers)[qid] = stats.tier;
    (*args->margins)[qid] = stats.margin;
    (*args->nprobes)[qid] = stats.nprobe;
    (*args->rerank_ps)[qid] = stats.rerank_p;
    (*args->scanned)[qid] = stats.scanned;
    (*args->query_us)[qid] =
        std::chrono::duration<double, std::micro>(stop - start).count();
}

static void* WorkerMain(void* raw) {
    WorkerArgs* args = static_cast<WorkerArgs*>(raw);
    if (args->next_query != nullptr) {
        while (true) {
            const size_t i =
                args->next_query->fetch_add(1, std::memory_order_relaxed);
            if (i >= args->query_n) {
                break;
            }
            RunOneQuery(args, i);
        }
        return nullptr;
    }

    for (size_t i = args->q_start; i < args->q_end; ++i) {
        RunOneQuery(args, i);
    }
    return nullptr;
}

static double RecallAtK(std::vector<SearchHeap>& results, const int* gt,
                        size_t query_n, size_t gt_dim, size_t k,
                        std::vector<double>& per_query_recall) {
    double total_recall = 0.0;
    per_query_recall.assign(query_n, 0.0);
    for (size_t i = 0; i < query_n; ++i) {
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) {
            gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
        }

        size_t hits = 0;
        SearchHeap& heap = results[i];
        while (!heap.empty()) {
            const uint32_t id = heap.top().second;
            if (gtset.find(id) != gtset.end()) {
                ++hits;
            }
            heap.pop();
        }
        per_query_recall[i] =
            static_cast<double>(hits) / static_cast<double>(k);
        total_recall += per_query_recall[i];
    }
    return total_recall / static_cast<double>(query_n);
}

static void AccumulateBin(BinSummary& bin, double recall, double query_us,
                          size_t scanned) {
    ++bin.count;
    bin.recall += recall;
    bin.query_us += query_us;
    bin.scanned += static_cast<double>(scanned);
}

static void NormalizeBin(BinSummary& bin) {
    if (bin.count == 0) {
        return;
    }
    const double inv = 1.0 / static_cast<double>(bin.count);
    bin.recall *= inv;
    bin.query_us *= inv;
    bin.scanned *= inv;
}

static std::vector<size_t> BuildNearestCentroidOrder(
    const ann_ivfpq::IVFPQIndex& index, const float* queries, size_t query_n);

static ExperimentResult SummarizeExperiment(
    const ExperimentConfig& config, std::vector<SearchHeap>& results,
    const int* gt, size_t query_n, size_t gt_dim, size_t k,
    const std::vector<int>& tiers, const std::vector<float>& margins,
    const std::vector<size_t>& nprobes, const std::vector<size_t>& rerank_ps,
    const std::vector<size_t>& scanned, const std::vector<double>& query_us,
    double latency_us) {
    size_t count_low = 0;
    size_t count_mid = 0;
    size_t count_high = 0;
    double sum_nprobe = 0.0;
    double sum_rerank = 0.0;
    double sum_scanned = 0.0;
    for (size_t i = 0; i < query_n; ++i) {
        if (tiers[i] == 2) {
            ++count_high;
        } else if (tiers[i] == 0) {
            ++count_low;
        } else {
            ++count_mid;
        }
        sum_nprobe += static_cast<double>(nprobes[i]);
        sum_rerank += static_cast<double>(rerank_ps[i]);
        sum_scanned += static_cast<double>(scanned[i]);
    }

    std::vector<double> per_query_recall;
    ExperimentResult result;
    result.label = config.label;
    result.schedule = config.static_schedule ? "static" : "dynamic";
    result.order = config.grouped_order ? "grouped" : "original";
    result.recall = RecallAtK(results, gt, query_n, gt_dim, k,
                              per_query_recall);
    result.latency_us = latency_us;
    result.count_low = count_low;
    result.count_mid = count_mid;
    result.count_high = count_high;
    result.avg_nprobe = sum_nprobe / static_cast<double>(query_n);
    result.avg_rerank_p = sum_rerank / static_cast<double>(query_n);
    result.avg_scanned = sum_scanned / static_cast<double>(query_n);

    for (size_t i = 0; i < query_n; ++i) {
        if (margins[i] <= config.tau_low) {
            AccumulateBin(result.hard, per_query_recall[i], query_us[i],
                          scanned[i]);
        } else if (margins[i] <= config.tau_high) {
            AccumulateBin(result.medium, per_query_recall[i], query_us[i],
                          scanned[i]);
        } else {
            AccumulateBin(result.easy, per_query_recall[i], query_us[i],
                          scanned[i]);
        }
    }
    NormalizeBin(result.hard);
    NormalizeBin(result.medium);
    NormalizeBin(result.easy);
    return result;
}

static ExperimentResult RunExperiment(const ann_ivfpq::IVFPQIndex& index,
                                      const float* queries, const int* gt,
                                      size_t query_n, size_t gt_dim,
                                      size_t k, int nthreads,
                                      const ExperimentConfig& config) {
    nthreads = std::max(1, nthreads);
    std::vector<SearchHeap> results(query_n);
    std::vector<int> tiers(query_n, 1);
    std::vector<float> margins(query_n, 0.0f);
    std::vector<size_t> nprobes(query_n, 0);
    std::vector<size_t> rerank_ps(query_n, 0);
    std::vector<size_t> scanned(query_n, 0);
    std::vector<double> query_us(query_n, 0.0);
    std::atomic<size_t> next_query(0);

    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    std::vector<size_t> grouped_order;
    const std::vector<size_t>* order = nullptr;
    if (config.grouped_order) {
        grouped_order = BuildNearestCentroidOrder(index, queries, query_n);
        order = &grouped_order;
    }

    const auto start = std::chrono::high_resolution_clock::now();
    std::vector<WorkerArgs> static_args;
    WorkerArgs dynamic_args = {};
    if (config.static_schedule) {
        static_args.resize(static_cast<size_t>(nthreads));
        const size_t chunk =
            (query_n + static_cast<size_t>(nthreads) - 1) /
            static_cast<size_t>(nthreads);
        for (int t = 0; t < nthreads; ++t) {
            const size_t start_q = static_cast<size_t>(t) * chunk;
            const size_t end_q = std::min(start_q + chunk, query_n);
            static_args[static_cast<size_t>(t)] =
                {&index, queries, query_n, k, &config, nullptr,
                 start_q, end_q, &results, &tiers, &margins, &nprobes,
                 &rerank_ps, &scanned, &query_us, order};
            pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                           &WorkerMain,
                           &static_args[static_cast<size_t>(t)]);
        }
    } else {
        dynamic_args =
            {&index, queries, query_n, k, &config, &next_query,
             0, query_n, &results, &tiers, &margins, &nprobes,
             &rerank_ps, &scanned, &query_us, order};
        for (int t = 0; t < nthreads; ++t) {
            pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                           &WorkerMain, &dynamic_args);
        }
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(threads[static_cast<size_t>(t)], nullptr);
    }
    const auto stop = std::chrono::high_resolution_clock::now();
    const double latency_us =
        std::chrono::duration<double, std::micro>(stop - start).count() /
        static_cast<double>(query_n);
    return SummarizeExperiment(config, results, gt, query_n, gt_dim, k,
                               tiers, margins, nprobes, rerank_ps, scanned,
                               query_us, latency_us);
}

static std::vector<float> ComputeMargins(const ann_ivfpq::IVFPQIndex& index,
                                         const float* queries,
                                         size_t query_n) {
    std::vector<float> margins(query_n);
    for (size_t i = 0; i < query_n; ++i) {
        const ProbeSelection selection =
            SelectProbesWithMargin(index, queries + i * index.d, 2);
        margins[i] = selection.margin;
    }
    return margins;
}

static std::vector<size_t> BuildNearestCentroidOrder(
    const ann_ivfpq::IVFPQIndex& index, const float* queries, size_t query_n) {
    std::vector<std::pair<uint32_t, size_t>> keyed;
    keyed.reserve(query_n);
    for (size_t i = 0; i < query_n; ++i) {
        const ProbeSelection selection =
            SelectProbesWithMargin(index, queries + i * index.d, 1);
        keyed.push_back(std::make_pair(selection.probes[0], i));
    }
    std::stable_sort(keyed.begin(), keyed.end());

    std::vector<size_t> order;
    order.reserve(query_n);
    for (size_t i = 0; i < keyed.size(); ++i) {
        order.push_back(keyed[i].second);
    }
    return order;
}

static float Quantile(std::vector<float> values, double q) {
    if (values.empty()) {
        return 0.0f;
    }
    std::sort(values.begin(), values.end());
    const double pos = q * static_cast<double>(values.size() - 1);
    const size_t lo = static_cast<size_t>(pos);
    const size_t hi = std::min(values.size() - 1, lo + 1);
    const double frac = pos - static_cast<double>(lo);
    return static_cast<float>(values[lo] * (1.0 - frac) +
                              values[hi] * frac);
}

static void WriteCsv(const std::string& path,
                     const std::vector<ExperimentResult>& results,
                     size_t query_n, int nthreads, size_t nlist,
                     float tau_low, float tau_high) {
    std::ofstream out(path.c_str());
    if (!out) {
        throw std::runtime_error("failed to write csv: " + path);
    }
    out << "method,query_n,nthreads,nlist,tau_low,tau_high,recall_at_10,"
           "schedule,query_order,latency_us,low_count,mid_count,high_count,"
           "avg_nprobe,avg_rerank_p,avg_scanned,hard_count,hard_recall,"
           "hard_query_us,hard_scanned,medium_count,medium_recall,"
           "medium_query_us,medium_scanned,easy_count,easy_recall,"
           "easy_query_us,easy_scanned\n";
    out << std::fixed << std::setprecision(5);
    for (size_t i = 0; i < results.size(); ++i) {
        const ExperimentResult& r = results[i];
        out << r.label << ','
            << query_n << ','
            << nthreads << ','
            << nlist << ','
            << tau_low << ','
            << tau_high << ','
            << r.recall << ','
            << r.schedule << ','
            << r.order << ','
            << r.latency_us << ','
            << r.count_low << ','
            << r.count_mid << ','
            << r.count_high << ','
            << r.avg_nprobe << ','
            << r.avg_rerank_p << ','
            << r.avg_scanned << ','
            << r.hard.count << ','
            << r.hard.recall << ','
            << r.hard.query_us << ','
            << r.hard.scanned << ','
            << r.medium.count << ','
            << r.medium.recall << ','
            << r.medium.query_us << ','
            << r.medium.scanned << ','
            << r.easy.count << ','
            << r.easy.recall << ','
            << r.easy.query_us << ','
            << r.easy.scanned << '\n';
    }
}

static void WriteTextSummary(const std::string& path,
                             const std::vector<ExperimentResult>& results,
                             size_t query_n, int nthreads, size_t nlist,
                             float tau_low, float tau_high,
                             const std::string& data_path) {
    std::ofstream out(path.c_str());
    if (!out) {
        throw std::runtime_error("failed to write summary: " + path);
    }
    out << std::fixed << std::setprecision(5);
    out << "adaptive_ivfpq_final_experiment\n";
    out << "data_path=" << data_path << "\n";
    out << "query_n=" << query_n
        << ", nthreads=" << nthreads
        << ", nlist=" << nlist
        << ", k=10"
        << ", mode=local"
        << ", tau_low=" << tau_low
        << ", tau_high=" << tau_high << "\n";
    for (size_t i = 0; i < results.size(); ++i) {
        const ExperimentResult& r = results[i];
        out << r.label
            << ", schedule=" << r.schedule
            << ", order=" << r.order
            << ", average recall: " << r.recall
            << ", average latency (us): " << r.latency_us
            << ", counts(low,mid,high)=" << r.count_low
            << "/" << r.count_mid
            << "/" << r.count_high
            << ", avg_nprobe=" << r.avg_nprobe
            << ", avg_rerank_p=" << r.avg_rerank_p
            << ", avg_scanned=" << r.avg_scanned << "\n";
        out << "  hard(count/recall/us/scanned)=" << r.hard.count
            << "/" << r.hard.recall
            << "/" << r.hard.query_us
            << "/" << r.hard.scanned
            << ", medium=" << r.medium.count
            << "/" << r.medium.recall
            << "/" << r.medium.query_us
            << "/" << r.medium.scanned
            << ", easy=" << r.easy.count
            << "/" << r.easy.recall
            << "/" << r.easy.query_us
            << "/" << r.easy.scanned << "\n";
    }
}

}  // namespace

int main(int argc, char** argv) {
    try {
        const size_t requested_query_n = ParseSizeArg(argc, argv, 1, 2000);
        const int nthreads = ParseIntArg(argc, argv, 2, 8);
        const std::string output_dir =
            ParseStringArg(argc, argv, 3, "ann-final/report/results");

        const size_t nlist = 16;
        const size_t k = 10;
        const Budget low = {"low", 2, 500};
        const Budget mid = {"mid", 4, 1000};
        const Budget near = {"near", 5, 1000};
        const Budget high = {"high", 8, 1500};
        const Budget conservative_low = {"low", 3, 800};
        const Budget conservative_mid = {"mid", 4, 1000};
        const Budget conservative_high = {"high", 5, 1000};
        const Budget aggressive_low = {"low", 2, 500};
        const Budget aggressive_mid = {"mid", 4, 1000};
        const Budget aggressive_high = {"high", 8, 1500};
        const Budget recall_low = {"low", 4, 1000};
        const Budget recall_mid = {"mid", 5, 1000};
        const Budget recall_high = {"high", 8, 1500};

        const std::string data_path = ResolveDataPath();
        size_t query_n = 0;
        size_t query_d = 0;
        size_t gt_n = 0;
        size_t gt_dim = 0;
        size_t base_n = 0;
        size_t base_d = 0;

        auto queries = ann_bench::LoadData<float>(
            data_path + "DEEP100K.query.fbin", query_n, query_d);
        auto gt = ann_bench::LoadData<int>(
            data_path + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
        auto base = ann_bench::LoadData<float>(
            data_path + "DEEP100K.base.100k.fbin", base_n, base_d);

        if (base_d != query_d) {
            std::cerr << "base/query dimension mismatch: base_d=" << base_d
                      << ", query_d=" << query_d << "\n";
            return 2;
        }
        if (gt_n < query_n || gt_dim < k) {
            std::cerr << "ground truth shape mismatch: gt_n=" << gt_n
                      << ", gt_dim=" << gt_dim
                      << ", query_n=" << query_n
                      << ", k=" << k << "\n";
            return 2;
        }

        query_n = std::min(query_n, requested_query_n);

        ann_ivfpq::IVFPQIndex index;
        index.build(base.get(), base_n, base_d, nlist,
                    ann_ivfpq::BuildMode::IVFLocalPQ, 8, 8);

        const size_t calibration_n = std::min<size_t>(query_n, 256);
        const std::vector<float> margins =
            ComputeMargins(index, queries.get(), calibration_n);
        const float tau_low = Quantile(margins, 1.0 / 3.0);
        const float tau_high = Quantile(margins, 2.0 / 3.0);

        std::vector<ExperimentConfig> configs;
        configs.push_back({"fixed_low_np2_p500", false, false, false,
                           low, low, mid, high, tau_low, tau_high});
        configs.push_back({"fixed_mid_np4_p1000", false, false, false,
                           mid, low, mid, high, tau_low, tau_high});
        configs.push_back({"fixed_mid_grouped_np4_p1000", false, true, false,
                           mid, low, mid, high, tau_low, tau_high});
        configs.push_back({"fixed_mid_static_np4_p1000", false, false, true,
                           mid, low, mid, high, tau_low, tau_high});
        configs.push_back({"fixed_mid_static_grouped_np4_p1000", false, true,
                           true, mid, low, mid, high, tau_low, tau_high});
        configs.push_back({"fixed_near_np5_p1000", false, false, false,
                           near, low, mid, high, tau_low, tau_high});
        configs.push_back({"fixed_high_np8_p1500", false, false, false,
                           high, low, mid, high, tau_low, tau_high});
        configs.push_back({"adaptive_conservative", true, false, false,
                           conservative_mid, conservative_low,
                           conservative_mid, conservative_high,
                           tau_low, tau_high});
        configs.push_back({"adaptive_aggressive", true, false, false,
                           aggressive_mid, aggressive_low, aggressive_mid,
                           aggressive_high, tau_low, tau_high});
        configs.push_back({"adaptive_recall_oriented", true, false, false,
                           recall_mid, recall_low, recall_mid, recall_high,
                           tau_low, tau_high});
        configs.push_back({"adaptive_conservative_grouped", true, true, false,
                           conservative_mid, conservative_low,
                           conservative_mid, conservative_high,
                           tau_low, tau_high});
        configs.push_back({"adaptive_conservative_static", true, false, true,
                           conservative_mid, conservative_low,
                           conservative_mid, conservative_high,
                           tau_low, tau_high});

        std::vector<ExperimentResult> results;
        results.reserve(configs.size());
        for (size_t i = 0; i < configs.size(); ++i) {
            results.push_back(RunExperiment(index, queries.get(), gt.get(),
                                            query_n, gt_dim, k, nthreads,
                                            configs[i]));
        }

        ann_bench::EnsureDirectory(output_dir);
        const std::string csv_path =
            output_dir + "/adaptive_ivfpq_20260630.csv";
        const std::string text_path =
            output_dir + "/adaptive_ivfpq_20260630.txt";
        WriteCsv(csv_path, results, query_n, nthreads, nlist,
                 tau_low, tau_high);
        WriteTextSummary(text_path, results, query_n, nthreads, nlist,
                         tau_low, tau_high, data_path);

        std::cout << std::fixed << std::setprecision(5);
        std::cout << "adaptive_ivfpq_final_experiment"
                  << ", query_n=" << query_n
                  << ", nthreads=" << nthreads
                  << ", nlist=" << nlist
                  << ", tau_low=" << tau_low
                  << ", tau_high=" << tau_high << "\n";
        for (size_t i = 0; i < results.size(); ++i) {
            const ExperimentResult& r = results[i];
            std::cout << r.label
                      << ", schedule=" << r.schedule
                      << ", order=" << r.order
                      << ", average recall: " << r.recall
                      << ", average latency (us): " << r.latency_us
                      << ", counts(low,mid,high)=" << r.count_low
                      << "/" << r.count_mid
                      << "/" << r.count_high
                      << ", avg_nprobe=" << r.avg_nprobe
                      << ", avg_rerank_p=" << r.avg_rerank_p
                      << ", avg_scanned=" << r.avg_scanned << "\n";
        }
        std::cout << "wrote " << csv_path << "\n";
        std::cout << "wrote " << text_path << "\n";
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "adaptive_ivfpq failed: " << ex.what() << "\n";
        return 1;
    }
}
