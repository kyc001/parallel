#pragma once
#include <pthread.h>

#include <algorithm>
#include <cstddef>
#include <functional>
#include <vector>

namespace pth_dyn {

struct Args {
    size_t lo = 0;
    size_t hi = 0;
    std::function<void(size_t)>* work = nullptr;
};

inline void* worker(void* a) {
    auto* args = static_cast<Args*>(a);
    for (size_t i = args->lo; i < args->hi; ++i) {
        (*args->work)(i);
    }
    return nullptr;
}

inline void parallel_for(size_t n, int nthreads,
                         std::function<void(size_t)> work) {
    if (nthreads <= 0) {
        nthreads = 1;
    }
    std::vector<pthread_t> tids(static_cast<size_t>(nthreads));
    std::vector<Args> args(static_cast<size_t>(nthreads));
    const size_t chunk = (n + static_cast<size_t>(nthreads) - 1) /
                         static_cast<size_t>(nthreads);
    for (int t = 0; t < nthreads; ++t) {
        args[static_cast<size_t>(t)].lo = static_cast<size_t>(t) * chunk;
        args[static_cast<size_t>(t)].hi =
            std::min(args[static_cast<size_t>(t)].lo + chunk, n);
        args[static_cast<size_t>(t)].work = &work;
        pthread_create(&tids[static_cast<size_t>(t)], nullptr, worker,
                       &args[static_cast<size_t>(t)]);
    }
    for (int t = 0; t < nthreads; ++t) {
        pthread_join(tids[static_cast<size_t>(t)], nullptr);
    }
}

}  // namespace pth_dyn
