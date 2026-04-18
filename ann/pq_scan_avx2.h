#pragma once

#include <algorithm>
#include <cfloat>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <immintrin.h>
#include <iostream>
#include <queue>
#include <vector>

#include "pq_blocked_avx2.h"

#ifndef ANN_AVX2_COMMON_HELPERS
#define ANN_AVX2_COMMON_HELPERS
namespace ann_avx2 {

inline float horizontal_sum256_ps(__m256 v) {
    __m256 h1 = _mm256_hadd_ps(v, v);
    __m256 h2 = _mm256_hadd_ps(h1, h1);
    __m128 lo = _mm256_castps256_ps128(h2);
    __m128 hi = _mm256_extractf128_ps(h2, 1);
    return _mm_cvtss_f32(_mm_add_ss(lo, hi));
}

inline float horizontal_sum128_ps(__m128 v) {
    __m128 h1 = _mm_hadd_ps(v, v);
    __m128 h2 = _mm_hadd_ps(h1, h1);
    return _mm_cvtss_f32(h2);
}

inline float ip_distance_avx2(const float* x, const float* y, int d) {
    __m256 sum0 = _mm256_setzero_ps();
    __m256 sum1 = _mm256_setzero_ps();
    __m256 sum2 = _mm256_setzero_ps();
    __m256 sum3 = _mm256_setzero_ps();

    int i = 0;
    for (; i + 32 <= d; i += 32) {
        __m256 vx0 = _mm256_loadu_ps(x + i);
        __m256 vy0 = _mm256_loadu_ps(y + i);
        sum0 = _mm256_fmadd_ps(vx0, vy0, sum0);

        __m256 vx1 = _mm256_loadu_ps(x + i + 8);
        __m256 vy1 = _mm256_loadu_ps(y + i + 8);
        sum1 = _mm256_fmadd_ps(vx1, vy1, sum1);

        __m256 vx2 = _mm256_loadu_ps(x + i + 16);
        __m256 vy2 = _mm256_loadu_ps(y + i + 16);
        sum2 = _mm256_fmadd_ps(vx2, vy2, sum2);

        __m256 vx3 = _mm256_loadu_ps(x + i + 24);
        __m256 vy3 = _mm256_loadu_ps(y + i + 24);
        sum3 = _mm256_fmadd_ps(vx3, vy3, sum3);
    }

    for (; i + 8 <= d; i += 8) {
        __m256 vx = _mm256_loadu_ps(x + i);
        __m256 vy = _mm256_loadu_ps(y + i);
        sum0 = _mm256_fmadd_ps(vx, vy, sum0);
    }

    __m256 sum_all = _mm256_add_ps(_mm256_add_ps(sum0, sum1),
                                   _mm256_add_ps(sum2, sum3));
    float dot = horizontal_sum256_ps(sum_all);

    for (; i < d; ++i) {
        dot += x[i] * y[i];
    }

    return 1.0f - dot;
}

}  // namespace ann_avx2
#endif

namespace ann_avx2 {

inline float l2_dist_sub_avx2(const float* x, const float* y, int dsub) {
    __m256 sum = _mm256_setzero_ps();
    int j = 0;

    for (; j + 8 <= dsub; j += 8) {
        __m256 diff = _mm256_sub_ps(_mm256_loadu_ps(x + j),
                                    _mm256_loadu_ps(y + j));
        sum = _mm256_fmadd_ps(diff, diff, sum);
    }

    float total = horizontal_sum256_ps(sum);
    if (j + 4 <= dsub) {
        __m128 diff = _mm_sub_ps(_mm_loadu_ps(x + j), _mm_loadu_ps(y + j));
        __m128 sq = _mm_mul_ps(diff, diff);
        total += horizontal_sum128_ps(sq);
        j += 4;
    }

    for (; j < dsub; ++j) {
        float diff = x[j] - y[j];
        total += diff * diff;
    }

    return total;
}

inline float dot_sub_avx2(const float* x, const float* y, int dsub) {
    __m256 sum = _mm256_setzero_ps();
    int j = 0;

    for (; j + 8 <= dsub; j += 8) {
        sum = _mm256_fmadd_ps(_mm256_loadu_ps(x + j),
                              _mm256_loadu_ps(y + j), sum);
    }

    float total = horizontal_sum256_ps(sum);
    if (j + 4 <= dsub) {
        __m128 prod = _mm_mul_ps(_mm_loadu_ps(x + j), _mm_loadu_ps(y + j));
        total += horizontal_sum128_ps(prod);
        j += 4;
    }

    for (; j < dsub; ++j) {
        total += x[j] * y[j];
    }

    return total;
}

}  // namespace ann_avx2

struct PQIndex {
    int M;
    int dsub;
    int ksub;
    int padded_ksub;
    size_t n, d;

    std::vector<float> centroids;
    std::vector<float> centroids_soa;
    std::vector<uint8_t> codes;

