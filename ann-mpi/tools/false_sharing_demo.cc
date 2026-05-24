// False sharing 对照实验
// 两个版本: (a) 紧凑 counters，相邻线程的 counter 在同一 cache line (false sharing)
//          (b) padding 到 64B，每个 counter 独占 cache line
// 编译: g++ tools/false_sharing_demo.cc -o build/false_sharing_demo.exe -O2 -fopenmp -lpthread -std=c++17

#include <atomic>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <vector>
#include <omp.h>

struct Counter {
    int64_t value;  // 8 bytes, 8 counters/cache line
};

struct alignas(64) PaddedCounter {
    int64_t value;
    char padding[56];  // 让总大小 64B, 每个 counter 独占 cache line
};

int main(int argc, char** argv) {
    const int  T = (argc > 1) ? std::atoi(argv[1]) : 16;
    const long ITERS = (argc > 2) ? std::atol(argv[2]) : 50000000L;

    // Version A: compact counters (false sharing)
    std::vector<Counter> ca(static_cast<size_t>(T));
    for (auto& c : ca) c.value = 0;
    const auto t1 = std::chrono::high_resolution_clock::now();
#pragma omp parallel num_threads(T)
    {
        const int tid = omp_get_thread_num();
        for (long i = 0; i < ITERS; ++i) {
            ca[tid].value += 1;
        }
    }
    const auto t2 = std::chrono::high_resolution_clock::now();
    const double ms_a = std::chrono::duration<double, std::milli>(t2 - t1).count();

    // Version B: padded counters (no false sharing)
    std::vector<PaddedCounter> cb(static_cast<size_t>(T));
    for (auto& c : cb) c.value = 0;
    const auto t3 = std::chrono::high_resolution_clock::now();
#pragma omp parallel num_threads(T)
    {
        const int tid = omp_get_thread_num();
        for (long i = 0; i < ITERS; ++i) {
            cb[tid].value += 1;
        }
    }
    const auto t4 = std::chrono::high_resolution_clock::now();
    const double ms_b = std::chrono::duration<double, std::milli>(t4 - t3).count();

    // sanity check
    int64_t sum_a = 0, sum_b = 0;
    for (auto& c : ca) sum_a += c.value;
    for (auto& c : cb) sum_b += c.value;

    std::cout << std::fixed << std::setprecision(2);
    std::cout << "T=" << T << " iters=" << ITERS << "\n";
    std::cout << "  false_sharing:  " << ms_a << " ms (sum=" << sum_a << ")\n";
    std::cout << "  padded(64B):    " << ms_b << " ms (sum=" << sum_b << ")\n";
    std::cout << "  ratio (FS/pad): " << (ms_a / ms_b) << "x\n";
    return 0;
}
