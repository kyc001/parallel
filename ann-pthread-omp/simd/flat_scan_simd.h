#pragma once
#include <queue>
#include "neon_common.h"

// (horizontal_sum_f32 / ip_distance_simd / l2_distance_simd 在 neon_common.h 中统一定义)

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
