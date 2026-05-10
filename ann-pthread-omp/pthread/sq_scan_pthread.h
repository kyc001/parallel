#pragma once

#include <algorithm>
#include <atomic>
#include <cstdint>
#include <cstddef>
#include <pthread.h>
#include <queue>
#include <utility>
#include <vector>

#if defined(__aarch64__) || defined(__ARM_NEON)
#include "simd/sq_scan_simd.h"
#define ANN_SQ_HAS_NEON 1
#elif defined(__AVX2__)
#include "simd/sq_scan_avx2.h"
#define ANN_SQ_HAS_AVX2 1
#else
#error "SQ SIMD requires ARM NEON or x86 AVX2. Compile x86 builds with -mavx2 -mfma."
#endif

#include "pthread/thread_pool.h"

namespace ann_sq_pthread {

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

static inline uint32_t CoarseDistance(const uint8_t* x, const uint8_t* y, size_t d) {
#if defined(ANN_SQ_HAS_NEON)
    return sq_l2_distance_simd(x, y, static_cast<int>(d));
#else
    return sq_l2_distance_avx2(x, y, static_cast<int>(d));
#endif
}

static inline float ExactDistance(const float* base, const float* query, size_t d) {
#if defined(ANN_SQ_HAS_NEON)
    return ip_distance_simd(base, query, static_cast<int>(d));
#else
    return ann_avx2::ip_distance_avx2(base, query, static_cast<int>(d));
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

static inline SearchHeap Rerank(float* base, float* query, size_t d,
                                size_t k, CoarseHeap& coarse) {
    SearchHeap result;
    while (!coarse.empty()) {
        const uint32_t id = coarse.top().second;
        coarse.pop();
        const float dist = ExactDistance(base + static_cast<size_t>(id) * d, query, d);
        PushTopK(result, dist, id, k);
    }
    return result;
}

struct InterStaticArg {
    float* base;
    float* queries;
    size_t base_n;
    size_t d;
    size_t k;
    const SQIndex* index;
    size_t rerank_p;
    size_t q_start;
    size_t q_end;
    std::vector<SearchHeap>* results;
};

static inline void* InterStaticWorker(void* arg) {
    InterStaticArg* a = static_cast<InterStaticArg*>(arg);
    for (size_t i = a->q_start; i < a->q_end; ++i) {
        (*a->results)[i] = sq_search(a->base, a->queries + i * a->d,
                                     a->base_n, a->d, a->k, *a->index,
                                     a->rerank_p);
    }
    return nullptr;
}

struct InterDynamicArg {
    float* base;
    float* queries;
    size_t base_n;
    size_t query_n;
    size_t d;
    size_t k;
    const SQIndex* index;
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
        (*a->results)[i] = sq_search(a->base, a->queries + i * a->d,
                                     a->base_n, a->d, a->k, *a->index,
                                     a->rerank_p);
    }
    return nullptr;
}

struct IntraStaticArg {
    const SQIndex* index;
    const uint8_t* query_code;
    size_t d;
    size_t keep;
    size_t b_start;
    size_t b_end;
    CoarseHeap local_heap;
};

static inline void* IntraStaticWorker(void* arg) {
    IntraStaticArg* a = static_cast<IntraStaticArg*>(arg);
    for (size_t i = a->b_start; i < a->b_end; ++i) {
        const uint32_t dist = CoarseDistance(
            a->index->codes.data() + i * a->d, a->query_code, a->d);
        PushCoarse(a->local_heap, dist, static_cast<uint32_t>(i), a->keep);
    }
    return nullptr;
}

struct IntraDynamicArg {
    const SQIndex* index;
    const uint8_t* query_code;
    size_t base_n;
    size_t d;
    size_t keep;
    std::atomic<size_t>* next_base;
};

static inline void* IntraDynamicWorker(void* arg) {
    IntraDynamicArg* a = static_cast<IntraDynamicArg*>(arg);
    CoarseHeap* heap = new CoarseHeap();
    while (true) {
        const size_t i = a->next_base->fetch_add(1, std::memory_order_relaxed);
        if (i >= a->base_n) {
            break;
        }
        const uint32_t dist = CoarseDistance(
            a->index->codes.data() + i * a->d, a->query_code, a->d);
        PushCoarse(*heap, dist, static_cast<uint32_t>(i), a->keep);
    }
    return heap;
}

}  // namespace ann_sq_pthread

static inline void sq_search_inter_static(
    float* base, float* queries, size_t base_n, size_t query_n,
    size_t d, size_t k, const SQIndex& sq_index, size_t rerank_p, int nthreads,
    std::vector<ann_sq_pthread::SearchHeap>& results) {
    using namespace ann_sq_pthread;
    nthreads = NormalizeThreads(nthreads);
    rerank_p = NormalizeRerankP(rerank_p, base_n, k);
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
            {base, queries, base_n, d, k, &sq_index, rerank_p, start, end, &results};
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &InterStaticWorker, &args[static_cast<size_t>(t)]);
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(threads[static_cast<size_t>(t)], nullptr);
    }
}

