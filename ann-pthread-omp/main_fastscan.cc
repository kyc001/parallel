#include "ann_bench_common.h"
#include "pq_fastscan_simd.h"

#include <iostream>
#include <set>
#include <sys/time.h>
#include <vector>

int main(int argc, char* argv[]) {
    (void)argc;
    (void)argv;

    size_t test_number = 0, base_number = 0, test_gt_d = 0, vecdim = 0;
    std::string data_path = ANN_DATA_DIR;
    auto test_query = LoadDataRaw<float>(data_path + ANN_FILE_QUERY,
                                         test_number, vecdim);
    auto test_gt = LoadDataRaw<int>(data_path + ANN_FILE_GT,
                                    test_number, test_gt_d);
    auto base = LoadDataRaw<float>(data_path + ANN_FILE_BASE,
                                   base_number, vecdim);

    test_number = 2000;
    const size_t k = 10;
    const int p = 1000;
    std::vector<SearchResult> results(test_number);

    ann_fs::FastScanIndex fs_idx;
    ann_fs::train_fastscan(fs_idx, base, static_cast<int>(base_number),
                           static_cast<int>(vecdim));
    ann_fs::encode_fastscan(fs_idx, base);

    AnnTimer wall;
    for (int i = 0; i < static_cast<int>(test_number); ++i) {
        const unsigned long Converter = 1000 * 1000;
        struct timeval val, newVal;
        gettimeofday(&val, NULL);

        auto res = ann_fs::fastscan_search(
            fs_idx, base, test_query + i * vecdim, k, p);

        gettimeofday(&newVal, NULL);
        int64_t diff = (newVal.tv_sec * Converter + newVal.tv_usec) -
                       (val.tv_sec * Converter + val.tv_usec);

        std::set<uint32_t> gtset;
        for (int j = 0; j < static_cast<int>(k); ++j) {
            gtset.insert(test_gt[j + i * test_gt_d]);
        }
        size_t acc = 0;
        while (res.size()) {
            if (gtset.find(res.top().second) != gtset.end()) ++acc;
            res.pop();
        }
        results[i] = {static_cast<float>(acc) / k, diff};
    }
    int64_t total_wall = wall.elapsed_us();

    float avg_recall = 0, avg_latency = 0;
    for (auto& r : results) {
        avg_recall += r.recall;
        avg_latency += r.latency;
    }
    avg_recall /= test_number;
    avg_latency /= test_number;

    std::cout << "average recall: " << avg_recall << "\n";
    std::cout << "average latency (us): " << avg_latency << "\n";
    std::cout << "total wall (us): " << total_wall << "\n";
    std::cout << "throughput (qps): " << (1e6 * test_number / total_wall) << "\n";

    CsvWriter csv;
    csv.append({"fastscan",
                "serial", "none", "n/a",
                1, "n/a", 0,
                p, static_cast<int>(base_number),
                avg_recall, avg_latency, total_wall});

    delete[] test_query;
    delete[] test_gt;
    delete[] base;
    return 0;
}
