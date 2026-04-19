// Microbenchmark: AoS baseline vs SoA+blocking argmin for PQ encoding.
// Predicts the 15-point "cross-centroid + SoA layout + block+cache" path
// actually delivers measurable speedup in the encoding stage (which is
// where this repository applies it; query hot-path is intentionally
// untouched, see report section 3.4).
//
// Scenario: one k-means assignment pass over N=100000 sub-vectors of
// dimension dsub=12 against Ks=256 centroids, repeated 5 times.
//
// Output: CSV on stdout.

#include <algorithm>
#include <chrono>
#include <cfloat>
#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <memory>
#include <random>
#include <string>
#include <vector>

#include "../pq_blocked_avx2.h"

// AoS: centroids laid out as [c][j], one centroid contiguous.
// argmin searches by iterating c, computing scalar/SIMD L2 per centroid.
static int argmin_l2_aos(const float* x, const float* cent_aos, int ksub, int dsub) {
    float best = FLT_MAX;
    int best_c = 0;
    for (int c = 0; c < ksub; ++c) {
        const float* v = cent_aos + static_cast<size_t>(c) * dsub;
        float s = 0.0f;
        for (int j = 0; j < dsub; ++j) {
            float diff = v[j] - x[j];
            s += diff * diff;
        }
        if (s < best) {
            best = s;
            best_c = c;
        }
    }
    return best_c;
}

int main(int argc, char** argv) {
    const size_t N = (argc > 1) ? std::strtoull(argv[1], nullptr, 10) : 100000;
    const int dsub = 12;
    const int ksub = 256;
    const int repeat = (argc > 2) ? std::atoi(argv[2]) : 5;

    // Load 100K base for realistic input; take first N sub-vectors of
    // segment 0 (offset 0, dimension dsub).
    std::ifstream fin("./files/DEEP100K.base.100k.fbin", std::ios::binary);
    if (!fin) {
        std::cerr << "cannot open ./files/DEEP100K.base.100k.fbin\n";
        return 1;
    }
    uint32_t n32 = 0, d32 = 0;
    fin.read(reinterpret_cast<char*>(&n32), 4);
    fin.read(reinterpret_cast<char*>(&d32), 4);
    if (n32 < N) {
        std::cerr << "not enough vectors in base: " << n32 << "\n";
        return 1;
    }
    std::vector<float> base(static_cast<size_t>(n32) * d32);
    fin.read(reinterpret_cast<char*>(base.data()),
             static_cast<std::streamsize>(base.size() * sizeof(float)));

    // Extract first dsub dimensions for N vectors.
    std::vector<float> subvecs(N * dsub);
    for (size_t i = 0; i < N; ++i) {
        for (int j = 0; j < dsub; ++j) {
            subvecs[i * dsub + j] = base[i * d32 + j];
        }
    }

    // Random centroids for repeatable comparison.
    std::mt19937 rng(42);
    std::uniform_int_distribution<size_t> pick(0, N - 1);
    std::vector<float> cent_aos(static_cast<size_t>(ksub) * dsub);
    for (int c = 0; c < ksub; ++c) {
        size_t id = pick(rng);
        for (int j = 0; j < dsub; ++j) {
            cent_aos[c * dsub + j] = subvecs[id * dsub + j];
        }
    }

    const int padded = ann_pq_blocked_avx2::padded_ksub(ksub);
    std::vector<float> cent_soa(static_cast<size_t>(padded) * dsub);
    ann_pq_blocked_avx2::build_soa_from_aos(
        cent_aos.data(), ksub, dsub, padded, cent_soa.data());

    std::cout << "variant,repeat,ms,assign_per_us\n";
    std::cout << std::fixed << std::setprecision(4);

    // Correctness sanity: both variants should agree on assignment.
    bool match = true;
    for (size_t sample = 0; sample < std::min<size_t>(1000, N); ++sample) {
        int a = argmin_l2_aos(subvecs.data() + sample * dsub, cent_aos.data(), ksub, dsub);
        int b = ann_pq_blocked_avx2::argmin_l2_blocked(
            subvecs.data() + sample * dsub, cent_soa.data(), ksub, dsub, padded, 32);
        if (a != b) { match = false; break; }
    }
    std::cerr << "sanity check (AoS == SoA): " << (match ? "OK" : "MISMATCH") << "\n";

    std::vector<int> assign(N);

    // ---- AoS ----
    for (int rep = 0; rep < repeat; ++rep) {
        auto t0 = std::chrono::high_resolution_clock::now();
        for (size_t i = 0; i < N; ++i) {
            assign[i] = argmin_l2_aos(
                subvecs.data() + i * dsub, cent_aos.data(), ksub, dsub);
        }
        auto t1 = std::chrono::high_resolution_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        double per_us = static_cast<double>(N) / (ms * 1000.0);
        std::cout << "aos," << rep << "," << ms << "," << per_us << "\n";
    }

    // ---- SoA + blocking ----
    for (int rep = 0; rep < repeat; ++rep) {
        auto t0 = std::chrono::high_resolution_clock::now();
        for (size_t i = 0; i < N; ++i) {
            assign[i] = ann_pq_blocked_avx2::argmin_l2_blocked(
                subvecs.data() + i * dsub, cent_soa.data(), ksub, dsub, padded, 32);
        }
        auto t1 = std::chrono::high_resolution_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        double per_us = static_cast<double>(N) / (ms * 1000.0);
        std::cout << "soa_blocked," << rep << "," << ms << "," << per_us << "\n";
    }

    return 0;
}