static inline ann_sq_pthread::SearchHeap sq_search_intra_static(
    float* base, float* query, size_t base_n, size_t d, size_t k,
    const SQIndex& sq_index, size_t rerank_p, int nthreads) {
    using namespace ann_sq_pthread;
    nthreads = NormalizeThreads(nthreads);
    rerank_p = NormalizeRerankP(rerank_p, base_n, k);
    std::vector<uint8_t> query_code(d);
    sq_index.encode_query(query, query_code.data());

    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    std::vector<IntraStaticArg> args(static_cast<size_t>(nthreads));
    const size_t chunk = (base_n + static_cast<size_t>(nthreads) - 1) /
                         static_cast<size_t>(nthreads);
    for (int t = 0; t < nthreads; ++t) {
        const size_t start = static_cast<size_t>(t) * chunk;
        const size_t end = std::min(start + chunk, base_n);
        args[static_cast<size_t>(t)] =
            {&sq_index, query_code.data(), d, rerank_p, start, end, CoarseHeap()};
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
    return Rerank(base, query, d, k, coarse);
}

static inline void sq_search_inter_dynamic(
    float* base, float* queries, size_t base_n, size_t query_n,
    size_t d, size_t k, const SQIndex& sq_index, size_t rerank_p, int nthreads,
    std::vector<ann_sq_pthread::SearchHeap>& results) {
    using namespace ann_sq_pthread;
    nthreads = NormalizeThreads(nthreads);
    rerank_p = NormalizeRerankP(rerank_p, base_n, k);
    results.clear();
    results.resize(query_n);

    std::atomic<size_t> next_query(0);
    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    InterDynamicArg arg =
        {base, queries, base_n, query_n, d, k, &sq_index, rerank_p, &next_query, &results};
    for (int t = 0; t < nthreads; ++t) {
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &InterDynamicWorker, &arg);
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(threads[static_cast<size_t>(t)], nullptr);
    }
}

static inline ann_sq_pthread::SearchHeap sq_search_intra_dynamic(
    float* base, float* query, size_t base_n, size_t d, size_t k,
    const SQIndex& sq_index, size_t rerank_p, int nthreads) {
    using namespace ann_sq_pthread;
    nthreads = NormalizeThreads(nthreads);
    rerank_p = NormalizeRerankP(rerank_p, base_n, k);
    std::vector<uint8_t> query_code(d);
    sq_index.encode_query(query, query_code.data());

    std::atomic<size_t> next_base(0);
    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    IntraDynamicArg arg = {&sq_index, query_code.data(), base_n, d, rerank_p, &next_base};
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
    return Rerank(base, query, d, k, coarse);
}

static inline void sq_search_inter_pool(
    float* base, float* queries, size_t base_n, size_t query_n,
    size_t d, size_t k, const SQIndex& sq_index, size_t rerank_p, int nthreads,
    std::vector<ann_sq_pthread::SearchHeap>& results) {
    using namespace ann_sq_pthread;
    nthreads = NormalizeThreads(nthreads);
    rerank_p = NormalizeRerankP(rerank_p, base_n, k);
    results.clear();
    results.resize(query_n);

    ThreadPool pool(nthreads);
    for (size_t i = 0; i < query_n; ++i) {
        pool.Enqueue({i, i + 1, [&, i](size_t, size_t) {
            results[i] = sq_search(base, queries + i * d, base_n, d, k, sq_index, rerank_p);
        }});
    }
    pool.WaitAll();
}

static inline ann_sq_pthread::SearchHeap sq_search_intra_pool(
    float* base, float* query, size_t base_n, size_t d, size_t k,
    const SQIndex& sq_index, size_t rerank_p, int nthreads) {
    using namespace ann_sq_pthread;
    nthreads = NormalizeThreads(nthreads);
    rerank_p = NormalizeRerankP(rerank_p, base_n, k);
    std::vector<uint8_t> query_code(d);
    sq_index.encode_query(query, query_code.data());

    std::vector<CoarseHeap> heaps(static_cast<size_t>(nthreads));
    const size_t chunk = (base_n + static_cast<size_t>(nthreads) - 1) /
                         static_cast<size_t>(nthreads);

    ThreadPool pool(nthreads);
    for (int t = 0; t < nthreads; ++t) {
        const size_t tid = static_cast<size_t>(t);
        const size_t start = tid * chunk;
        const size_t end = std::min(start + chunk, base_n);
        pool.Enqueue({start, end, [&, tid](size_t begin, size_t finish) {
            for (size_t i = begin; i < finish; ++i) {
                const uint32_t dist = CoarseDistance(
                    sq_index.codes.data() + i * d, query_code.data(), d);
                PushCoarse(heaps[tid], dist, static_cast<uint32_t>(i), rerank_p);
            }
        }});
    }
    pool.WaitAll();

    CoarseHeap coarse = MergeCoarse(heaps, rerank_p);
    return Rerank(base, query, d, k, coarse);
}
