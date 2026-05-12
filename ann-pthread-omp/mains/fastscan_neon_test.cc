// FastScan ARM NEON 独立调试
// 逐步测试：索引构建 → 单查询搜索 → 多线程搜索
// 用法: ./main [threads]
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include "../simd/ann_bench_common.h"
#include "../simd/pq_fastscan_simd.h"
#include "../pthread/pq_fastscan_pthread.h"
#include "../omp/pq_fastscan_omp.h"

int main(int argc, char** argv) {
    int nthr = (argc > 1) ? std::atoi(argv[1]) : 1;
    if (nthr < 1) nthr = 1;

    std::string path = ann_bench::DefaultDataPath();
    std::cerr << "Loading data from: " << path << "\n";

    size_t qn=0, bn=0, gn=0, qd=0, bd=0, gtd=0;
    auto queries = ann_bench::LoadData<float>(path+"DEEP100K.query.fbin", qn, qd);
    auto gt      = ann_bench::LoadData<int>(path+"DEEP100K.gt.query.100k.top100.bin", gn, gtd);
    auto base    = ann_bench::LoadData<float>(path+"DEEP100K.base.100k.fbin", bn, bd);
    qn = std::min<size_t>(qn, 100);  // 只用100条query测试
    const size_t k=10, p=1000;

    std::cerr << "Step 1: train_fastscan...\n";
    ann_fs::FastScanIndex idx;
    ann_fs::train_fastscan(idx, base.get(), static_cast<int>(bn), static_cast<int>(bd));
    ann_fs::encode_fastscan(idx, base.get());
    std::cerr << "  nblk=" << idx.nblk << " M=" << idx.M << " codes_packed.size=" << idx.codes_packed.size() << "\n";

    std::cerr << "Step 2: single query search...\n";
    for (size_t i = 0; i < 3; ++i) {
        auto heap = ann_fs::fastscan_search(idx, base.get(), queries.get()+i*bd, k, static_cast<int>(p));
        std::cerr << "  q" << i << " top-1: id=" << heap.top().second << " dist=" << heap.top().first << "\n";
    }
    std::cerr << "  single query OK\n";

    std::cerr << "Step 3: inter static with nthreads=" << nthr << "...\n";
    {
        std::vector<std::priority_queue<std::pair<float, uint32_t>>> results;
        fastscan_search_inter_static(idx, base.get(), queries.get(), qn, k, p, nthr, results);
        std::cerr << "  inter static OK, results=" << results.size() << "\n";
    }

    std::cerr << "Step 4: inter omp with nthreads=" << nthr << "...\n";
    {
        std::vector<std::priority_queue<std::pair<float, uint32_t>>> results;
        fastscan_search_inter_omp(idx, base.get(), queries.get(), qn, k, p, nthr, results);
        std::cerr << "  inter omp OK, results=" << results.size() << "\n";
    }

    std::cerr << "ALL STEPS PASSED\n";
    return 0;
}
