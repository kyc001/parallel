#include <algorithm>
#include <cfloat>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <queue>
#include <set>
#include <string>
#include <sys/time.h>
#include <vector>
#include <arm_neon.h>

#define flat_search serial_flat_search
#include "flat_scan.h"
#undef flat_search

#define horizontal_sum_f32 simd_horizontal_sum_f32
#define ip_distance_simd simd_ip_distance_simd
#define l2_distance_simd simd_l2_distance_simd
#define flat_search simd_flat_search
#include "flat_scan_simd.h"
#undef horizontal_sum_f32
#undef ip_distance_simd
#undef l2_distance_simd
#undef flat_search

#define horizontal_sum_f32 sq_horizontal_sum_f32
#define ip_distance_simd sq_ip_distance_simd
#define SQIndex BenchSQIndex
#define sq_l2_distance_simd bench_sq_l2_distance_simd
#define sq_search bench_sq_search
#include "sq_scan_simd.h"
#undef horizontal_sum_f32
#undef ip_distance_simd
#undef SQIndex
#undef sq_l2_distance_simd
#undef sq_search

#define horizontal_sum_f32 pq_horizontal_sum_f32
#define ip_distance_simd pq_ip_distance_simd
#define l2_dist_sub_simd bench_l2_dist_sub_simd
#define dot_sub_simd bench_dot_sub_simd
#define PQIndex BenchPQIndex
#define adc_distance bench_adc_distance
#define pq_search bench_pq_search
#include "pq_scan_simd.h"
#undef horizontal_sum_f32
#undef ip_distance_simd
#undef l2_dist_sub_simd
#undef dot_sub_simd
#undef PQIndex
#undef adc_distance
#undef pq_search

struct SearchResult {
    double recall;
    int64_t latency_us;
};

static std::string g_results_dir = "bench_results/android_termux_proot_ubuntu";

template<typename T>
T* LoadData(const std::string& data_path, size_t& n, size_t& d) {
    std::ifstream fin(data_path.c_str(), std::ios::in | std::ios::binary);
    if (!fin) {
        std::cerr << "failed to open " << data_path << "\n";
        std::exit(1);
    }
    fin.read((char*)&n, 4);
    fin.read((char*)&d, 4);
    T* data = new T[n * d];
    int sz = sizeof(T);
    for (size_t i = 0; i < n; ++i) {
        fin.read(((char*)data + i * d * sz), d * sz);
    }
    fin.close();
    std::cerr << "load data " << data_path << "\n";
    std::cerr << "dimension: " << d << "  number:" << n
              << "  size_per_element:" << sizeof(T) << "\n";
    return data;
}

inline int64_t now_us() {
    const unsigned long Converter = 1000 * 1000;
    struct timeval val;
    gettimeofday(&val, NULL);
    return val.tv_sec * Converter + val.tv_usec;
}

double median(std::vector<double> values) {
    std::sort(values.begin(), values.end());
    return values[values.size() / 2];
}

std::priority_queue<std::pair<float, uint32_t>>
flat_search_simd_pf(float* base, float* query, size_t base_number,
                    size_t vecdim, size_t k, int pf_dist) {
    std::priority_queue<std::pair<float, uint32_t>> q;
    for (size_t i = 0; i < base_number; ++i) {
        if (pf_dist > 0 && i + (size_t)pf_dist < base_number) {
            __builtin_prefetch(base + (i + (size_t)pf_dist) * vecdim, 0, 0);
        }
        float dis = simd_ip_distance_simd(base + i * vecdim, query, (int)vecdim);
        if (q.size() < k) {
            q.push({dis, (uint32_t)i});
        } else if (dis < q.top().first) {
            q.push({dis, (uint32_t)i});
            q.pop();
        }
    }
    return q;
}

