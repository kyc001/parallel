#include <cstdint>
#include <cstddef>
#include <queue>
#include <vector>
#include <algorithm>
#include <cmath>
#include <cfloat>
#include <cstring>
#include <arm_neon.h>

// ---- 串行版本 ----
float ip_distance_serial(const float* x, const float* y, int d) {
    float sum = 0;
    for (int i = 0; i < d; i++) {
        sum += x[i] * y[i];
    }
    return 1.0f - sum;
}

// ---- 从 flat_scan_simd.h 提取 ----
inline float horizontal_sum_f32(float32x4_t v) {
    float32x2_t sum2 = vadd_f32(vget_low_f32(v), vget_high_f32(v));
    float32x2_t sum1 = vpadd_f32(sum2, sum2);
    return vget_lane_f32(sum1, 0);
}

float ip_distance_simd(const float* x, const float* y, int d) {
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

// ---- 从 sq_scan_simd.h 提取 ----
uint32_t sq_l2_distance_simd(const uint8_t* x, const uint8_t* y, int d) {
    uint32x4_t sum = vdupq_n_u32(0);
    for (int i = 0; i < d; i += 16) {
        uint8x16_t vx = vld1q_u8(x + i);
        uint8x16_t vy = vld1q_u8(y + i);
        uint8x16_t diff = vabdq_u8(vx, vy);
        uint16x8_t sq_lo = vmull_u8(vget_low_u8(diff), vget_low_u8(diff));
        uint16x8_t sq_hi = vmull_u8(vget_high_u8(diff), vget_high_u8(diff));
        sum = vpadalq_u16(sum, sq_lo);
        sum = vpadalq_u16(sum, sq_hi);
    }
    return vaddvq_u32(sum);
}

// ---- 从 pq_scan_simd.h 提取 ----
float adc_distance(const float* lut, const uint8_t* code, int M) {
    float dot = 0.0f;
    for (int m = 0; m < M; m++) {
        dot += lut[m * 256 + code[m]];
    }
    return 1.0f - dot;
}

float dot_sub_simd(const float* x, const float* y, int dsub) {
    float32x4_t sum = vdupq_n_f32(0.0f);
    for (int j = 0; j < dsub; j += 4) {
        sum = vmlaq_f32(sum, vld1q_f32(x + j), vld1q_f32(y + j));
    }
    return horizontal_sum_f32(sum);
}

// 防止编译器优化掉未使用的函数
volatile float sink;
volatile uint32_t usink;

int main() {
    float a[96], b[96];
    uint8_t ua[96], ub[96];
    float lut[8 * 256];
    uint8_t code[8];

    sink = ip_distance_serial(a, b, 96);
    sink = ip_distance_simd(a, b, 96);
    usink = sq_l2_distance_simd(ua, ub, 96);
    sink = adc_distance(lut, code, 8);
    sink = dot_sub_simd(a, b, 12);
    return 0;
}
