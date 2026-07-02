#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <numeric>
#include <queue>
#include <set>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#include "simd/ann_bench_common.h"
#include "simd/pq_scan_avx2.h"
#include "ivf/ivf_index.h"

namespace {

using SearchHeap = std::priority_queue<std::pair<float, uint32_t>>;

struct Config {
    size_t query_n = 2000;
    size_t nlist = 16;
    int pq_iter = 8;
    int opq_iter = 5;
    std::vector<int> m_values;
    std::vector<size_t> nprobes;
    std::vector<size_t> rerank_ps;
    std::string output_csv = "report/results/opq_ivfpq.csv";
    int repeat = 3;
    size_t warmup_n = 64;
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

struct RunStats {
    std::string method;
    size_t query_n = 0;
    size_t nlist = 0;
    size_t nprobe = 0;
    int M = 0;
    int ksub = 256;
    size_t rerank_p = 0;
    int opq_iter = 0;
    double recall_at_10 = 0.0;
    double recall_at_100 = 0.0;
    double latency_us = 0.0;
    double wall_latency_us = 0.0;
    double build_ms = 0.0;
    double train_ms = 0.0;
    double rotate_ms = 0.0;
    double scan_ms = 0.0;
    double rerank_ms = 0.0;
    size_t index_bytes = 0;
    int repeat_count = 1;
    size_t warmup_n = 0;
};

template <typename T>
static T Clamp(T value, T lo, T hi) {
    return std::max(lo, std::min(value, hi));
}

static std::vector<size_t> ParseSizeList(const std::string& text) {
    std::vector<size_t> out;
    size_t start = 0;
    while (start <= text.size()) {
        const size_t comma = text.find(',', start);
        const std::string token = text.substr(
            start, comma == std::string::npos ? std::string::npos : comma - start);
        if (!token.empty()) {
            out.push_back(static_cast<size_t>(std::strtoull(token.c_str(), nullptr, 10)));
        }
        if (comma == std::string::npos) {
            break;
        }
        start = comma + 1;
    }
    return out;
}

static std::vector<int> ParseIntList(const std::string& text) {
    std::vector<size_t> raw = ParseSizeList(text);
    std::vector<int> out;
    for (size_t i = 0; i < raw.size(); ++i) {
        out.push_back(static_cast<int>(raw[i]));
    }
    return out;
}

static Config ParseArgs(int argc, char** argv) {
    Config cfg;
    cfg.m_values.push_back(8);
    cfg.m_values.push_back(12);
    cfg.m_values.push_back(16);
    cfg.nprobes.push_back(2);
    cfg.nprobes.push_back(4);
    cfg.nprobes.push_back(8);
    cfg.rerank_ps.push_back(500);
    cfg.rerank_ps.push_back(1000);
    cfg.rerank_ps.push_back(1500);

    for (int i = 1; i < argc; ++i) {
        const std::string arg = argv[i];
        const size_t eq = arg.find('=');
        if (eq == std::string::npos || arg.substr(0, 2) != "--") {
            throw std::runtime_error("invalid argument: " + arg);
        }
        const std::string key = arg.substr(2, eq - 2);
        const std::string value = arg.substr(eq + 1);
        if (key == "query_n") {
            cfg.query_n = static_cast<size_t>(std::strtoull(value.c_str(), nullptr, 10));
        } else if (key == "nlist") {
            cfg.nlist = static_cast<size_t>(std::strtoull(value.c_str(), nullptr, 10));
        } else if (key == "pq_iter") {
            cfg.pq_iter = std::atoi(value.c_str());
        } else if (key == "opq_iter") {
            cfg.opq_iter = std::atoi(value.c_str());
        } else if (key == "m") {
            cfg.m_values = ParseIntList(value);
        } else if (key == "nprobe") {
            cfg.nprobes = ParseSizeList(value);
        } else if (key == "rerank_p") {
            cfg.rerank_ps = ParseSizeList(value);
        } else if (key == "out") {
            cfg.output_csv = value;
        } else if (key == "repeat") {
            cfg.repeat = std::max(1, std::atoi(value.c_str()));
        } else if (key == "warmup_n") {
            cfg.warmup_n = static_cast<size_t>(std::strtoull(value.c_str(), nullptr, 10));
        } else {
            throw std::runtime_error("unknown argument: " + key);
        }
    }
    if (cfg.query_n == 0 || cfg.nlist == 0 || cfg.m_values.empty() ||
        cfg.nprobes.empty() || cfg.rerank_ps.empty()) {
        throw std::runtime_error("empty OPQ experiment configuration");
    }
    cfg.pq_iter = std::max(1, cfg.pq_iter);
    cfg.opq_iter = std::max(0, cfg.opq_iter);
    cfg.repeat = std::max(1, cfg.repeat);
    return cfg;
}

static Dataset LoadDataset(size_t query_limit) {
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
    if (data.query_d != 96) {
        std::cerr << "warning: expected DEEP100K dimension 96, got "
                  << data.query_d << "\n";
    }
    data.query_n = std::min(data.query_n, data.gt_n);
    data.query_n = std::min(data.query_n, query_limit);
    return data;
}

static void EnsureParentDir(const std::string& file_path) {
    const size_t pos = file_path.find_last_of("/\\");
    if (pos == std::string::npos) {
        return;
    }
    ann_bench::EnsureDirectory(file_path.substr(0, pos));
}

static double NowMsSince(const std::chrono::high_resolution_clock::time_point& start) {
    const auto stop = std::chrono::high_resolution_clock::now();
    return std::chrono::duration<double, std::milli>(stop - start).count();
}

static float IpDistance(const float* x, const float* y, size_t d) {
    return ann_avx2::ip_distance_avx2(x, y, static_cast<int>(d));
}

static void PushTopK(SearchHeap& heap, float dist, uint32_t id, size_t k) {
    if (heap.size() < k) {
        heap.push(std::make_pair(dist, id));
    } else if (dist < heap.top().first) {
        heap.push(std::make_pair(dist, id));
        heap.pop();
    }
}

static double RecallAtK(SearchHeap heap, const int* gt, size_t gt_d, size_t k) {
    std::set<uint32_t> truth;
    for (size_t i = 0; i < k; ++i) {
        truth.insert(static_cast<uint32_t>(gt[i]));
    }
    std::vector<std::pair<float, uint32_t>> returned;
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
    (void)gt_d;
    return static_cast<double>(hits) / static_cast<double>(k);
}

static SearchHeap RerankRaw(const float* base, size_t d, const float* query,
                            SearchHeap coarse, size_t k) {
    SearchHeap result;
    while (!coarse.empty()) {
        const uint32_t id = coarse.top().second;
        coarse.pop();
        const float dist = IpDistance(base + static_cast<size_t>(id) * d, query, d);
        PushTopK(result, dist, id, k);
    }
    return result;
}

static void BuildCovariance(const float* data, size_t n, size_t d,
                            std::vector<double>* mean,
                            std::vector<double>* cov) {
    mean->assign(d, 0.0);
    cov->assign(d * d, 0.0);
    for (size_t i = 0; i < n; ++i) {
        const float* row = data + i * d;
        for (size_t j = 0; j < d; ++j) {
            (*mean)[j] += row[j];
        }
    }
    const double inv_n = 1.0 / static_cast<double>(n);
    for (size_t j = 0; j < d; ++j) {
        (*mean)[j] *= inv_n;
    }
    for (size_t i = 0; i < n; ++i) {
        const float* row = data + i * d;
        for (size_t a = 0; a < d; ++a) {
            const double xa = static_cast<double>(row[a]) - (*mean)[a];
            for (size_t b = 0; b <= a; ++b) {
                const double xb = static_cast<double>(row[b]) - (*mean)[b];
                (*cov)[a * d + b] += xa * xb;
            }
        }
    }
    const double scale = n > 1 ? 1.0 / static_cast<double>(n - 1) : 1.0;
    for (size_t a = 0; a < d; ++a) {
        for (size_t b = 0; b <= a; ++b) {
            const double value = (*cov)[a * d + b] * scale;
            (*cov)[a * d + b] = value;
            (*cov)[b * d + a] = value;
        }
    }
}

static void JacobiEigenSymmetric(std::vector<double> matrix, size_t d,
                                 std::vector<double>* eigenvalues,
                                 std::vector<double>* eigenvectors) {
    eigenvectors->assign(d * d, 0.0);
    for (size_t i = 0; i < d; ++i) {
        (*eigenvectors)[i * d + i] = 1.0;
    }

    const size_t max_iter = d * d * 12;
    for (size_t iter = 0; iter < max_iter; ++iter) {
        size_t p = 0;
        size_t q = 1;
        double max_off = 0.0;
        for (size_t i = 0; i < d; ++i) {
            for (size_t j = i + 1; j < d; ++j) {
                const double value = std::fabs(matrix[i * d + j]);
                if (value > max_off) {
                    max_off = value;
                    p = i;
                    q = j;
                }
            }
        }
        if (max_off < 1e-8) {
            break;
        }

        const double app = matrix[p * d + p];
        const double aqq = matrix[q * d + q];
        const double apq = matrix[p * d + q];
        const double tau = (aqq - app) / (2.0 * apq);
        const double t = (tau >= 0.0 ? 1.0 : -1.0) /
                         (std::fabs(tau) + std::sqrt(1.0 + tau * tau));
        const double c = 1.0 / std::sqrt(1.0 + t * t);
        const double s = t * c;

        for (size_t k = 0; k < d; ++k) {
            if (k == p || k == q) {
                continue;
            }
            const double aik = matrix[k * d + p];
            const double akq = matrix[k * d + q];
            matrix[k * d + p] = c * aik - s * akq;
            matrix[p * d + k] = matrix[k * d + p];
            matrix[k * d + q] = s * aik + c * akq;
            matrix[q * d + k] = matrix[k * d + q];
        }
        matrix[p * d + p] = c * c * app - 2.0 * s * c * apq + s * s * aqq;
        matrix[q * d + q] = s * s * app + 2.0 * s * c * apq + c * c * aqq;
        matrix[p * d + q] = 0.0;
        matrix[q * d + p] = 0.0;

        for (size_t k = 0; k < d; ++k) {
            const double vip = (*eigenvectors)[k * d + p];
            const double viq = (*eigenvectors)[k * d + q];
            (*eigenvectors)[k * d + p] = c * vip - s * viq;
            (*eigenvectors)[k * d + q] = s * vip + c * viq;
        }
    }

    eigenvalues->assign(d, 0.0);
    for (size_t i = 0; i < d; ++i) {
        (*eigenvalues)[i] = matrix[i * d + i];
    }
}

static std::vector<size_t> BalancedComponentOrder(const std::vector<double>& evals,
                                                  int M) {
    const size_t d = evals.size();
    std::vector<size_t> sorted(d);
    for (size_t i = 0; i < d; ++i) {
        sorted[i] = i;
    }
    std::sort(sorted.begin(), sorted.end(), [&evals](size_t a, size_t b) {
        return evals[a] > evals[b];
    });

    std::vector<double> bucket_var(static_cast<size_t>(M), 0.0);
    std::vector<std::vector<size_t>> buckets(static_cast<size_t>(M));
    const size_t dsub = d / static_cast<size_t>(M);
    for (size_t i = 0; i < sorted.size(); ++i) {
        size_t best = 0;
        for (size_t b = 1; b < buckets.size(); ++b) {
            if (buckets[b].size() < dsub &&
                (buckets[best].size() >= dsub || bucket_var[b] < bucket_var[best])) {
                best = b;
            }
        }
        if (buckets[best].size() >= dsub) {
            for (size_t b = 0; b < buckets.size(); ++b) {
                if (buckets[b].size() < dsub) {
                    best = b;
                    break;
                }
            }
        }
        buckets[best].push_back(sorted[i]);
        bucket_var[best] += std::max(0.0, evals[sorted[i]]);
    }

    std::vector<size_t> order;
    order.reserve(d);
    for (size_t b = 0; b < buckets.size(); ++b) {
        for (size_t j = 0; j < buckets[b].size(); ++j) {
            order.push_back(buckets[b][j]);
        }
    }
    return order;
}

struct OrthogonalRotation {
    size_t d = 0;
    std::vector<float> matrix;

