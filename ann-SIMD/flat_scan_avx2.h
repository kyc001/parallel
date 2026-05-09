#pragma once

#include <cstddef>
#include <cstdint>
#include <immintrin.h>
#include <queue>

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

std::priority_queue<std::pair<float, uint32_t>>
flat_search(float* base, float* query, size_t base_number, size_t vecdim, size_t k) {
    std::priority_queue<std::pair<float, uint32_t>> q;

    for (size_t i = 0; i < base_number; ++i) {
        float dis = ann_avx2::ip_distance_avx2(base + i * vecdim, query,
                                               static_cast<int>(vecdim));

        if (q.size() < k) {
            q.push({dis, static_cast<uint32_t>(i)});
        } else if (dis < q.top().first) {
            q.push({dis, static_cast<uint32_t>(i)});
            q.pop();
        }
    }

    return q;
}
