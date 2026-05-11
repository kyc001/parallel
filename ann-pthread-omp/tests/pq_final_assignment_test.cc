#include <cmath>
#include <cstdint>
#include <iostream>
#include <limits>
#include <random>
#include <sstream>
#include <vector>

#include "simd/pq_scan_avx2.h"

static int nearest_final_centroid(const PQIndex& index,
                                  const float* vec,
                                  int segment) {
    const float* centroids = index.centroids.data() +
        static_cast<size_t>(segment) * index.ksub * index.dsub;

    int best = 0;
    float best_dist = std::numeric_limits<float>::max();
    for (int c = 0; c < index.ksub; ++c) {
        const float* centroid = centroids + static_cast<size_t>(c) * index.dsub;
        float dist = 0.0f;
        for (int j = 0; j < index.dsub; ++j) {
            const float diff = vec[j] - centroid[j];
            dist += diff * diff;
        }
        if (dist < best_dist) {
            best_dist = dist;
            best = c;
        }
    }
    return best;
}

int main() {
    constexpr size_t n = 64;
    constexpr size_t d = 12;
    constexpr int m = 1;
    constexpr int ksub = 8;
    constexpr int niter = 1;

    std::ostringstream pq_logs;
    std::streambuf* old_cerr = std::cerr.rdbuf(pq_logs.rdbuf());

    for (int seed = 0; seed < 128; ++seed) {
        std::mt19937 rng(static_cast<uint32_t>(seed));
        std::normal_distribution<float> noise(0.0f, 0.08f);
        std::vector<float> base(n * d);

        for (size_t i = 0; i < n; ++i) {
            const float cluster = static_cast<float>(i % 4);
            for (size_t j = 0; j < d; ++j) {
                base[i * d + j] =
                    cluster * 3.0f +
                    static_cast<float>(j) * 0.15f +
                    noise(rng);
            }
        }

        PQIndex index;
        index.build(base.data(), n, d, m, ksub, niter);

        for (size_t i = 0; i < n; ++i) {
            const int expected =
                nearest_final_centroid(index, base.data() + i * d, 0);
            const int actual = static_cast<int>(index.codes[i * m]);
            if (actual != expected) {
                std::cerr.rdbuf(old_cerr);
                std::cerr << "PQ code was not recomputed against final centroids: "
                          << "seed=" << seed
                          << " point=" << i
                          << " expected=" << expected
                          << " actual=" << actual << "\n";
                return 1;
            }
        }
    }

    std::cerr.rdbuf(old_cerr);
    return 0;
}