template<typename SearchFn>
SearchResult run_queries(SearchFn fn, float* base, float* query, int* gt,
                         size_t base_number, size_t vecdim, size_t gt_d,
                         size_t test_number, size_t k, bool calc_recall) {
    int64_t total_latency = 0;
    double total_recall = 0.0;
    for (size_t i = 0; i < test_number; ++i) {
        int64_t t0 = now_us();
        std::priority_queue<std::pair<float, uint32_t>> res =
            fn(base, query + i * vecdim, base_number, vecdim, k);
        int64_t t1 = now_us();
        total_latency += (t1 - t0);

        if (calc_recall) {
            std::set<uint32_t> gtset;
            for (size_t j = 0; j < k; ++j) {
                gtset.insert((uint32_t)gt[j + i * gt_d]);
            }
            size_t acc = 0;
            while (!res.empty()) {
                uint32_t x = res.top().second;
                if (gtset.find(x) != gtset.end()) ++acc;
                res.pop();
            }
            total_recall += (double)acc / (double)k;
        }
    }
    return {calc_recall ? total_recall / (double)test_number : 0.0, total_latency};
}

void ensure_results_dir() {
    std::string cmd = "mkdir -p " + g_results_dir;
    int ret = system(cmd.c_str());
    (void)ret;
}

std::string result_path(const char* file_name) {
    return g_results_dir + "/" + file_name;
}

int run_e1(float* base, float* query, int* gt, size_t base_number,
           size_t vecdim, size_t gt_d, size_t test_number, size_t k) {
    ensure_results_dir();
    const size_t bytes = base_number * vecdim * sizeof(float);
    void* raw64 = NULL;
    void* raw_unaligned = NULL;
    if (posix_memalign(&raw64, 64, bytes + 64) != 0) return 1;
    if (posix_memalign(&raw_unaligned, 64, bytes + 65) != 0) return 1;

    float* base64 = (float*)raw64;
    float* base16 = new float[base_number * vecdim];
    float* base_unaligned = (float*)((char*)raw_unaligned + 1);
    memcpy(base64, base, bytes);
    memcpy(base16, base, bytes);
    memcpy(base_unaligned, base, bytes);

    struct Case { const char* name; float* ptr; };
    Case cases[] = {{"64B", base64}, {"16B_new", base16}, {"offset_1B", base_unaligned}};
    std::vector<double> medians;

    for (size_t ci = 0; ci < 3; ++ci) {
        std::vector<double> runs;
        for (int r = 0; r < 5; ++r) {
            SearchResult res = run_queries(
                [](float* b, float* q, size_t n, size_t d, size_t kk) {
                    return simd_flat_search(b, q, n, d, kk);
                },
                cases[ci].ptr, query, gt, base_number, vecdim, gt_d, test_number, k, false);
            runs.push_back((double)res.latency_us);
            std::cerr << "[E1] " << cases[ci].name << " run " << (r + 1)
                      << " total_us=" << res.latency_us << "\n";
        }
        medians.push_back(median(runs));
    }

    std::ofstream out(result_path("E1_alignment.csv").c_str());
    out << "alignment,latency_us,speedup_vs_64B\n";
    out << std::fixed;
    double baseline = medians[0];
    for (size_t i = 0; i < 3; ++i) {
        out << cases[i].name << "," << std::setprecision(2) << medians[i]
            << "," << std::setprecision(5) << baseline / medians[i] << "\n";
    }

    free(raw64);
    free(raw_unaligned);
    delete[] base16;
    return 0;
}

int run_e2(float* base, float* query, int* gt, size_t base_number,
           size_t vecdim, size_t gt_d, size_t test_number, size_t k) {
    ensure_results_dir();
    const int pf_values[] = {0, 4, 8, 16, 32};
    std::vector<double> medians;
    for (size_t pi = 0; pi < 5; ++pi) {
        int pf = pf_values[pi];
        std::vector<double> runs;
        for (int r = 0; r < 5; ++r) {
            SearchResult res = run_queries(
                [pf](float* b, float* q, size_t n, size_t d, size_t kk) {
                    return flat_search_simd_pf(b, q, n, d, kk, pf);
                },
                base, query, gt, base_number, vecdim, gt_d, test_number, k, false);
            runs.push_back((double)res.latency_us);
            std::cerr << "[E2] pf=" << pf << " run " << (r + 1)
                      << " total_us=" << res.latency_us << "\n";
        }
        medians.push_back(median(runs));
    }

    std::ofstream out(result_path("E2_prefetch.csv").c_str());
    out << "pf_distance,latency_us,speedup_vs_baseline\n";
    out << std::fixed;
    double baseline = medians[0];
    for (size_t i = 0; i < 5; ++i) {
        out << pf_values[i] << "," << std::setprecision(2) << medians[i]
            << "," << std::setprecision(5) << baseline / medians[i] << "\n";
    }
    return 0;
}

