// Flat-AVX-512 inner-product distance kernel (96-dim).
// Drop-in replacement for flat_scan_avx2's kernel, but with 512-bit zmm.
// 96 floats / 16 floats/lane = 6 zmm FMAs per distance, organized as
// three independent accumulators to keep the two FMA ports saturated.
#pragma once

#include <cstddef>
#include <cstdint>
#include <queue>

#ifdef __AVX512F__
#include <immintrin.h>

namespace ann_avx512 {

inline float horizontal_sum512_ps(__m512 v) {
    return _mm512_reduce_add_ps(v);
}

inline float ip_distance_avx512(const float* x, const float* y, int d) {
    __m512 s0 = _mm512_setzero_ps();
    __m512 s1 = _mm512_setzero_ps();
    __m512 s2 = _mm512_setzero_ps();

    int i = 0;
    // 96-dim => 6 full 16-lane blocks, grouped 3-wide.
    for (; i + 48 <= d; i += 48) {
        __m512 vx0 = _mm512_loadu_ps(x + i);
        __m512 vy0 = _mm512_loadu_ps(y + i);
        s0 = _mm512_fmadd_ps(vx0, vy0, s0);
        __m512 vx1 = _mm512_loadu_ps(x + i + 16);
        __m512 vy1 = _mm512_loadu_ps(y + i + 16);
        s1 = _mm512_fmadd_ps(vx1, vy1, s1);
        __m512 vx2 = _mm512_loadu_ps(x + i + 32);
        __m512 vy2 = _mm512_loadu_ps(y + i + 32);
        s2 = _mm512_fmadd_ps(vx2, vy2, s2);
    }
    for (; i + 16 <= d; i += 16) {
        __m512 vx = _mm512_loadu_ps(x + i);
        __m512 vy = _mm512_loadu_ps(y + i);
        s0 = _mm512_fmadd_ps(vx, vy, s0);
    }
    __m512 sum = _mm512_add_ps(_mm512_add_ps(s0, s1), s2);
    float dot = horizontal_sum512_ps(sum);
    for (; i < d; ++i) dot += x[i] * y[i];
    return 1.0f - dot;
}

}  // namespace ann_avx512

inline std::priority_queue<std::pair<float, uint32_t>>
flat_search_avx512(const float* base, const float* query, size_t base_number,
                   size_t vecdim, size_t k) {
    std::priority_queue<std::pair<float, uint32_t>> q;
    for (size_t i = 0; i < base_number; ++i) {
        float dis = ann_avx512::ip_distance_avx512(
            base + i * vecdim, query, static_cast<int>(vecdim));
        if (q.size() < k) {
            q.push({dis, static_cast<uint32_t>(i)});
        } else if (dis < q.top().first) {
            q.push({dis, static_cast<uint32_t>(i)});
            q.pop();
        }
    }
    return q;
}

#endif  // __AVX512F__
