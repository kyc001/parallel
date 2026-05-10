#pragma once
#include <pthread.h>
#include <algorithm>
#include <atomic>
#include <cstddef>
#include <functional>
#include <vector>

namespace pth_bar {

struct Pool;
struct WorkerArg { Pool* pool = nullptr; int tid = 0; };

struct Pool {
    int nthreads = 1;
    std::vector<pthread_t> tids;
    std::vector<WorkerArg> args;
    pthread_barrier_t bar_start, bar_end;
    std::function<void(size_t)>* work = nullptr;
    size_t n = 0;
    std::atomic<bool> stop{false};
    void init(int threads);
    void submit(std::function<void(size_t)> fn, size_t count);
    void shutdown();
};

inline void* worker(void* a) {
    auto* arg = static_cast<WorkerArg*>(a);
    Pool* pool = arg->pool;
    while (true) {
        pthread_barrier_wait(&pool->bar_start);
        if (pool->stop.load()) break;
        const size_t chunk = (pool->n + static_cast<size_t>(pool->nthreads) - 1) /
                             static_cast<size_t>(pool->nthreads);
        const size_t lo = static_cast<size_t>(arg->tid) * chunk;
        const size_t hi = std::min(lo + chunk, pool->n);
        for (size_t i = lo; i < hi; ++i) (*pool->work)(i);
        pthread_barrier_wait(&pool->bar_end);
    }
    return nullptr;
}

inline void Pool::init(int threads) {
    nthreads = threads > 0 ? threads : 1;
    tids.resize(static_cast<size_t>(nthreads));
    args.resize(static_cast<size_t>(nthreads));
    pthread_barrier_init(&bar_start, nullptr, static_cast<unsigned>(nthreads + 1));
    pthread_barrier_init(&bar_end, nullptr, static_cast<unsigned>(nthreads + 1));
    for (int t = 0; t < nthreads; ++t) {
        args[static_cast<size_t>(t)] = {this, t};
        pthread_create(&tids[static_cast<size_t>(t)], nullptr, worker,
                       &args[static_cast<size_t>(t)]);
    }
}

inline void Pool::submit(std::function<void(size_t)> fn, size_t count) {
    work = &fn;
    n = count;
    pthread_barrier_wait(&bar_start);
    pthread_barrier_wait(&bar_end);
}

inline void Pool::shutdown() {
    stop.store(true);
    pthread_barrier_wait(&bar_start);
    for (auto& tid : tids) pthread_join(tid, nullptr);
    pthread_barrier_destroy(&bar_start);
    pthread_barrier_destroy(&bar_end);
}

}  // namespace pth_bar
