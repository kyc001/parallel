#pragma once

#include <algorithm>
#include <atomic>
#include <cstddef>
#include <pthread.h>
#include <vector>

#include "ivf/ivf_scan_simd.h"
#include "pthread/thread_pool.h"

namespace ann_ivf_pthread {

static inline int NormalizeThreads(int nthreads) {
    return nthreads < 1 ? 1 : nthreads;
}

struct InterStaticArg {
    const ann_ivf::IVFIndex* index;
    const float* queries;
    size_t query_n;
    size_t d;
    size_t k;
    size_t nprobe;
    size_t q_start;
    size_t q_end;
    std::vector<ann_ivf::SearchHeap>* results;
};

static inline void* InterStaticWorker(void* arg) {
    InterStaticArg* a = static_cast<InterStaticArg*>(arg);
    for (size_t i = a->q_start; i < a->q_end; ++i) {
        (*a->results)[i] = ivf_search(*a->index, a->queries + i * a->d,
                                      a->k, a->nprobe);
    }
    return nullptr;
}

struct InterDynamicArg {
    const ann_ivf::IVFIndex* index;
    const float* queries;
    size_t query_n;
    size_t d;
    size_t k;
    size_t nprobe;
    std::atomic<size_t>* next_query;
    std::vector<ann_ivf::SearchHeap>* results;
};

static inline void* InterDynamicWorker(void* arg) {
    InterDynamicArg* a = static_cast<InterDynamicArg*>(arg);
    while (true) {
        const size_t i = a->next_query->fetch_add(1, std::memory_order_relaxed);
        if (i >= a->query_n) {
            break;
        }
        (*a->results)[i] = ivf_search(*a->index, a->queries + i * a->d,
                                      a->k, a->nprobe);
    }
    return nullptr;
}

struct IntraStaticArg {
    const ann_ivf::IVFIndex* index;
    const float* query;
    const std::vector<uint32_t>* probes;
    size_t k;
    size_t p_start;
    size_t p_end;
    ann_ivf::SearchHeap local_heap;
};

static inline void* IntraStaticWorker(void* arg) {
    IntraStaticArg* a = static_cast<IntraStaticArg*>(arg);
    for (size_t i = a->p_start; i < a->p_end; ++i) {
        ann_ivf::ScanList(*a->index, a->query, (*a->probes)[i],
                          a->k, a->local_heap);
    }
    return nullptr;
}

struct IntraDynamicArg {
    const ann_ivf::IVFIndex* index;
    const float* query;
    const std::vector<uint32_t>* probes;
    size_t k;
    std::atomic<size_t>* next_probe;
};

static inline void* IntraDynamicWorker(void* arg) {
    IntraDynamicArg* a = static_cast<IntraDynamicArg*>(arg);
    ann_ivf::SearchHeap* heap = new ann_ivf::SearchHeap();
    while (true) {
        const size_t i = a->next_probe->fetch_add(1, std::memory_order_relaxed);
        if (i >= a->probes->size()) {
            break;
        }
        ann_ivf::ScanList(*a->index, a->query, (*a->probes)[i], a->k, *heap);
    }
    return heap;
}

}  // namespace ann_ivf_pthread

static inline void ivf_search_inter_static(
    const ann_ivf::IVFIndex& index, const float* queries, size_t query_n,
    size_t k, size_t nprobe, int nthreads,
    std::vector<ann_ivf::SearchHeap>& results) {
    using namespace ann_ivf_pthread;
    nthreads = NormalizeThreads(nthreads);
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
            {&index, queries, query_n, index.d, k, nprobe, start, end, &results};
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &InterStaticWorker, &args[static_cast<size_t>(t)]);
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(threads[static_cast<size_t>(t)], nullptr);
    }
}

