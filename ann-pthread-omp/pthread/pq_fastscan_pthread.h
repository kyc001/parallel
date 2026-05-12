#pragma once

#include <algorithm>
#include <atomic>
#include <cstdint>
#include <cstddef>
#include <pthread.h>
#include <queue>
#include <utility>
#include <vector>

#include "../simd/pq_fastscan_simd.h"
#include "thread_pool.h"

namespace ann_fastscan_pthread {

using SearchHeap = std::priority_queue<std::pair<float, uint32_t>>;
using CoarseHeap = std::priority_queue<std::pair<uint32_t, uint32_t>>;

static inline int NormalizeThreads(int nthreads) {
    return nthreads < 1 ? 1 : nthreads;
}

static inline size_t NormalizeRerankP(size_t rerank_p, size_t base_n, size_t k) {
    if (rerank_p < k) {
        rerank_p = k;
    }
    return std::min(rerank_p, base_n);
}

static inline int BatchWidth() {
#if defined(__AVX2__)
    return 32;
#else
    return 16;
#endif
}

static inline void ComputeBlock(const ann_fs::FastScanIndex& index,
                                const std::vector<uint8_t>& lut,
                                int block, uint8_t* out) {
#if defined(__AVX2__)
    ann_fs::fastscan_batch32(index.codes_packed.data(), lut.data(), index.M,
                             index.nblk, block, out);
#else
    ann_fs::fastscan_batch16(index.codes_packed.data(), lut.data(), index.M,
                             index.nblk, block, out);
#endif
}

static inline void PushCoarse(CoarseHeap& heap, uint32_t dist, uint32_t id, size_t keep) {
    if (heap.size() < keep) {
        heap.push(std::make_pair(dist, id));
    } else if (dist < heap.top().first) {
        heap.push(std::make_pair(dist, id));
        heap.pop();
    }
}

static inline void PushTopK(SearchHeap& heap, float dist, uint32_t id, size_t k) {
    if (heap.size() < k) {
        heap.push(std::make_pair(dist, id));
    } else if (dist < heap.top().first) {
        heap.push(std::make_pair(dist, id));
        heap.pop();
    }
}

static inline CoarseHeap MergeCoarse(std::vector<CoarseHeap>& heaps, size_t keep) {
    CoarseHeap result;
    for (size_t i = 0; i < heaps.size(); ++i) {
        while (!heaps[i].empty()) {
            const std::pair<uint32_t, uint32_t> item = heaps[i].top();
            heaps[i].pop();
            PushCoarse(result, item.first, item.second, keep);
        }
    }
    return result;
}

static inline SearchHeap Rerank(const ann_fs::FastScanIndex& index,
                                const float* base, const float* query,
                                size_t k, CoarseHeap& coarse) {
    SearchHeap result;
    while (!coarse.empty()) {
        const uint32_t id = coarse.top().second;
        coarse.pop();
        const float dist =
            ann_fs::fs_ip_distance(base + static_cast<size_t>(id) * index.d, query, index.d);
        PushTopK(result, dist, id, k);
    }
    return result;
}

struct InterStaticArg {
    const ann_fs::FastScanIndex* index;
    const float* base;
    const float* queries;
    size_t query_n;
    size_t k;
    size_t rerank_p;
    size_t q_start;
    size_t q_end;
    std::vector<SearchHeap>* results;
};

static inline void* InterStaticWorker(void* arg) {
    InterStaticArg* a = static_cast<InterStaticArg*>(arg);
    for (size_t i = a->q_start; i < a->q_end; ++i) {
        (*a->results)[i] = ann_fs::fastscan_search(
            *a->index, a->base, a->queries + i * a->index->d,
            a->k, static_cast<int>(a->rerank_p));
    }
    return nullptr;
}

struct InterDynamicArg {
    const ann_fs::FastScanIndex* index;
    const float* base;
    const float* queries;
    size_t query_n;
    size_t k;
    size_t rerank_p;
    std::atomic<size_t>* next_query;
    std::vector<SearchHeap>* results;
};

static inline void* InterDynamicWorker(void* arg) {
    InterDynamicArg* a = static_cast<InterDynamicArg*>(arg);
    while (true) {
        const size_t i = a->next_query->fetch_add(1, std::memory_order_relaxed);
        if (i >= a->query_n) {
            break;
        }
        (*a->results)[i] = ann_fs::fastscan_search(
            *a->index, a->base, a->queries + i * a->index->d,
            a->k, static_cast<int>(a->rerank_p));
    }
    return nullptr;
}

struct IntraStaticArg {
    const ann_fs::FastScanIndex* index;
    const std::vector<uint8_t>* lut;
    size_t keep;
    int block_start;
    int block_end;
    CoarseHeap local_heap;
};

static inline void* IntraStaticWorker(void* arg) {
    IntraStaticArg* a = static_cast<IntraStaticArg*>(arg);
    const int width = BatchWidth();
    std::vector<uint8_t> dist(static_cast<size_t>(width), 0);
    for (int block = a->block_start; block < a->block_end; ++block) {
        ComputeBlock(*a->index, *a->lut, block, dist.data());
        for (int lane = 0; lane < width; ++lane) {
            const uint32_t id = static_cast<uint32_t>(block * width + lane);
            if (id < static_cast<uint32_t>(a->index->N)) {
                PushCoarse(a->local_heap, dist[static_cast<size_t>(lane)], id, a->keep);
            }
        }
    }
    return nullptr;
}

struct IntraDynamicArg {
    const ann_fs::FastScanIndex* index;
    const std::vector<uint8_t>* lut;
    size_t keep;
    std::atomic<int>* next_block;
};

static inline void* IntraDynamicWorker(void* arg) {
    IntraDynamicArg* a = static_cast<IntraDynamicArg*>(arg);
    CoarseHeap* heap = new CoarseHeap();
    const int width = BatchWidth();
    std::vector<uint8_t> dist(static_cast<size_t>(width), 0);
    while (true) {
        const int block = a->next_block->fetch_add(1, std::memory_order_relaxed);
        if (block >= a->index->nblk) {
            break;
        }
        ComputeBlock(*a->index, *a->lut, block, dist.data());
        for (int lane = 0; lane < width; ++lane) {
            const uint32_t id = static_cast<uint32_t>(block * width + lane);
            if (id < static_cast<uint32_t>(a->index->N)) {
                PushCoarse(*heap, dist[static_cast<size_t>(lane)], id, a->keep);
            }
        }
    }
    return heap;
}

}  // namespace ann_fastscan_pthread

