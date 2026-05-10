#pragma once
#include <pthread.h>
#include <functional>
#include <vector>

namespace pth_bar_intra {

struct Pool;
struct Arg { Pool* pool = nullptr; int tid = 0; };

struct Pool {
    int nthreads = 1;
    std::vector<pthread_t> tids;
    std::vector<Arg> args;
    pthread_barrier_t bar_start, bar_end;
    std::function<void(int)>* work = nullptr;
    bool stop = false;
};

inline void* worker(void* a) {
    auto* arg = static_cast<Arg*>(a);
    Pool* p = arg->pool;
    while (true) {
        pthread_barrier_wait(&p->bar_start);
        if (p->stop) break;
        (*p->work)(arg->tid);
        pthread_barrier_wait(&p->bar_end);
    }
    return nullptr;
}

inline void init(Pool& p, int nthreads) {
    p.nthreads = nthreads > 0 ? nthreads : 1;
    p.tids.resize(static_cast<size_t>(p.nthreads));
    p.args.resize(static_cast<size_t>(p.nthreads));
    pthread_barrier_init(&p.bar_start, nullptr, static_cast<unsigned>(p.nthreads + 1));
    pthread_barrier_init(&p.bar_end, nullptr, static_cast<unsigned>(p.nthreads + 1));
    for (int t = 0; t < p.nthreads; ++t) {
        p.args[static_cast<size_t>(t)] = {&p, t};
        pthread_create(&p.tids[static_cast<size_t>(t)], nullptr, worker,
                       &p.args[static_cast<size_t>(t)]);
    }
}

inline void run(Pool& p, std::function<void(int)> work) {
    p.work = &work;
    pthread_barrier_wait(&p.bar_start);
    pthread_barrier_wait(&p.bar_end);
}

inline void shutdown(Pool& p) {
    p.stop = true;
    pthread_barrier_wait(&p.bar_start);
    for (auto& tid : p.tids) pthread_join(tid, nullptr);
    pthread_barrier_destroy(&p.bar_start);
    pthread_barrier_destroy(&p.bar_end);
}

}  // namespace pth_bar_intra
