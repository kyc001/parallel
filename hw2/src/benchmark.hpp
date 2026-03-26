#pragma once

#include <chrono>
#include <cstddef>
#include <cstdint>
#include <functional>
#include <string>

#if defined(_MSC_VER)
#include <intrin.h>
#endif

using Clock = std::chrono::steady_clock;

struct Measurement {
    std::size_t iterations = 0;
    double total_ms = 0.0;
    double avg_ms = 0.0;
    double checksum = 0.0;
};

struct PerfReadings {
    bool available = false;
    std::uint64_t cycles = 0;
    std::uint64_t instructions = 0;
    std::uint64_t cache_references = 0;
    std::uint64_t cache_misses = 0;
    std::string error;
};

bool pin_to_core_zero();
int detect_first_allowed_cpu();
PerfReadings profile_once(const std::function<double()>& fn, std::size_t repeat);

template <class T>
inline void do_not_optimize(const T& value) {
#if defined(_MSC_VER)
    const void* volatile opaque = &value;
    (void)opaque;
    _ReadWriteBarrier();
#else
    asm volatile("" : : "g"(value) : "memory");
#endif
}

inline void clobber_memory() {
#if defined(_MSC_VER)
    _ReadWriteBarrier();
#else
    asm volatile("" : : : "memory");
#endif
}

template <class Fn>
Measurement benchmark(Fn&& fn, double min_total_ms) {
    volatile double sink = 0.0;

    for (int i = 0; i < 2; ++i) {
        const double value = fn();
        do_not_optimize(value);
        sink += value;
        clobber_memory();
    }

    std::size_t iterations = 1;
    double elapsed_ms = 0.0;
    while (true) {
        const auto start = Clock::now();
        double checksum = 0.0;
        for (std::size_t i = 0; i < iterations; ++i) {
            const double value = fn();
            do_not_optimize(value);
            checksum += value;
            clobber_memory();
        }
        const auto end = Clock::now();
        elapsed_ms = std::chrono::duration<double, std::milli>(end - start).count();
        do_not_optimize(checksum);
        sink = checksum;
        if (elapsed_ms >= min_total_ms || iterations > (1u << 20)) {
            break;
        }
        iterations *= 2;
    }

    Measurement m;
    m.iterations = iterations;
    m.total_ms = elapsed_ms;
    m.avg_ms = elapsed_ms / static_cast<double>(iterations);
    m.checksum = sink;
    return m;
}
