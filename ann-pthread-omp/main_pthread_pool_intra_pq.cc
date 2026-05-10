#include "ann_bench_common.h"
#include "pq_intra_kernel.h"
#include "pthread_intra_pool.h"

#include <cstdlib>
#include <iostream>
#include <set>
#include <sys/time.h>
#include <vector>

static size_t PoolChunkSize(const char* name, size_t fallback) {
    const char* env = std::getenv(name);
    if (!env || !env[0]) return fallback;
    char* end = nullptr;
    const unsigned long value = std::strtoul(env, &end, 10);
    return (end == env || value == 0) ? fallback : static_cast<size_t>(value);
}

int main(int argc, char* argv[]) {
    (void)argc; (void)argv;
    size_t test_number = 0, base_number = 0, test_gt_d = 0, vecdim = 0;
    std::string data_path = ANN_DATA_DIR;
    auto test_query = LoadDataRaw<float>(data_path + ANN_FILE_QUERY, test_number, vecdim);
    auto test_gt = LoadDataRaw<int>(data_path + ANN_FILE_GT, test_number, test_gt_d);
    auto base = LoadDataRaw<float>(data_path + ANN_FILE_BASE, base_number, vecdim);
    test_number = 2000;
    const size_t k = 10, rerank_p = 1000;
    const size_t chunk_size = PoolChunkSize("PTHREAD_POOL_CHUNK_INTRA", 1024);
    std::vector<SearchResult> results(test_number);
    PQIndex pq_index;
    pq_index.build(base, base_number, vecdim, 8, 256, 20);
    int threads = 1;
    if (const char* env = std::getenv("PTHREAD_NUM_THREADS")) threads = std::atoi(env);
    if (threads <= 0) threads = 1;
    pth_pool_intra::Pool pool;
    pth_pool_intra::init(pool, threads);

    AnnTimer wall;
    for (size_t qi = 0; qi < test_number; ++qi) {
        const unsigned long Converter = 1000 * 1000;
        struct timeval val, newVal;
        gettimeofday(&val, NULL);
        std::vector<float> lut(static_cast<size_t>(pq_index.M) * 256);
        pq_index.build_lut(test_query + qi * vecdim, lut.data());
        std::vector<pq_intra::CoarseHeap> locals(static_cast<size_t>(threads));
        pth_pool_intra::run(pool, base_number, chunk_size,
                            [&](int tid, size_t lo, size_t hi) {
            auto partial = pq_intra::chunk_coarse_lut(pq_index, lut.data(), lo, hi, rerank_p);
            pq_intra::merge_into(locals[static_cast<size_t>(tid)],
                                 std::move(partial), rerank_p);
        });
        auto coarse = pq_intra::merge_topp(locals, rerank_p);
        auto res = pq_intra::rerank(base, test_query + qi * vecdim, vecdim, k,
                                    std::move(coarse));
        gettimeofday(&newVal, NULL);
        int64_t diff = (newVal.tv_sec * Converter + newVal.tv_usec) -
                       (val.tv_sec * Converter + val.tv_usec);
        std::set<uint32_t> gtset;
        for (int j = 0; j < static_cast<int>(k); ++j) gtset.insert(test_gt[j + qi * test_gt_d]);
        size_t acc = 0;
        while (res.size()) {
            if (gtset.find(res.top().second) != gtset.end()) ++acc;
            res.pop();
        }
        results[qi] = {static_cast<float>(acc) / k, diff};
    }
    int64_t total_wall = wall.elapsed_us();
    pth_pool_intra::shutdown(pool);

    float avg_recall = 0, avg_latency = 0;
    for (auto& r : results) { avg_recall += r.recall; avg_latency += r.latency; }
    avg_recall /= test_number; avg_latency /= test_number;
    std::cout << "average recall: " << avg_recall << "\n";
    std::cout << "average latency (us): " << avg_latency << "\n";
    std::cout << "total wall (us): " << total_wall << "\n";
    std::cout << "throughput (qps): " << (1e6 * test_number / total_wall) << "\n";
    std::cout << "threads: " << threads << "\n";
    CsvWriter csv;
    csv.append({"pq_simd", "pthread", "intra", "pool", threads, "dynamic",
                static_cast<int>(chunk_size), static_cast<int>(rerank_p),
                static_cast<int>(base_number), avg_recall, avg_latency, total_wall});
    delete[] test_query; delete[] test_gt; delete[] base;
    return 0;
}
