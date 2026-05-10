#pragma once

#include <algorithm>
#include <atomic>
#include <pthread.h>
#include <vector>

#include "hnsw/hnsw_graph_utils.h"
#include "pthread/thread_pool.h"

namespace ann_hnsw_pthread {

static inline int NormalizeThreads(int nthreads) {
    return nthreads < 1 ? 1 : nthreads;
}

struct EntryArg {
    const ann_hnsw::HnswIndex* index;
    const float* query;
    const std::vector<uint32_t>* entries;
    size_t k;
    size_t ef;
    size_t start;
    size_t end;
    ann_hnsw::SearchHeap local_heap;
};

static inline void* EntryStaticWorker(void* arg) {
    EntryArg* a = static_cast<EntryArg*>(arg);
    std::vector<ann_hnsw::SearchHeap> heaps;
    for (size_t i = a->start; i < a->end; ++i) {
        heaps.push_back(ann_hnsw::SearchLayer0FromEntry(
            *a->index, a->query, (*a->entries)[i], a->k, a->ef));
    }
    a->local_heap = ann_hnsw::MergeHeaps(heaps, a->k);
    return nullptr;
}

struct EntryDynamicArg {
    const ann_hnsw::HnswIndex* index;
    const float* query;
    const std::vector<uint32_t>* entries;
    size_t k;
    size_t ef;
    std::atomic<size_t>* next_entry;
};

static inline void* EntryDynamicWorker(void* arg) {
    EntryDynamicArg* a = static_cast<EntryDynamicArg*>(arg);
    std::vector<ann_hnsw::SearchHeap> heaps;
    while (true) {
        const size_t i = a->next_entry->fetch_add(1, std::memory_order_relaxed);
        if (i >= a->entries->size()) {
            break;
        }
        heaps.push_back(ann_hnsw::SearchLayer0FromEntry(
            *a->index, a->query, (*a->entries)[i], a->k, a->ef));
    }
    ann_hnsw::SearchHeap* result = new ann_hnsw::SearchHeap(
        ann_hnsw::MergeHeaps(heaps, a->k));
    return result;
}

}  // namespace ann_hnsw_pthread

static inline ann_hnsw::SearchHeap hnsw_search_multi_entry_static(
    const ann_hnsw::HnswIndex& index, const float* query, size_t k,
    size_t ef, int nthreads) {
    using namespace ann_hnsw_pthread;
    nthreads = NormalizeThreads(nthreads);
    const std::vector<uint32_t> entries = ann_hnsw::PickEntries(index, nthreads);
    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    std::vector<EntryArg> args(static_cast<size_t>(nthreads));
    const size_t chunk = (entries.size() + static_cast<size_t>(nthreads) - 1) /
                         static_cast<size_t>(nthreads);
    for (int t = 0; t < nthreads; ++t) {
        const size_t start = static_cast<size_t>(t) * chunk;
        const size_t end = std::min(start + chunk, entries.size());
        args[static_cast<size_t>(t)] = {&index, query, &entries, k, ef, start, end,
                                        ann_hnsw::SearchHeap()};
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &EntryStaticWorker, &args[static_cast<size_t>(t)]);
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(threads[static_cast<size_t>(t)], nullptr);
    }
    std::vector<ann_hnsw::SearchHeap> heaps;
    for (int t = 0; t < nthreads; ++t) {
        heaps.push_back(std::move(args[static_cast<size_t>(t)].local_heap));
    }
    return ann_hnsw::MergeHeaps(heaps, k);
}

static inline ann_hnsw::SearchHeap hnsw_search_multi_entry_dynamic(
    const ann_hnsw::HnswIndex& index, const float* query, size_t k,
    size_t ef, int nthreads) {
    using namespace ann_hnsw_pthread;
    nthreads = NormalizeThreads(nthreads);
    const std::vector<uint32_t> entries = ann_hnsw::PickEntries(index, nthreads);
    std::atomic<size_t> next_entry(0);
    std::vector<pthread_t> threads(static_cast<size_t>(nthreads));
    EntryDynamicArg arg = {&index, query, &entries, k, ef, &next_entry};
    for (int t = 0; t < nthreads; ++t) {
        pthread_create(&threads[static_cast<size_t>(t)], nullptr,
                       &EntryDynamicWorker, &arg);
    }
    std::vector<ann_hnsw::SearchHeap> heaps;
    for (int t = 0; t < nthreads; ++t) {
        void* ret = nullptr;
        pthread_join(threads[static_cast<size_t>(t)], &ret);
        ann_hnsw::SearchHeap* heap = static_cast<ann_hnsw::SearchHeap*>(ret);
        heaps.push_back(std::move(*heap));
        delete heap;
    }
    return ann_hnsw::MergeHeaps(heaps, k);
}

static inline ann_hnsw::SearchHeap hnsw_search_multi_entry_pool(
    const ann_hnsw::HnswIndex& index, const float* query, size_t k,
    size_t ef, int nthreads) {
    nthreads = ann_hnsw_pthread::NormalizeThreads(nthreads);
    const std::vector<uint32_t> entries = ann_hnsw::PickEntries(index, nthreads);
    std::vector<ann_hnsw::SearchHeap> heaps(entries.size());
    ThreadPool pool(nthreads);
    for (size_t i = 0; i < entries.size(); ++i) {
        pool.Enqueue({i, i + 1, [&, i](size_t, size_t) {
            heaps[i] = ann_hnsw::SearchLayer0FromEntry(index, query, entries[i], k, ef);
        }});
    }
    pool.WaitAll();
    return ann_hnsw::MergeHeaps(heaps, k);
}
