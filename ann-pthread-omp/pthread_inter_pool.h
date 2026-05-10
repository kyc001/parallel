#pragma once
#include <pthread.h>
#include <cstddef>
#include <functional>
#include <queue>
#include <vector>

namespace pth_pool {
struct Task { size_t lo = 0; size_t hi = 0; };

struct Pool {
    int nthreads = 1, active = 0;
    std::vector<pthread_t> tids;
    std::queue<Task> q;
    pthread_mutex_t mu;
    pthread_cond_t cv_work, cv_done;
    std::function<void(size_t)>* work = nullptr;
    bool stop = false;
    void init(int threads);
    void submit(std::function<void(size_t)> fn, size_t n, size_t chunk_size = 64);
    void shutdown();
};

inline void* worker(void* a) {
    auto* pool = static_cast<Pool*>(a);
    while (true) {
        pthread_mutex_lock(&pool->mu);
        while (pool->q.empty() && !pool->stop) pthread_cond_wait(&pool->cv_work, &pool->mu);
        if (pool->stop && pool->q.empty()) {
            pthread_mutex_unlock(&pool->mu);
            break;
        }
        Task task = pool->q.front();
        pool->q.pop();
        ++pool->active;
        auto* work = pool->work;
        pthread_mutex_unlock(&pool->mu);
        for (size_t i = task.lo; i < task.hi; ++i) (*work)(i);
        pthread_mutex_lock(&pool->mu);
        --pool->active;
        if (pool->active == 0 && pool->q.empty()) pthread_cond_signal(&pool->cv_done);
        pthread_mutex_unlock(&pool->mu);
    }
    return nullptr;
}

inline void Pool::init(int threads) {
    nthreads = threads > 0 ? threads : 1;
    pthread_mutex_init(&mu, nullptr);
    pthread_cond_init(&cv_work, nullptr);
    pthread_cond_init(&cv_done, nullptr);
    tids.resize(static_cast<size_t>(nthreads));
    for (int t = 0; t < nthreads; ++t) pthread_create(&tids[static_cast<size_t>(t)], nullptr, worker, this);
}

inline void Pool::submit(std::function<void(size_t)> fn, size_t n, size_t chunk_size) {
    if (chunk_size == 0) chunk_size = 64;
    pthread_mutex_lock(&mu);
    work = &fn;
    for (size_t lo = 0; lo < n; lo += chunk_size) {
        const size_t hi = lo + chunk_size < n ? lo + chunk_size : n;
        q.push({lo, hi});
    }
    pthread_cond_broadcast(&cv_work);
    while (active > 0 || !q.empty()) pthread_cond_wait(&cv_done, &mu);
    pthread_mutex_unlock(&mu);
}

inline void Pool::shutdown() {
    pthread_mutex_lock(&mu);
    stop = true;
    pthread_cond_broadcast(&cv_work);
    pthread_mutex_unlock(&mu);
    for (auto& tid : tids) pthread_join(tid, nullptr);
    pthread_cond_destroy(&cv_done);
    pthread_cond_destroy(&cv_work);
    pthread_mutex_destroy(&mu);
}
}  // namespace pth_pool
