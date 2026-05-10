#pragma once
#include <pthread.h>
#include <functional>
#include <vector>

namespace pth_dyn_intra {

struct Args {
    int tid = 0;
    std::function<void(int)>* work = nullptr;
};

inline void* worker(void* a) {
    auto* x = static_cast<Args*>(a);
    (*x->work)(x->tid);
    return nullptr;
}

inline void run(int nthreads, std::function<void(int)> work) {
    if (nthreads <= 0) nthreads = 1;
    std::vector<pthread_t> tids(static_cast<size_t>(nthreads));
    std::vector<Args> args(static_cast<size_t>(nthreads));
    for (int t = 0; t < nthreads; ++t) {
        args[static_cast<size_t>(t)] = {t, &work};
        pthread_create(&tids[static_cast<size_t>(t)], nullptr, worker,
                       &args[static_cast<size_t>(t)]);
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(tids[static_cast<size_t>(t)], nullptr);
    }
}

}  // namespace pth_dyn_intra
