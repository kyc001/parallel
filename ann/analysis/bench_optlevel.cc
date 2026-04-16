#include <cstdint>
#include <cstddef>
#include <cstdio>
#include <cstring>
#include <sys/time.h>
#include <arm_neon.h>

inline float horizontal_sum_f32(float32x4_t v) {
    float32x2_t sum2 = vadd_f32(vget_low_f32(v), vget_high_f32(v));
    float32x2_t sum1 = vpadd_f32(sum2, sum2);
    return vget_lane_f32(sum1, 0);
}

// 串行版本
float __attribute__((noinline)) ip_serial(const float* x, const float* y, int d) {
    float sum = 0;
    for (int i = 0; i < d; i++) sum += x[i] * y[i];
    return 1.0f - sum;
}

// SIMD 版本
float __attribute__((noinline)) ip_simd(const float* x, const float* y, int d) {
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

int main() {
    const int d = 96;
    const int N = 1000000; // 100万次调用
    float a[96], b[96];
    for (int i = 0; i < 96; i++) { a[i] = 0.01f * i; b[i] = 0.02f * i; }

    volatile float result;
    struct timeval t1, t2;

    // 测试串行
    gettimeofday(&t1, NULL);
    for (int i = 0; i < N; i++) result = ip_serial(a, b, d);
    gettimeofday(&t2, NULL);
    long serial_us = (t2.tv_sec - t1.tv_sec) * 1000000L + (t2.tv_usec - t1.tv_usec);

    // 测试 SIMD
    gettimeofday(&t1, NULL);
    for (int i = 0; i < N; i++) result = ip_simd(a, b, d);
    gettimeofday(&t2, NULL);
    long simd_us = (t2.tv_sec - t1.tv_sec) * 1000000L + (t2.tv_usec - t1.tv_usec);

    printf("Serial: %ld us for %d calls (%.2f ns/call)\n", serial_us, N, serial_us * 1000.0 / N);
    printf("SIMD:   %ld us for %d calls (%.2f ns/call)\n", simd_us, N, simd_us * 1000.0 / N);
    printf("Speedup: %.2fx\n", (double)serial_us / simd_us);
    return 0;
}