    void build(const float* base, size_t n_, size_t d_,
               int M_ = 8, int ksub_ = 256, int niter = 20) {
        n = n_;
        d = d_;
        M = M_;
        ksub = ksub_;
        dsub = static_cast<int>(d / M);
        padded_ksub = ann_pq_blocked_avx2::padded_ksub(ksub);

        centroids.resize(static_cast<size_t>(M) * ksub * dsub);
        centroids_soa.resize(static_cast<size_t>(M) * padded_ksub * dsub);
        codes.resize(n * M);

        std::cerr << "[PQ] Building index: M=" << M
                  << ", dsub=" << dsub
                  << ", ksub=" << ksub
                  << ", niter=" << niter << "\n";

        for (int m = 0; m < M; ++m) {
            std::cerr << "[PQ] Training sub-segment " << m + 1
                      << "/" << M << "...\n";

            std::vector<float> sub_data(n * dsub);
            for (size_t i = 0; i < n; ++i) {
                std::memcpy(sub_data.data() + i * dsub,
                            base + i * d + m * dsub,
                            static_cast<size_t>(dsub) * sizeof(float));
            }

            float* cent = centroids.data() + m * ksub * dsub;

            std::srand(42 + m);
            for (int c = 0; c < ksub; ++c) {
                size_t idx = static_cast<size_t>(std::rand()) % n;
                std::memcpy(cent + c * dsub,
                            sub_data.data() + idx * dsub,
                            static_cast<size_t>(dsub) * sizeof(float));
            }
            float* cent_soa = centroids_soa.data() +
                              static_cast<size_t>(m) * padded_ksub * dsub;
            ann_pq_blocked_avx2::build_soa_from_aos(
                cent, ksub, dsub, padded_ksub, cent_soa);

            std::vector<int> assign(n);

            for (int iter = 0; iter < niter; ++iter) {
                for (size_t i = 0; i < n; ++i) {
                    const float* vec = sub_data.data() + i * dsub;
                    assign[i] = ann_pq_blocked_avx2::argmin_l2_blocked(
                        vec, cent_soa, ksub, dsub, padded_ksub, 32);
                }

                std::vector<float> new_cent(
                    static_cast<size_t>(ksub) * dsub, 0.0f);
                std::vector<int> counts(ksub, 0);

                for (size_t i = 0; i < n; ++i) {
                    int c = assign[i];
                    ++counts[c];
                    const float* vec = sub_data.data() + i * dsub;
                    for (int j = 0; j < dsub; ++j) {
                        new_cent[c * dsub + j] += vec[j];
                    }
                }

                for (int c = 0; c < ksub; ++c) {
                    if (counts[c] > 0) {
                        float inv = 1.0f / counts[c];
                        for (int j = 0; j < dsub; ++j) {
                            cent[c * dsub + j] = new_cent[c * dsub + j] * inv;
                        }
                    }
                }
                ann_pq_blocked_avx2::build_soa_from_aos(
                    cent, ksub, dsub, padded_ksub, cent_soa);
            }

            for (size_t i = 0; i < n; ++i) {
                codes[i * M + m] = static_cast<uint8_t>(assign[i]);
            }
        }

        std::cerr << "[PQ] Index built.\n";
    }

    void build_lut(const float* query, float* lut) const {
        for (int m = 0; m < M; ++m) {
            const float* q_sub = query + m * dsub;
            const float* cent = centroids.data() + static_cast<size_t>(m) * ksub * dsub;
            for (int c = 0; c < ksub; ++c) {
                lut[m * 256 + c] = ann_avx2::dot_sub_avx2(
                    q_sub, cent + static_cast<size_t>(c) * dsub, dsub);
            }
        }
    }
};

inline float adc_distance(const float* lut, const uint8_t* code, int M) {
    float dot = 0.0f;
    for (int m = 0; m < M; ++m) {
        dot += lut[m * 256 + code[m]];
    }
    return 1.0f - dot;
}

std::priority_queue<std::pair<float, uint32_t>>
pq_search(float* base, float* query, size_t base_number, size_t vecdim, size_t k,
          const PQIndex& pq_index, size_t rerank_p) {
    std::vector<float> lut(static_cast<size_t>(pq_index.M) * 256);
    pq_index.build_lut(query, lut.data());

    std::priority_queue<std::pair<float, uint32_t>> coarse_q;

    for (size_t i = 0; i < base_number; ++i) {
        float dis = adc_distance(lut.data(),
                                 pq_index.codes.data() + i * pq_index.M,
                                 pq_index.M);

        if (coarse_q.size() < rerank_p) {
            coarse_q.push({dis, static_cast<uint32_t>(i)});
        } else if (dis < coarse_q.top().first) {
            coarse_q.push({dis, static_cast<uint32_t>(i)});
            coarse_q.pop();
        }
    }

    std::priority_queue<std::pair<float, uint32_t>> q;

    while (!coarse_q.empty()) {
        uint32_t idx = coarse_q.top().second;
        coarse_q.pop();
        float dis = ann_avx2::ip_distance_avx2(base + idx * vecdim, query,
                                               static_cast<int>(vecdim));

        if (q.size() < k) {
            q.push({dis, idx});
        } else if (dis < q.top().first) {
            q.push({dis, idx});
            q.pop();
        }
    }

    return q;
}
