#pragma once

#include <algorithm>
#include <cfloat>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <immintrin.h>
#include <queue>
#include <vector>

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

struct SQIndex {
    size_t n, d;
    std::vector<float> vmin, vmax, scale;
    std::vector<uint8_t> codes;

    void build(const float* base, size_t n_, size_t d_) {
        n = n_;
        d = d_;
        vmin.assign(d, FLT_MAX);
        vmax.assign(d, -FLT_MAX);
        scale.resize(d);

        for (size_t i = 0; i < n; ++i) {
            for (size_t j = 0; j < d; ++j) {
                float val = base[i * d + j];
                if (val < vmin[j]) vmin[j] = val;
                if (val > vmax[j]) vmax[j] = val;
            }
        }

        for (size_t j = 0; j < d; ++j) {
            float range = vmax[j] - vmin[j];
            scale[j] = (range > 1e-10f) ? 255.0f / range : 0.0f;
        }

        codes.resize(n * d);
        for (size_t i = 0; i < n; ++i) {
            for (size_t j = 0; j < d; ++j) {
                float normalized = (base[i * d + j] - vmin[j]) * scale[j];
                int val = static_cast<int>(roundf(normalized));
                codes[i * d + j] = static_cast<uint8_t>(
                    val < 0 ? 0 : (val > 255 ? 255 : val));
            }
        }
    }

    void encode_query(const float* query, uint8_t* code) const {
        for (size_t j = 0; j < d; ++j) {
            float normalized = (query[j] - vmin[j]) * scale[j];
            int val = static_cast<int>(roundf(normalized));
            code[j] = static_cast<uint8_t>(
                val < 0 ? 0 : (val > 255 ? 255 : val));
        }
    }
};

inline uint32_t horizontal_sum256_epi32(__m256i v) {
    __m128i lo = _mm256_castsi256_si128(v);
    __m128i hi = _mm256_extracti128_si256(v, 1);
    __m128i sum = _mm_add_epi32(lo, hi);
    sum = _mm_hadd_epi32(sum, sum);
    sum = _mm_hadd_epi32(sum, sum);
    return static_cast<uint32_t>(_mm_cvtsi128_si32(sum));
}

inline uint32_t sq_l2_distance_avx2(const uint8_t* x, const uint8_t* y, int d) {
    const __m256i zero = _mm256_setzero_si256();
    __m256i sum = _mm256_setzero_si256();

    int i = 0;
    for (; i + 32 <= d; i += 32) {
        __m256i vx = _mm256_loadu_si256(reinterpret_cast<const __m256i*>(x + i));
        __m256i vy = _mm256_loadu_si256(reinterpret_cast<const __m256i*>(y + i));

        __m256i xlo = _mm256_unpacklo_epi8(vx, zero);
        __m256i xhi = _mm256_unpackhi_epi8(vx, zero);
        __m256i ylo = _mm256_unpacklo_epi8(vy, zero);
        __m256i yhi = _mm256_unpackhi_epi8(vy, zero);

        __m256i dlo = _mm256_sub_epi16(xlo, ylo);
        __m256i dhi = _mm256_sub_epi16(xhi, yhi);

        sum = _mm256_add_epi32(sum, _mm256_madd_epi16(dlo, dlo));
        sum = _mm256_add_epi32(sum, _mm256_madd_epi16(dhi, dhi));
    }

    uint32_t total = horizontal_sum256_epi32(sum);
    for (; i < d; ++i) {
        int diff = static_cast<int>(x[i]) - static_cast<int>(y[i]);
        total += static_cast<uint32_t>(diff * diff);
    }

    return total;
}

std::priority_queue<std::pair<float, uint32_t>>
sq_search(float* base, float* query, size_t base_number, size_t vecdim, size_t k,
          const SQIndex& sq_index, size_t rerank_p) {
    std::vector<uint8_t> query_code(vecdim);
    sq_index.encode_query(query, query_code.data());
    const uint8_t* qc = query_code.data();

    std::priority_queue<std::pair<uint32_t, uint32_t>> coarse_q;

    for (size_t i = 0; i < base_number; ++i) {
        uint32_t dis = sq_l2_distance_avx2(
            sq_index.codes.data() + i * vecdim, qc, static_cast<int>(vecdim));

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