static inline void fastscan_search_inter_static(
    const ann_fs::FastScanIndex& index, const float* base, const float* queries,
    size_t query_n, size_t k, size_t rerank_p, int nthreads,
    std::vector<ann_fastscan_pthread::SearchHeap>& results) {
    using namespace ann_fastscan_pthread;
    nthreads = NormalizeThreads(nthreads);
    rerank_p = NormalizeRerankP(rerank_p, static_cast<size_t>(index.N), k);
    results.clear();
    results.resize(query_n);

    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    std::vector<InterStaticArg> args(static_cast<size_t>(nthreads));
    const size_t chunk = (query_n + static_cast<size_t>(nthreads) - 1) /
                         static_cast<size_t>(nthreads);
    for (int t = 0; t < nthreads; ++t) {
        const size_t start = static_cast<size_t>(t) * chunk;
        const size_t end = std::min(start + chunk, query_n);
        args[static_cast<size_t>(t)] =
            {&index, base, queries, query_n, k, rerank_p, start, end, &results};
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &InterStaticWorker, &args[static_cast<size_t>(t)]);
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(threads[static_cast<size_t>(t)], nullptr);
    }
}

static inline ann_fastscan_pthread::SearchHeap fastscan_search_intra_static(
    const ann_fs::FastScanIndex& index, const float* base, const float* query,
    size_t k, size_t rerank_p, int nthreads) {
    using namespace ann_fastscan_pthread;
    nthreads = NormalizeThreads(nthreads);
    rerank_p = NormalizeRerankP(rerank_p, static_cast<size_t>(index.N), k);
    std::vector<uint8_t> lut;
    ann_fs::build_lut_u8(index, query, lut);

    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    std::vector<IntraStaticArg> args(static_cast<size_t>(nthreads));
    const int chunk = (index.nblk + nthreads - 1) / nthreads;
    for (int t = 0; t < nthreads; ++t) {
        const int start = t * chunk;
        const int end = std::min(start + chunk, index.nblk);
        args[static_cast<size_t>(t)] =
            {&index, &lut, rerank_p, start, end, CoarseHeap()};
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &IntraStaticWorker, &args[static_cast<size_t>(t)]);
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(threads[static_cast<size_t>(t)], nullptr);
    }

    std::vector<CoarseHeap> heaps;
    heaps.reserve(static_cast<size_t>(nthreads));
    for (int t = 0; t < nthreads; ++t) {
        heaps.push_back(std::move(args[static_cast<size_t>(t)].local_heap));
    }
    CoarseHeap coarse = MergeCoarse(heaps, rerank_p);
    return Rerank(index, base, query, k, coarse);
}

