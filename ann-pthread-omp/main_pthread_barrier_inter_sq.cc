#include "ann_bench_common.h"
#include "pthread_inter_barrier.h"
#include "sq_scan_dispatch.h"

#include <cstdlib>
#include <iostream>
#include <set>
#include <sys/time.h>
#include <vector>

int main(int argc, char* argv[]) {
    (void)argc; (void)argv;
    size_t test_number = 0, base_number = 0, test_gt_d = 0, vecdim = 0;
    std::string data_path = ANN_DATA_DIR;
    auto test_query = LoadDataRaw<float>(data_path + ANN_FILE_QUERY, test_number, vecdim);
    auto test_gt = LoadDataRaw<int>(data_path + ANN_FILE_GT, test_number, test_gt_d);
    auto base = LoadDataRaw<float>(data_path + ANN_FILE_BASE, base_number, vecdim);
    test_number = 2000;
    const size_t k = 10, p = 100;
    std::vector<SearchResult> results(test_number);
    SQIndex sq_index;
    sq_index.build(base, base_number, vecdim);
    int threads = 1;
    if (const char* env = std::getenv("PTHREAD_NUM_THREADS")) threads = std::atoi(env);
    if (threads <= 0) threads = 1;
    pth_bar::Pool pool;
    pool.init(threads);

    AnnTimer wall;
    pool.submit([&](size_t i) {
        const unsigned long Converter = 1000 * 1000;
        struct timeval val, newVal;
        gettimeofday(&val, NULL);
        auto res = sq_search(base, test_query + i * vecdim, base_number, vecdim, k, sq_index, p);
        gettimeofday(&newVal, NULL);
        int64_t diff = (newVal.tv_sec * Converter + newVal.tv_usec) -
                       (val.tv_sec * Converter + val.tv_usec);
        std::set<uint32_t> gtset;
        for (int j = 0; j < static_cast<int>(k); ++j) gtset.insert(test_gt[j + i * test_gt_d]);
        size_t acc = 0;
        while (res.size()) {
            if (gtset.find(res.top().second) != gtset.end()) ++acc;
            res.pop();
        }
        results[i] = {static_cast<float>(acc) / k, diff};
    }, test_number);
    int64_t total_wall = wall.elapsed_us();
    pool.shutdown();

    float avg_recall = 0, avg_latency = 0;
    for (auto& r : results) { avg_recall += r.recall; avg_latency += r.latency; }
    avg_recall /= test_number; avg_latency /= test_number;
    std::cout << "average recall: " << avg_recall << "\n";
    std::cout << "average latency (us): " << avg_latency << "\n";
    std::cout << "total wall (us): " << total_wall << "\n";
    std::cout << "throughput (qps): " << (1e6 * test_number / total_wall) << "\n";
    std::cout << "threads: " << threads << "\n";
    CsvWriter csv;
    csv.append({"sq_simd", "pthread", "inter", "barrier", threads, "static", 0,
                static_cast<int>(p), static_cast<int>(base_number), avg_recall, avg_latency, total_wall});
    delete[] test_query; delete[] test_gt; delete[] base;
    return 0;
}
