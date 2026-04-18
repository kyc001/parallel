#include <algorithm>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <set>
#include <string>
#include <sys/time.h>
#include <vector>

#include "pq_fastscan_simd.h"

template <typename T>
T* LoadData(const std::string& data_path, size_t& n, size_t& d) {
    std::ifstream fin(data_path.c_str(), std::ios::in | std::ios::binary);
    if (!fin) {
        std::cerr << "failed to open " << data_path << "\n";
        std::exit(1);
    }
    fin.read(reinterpret_cast<char*>(&n), 4);
    fin.read(reinterpret_cast<char*>(&d), 4);
    T* data = new T[n * d];
    const int sz = static_cast<int>(sizeof(T));
    for (size_t i = 0; i < n; ++i) {
        fin.read(reinterpret_cast<char*>(data) + i * d * sz, d * sz);
    }
    fin.close();
    std::cerr << "load data " << data_path << "\n";
    std::cerr << "dimension: " << d << "  number:" << n
              << "  size_per_element:" << sizeof(T) << "\n";
    return data;
}

struct SearchResult {
    float recall;
    int64_t latency;
};

static inline int64_t now_us() {
    const unsigned long converter = 1000 * 1000;
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * converter + tv.tv_usec;
}

int main(int argc, char** argv) {
    size_t test_number = 0;
    size_t base_number = 0;
    size_t test_gt_d = 0;
    size_t vecdim = 0;

    const std::string data_path = "/anndata/";
    float* test_query = LoadData<float>(data_path + "DEEP100K.query.fbin", test_number, vecdim);
    int* test_gt = LoadData<int>(data_path + "DEEP100K.gt.query.100k.top100.bin", test_number, test_gt_d);
    float* base = LoadData<float>(data_path + "DEEP100K.base.100k.fbin", base_number, vecdim);

    test_number = std::min(static_cast<size_t>(2000), test_number);
    const size_t k = 10;
    const std::vector<size_t> rerank_ps = {
        40, 100, 500, 1000, 2000, 5000
    };

    ann_fs::FastScanIndex idx;
    std::cerr << "[FastScan] training ...\n";
    ann_fs::train_fastscan(idx, base, static_cast<int>(base_number), static_cast<int>(vecdim));
    ann_fs::encode_fastscan(idx, base);
    std::cerr << "[FastScan] trained, codes_packed bytes = "
              << idx.codes_packed.size() << "\n";

    std::cout << std::fixed << std::setprecision(5);
    for (size_t p_idx = 0; p_idx < rerank_ps.size(); ++p_idx) {
        const size_t rerank_p = std::min(rerank_ps[p_idx], base_number);
        std::vector<SearchResult> results(test_number);

        for (size_t i = 0; i < test_number; ++i) {
            const int64_t t0 = now_us();
            std::priority_queue<std::pair<float, uint32_t> > res =
                ann_fs::fastscan_search(idx, base, test_query + i * vecdim, k,
                                        static_cast<int>(rerank_p));
            const int64_t t1 = now_us();

            std::set<uint32_t> gtset;
            for (size_t j = 0; j < k; ++j) {
                gtset.insert(static_cast<uint32_t>(test_gt[j + i * test_gt_d]));
            }

            size_t hit = 0;
            while (!res.empty()) {
                const uint32_t x = res.top().second;
                if (gtset.find(x) != gtset.end()) {
                    ++hit;
                }
                res.pop();
            }
            results[i].recall = static_cast<float>(hit) / static_cast<float>(k);
            results[i].latency = t1 - t0;
        }

        double avg_recall = 0.0;
        double avg_latency = 0.0;
        for (size_t i = 0; i < test_number; ++i) {
            avg_recall += results[i].recall;
            avg_latency += static_cast<double>(results[i].latency);
        }

        std::cout << "fastscan_simd, p=" << rerank_p << "\n";
        std::cout << "average recall: " << avg_recall / static_cast<double>(test_number) << "\n";
        std::cout << "average latency (us): " << avg_latency / static_cast<double>(test_number) << "\n";
    }

    delete[] test_query;
    delete[] test_gt;
    delete[] base;
    (void)argc;
    (void)argv;
    return 0;
}
