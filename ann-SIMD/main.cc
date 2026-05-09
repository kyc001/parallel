#include <algorithm>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <queue>
#include <set>
#include <string>
#include <sys/time.h>
#include <vector>

#include "pq_fastscan_simd.h"

#ifndef FASTSCAN_DEFAULT_RERANK_P
#define FASTSCAN_DEFAULT_RERANK_P 1000
#endif

template<typename T>
T *LoadData(std::string data_path, size_t& n, size_t& d)
{
    std::ifstream fin;
    fin.open(data_path.c_str(), std::ios::in | std::ios::binary);
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

struct SearchResult
{
    float recall;
    int64_t latency; // us
};

static int get_fastscan_rerank_p(size_t base_number)
{
    int rerank_p = FASTSCAN_DEFAULT_RERANK_P;
    if (rerank_p <= 0) {
        rerank_p = 1000;
    }
    if ((size_t)rerank_p > base_number) {
        return (int)base_number;
    }
    return rerank_p;
}

static inline std::priority_queue<std::pair<float, uint32_t> >
fastscan_search_submit(ann_fs::FastScanIndex& fastscan_index,
                       float* base,
                       float* query,
                       size_t base_number,
                       size_t vecdim,
                       size_t k,
                       int rerank_p)
{
    (void)base_number;
    (void)vecdim;
    return ann_fs::fastscan_search(fastscan_index, base, query, k, rerank_p);
}

int main(int argc, char *argv[])
{
    size_t test_number = 0, base_number = 0;
    size_t test_gt_d = 0, vecdim = 0;

    std::string data_path = "/anndata/";
    auto test_query = LoadData<float>(data_path + "DEEP100K.query.fbin", test_number, vecdim);
    auto test_gt = LoadData<int>(data_path + "DEEP100K.gt.query.100k.top100.bin", test_number, test_gt_d);
    auto base = LoadData<float>(data_path + "DEEP100K.base.100k.fbin", base_number, vecdim);

    test_number = std::min((size_t)2000, test_number);
    const size_t k = 10;
    const int rerank_p = get_fastscan_rerank_p(base_number);

    std::vector<SearchResult> results(test_number);

    ann_fs::FastScanIndex fastscan_index;
    ann_fs::train_fastscan(fastscan_index, base, (int)base_number, (int)vecdim);
    ann_fs::encode_fastscan(fastscan_index, base);

    for (size_t i = 0; i < test_number; ++i) {
        const unsigned long Converter = 1000 * 1000;
        struct timeval val;
        gettimeofday(&val, NULL);

        auto res = fastscan_search_submit(
            fastscan_index,
            base,
            test_query + i * vecdim,
            base_number,
            vecdim,
            k,
            rerank_p);

        struct timeval newVal;
        gettimeofday(&newVal, NULL);
        int64_t diff = (newVal.tv_sec * Converter + newVal.tv_usec) -
                       (val.tv_sec * Converter + val.tv_usec);

        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) {
            int t = test_gt[j + i * test_gt_d];
            gtset.insert((uint32_t)t);
        }

        size_t acc = 0;
        while (res.size()) {
            int x = (int)res.top().second;
            if (gtset.find((uint32_t)x) != gtset.end()) {
                ++acc;
            }
            res.pop();
        }

        results[i] = {(float)acc / (float)k, diff};
    }

    float avg_recall = 0, avg_latency = 0;
    for (size_t i = 0; i < test_number; ++i) {
        avg_recall += results[i].recall;
        avg_latency += (float)results[i].latency;
    }

    std::cout << "fastscan_simd, p=" << rerank_p << "\n";
    std::cout << "average recall: " << avg_recall / test_number << "\n";
    std::cout << "average latency (us): " << avg_latency / test_number << "\n";

    delete[] test_query;
    delete[] test_gt;
    delete[] base;
    (void)argc;
    (void)argv;
    return 0;
}
