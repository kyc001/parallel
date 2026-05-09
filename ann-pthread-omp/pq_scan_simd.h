#pragma once

#include <algorithm>
#include <arm_neon.h>
#include <cfloat>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <queue>
#include <vector>

#include "pq_blocked_neon.h"

inline float horizontal_sum_f32(float32x4_t v) {
    const float32x2_t sum2 = vadd_f32(vget_low_f32(v), vget_high_f32(v));
    const float32x2_t sum1 = vpadd_f32(sum2, sum2);
    return vget_lane_f32(sum1, 0);
}

inline float ip_distance_simd(const float* x, const float* y, int d) {
    float32x4_t sum0 = vdupq_n_f32(0.0f);
    float32x4_t sum1 = vdupq_n_f32(0.0f);
    float32x4_t sum2 = vdupq_n_f32(0.0f);
    float32x4_t sum3 = vdupq_n_f32(0.0f);
    int i = 0;
    for (; i + 16 <= d; i += 16) {
        sum0 = vmlaq_f32(sum0, vld1q_f32(x + i),      vld1q_f32(y + i));
        sum1 = vmlaq_f32(sum1, vld1q_f32(x + i + 4),  vld1q_f32(y + i + 4));
        sum2 = vmlaq_f32(sum2, vld1q_f32(x + i + 8),  vld1q_f32(y + i + 8));
        sum3 = vmlaq_f32(sum3, vld1q_f32(x + i + 12), vld1q_f32(y + i + 12));
    }
    for (; i + 4 <= d; i += 4) {
        sum0 = vmlaq_f32(sum0, vld1q_f32(x + i), vld1q_f32(y + i));
    }
    const float32x4_t s = vaddq_f32(vaddq_f32(sum0, sum1), vaddq_f32(sum2, sum3));
    return 1.0f - horizontal_sum_f32(s);
}

inline float l2_dist_sub_simd(const float* x, const float* y, int dsub) {
    float32x4_t sum = vdupq_n_f32(0.0f);
    for (int j = 0; j < dsub; j += 4) {
        const float32x4_t diff = vsubq_f32(vld1q_f32(x + j), vld1q_f32(y + j));
        sum = vmlaq_f32(sum, diff, diff);
    }
    return horizontal_sum_f32(sum);
}

inline float dot_sub_simd(const float* x, const float* y, int dsub) {
    float32x4_t sum = vdupq_n_f32(0.0f);
    for (int j = 0; j < dsub; j += 4) {
        sum = vmlaq_f32(sum, vld1q_f32(x + j), vld1q_f32(y + j));
    }
    return horizontal_sum_f32(sum);
}

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
        padded_ksub = ann_pq_blocked_neon::padded_ksub(ksub);

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
                            base + i * d + static_cast<size_t>(m) * dsub,
                            static_cast<size_t>(dsub) * sizeof(float));
            }

            float* cent = centroids.data() + static_cast<size_t>(m) * ksub * dsub;
            float* cent_soa =
                centroids_soa.data() + static_cast<size_t>(m) * padded_ksub * dsub;

            std::srand(42 + m);
            for (int c = 0; c < ksub; ++c) {
                const size_t idx = static_cast<size_t>(std::rand()) % n;
                std::memcpy(cent + static_cast<size_t>(c) * dsub,
                            sub_data.data() + idx * dsub,
                            static_cast<size_t>(dsub) * sizeof(float));
            }
            ann_pq_blocked_neon::build_soa_from_aos(
                cent, ksub, dsub, padded_ksub, cent_soa);

            std::vector<int> assign(n);
            for (int iter = 0; iter < niter; ++iter) {
                for (size_t i = 0; i < n; ++i) {
                    const float* vec = sub_data.data() + i * dsub;
                    assign[i] = ann_pq_blocked_neon::argmin_l2_blocked(
                        vec, cent_soa, ksub, dsub, padded_ksub, 32);
                }

                std::vector<float> new_cent(
                    static_cast<size_t>(ksub) * dsub, 0.0f);
                std::vector<int> counts(ksub, 0);
                for (size_t i = 0; i < n; ++i) {
                    const int c = assign[i];
                    ++counts[c];
                    const float* vec = sub_data.data() + i * dsub;
                    for (int j = 0; j < dsub; ++j) {
                        new_cent[static_cast<size_t>(c) * dsub + j] += vec[j];
                    }
                }

                for (int c = 0; c < ksub; ++c) {
                    if (counts[c] == 0) {
                        continue;
                    }
                    const float inv = 1.0f / counts[c];
                    for (int j = 0; j < dsub; ++j) {
                        cent[static_cast<size_t>(c) * dsub + j] =
                            new_cent[static_cast<size_t>(c) * dsub + j] * inv;
                    }
                }
                ann_pq_blocked_neon::build_soa_from_aos(
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
            const float* q_sub = query + static_cast<size_t>(m) * dsub;
            const float* cent = centroids.data() + static_cast<size_t>(m) * ksub * dsub;
            for (int c = 0; c < ksub; ++c) {
                lut[m * 256 + c] = dot_sub_simd(
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
        const float dis = adc_distance(
            lut.data(),
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
        const uint32_t idx = coarse_q.top().second;
        coarse_q.pop();
        const float dis = ip_distance_simd(
            base + static_cast<size_t>(idx) * vecdim, query, static_cast<int>(vecdim));

        if (q.size() < k) {
            q.push({dis, idx});
        } else if (dis < q.top().first) {
            q.push({dis, idx});
            q.pop();
        }
    }
    return q;
}
