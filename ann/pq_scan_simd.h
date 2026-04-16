#pragma once
#include <queue>
#include <vector>
#include <algorithm>
#include <cmath>
#include <cfloat>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <arm_neon.h>

// ============================================================
// 工具函数
// ============================================================
inline float horizontal_sum_f32(float32x4_t v) {
    float32x2_t sum2 = vadd_f32(vget_low_f32(v), vget_high_f32(v));
    float32x2_t sum1 = vpadd_f32(sum2, sum2);
    return vget_lane_f32(sum1, 0);
}

// float32 IP 距离 SIMD（rerank 用）
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
    for (; i + 4 <= d; i += 4)
        sum0 = vmlaq_f32(sum0, vld1q_f32(x + i), vld1q_f32(y + i));
    float32x4_t s = vaddq_f32(vaddq_f32(sum0, sum1), vaddq_f32(sum2, sum3));
    return 1.0f - horizontal_sum_f32(s);
}

// 子向量 L2 距离 SIMD（KMeans 用，dsub 是 4 的倍数）
inline float l2_dist_sub_simd(const float* x, const float* y, int dsub) {
    float32x4_t sum = vdupq_n_f32(0.0f);
    for (int j = 0; j < dsub; j += 4) {
        float32x4_t diff = vsubq_f32(vld1q_f32(x + j), vld1q_f32(y + j));
        sum = vmlaq_f32(sum, diff, diff);
    }
    return horizontal_sum_f32(sum);
}

// 子向量点积 SIMD（LUT 构建用）
inline float dot_sub_simd(const float* x, const float* y, int dsub) {
    float32x4_t sum = vdupq_n_f32(0.0f);
    for (int j = 0; j < dsub; j += 4) {
        sum = vmlaq_f32(sum, vld1q_f32(x + j), vld1q_f32(y + j));
    }
    return horizontal_sum_f32(sum);
}

// ============================================================
// PQ 索引
// ============================================================
struct PQIndex {
    int M;         // 子段数
    int dsub;      // 每段维度
    int ksub;      // 每段聚类中心数 (256)
    size_t n, d;

    // centroids[m * ksub * dsub + c * dsub + j]
    std::vector<float> centroids;
    // codes[i * M + m]
    std::vector<uint8_t> codes;

    // ----------------------------------------------------------
    // 构建 PQ 索引：KMeans 聚类 + 编码
    // M_: 子段数（默认 8，dsub=12）
    // ksub_: 每段聚类数（固定 256）
    // niter: KMeans 迭代次数
    // ----------------------------------------------------------
    void build(const float* base, size_t n_, size_t d_,
               int M_ = 8, int ksub_ = 256, int niter = 20) {
        n = n_; d = d_; M = M_; ksub = ksub_;
        dsub = d / M;

        centroids.resize(M * ksub * dsub);
        codes.resize(n * M);

        std::cerr << "[PQ] Building index: M=" << M
                  << ", dsub=" << dsub << ", ksub=" << ksub
                  << ", niter=" << niter << "\n";

        for (int m = 0; m < M; m++) {
            std::cerr << "[PQ] Training sub-segment " << m+1 << "/" << M << "...\n";

            // 提取子向量
            std::vector<float> sub_data(n * dsub);
            for (size_t i = 0; i < n; i++) {
                memcpy(sub_data.data() + i * dsub,
                       base + i * d + m * dsub,
                       dsub * sizeof(float));
            }

            float* cent = centroids.data() + m * ksub * dsub;

            // 随机初始化中心
            srand(42 + m);
            for (int c = 0; c < ksub; c++) {
                size_t idx = rand() % n;
                memcpy(cent + c * dsub,
                       sub_data.data() + idx * dsub,
                       dsub * sizeof(float));
            }

            // Lloyd's KMeans
            std::vector<int> assign(n);

            for (int iter = 0; iter < niter; iter++) {
                // --- 分配阶段 ---
                for (size_t i = 0; i < n; i++) {
                    const float* vec = sub_data.data() + i * dsub;
                    float best_dist = FLT_MAX;
                    int best_c = 0;
                    for (int c = 0; c < ksub; c++) {
                        float dist = l2_dist_sub_simd(vec, cent + c * dsub, dsub);
                        if (dist < best_dist) {
                            best_dist = dist;
                            best_c = c;
                        }
                    }
                    assign[i] = best_c;
                }

                // --- 更新中心 ---
                std::vector<float> new_cent(ksub * dsub, 0.0f);
                std::vector<int> counts(ksub, 0);
                for (size_t i = 0; i < n; i++) {
                    int c = assign[i];
                    counts[c]++;
                    const float* vec = sub_data.data() + i * dsub;
                    for (int j = 0; j < dsub; j++) {
                        new_cent[c * dsub + j] += vec[j];
                    }
                }
                for (int c = 0; c < ksub; c++) {
                    if (counts[c] > 0) {
                        float inv = 1.0f / counts[c];
                        for (int j = 0; j < dsub; j++) {
                            cent[c * dsub + j] = new_cent[c * dsub + j] * inv;
                        }
                    }
                }
            }

            // --- 编码 ---
            for (size_t i = 0; i < n; i++) {
                codes[i * M + m] = (uint8_t)assign[i];
            }
        }
        std::cerr << "[PQ] Index built.\n";
    }