    void build_pca_balanced(const float* base, size_t n, size_t dim, int M) {
        d = dim;
        std::vector<double> mean;
        std::vector<double> cov;
        std::vector<double> evals;
        std::vector<double> evecs;
        BuildCovariance(base, n, d, &mean, &cov);
        JacobiEigenSymmetric(cov, d, &evals, &evecs);
        const std::vector<size_t> order = BalancedComponentOrder(evals, M);

        matrix.assign(d * d, 0.0f);
        for (size_t out = 0; out < d; ++out) {
            const size_t component = order[out];
            for (size_t in = 0; in < d; ++in) {
                matrix[in * d + out] =
                    static_cast<float>(evecs[in * d + component]);
            }
        }
    }

    void identity(size_t dim) {
        d = dim;
        matrix.assign(d * d, 0.0f);
        for (size_t i = 0; i < d; ++i) {
            matrix[i * d + i] = 1.0f;
        }
    }

    void apply_one(const float* src, float* dst) const {
        for (size_t out = 0; out < d; ++out) {
            float sum = 0.0f;
            for (size_t in = 0; in < d; ++in) {
                sum += src[in] * matrix[in * d + out];
            }
            dst[out] = sum;
        }
    }

    std::vector<float> apply_all(const float* src, size_t n) const {
        std::vector<float> out(n * d);
        for (size_t i = 0; i < n; ++i) {
            apply_one(src + i * d, out.data() + i * d);
        }
        return out;
    }
};

static size_t PQIndexBytes(const PQIndex& pq) {
    return pq.centroids.size() * sizeof(float) +
           pq.centroids_soa.size() * sizeof(float) +
           pq.codes.size() * sizeof(uint8_t);
}

static SearchHeap PqSearchTimed(const PQIndex& pq, const float* rotated_base,
                                const float* raw_base, const float* rotated_query,
                                const float* raw_query, size_t base_n,
                                size_t d, size_t k, size_t rerank_p,
                                double* scan_us, double* rerank_us) {
    const auto scan_start = std::chrono::high_resolution_clock::now();
    std::vector<float> lut(static_cast<size_t>(pq.M) * 256);
    pq.build_lut(rotated_query, lut.data());
    SearchHeap coarse;
    rerank_p = Clamp<size_t>(rerank_p, k, base_n);
    for (size_t i = 0; i < base_n; ++i) {
        const float dist = adc_distance(
            lut.data(), pq.codes.data() + i * static_cast<size_t>(pq.M), pq.M);
        PushTopK(coarse, dist, static_cast<uint32_t>(i), rerank_p);
    }
    const auto rerank_start = std::chrono::high_resolution_clock::now();
    *scan_us += std::chrono::duration<double, std::micro>(
        rerank_start - scan_start).count();
    SearchHeap result = RerankRaw(raw_base, d, raw_query, coarse, k);
    *rerank_us += std::chrono::duration<double, std::micro>(
        std::chrono::high_resolution_clock::now() - rerank_start).count();
    (void)rotated_base;
    return result;
}

struct IVFPQFlexible {
    ann_ivf::IVFIndex ivf;
    PQIndex pq;
    const float* raw_base = nullptr;
    const float* rotated_base = nullptr;
    size_t n = 0;
    size_t d = 0;

