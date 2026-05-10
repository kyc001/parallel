#pragma once
#include <queue>
#include <arm_neon.h>

// ============================================================
// 水平求和：将 float32x4_t 的 4 个 lane 求和为一个 float
// ============================================================
inline float horizontal_sum_f32(float32x4_t v) {
    float32x2_t sum2 = vadd_f32(vget_low_f32(v), vget_high_f32(v));
    float32x2_t sum1 = vpadd_f32(sum2, sum2);
    return vget_lane_f32(sum1, 0);
}

// ============================================================
// SIMD 内积距离（NEON 加速）
// 计算 1 - Σ(x[i] * y[i])
// 要求：d 是 4 的倍数（DEEP100K d=96，满足）
// ============================================================
inline float ip_distance_simd(const float* x, const float* y, int d) {
    float32x4_t sum0 = vdupq_n_f32(0.0f);
    float32x4_t sum1 = vdupq_n_f32(0.0f);
    float32x4_t sum2 = vdupq_n_f32(0.0f);
    float32x4_t sum3 = vdupq_n_f32(0.0f);

    int i = 0;
    // 4路展开：每次处理 16 个 float
    for (; i + 16 <= d; i += 16) {
        float32x4_t vx0 = vld1q_f32(x + i);
        float32x4_t vy0 = vld1q_f32(y + i);
        sum0 = vmlaq_f32(sum0, vx0, vy0);

        float32x4_t vx1 = vld1q_f32(x + i + 4);
        float32x4_t vy1 = vld1q_f32(y + i + 4);
        sum1 = vmlaq_f32(sum1, vx1, vy1);

        float32x4_t vx2 = vld1q_f32(x + i + 8);
        float32x4_t vy2 = vld1q_f32(y + i + 8);
        sum2 = vmlaq_f32(sum2, vx2, vy2);

        float32x4_t vx3 = vld1q_f32(x + i + 12);
        float32x4_t vy3 = vld1q_f32(y + i + 12);
        sum3 = vmlaq_f32(sum3, vx3, vy3);
    }
    // 处理剩余（16的倍数之后，4个一组）
    for (; i + 4 <= d; i += 4) {
        float32x4_t vx = vld1q_f32(x + i);
        float32x4_t vy = vld1q_f32(y + i);
        sum0 = vmlaq_f32(sum0, vx, vy);
    }

    // 合并 4 个累加器
    float32x4_t sum_all = vaddq_f32(vaddq_f32(sum0, sum1), vaddq_f32(sum2, sum3));
    return 1.0f - horizontal_sum_f32(sum_all);
}

// ============================================================
// SIMD 欧几里得距离（备用，报告中用于对比）
// 计算 Σ(x[i] - y[i])^2
// ============================================================
inline float l2_distance_simd(const float* x, const float* y, int d) {
    float32x4_t sum0 = vdupq_n_f32(0.0f);
    float32x4_t sum1 = vdupq_n_f32(0.0f);
    float32x4_t sum2 = vdupq_n_f32(0.0f);
    float32x4_t sum3 = vdupq_n_f32(0.0f);

    int i = 0;
    for (; i + 16 <= d; i += 16) {
        float32x4_t diff0 = vsubq_f32(vld1q_f32(x + i), vld1q_f32(y + i));
        sum0 = vmlaq_f32(sum0, diff0, diff0);

        float32x4_t diff1 = vsubq_f32(vld1q_f32(x + i + 4), vld1q_f32(y + i + 4));
        sum1 = vmlaq_f32(sum1, diff1, diff1);

        float32x4_t diff2 = vsubq_f32(vld1q_f32(x + i + 8), vld1q_f32(y + i + 8));
        sum2 = vmlaq_f32(sum2, diff2, diff2);

        float32x4_t diff3 = vsubq_f32(vld1q_f32(x + i + 12), vld1q_f32(y + i + 12));
        sum3 = vmlaq_f32(sum3, diff3, diff3);
    }
    for (; i + 4 <= d; i += 4) {
        float32x4_t diff = vsubq_f32(vld1q_f32(x + i), vld1q_f32(y + i));
        sum0 = vmlaq_f32(sum0, diff, diff);
    }

    float32x4_t sum_all = vaddq_f32(vaddq_f32(sum0, sum1), vaddq_f32(sum2, sum3));
    return horizontal_sum_f32(sum_all);
}

// ============================================================
// Flat Search — SIMD 加速版
// 返回值类型与原版完全一致
// ============================================================
std::priority_queue<std::pair<float, uint32_t>>
flat_search(float* base, float* query, size_t base_number, size_t vecdim, size_t k) {
    std::priority_queue<std::pair<float, uint32_t>> q;

    for (size_t i = 0; i < base_number; ++i) {
        float dis = ip_distance_simd(base + i * vecdim, query, vecdim);

        if (q.size() < k) {
            q.push({dis, (uint32_t)i});
        } else {
            if (dis < q.top().first) {
                q.push({dis, (uint32_t)i});
                q.pop();
            }
        }
    }
    return q;
}