    // ----------------------------------------------------------
    // 构建 LUT：查询子向量到每个中心的点积
    // lut[m * 256 + c] = dot(query_sub_m, centroid_m_c)
    // ----------------------------------------------------------
    void build_lut(const float* query, float* lut) const {
        for (int m = 0; m < M; m++) {
            const float* q_sub = query + m * dsub;
            const float* cent = centroids.data() + m * ksub * dsub;
            for (int c = 0; c < ksub; c++) {
                lut[m * 256 + c] = dot_sub_simd(q_sub, cent + c * dsub, dsub);
            }
        }
    }
};

// ============================================================
// ADC 距离：查表累加
// ============================================================
inline float adc_distance(const float* lut, const uint8_t* code, int M) {
    float dot = 0.0f;
    for (int m = 0; m < M; m++) {
        dot += lut[m * 256 + code[m]];
    }
    return 1.0f - dot;  // IP distance = 1 - dot_product
}

// ============================================================
// PQ 两阶段检索
//   粗排：ADC 距离，取 Top-p 候选
//   精排：float32 IP SIMD，取 Top-k
// ============================================================
std::priority_queue<std::pair<float, uint32_t>>
pq_search(float* base, float* query, size_t base_number, size_t vecdim, size_t k,
          const PQIndex& pq_index, size_t rerank_p) {

    // 构建 LUT
    std::vector<float> lut(pq_index.M * 256);
    pq_index.build_lut(query, lut.data());

    // ---- 粗排：ADC ----
    std::priority_queue<std::pair<float, uint32_t>> coarse_q;

    for (size_t i = 0; i < base_number; ++i) {
        float dis = adc_distance(
            lut.data(),
            pq_index.codes.data() + i * pq_index.M,
            pq_index.M);

        if (coarse_q.size() < rerank_p) {
            coarse_q.push({dis, (uint32_t)i});
        } else if (dis < coarse_q.top().first) {
            coarse_q.push({dis, (uint32_t)i});
            coarse_q.pop();
        }
    }

    // ---- 精排：float32 SIMD ----
    std::priority_queue<std::pair<float, uint32_t>> q;

    while (!coarse_q.empty()) {
        uint32_t idx = coarse_q.top().second;
        coarse_q.pop();
        float dis = ip_distance_simd(base + idx * vecdim, query, vecdim);

        if (q.size() < k) {
            q.push({dis, idx});
        } else if (dis < q.top().first) {
            q.push({dis, idx});
            q.pop();
        }
    }
    return q;
}