    void build(const float* raw_base_, const float* rotated_base_,
               size_t n_, size_t d_, size_t nlist, int M,
               int pq_iter, int ivf_iter) {
        raw_base = raw_base_;
        rotated_base = rotated_base_;
        n = n_;
        d = d_;
        ivf.build(rotated_base, n, d, nlist, ivf_iter);
        pq.build(rotated_base, n, d, M, 256, pq_iter);
    }

    size_t bytes() const {
        return PQIndexBytes(pq) +
               ivf.centroids.size() * sizeof(float) +
               ivf.reordered_base.size() * sizeof(float) +
               ivf.reordered_ids.size() * sizeof(uint32_t) +
               ivf.list_offsets.size() * sizeof(size_t);
    }
};

static SearchHeap IVFPqSearchTimed(const IVFPQFlexible& index,
                                   const float* rotated_query,
                                   const float* raw_query, size_t k,
                                   size_t nprobe, size_t rerank_p,
                                   double* scan_us, double* rerank_us) {
    const auto scan_start = std::chrono::high_resolution_clock::now();
    nprobe = Clamp<size_t>(nprobe, 1, index.ivf.nlist);
    rerank_p = Clamp<size_t>(rerank_p, k, index.n);
    const std::vector<uint32_t> probes = index.ivf.select_probes(rotated_query, nprobe);
    std::vector<float> lut(static_cast<size_t>(index.pq.M) * 256);
    index.pq.build_lut(rotated_query, lut.data());
    SearchHeap coarse;

    for (size_t p = 0; p < probes.size(); ++p) {
        const uint32_t list_id = probes[p];
        const size_t begin = index.ivf.list_offsets[list_id];
        const size_t end = index.ivf.list_offsets[static_cast<size_t>(list_id) + 1];
        for (size_t pos = begin; pos < end; ++pos) {
            const uint32_t id = index.ivf.reordered_ids[pos];
            const float dist = adc_distance(
                lut.data(), index.pq.codes.data() + static_cast<size_t>(id) * index.pq.M,
                index.pq.M);
            PushTopK(coarse, dist, id, rerank_p);
        }
    }

    const auto rerank_start = std::chrono::high_resolution_clock::now();
    *scan_us += std::chrono::duration<double, std::micro>(
        rerank_start - scan_start).count();
    SearchHeap result = RerankRaw(index.raw_base, index.d, raw_query, coarse, k);
    *rerank_us += std::chrono::duration<double, std::micro>(
        std::chrono::high_resolution_clock::now() - rerank_start).count();
    return result;
}

template <typename SearchFn>
static void EvaluateQueries(const Dataset& data, SearchFn search_fn,
                            RunStats* stats) {
    double recall10 = 0.0;
    double recall100 = 0.0;
    const auto begin = std::chrono::high_resolution_clock::now();
    for (size_t q = 0; q < data.query_n; ++q) {
        SearchHeap result = search_fn(q);
        recall10 += RecallAtK(result, data.gt.get() + q * data.gt_d, data.gt_d, 10);
        recall100 += RecallAtK(result, data.gt.get() + q * data.gt_d, data.gt_d, 100);
    }
    const double total_us = std::chrono::duration<double, std::micro>(
        std::chrono::high_resolution_clock::now() - begin).count();
    stats->recall_at_10 = recall10 / static_cast<double>(data.query_n);
    stats->recall_at_100 = recall100 / static_cast<double>(data.query_n);
    stats->latency_us = total_us / static_cast<double>(data.query_n);
}

static void WriteCsvHeader(std::ofstream* out) {
    *out << "method,query_n,nlist,nprobe,M,ksub,rerank_p,opq_iter,"
            "recall_at_10,recall_at_100,latency_us,wall_latency_us,"
            "build_ms,train_ms,rotate_ms,scan_ms,rerank_ms,index_bytes,"
            "repeat_count,warmup_n\n";
}

static void WriteCsvRow(std::ofstream* out, const RunStats& r) {
    *out << std::fixed << std::setprecision(5)
         << r.method << ','
         << r.query_n << ','
         << r.nlist << ','
         << r.nprobe << ','
         << r.M << ','
         << r.ksub << ','
         << r.rerank_p << ','
         << r.opq_iter << ','
         << r.recall_at_10 << ','
         << r.recall_at_100 << ','
         << r.latency_us << ','
         << r.wall_latency_us << ','
         << r.build_ms << ','
         << r.train_ms << ','
         << r.rotate_ms << ','
         << r.scan_ms << ','
         << r.rerank_ms << ','
         << r.index_bytes << ','
         << r.repeat_count << ','
         << r.warmup_n << '\n';
}

static double OnlineLatencyUs(const RunStats& r) {
    if (r.query_n == 0) {
        return 0.0;
    }
    return (r.scan_ms + r.rerank_ms) * 1000.0 / static_cast<double>(r.query_n);
}

static void FinalizeRepeatedRuns(std::vector<RunStats>* runs, RunStats* stats) {
    std::sort(runs->begin(), runs->end(),
              [](const RunStats& a, const RunStats& b) {
                  return a.latency_us < b.latency_us;
              });
    *stats = (*runs)[runs->size() / 2];
}

static void RunExperiment(const Config& cfg, const Dataset& data) {
    EnsureParentDir(cfg.output_csv);
    std::ofstream csv(cfg.output_csv.c_str());
    if (!csv) {
        throw std::runtime_error("failed to open output csv: " + cfg.output_csv);
    }
    WriteCsvHeader(&csv);

    for (size_t mi = 0; mi < cfg.m_values.size(); ++mi) {
        const int M = cfg.m_values[mi];
        if (M <= 0 || data.base_d % static_cast<size_t>(M) != 0) {
            std::cerr << "skip M=" << M << " because it does not divide d="
                      << data.base_d << "\n";
            continue;
        }

        for (int opq_enabled = 0; opq_enabled <= 1; ++opq_enabled) {
            OrthogonalRotation rotation;
            const auto train_start = std::chrono::high_resolution_clock::now();
            if (opq_enabled) {
                rotation.build_pca_balanced(data.base.get(), data.base_n, data.base_d, M);
            } else {
                rotation.identity(data.base_d);
            }
            const double train_ms = NowMsSince(train_start);

            const auto rotate_start = std::chrono::high_resolution_clock::now();
            std::vector<float> rotated_base =
                rotation.apply_all(data.base.get(), data.base_n);
            std::vector<float> rotated_queries =
                rotation.apply_all(data.queries.get(), data.query_n);
            const double rotate_ms = NowMsSince(rotate_start);

            const auto pq_build_start = std::chrono::high_resolution_clock::now();
            PQIndex pq;
            pq.build(rotated_base.data(), data.base_n, data.base_d, M, 256,
                     cfg.pq_iter);
            const double pq_build_ms = NowMsSince(pq_build_start);

            for (size_t ri = 0; ri < cfg.rerank_ps.size(); ++ri) {
                RunStats stats;
                stats.method = opq_enabled ? "OPQ" : "PQ";
                stats.query_n = data.query_n;
                stats.M = M;
                stats.rerank_p = cfg.rerank_ps[ri];
                stats.opq_iter = opq_enabled ? cfg.opq_iter : 0;
                stats.train_ms = train_ms;
                stats.rotate_ms = rotate_ms;
                stats.build_ms = pq_build_ms;
                stats.index_bytes = PQIndexBytes(pq);

                const size_t warmup_n = std::min(cfg.warmup_n, data.query_n);
                if (warmup_n > 0) {
                    double warm_scan_us = 0.0;
                    double warm_rerank_us = 0.0;
                    for (size_t q = 0; q < warmup_n; ++q) {
                        SearchHeap ignored = PqSearchTimed(
                            pq, rotated_base.data(), data.base.get(),
                            rotated_queries.data() + q * data.base_d,
                            data.queries.get() + q * data.base_d,
                            data.base_n, data.base_d, 100, cfg.rerank_ps[ri],
                            &warm_scan_us, &warm_rerank_us);
                        (void)ignored;
                    }
                }

                std::vector<RunStats> repeated;
                repeated.reserve(static_cast<size_t>(cfg.repeat));
                for (int rep = 0; rep < cfg.repeat; ++rep) {
                    RunStats run = stats;
                    double scan_us = 0.0;
                    double rerank_us = 0.0;
                    EvaluateQueries(data, [&](size_t q) {
                        return PqSearchTimed(
                            pq, rotated_base.data(), data.base.get(),
                            rotated_queries.data() + q * data.base_d,
                            data.queries.get() + q * data.base_d,
                            data.base_n, data.base_d, 100, cfg.rerank_ps[ri],
                            &scan_us, &rerank_us);
                    }, &run);
                    run.scan_ms = scan_us / 1000.0;
                    run.rerank_ms = rerank_us / 1000.0;
                    run.wall_latency_us = run.latency_us;
                    run.latency_us = OnlineLatencyUs(run);
                    run.repeat_count = cfg.repeat;
                    run.warmup_n = warmup_n;
                    repeated.push_back(run);
                }
                FinalizeRepeatedRuns(&repeated, &stats);
                WriteCsvRow(&csv, stats);
                std::cout << stats.method << ", M=" << M
                          << ", p=" << stats.rerank_p
                          << ", recall@10=" << stats.recall_at_10
                          << ", recall@100=" << stats.recall_at_100
                          << ", online_latency_us=" << stats.latency_us
                          << ", wall_latency_us=" << stats.wall_latency_us << "\n";
            }

            const auto ivf_build_start = std::chrono::high_resolution_clock::now();
            IVFPQFlexible ivfpq;
            ivfpq.build(data.base.get(), rotated_base.data(), data.base_n,
                        data.base_d, cfg.nlist, M, cfg.pq_iter, 8);
            const double ivf_build_ms = NowMsSince(ivf_build_start);

            for (size_t ni = 0; ni < cfg.nprobes.size(); ++ni) {
                for (size_t ri = 0; ri < cfg.rerank_ps.size(); ++ri) {
                    RunStats stats;
                    stats.method = opq_enabled ? "IVF-OPQ" : "IVF-PQ";
                    stats.query_n = data.query_n;
                    stats.nlist = cfg.nlist;
                    stats.nprobe = cfg.nprobes[ni];
                    stats.M = M;
                    stats.rerank_p = cfg.rerank_ps[ri];
                    stats.opq_iter = opq_enabled ? cfg.opq_iter : 0;
                    stats.train_ms = train_ms;
                    stats.rotate_ms = rotate_ms;
                    stats.build_ms = ivf_build_ms;
                    stats.index_bytes = ivfpq.bytes();

                    const size_t warmup_n = std::min(cfg.warmup_n, data.query_n);
                    if (warmup_n > 0) {
                        double warm_scan_us = 0.0;
                        double warm_rerank_us = 0.0;
                        for (size_t q = 0; q < warmup_n; ++q) {
                            SearchHeap ignored = IVFPqSearchTimed(
                                ivfpq, rotated_queries.data() + q * data.base_d,
                                data.queries.get() + q * data.base_d, 100,
                                cfg.nprobes[ni], cfg.rerank_ps[ri],
                                &warm_scan_us, &warm_rerank_us);
                            (void)ignored;
                        }
                    }

                    std::vector<RunStats> repeated;
                    repeated.reserve(static_cast<size_t>(cfg.repeat));
                    for (int rep = 0; rep < cfg.repeat; ++rep) {
                        RunStats run = stats;
                        double scan_us = 0.0;
                        double rerank_us = 0.0;
                        EvaluateQueries(data, [&](size_t q) {
                            return IVFPqSearchTimed(
                                ivfpq, rotated_queries.data() + q * data.base_d,
                                data.queries.get() + q * data.base_d, 100,
                                cfg.nprobes[ni], cfg.rerank_ps[ri],
                                &scan_us, &rerank_us);
                        }, &run);
                        run.scan_ms = scan_us / 1000.0;
                        run.rerank_ms = rerank_us / 1000.0;
                        run.wall_latency_us = run.latency_us;
                        run.latency_us = OnlineLatencyUs(run);
                        run.repeat_count = cfg.repeat;
                        run.warmup_n = warmup_n;
                        repeated.push_back(run);
                    }
                    FinalizeRepeatedRuns(&repeated, &stats);
                    WriteCsvRow(&csv, stats);
                    std::cout << stats.method << ", M=" << M
                              << ", nprobe=" << stats.nprobe
                              << ", p=" << stats.rerank_p
                              << ", recall@10=" << stats.recall_at_10
                              << ", recall@100=" << stats.recall_at_100
                              << ", online_latency_us=" << stats.latency_us
                              << ", wall_latency_us=" << stats.wall_latency_us << "\n";
                }
            }
        }
    }
}

}  // namespace

int main(int argc, char** argv) {
    try {
        Config cfg = ParseArgs(argc, argv);
        Dataset data = LoadDataset(cfg.query_n);
        std::cerr << "opq_ivfpq experiment: query_n=" << data.query_n
                  << ", base_n=" << data.base_n
                  << ", dim=" << data.base_d << "\n";
        RunExperiment(cfg, data);
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "opq_ivfpq failed: " << ex.what() << "\n";
        return 1;
    }
}
