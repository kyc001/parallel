#include <vector>
#include <cstring>
#include <string>
#include <iostream>
#include <fstream>
#include <set>
#include <chrono>
#include <iomanip>
#include <sstream>
#include <sys/time.h>
#include <omp.h>
#include <algorithm>
#include "hnswlib/hnswlib/hnswlib.h"
#include "pq_scan_simd.h"

using namespace hnswlib;

template<typename T>
T *LoadData(std::string data_path, size_t& n, size_t& d)
{
    std::ifstream fin;
    fin.open(data_path, std::ios::in | std::ios::binary);
    fin.read((char*)&n, 4);
    fin.read((char*)&d, 4);
    T* data = new T[n * d];
    int sz = sizeof(T);
    for (int i = 0; i < n; ++i) {
        fin.read(((char*)data + i*d*sz), d*sz);
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

int main(int argc, char *argv[])
{
    size_t test_number = 0, base_number = 0;
    size_t test_gt_d = 0, vecdim = 0;

    std::string data_path = "/anndata/";
    auto test_query = LoadData<float>(data_path + "DEEP100K.query.fbin", test_number, vecdim);
    auto test_gt = LoadData<int>(data_path + "DEEP100K.gt.query.100k.top100.bin", test_number, test_gt_d);
    auto base = LoadData<float>(data_path + "DEEP100K.base.100k.fbin", base_number, vecdim);

    test_number = 2000;
    PQIndex pq_index;
    pq_index.build(base, base_number, vecdim, 8, 256, 20);
    const size_t k = 10;
    const std::vector<size_t> rerank_ps = {
        100, 200, 500, 1000, 2000, 5000, 10000, 50000, 100000
    };

    std::cout << std::fixed << std::setprecision(5);
    for (size_t p_idx = 0; p_idx < rerank_ps.size(); ++p_idx) {
        const size_t rerank_p = std::min(rerank_ps[p_idx], base_number);
        std::vector<SearchResult> results(test_number);

        for (int i = 0; i < test_number; ++i) {
            const unsigned long Converter = 1000 * 1000;
            struct timeval val;
            gettimeofday(&val, NULL);

            auto res = pq_search(base, test_query + i*vecdim, base_number, vecdim, k, pq_index, rerank_p);

            struct timeval newVal;
            gettimeofday(&newVal, NULL);
            int64_t diff = (newVal.tv_sec * Converter + newVal.tv_usec) - (val.tv_sec * Converter + val.tv_usec);

            std::set<uint32_t> gtset;
            for (int j = 0; j < k; ++j) {
                gtset.insert(test_gt[j + i*test_gt_d]);
            }
            size_t acc = 0;
            while (res.size()) {
                int x = res.top().second;
                if (gtset.find(x) != gtset.end()) ++acc;
                res.pop();
            }
            results[i] = {(float)acc/k, diff};
        }

        double avg_recall = 0.0, avg_latency = 0.0;
        for (int i = 0; i < test_number; ++i) {
            avg_recall += results[i].recall;
            avg_latency += results[i].latency;
        }
        // ⬇️ 每个 p 都保留原版输出两行，再加一行自定义标签
        std::cout << "pq_simd, p=" << rerank_p << "\n";
        std::cout << "average recall: " << avg_recall / test_number << "\n";
        std::cout << "average latency (us): " << avg_latency / test_number << "\n";
    }
    return 0;
}