static inline void fastscan_search_inter_dynamic(
    const ann_fs::FastScanIndex& index, const float* base, const float* queries,
    size_t query_n, size_t k, size_t rerank_p, int nthreads,
    std::vector<ann_fastscan_pthread::SearchHeap>& results) {
    using namespace ann_fastscan_pthread;
    nthreads = NormalizeThreads(nthreads);
    rerank_p = NormalizeRerankP(rerank_p, static_cast<size_t>(index.N), k);
    results.clear();
    results.resize(query_n);

    std::atomic<size_t> next_query(0);
    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    InterDynamicArg arg = {&index, base, queries, query_n, k, rerank_p, &next_query, &results};
    for (int t = 0; t < nthreads; ++t) {
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &InterDynamicWorker, &arg);
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(threads[static_cast<size_t>(t)], nullptr);
    }
}

static inline ann_fastscan_pthread::SearchHeap fastscan_search_intra_dynamic(
    const ann_fs::FastScanIndex& index, const float* base, const float* query,
    size_t k, size_t rerank_p, int nthreads) {
    using namespace ann_fastscan_pthread;
    nthreads = NormalizeThreads(nthreads);
    rerank_p = NormalizeRerankP(rerank_p, static_cast<size_t>(index.N), k);
    std::vector<uint8_t> lut;
    ann_fs::build_lut_u8(index, query, lut);

    std::atomic<int> next_block(0);
    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    IntraDynamicArg arg = {&index, &lut, rerank_p, &next_block};
    for (int t = 0; t < nthreads; ++t) {
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &IntraDynamicWorker, &arg);
    }

    std::vector<CoarseHeap> heaps;
    heaps.reserve(static_cast<size_t>(nthreads));
    for (int t = 0; t < nthreads; ++t) {
        void* ret = nullptr;
        pthread_join(threads[static_cast<size_t>(t)], &ret);
        CoarseHeap* heap = static_cast<CoarseHeap*>(ret);
        heaps.push_back(std::move(*heap));
        delete heap;
    }
    CoarseHeap coarse = MergeCoarse(heaps, rerank_p);
    return Rerank(index, base, query, k, coarse);
}

static inline void fastscan_search_inter_pool(
    const ann_fs::FastScanIndex& index, const float* base, const float* queries,
    size_t query_n, size_t k, size_t rerank_p, int nthreads,
    std::vector<ann_fastscan_pthread::SearchHeap>& results) {
    using namespace ann_fastscan_pthread;
    nthreads = NormalizeThreads(nthreads);
    rerank_p = NormalizeRerankP(rerank_p, static_cast<size_t>(index.N), k);
    results.clear();
    results.resize(query_n);

    ThreadPool pool(nthreads);
    for (size_t i = 0; i < query_n; ++i) {
        pool.Enqueue({i, i + 1, [&, i](size_t, size_t) {
            results[i] = ann_fs::fastscan_search(
                index, base, queries + i * index.d, k, static_cast<int>(rerank_p));
        }});
    }
    pool.WaitAll();
}

static inline ann_fastscan_pthread::SearchHeap fastscan_search_intra_pool(
    const ann_fs::FastScanIndex& index, const float* base, const float* query,
    size_t k, size_t rerank_p, int nthreads) {
    using namespace ann_fastscan_pthread;
    nthreads = NormalizeThreads(nthreads);
    rerank_p = NormalizeRerankP(rerank_p, static_cast<size_t>(index.N), k);
    std::vector<uint8_t> lut;
    ann_fs::build_lut_u8(index, query, lut);

    std::vector<CoarseHeap> heaps(static_cast<size_t>(index.nblk));
    ThreadPool pool(nthreads);
    for (int block = 0; block < index.nblk; ++block) {
        pool.Enqueue({static_cast<size_t>(block), static_cast<size_t>(block + 1),
                      [&, block](size_t, size_t) {
            const int width = BatchWidth();
            std::vector<uint8_t> dist(static_cast<size_t>(width), 0);
            ComputeBlock(index, lut, block, dist.data());
            for (int lane = 0; lane < width; ++lane) {
                const uint32_t id = static_cast<uint32_t>(block * width + lane);
                if (id < static_cast<uint32_t>(index.N)) {
                    PushCoarse(heaps[static_cast<size_t>(block)],
                               dist[static_cast<size_t>(lane)], id, rerank_p);
                }
            }
        }});
    }
    pool.WaitAll();

    CoarseHeap coarse = MergeCoarse(heaps, rerank_p);
    return Rerank(index, base, query, k, coarse);
}