int run_e3(float* base, float* query, int* gt, size_t base_number,
           size_t vecdim, size_t gt_d, size_t test_number, size_t k) {
    ensure_results_dir();
    const size_t Ns[] = {10000, 25000, 50000, 100000};
    std::ofstream out(result_path("E3_scale.csv").c_str());
    out << "N,method,latency_us,recall\n";
    out << std::fixed;

    for (size_t ni = 0; ni < 4; ++ni) {
        size_t N = std::min(Ns[ni], base_number);
        std::cerr << "[E3] N=" << N << " building SQ/PQ indexes\n";
        BenchSQIndex sq_index;
        sq_index.build(base, N, vecdim);
        BenchPQIndex pq_index;
        pq_index.build(base, N, vecdim, 8, 256, 20);

        struct Method { const char* name; int type; };
        Method methods[] = {
            {"serial_flat", 0},
            {"flat_simd", 1},
            {"sq_simd_p100", 2},
            {"pq_simd_p1000", 3},
        };

        for (size_t mi = 0; mi < 4; ++mi) {
            std::vector<double> lat_runs;
            std::vector<double> recall_runs;
            for (int r = 0; r < 5; ++r) {
                SearchResult res;
                if (methods[mi].type == 0) {
                    res = run_queries(
                        [](float* b, float* q, size_t n, size_t d, size_t kk) {
                            return serial_flat_search(b, q, n, d, kk);
                        },
                        base, query, gt, N, vecdim, gt_d, test_number, k, true);
                } else if (methods[mi].type == 1) {
                    res = run_queries(
                        [](float* b, float* q, size_t n, size_t d, size_t kk) {
                            return simd_flat_search(b, q, n, d, kk);
                        },
                        base, query, gt, N, vecdim, gt_d, test_number, k, true);
                } else if (methods[mi].type == 2) {
                    res = run_queries(
                        [&sq_index](float* b, float* q, size_t n, size_t d, size_t kk) {
                            return bench_sq_search(b, q, n, d, kk, sq_index, 100);
                        },
                        base, query, gt, N, vecdim, gt_d, test_number, k, true);
                } else {
                    res = run_queries(
                        [&pq_index](float* b, float* q, size_t n, size_t d, size_t kk) {
                            return bench_pq_search(b, q, n, d, kk, pq_index, 1000);
                        },
                        base, query, gt, N, vecdim, gt_d, test_number, k, true);
                }
                lat_runs.push_back((double)res.latency_us / (double)test_number);
                recall_runs.push_back(res.recall);
                std::cerr << "[E3] N=" << N << " method=" << methods[mi].name
                          << " run " << (r + 1)
                          << " avg_us=" << lat_runs.back()
                          << " recall=" << res.recall << "\n";
            }
            out << N << "," << methods[mi].name << ","
                << std::setprecision(2) << median(lat_runs) << ","
                << std::setprecision(5) << median(recall_runs) << "\n";
            out.flush();
        }
    }
    return 0;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: " << argv[0] << " e1|e2|e3 [results_dir]\n";
        return 1;
    }
    if (argc >= 3) {
        g_results_dir = argv[2];
    }

    size_t test_number = 0, base_number = 0, gt_d = 0, vecdim = 0;
    const std::string data_path = "./files/";
    float* query = LoadData<float>(data_path + "DEEP100K.query.fbin", test_number, vecdim);
    int* gt = LoadData<int>(data_path + "DEEP100K.gt.query.100k.top100.bin", test_number, gt_d);
    float* base = LoadData<float>(data_path + "DEEP100K.base.100k.fbin", base_number, vecdim);
    test_number = std::min((size_t)2000, test_number);
    const size_t k = 10;

    std::string mode = argv[1];
    int rc = 1;
    if (mode == "e1") rc = run_e1(base, query, gt, base_number, vecdim, gt_d, test_number, k);
    else if (mode == "e2") rc = run_e2(base, query, gt, base_number, vecdim, gt_d, test_number, k);
    else if (mode == "e3") rc = run_e3(base, query, gt, base_number, vecdim, gt_d, test_number, k);
    else std::cerr << "unknown mode: " << mode << "\n";

    delete[] query;
    delete[] gt;
    delete[] base;
    return rc;
}