static inline ann_ivf::SearchHeap ivf_search_intra_static(
    const ann_ivf::IVFIndex& index, const float* query, size_t k,
    size_t nprobe, int nthreads) {
    using namespace ann_ivf_pthread;
    nthreads = NormalizeThreads(nthreads);
    const std::vector<uint32_t> probes = index.select_probes(query, nprobe);

    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    std::vector<IntraStaticArg> args(static_cast<size_t>(nthreads));
    const size_t chunk = (probes.size() + static_cast<size_t>(nthreads) - 1) /
                         static_cast<size_t>(nthreads);
    for (int t = 0; t < nthreads; ++t) {
        const size_t start = static_cast<size_t>(t) * chunk;
        const size_t end = std::min(start + chunk, probes.size());
        args[static_cast<size_t>(t)] =
            {&index, query, &probes, k, start, end, ann_ivf::SearchHeap()};
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &IntraStaticWorker, &args[static_cast<size_t>(t)]);
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(threads[static_cast<size_t>(t)], nullptr);
    }

    std::vector<ann_ivf::SearchHeap> heaps;
    heaps.reserve(static_cast<size_t>(nthreads));
    for (int t = 0; t < nthreads; ++t) {
        heaps.push_back(std::move(args[static_cast<size_t>(t)].local_heap));
    }
    return ann_ivf::MergeHeaps(heaps, k);
}

static inline void ivf_search_inter_dynamic(
    const ann_ivf::IVFIndex& index, const float* queries, size_t query_n,
    size_t k, size_t nprobe, int nthreads,
    std::vector<ann_ivf::SearchHeap>& results) {
    using namespace ann_ivf_pthread;
    nthreads = NormalizeThreads(nthreads);
    results.clear();
    results.resize(query_n);

    std::atomic<size_t> next_query(0);
    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    InterDynamicArg arg =
        {&index, queries, query_n, index.d, k, nprobe, &next_query, &results};
    for (int t = 0; t < nthreads; ++t) {
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &InterDynamicWorker, &arg);
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(threads[static_cast<size_t>(t)], nullptr);
    }
}

static inline ann_ivf::SearchHeap ivf_search_intra_dynamic(
    const ann_ivf::IVFIndex& index, const float* query, size_t k,
    size_t nprobe, int nthreads) {
    using namespace ann_ivf_pthread;
    nthreads = NormalizeThreads(nthreads);
    const std::vector<uint32_t> probes = index.select_probes(query, nprobe);
    std::atomic<size_t> next_probe(0);
    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    IntraDynamicArg arg = {&index, query, &probes, k, &next_probe};

    for (int t = 0; t < nthreads; ++t) {
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &IntraDynamicWorker, &arg);
    }

    std::vector<ann_ivf::SearchHeap> heaps;
    heaps.reserve(static_cast<size_t>(nthreads));
    for (int t = 0; t < nthreads; ++t) {
        void* ret = nullptr;
        pthread_join(threads[static_cast<size_t>(t)], &ret);
        ann_ivf::SearchHeap* heap = static_cast<ann_ivf::SearchHeap*>(ret);
        heaps.push_back(std::move(*heap));
        delete heap;
    }
    return ann_ivf::MergeHeaps(heaps, k);
}

static inline void ivf_search_inter_pool(
    const ann_ivf::IVFIndex& index, const float* queries, size_t query_n,
    size_t k, size_t nprobe, int nthreads,
    std::vector<ann_ivf::SearchHeap>& results) {
    nthreads = ann_ivf_pthread::NormalizeThreads(nthreads);
    results.clear();
    results.resize(query_n);

    ThreadPool pool(nthreads);
    for (size_t i = 0; i < query_n; ++i) {
        pool.Enqueue({i, i + 1, [&, i](size_t, size_t) {
            results[i] = ivf_search(index, queries + i * index.d, k, nprobe);
        }});
    }
    pool.WaitAll();
}

static inline ann_ivf::SearchHeap ivf_search_intra_pool(
    const ann_ivf::IVFIndex& index, const float* query, size_t k,
    size_t nprobe, int nthreads) {
    nthreads = ann_ivf_pthread::NormalizeThreads(nthreads);
    const std::vector<uint32_t> probes = index.select_probes(query, nprobe);
    std::vector<ann_ivf::SearchHeap> heaps(probes.size());

    ThreadPool pool(nthreads);
    for (size_t p = 0; p < probes.size(); ++p) {
        pool.Enqueue({p, p + 1, [&, p](size_t, size_t) {
            ann_ivf::ScanList(index, query, probes[p], k, heaps[p]);
        }});
    }
    pool.WaitAll();
    return ann_ivf::MergeHeaps(heaps, k);
}
