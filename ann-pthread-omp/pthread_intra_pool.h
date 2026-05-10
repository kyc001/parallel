#pragma once
#include <pthread.h>
#include <cstddef>
#include <functional>
#include <queue>
#include <vector>

namespace pth_pool_intra {

struct Task { size_t lo = 0; size_t hi = 0; };
struct Pool;
struct Arg { Pool* pool = nullptr; int tid = 0; };

struct Pool {
    int nthreads = 1, active = 0;
    std::vector<pthread_t> tids;
    std::vector<Arg> args;
    std::queue<Task> q;
    pthread_mutex_t mu;
    pthread_cond_t cv_work, cv_done;
    bool stop = false;
    std::function<void(int, size_t, size_t)>* work = nullptr;
};

inline void* worker(void* a) {
    auto* arg = static_cast<Arg*>(a);
    Pool* p = arg->pool;
    while (true) {
        pthread_mutex_lock(&p->mu);
        while (p->q.empty() && !p->stop) pthread_cond_wait(&p->cv_work, &p->mu);
        if (p->stop && p->q.empty()) { pthread_mutex_unlock(&p->mu); break; }
        Task task = p->q.front();
        p->q.pop();
        ++p->active;
        auto* work = p->work;
        pthread_mutex_unlock(&p->mu);
        (*work)(arg->tid, task.lo, task.hi);
        pthread_mutex_lock(&p->mu);
        --p->active;
        if (p->active == 0 && p->q.empty()) pthread_cond_signal(&p->cv_done);
        pthread_mutex_unlock(&p->mu);
    }
    return nullptr;
}

inline void init(Pool& p, int nthreads) {
    p.nthreads = nthreads > 0 ? nthreads : 1;
    pthread_mutex_init(&p.mu, nullptr);
    pthread_cond_init(&p.cv_work, nullptr);
    pthread_cond_init(&p.cv_done, nullptr);
    p.tids.resize(static_cast<size_t>(p.nthreads));
    p.args.resize(static_cast<size_t>(p.nthreads));
    for (int t = 0; t < p.nthreads; ++t) {
        p.args[static_cast<size_t>(t)] = {&p, t};
        pthread_create(&p.tids[static_cast<size_t>(t)], nullptr, worker,
                       &p.args[static_cast<size_t>(t)]);
    }
}

inline void run(Pool& p, size_t n, size_t chunk_size,
                std::function<void(int, size_t, size_t)> work) {
    if (chunk_size == 0) chunk_size = 1024;
    pthread_mutex_lock(&p.mu);
    p.work = &work;
    for (size_t lo = 0; lo < n; lo += chunk_size) {
        const size_t hi = lo + chunk_size < n ? lo + chunk_size : n;
        p.q.push({lo, hi});
    }
    pthread_cond_broadcast(&p.cv_work);
    while (p.active > 0 || !p.q.empty()) pthread_cond_wait(&p.cv_done, &p.mu);
    pthread_mutex_unlock(&p.mu);
}

inline void shutdown(Pool& p) {
    pthread_mutex_lock(&p.mu);
    p.stop = true;
    pthread_cond_broadcast(&p.cv_work);
    pthread_mutex_unlock(&p.mu);
    for (auto& tid : p.tids) pthread_join(tid, nullptr);
    pthread_cond_destroy(&p.cv_done);
    pthread_cond_destroy(&p.cv_work);
    pthread_mutex_destroy(&p.mu);
}

}  // namespace pth_pool_intra
