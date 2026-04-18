#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
#include <vector>

#if defined(__AVX2__)
#include "../flat_scan_avx2.h"
#elif defined(__aarch64__) || defined(__ARM_NEON)
#include "../flat_scan_simd.h"
#else
#error "manual_vs_autovec.cc requires AVX2 or AArch64 NEON."
#endif

namespace {

#if defined(__GNUC__) || defined(__clang__)
__attribute__((noinline, optimize("no-tree-vectorize")))
#endif
float ip_distance_scalar_novec(const float* x, const float* y, int d) {
    float sum = 0.0f;
    for (int i = 0; i < d; ++i) {
        sum += x[i] * y[i];
    }
    return 1.0f - sum;
}

#if defined(__GNUC__) || defined(__clang__)
__attribute__((noinline))
#endif
float ip_distance_auto(const float* __restrict x, const float* __restrict y, int d) {
    float sum = 0.0f;
    for (int i = 0; i < d; ++i) {
        sum += x[i] * y[i];
    }
    return 1.0f - sum;
}

float ip_distance_manual(const float* x, const float* y, int d) {
#if defined(__AVX2__)
    return ann_avx2::ip_distance_avx2(x, y, d);
#else
    return ip_distance_simd(x, y, d);
#endif
}

template <typename Fn>
double BenchmarkKernel(Fn fn, const std::vector<float>& a, const std::vector<float>& b,
                       int d, int repeat) {
    volatile float sink = 0.0f;
    const auto start = std::chrono::high_resolution_clock::now();
    for (int r = 0; r < repeat; ++r) {
        sink += fn(a.data(), b.data(), d);
    }
    const auto stop = std::chrono::high_resolution_clock::now();
    if (sink == 123456.0f) {
        std::fprintf(stderr, "impossible\n");
    }
    return std::chrono::duration<double, std::nano>(stop - start).count() /
           static_cast<double>(repeat);
}

std::string ArchLabel() {
#if defined(__AVX2__)
    return "avx2";
#else
    return "neon";
#endif
}

}  // namespace

int main(int argc, char** argv) {
    const int d = (argc >= 2) ? std::atoi(argv[1]) : 96;
    const int repeat = (argc >= 3) ? std::atoi(argv[2]) : 2000000;

    std::vector<float> a(static_cast<size_t>(d));
    std::vector<float> b(static_cast<size_t>(d));
    for (int i = 0; i < d; ++i) {
        a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
        b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
    }

    const double scalar_ns = BenchmarkKernel(ip_distance_scalar_novec, a, b, d, repeat);
    const double auto_ns = BenchmarkKernel(ip_distance_auto, a, b, d, repeat);
    const double manual_ns = BenchmarkKernel(ip_distance_manual, a, b, d, repeat);

    std::cout << "arch=" << ArchLabel() << "\n";
    std::cout << "d=" << d << " repeat=" << repeat << "\n";
    std::cout << "scalar_novec_ns=" << scalar_ns << "\n";
    std::cout << "autovec_ns=" << auto_ns << "\n";
    std::cout << "manual_simd_ns=" << manual_ns << "\n";
    std::cout << "autovec_speedup_vs_scalar=" << (scalar_ns / auto_ns) << "\n";
    std::cout << "manual_speedup_vs_scalar=" << (scalar_ns / manual_ns) << "\n";
    std::cout << "manual_speedup_vs_autovec=" << (auto_ns / manual_ns) << "\n";
    return 0;
}
