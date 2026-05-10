#pragma once
#include <queue>
#include <vector>
#include <algorithm>
#include <cmath>
#include <cfloat>
#include <cstdint>
#include "simd/neon_common.h"

// (horizontal_sum_f32 / ip_distance_simd 在 neon_common.h 中统一定义)

// ============================================================
// SQ 索引结构
// ============================================================
struct SQIndex {
    size_t n, d;
    std::vector<float> vmin, vmax, scale;
    std::vector<uint8_t> codes; // n * d

    // 构建索引：统计 min/max，量化 base 向量为 uint8
    void build(const float* base, size_t n_, size_t d_) {
        n = n_; d = d_;
        vmin.assign(d, FLT_MAX);
        vmax.assign(d, -FLT_MAX);
        scale.resize(d);

        // 统计每维 min/max
        for (size_t i = 0; i < n; i++) {
            for (size_t j = 0; j < d; j++) {
                float val = base[i * d + j];
                if (val < vmin[j]) vmin[j] = val;
                if (val > vmax[j]) vmax[j] = val;
            }
        }

        // 计算量化缩放系数
        for (size_t j = 0; j < d; j++) {
            float range = vmax[j] - vmin[j];
            scale[j] = (range > 1e-10f) ? 255.0f / range : 0.0f;
        }

        // 编码
        codes.resize(n * d);
        for (size_t i = 0; i < n; i++) {
            for (size_t j = 0; j < d; j++) {
                float normalized = (base[i * d + j] - vmin[j]) * scale[j];
                int val = (int)roundf(normalized);
                codes[i * d + j] = (uint8_t)(val < 0 ? 0 : (val > 255 ? 255 : val));
            }
        }
    }

    // 编码单条查询向量
    void encode_query(const float* query, uint8_t* code) const {
        for (size_t j = 0; j < d; j++) {
            float normalized = (query[j] - vmin[j]) * scale[j];
            int val = (int)roundf(normalized);
            code[j] = (uint8_t)(val < 0 ? 0 : (val > 255 ? 255 : val));
        }
    }
};

// ============================================================
// uint8 L2 平方距离 SIMD（粗排用）
// 每次处理 16 个 uint8，d=96 恰好循环 6 次
// ============================================================
inline uint32_t sq_l2_distance_simd(const uint8_t* x, const uint8_t* y, int d) {
    uint32x4_t sum = vdupq_n_u32(0);
    for (int i = 0; i < d; i += 16) {
        uint8x16_t vx = vld1q_u8(x + i);
        uint8x16_t vy = vld1q_u8(y + i);
        uint8x16_t diff = vabdq_u8(vx, vy);  // |x - y| 逐元素

        // 平方累加：先拆成 low/high 各 8 个 uint8
        uint16x8_t sq_lo = vmull_u8(vget_low_u8(diff), vget_low_u8(diff));
        uint16x8_t sq_hi = vmull_u8(vget_high_u8(diff), vget_high_u8(diff));

        // uint16 -> uint32 累加
        sum = vpadalq_u16(sum, sq_lo);
        sum = vpadalq_u16(sum, sq_hi);
    }
    return vaddvq_u32(sum);
}

// ============================================================
// SQ 两阶段检索
//   粗排：uint8 L2 距离，取 Top-p 候选
//   精排：float32 IP 距离 SIMD，取 Top-k
// ============================================================
std::priority_queue<std::pair<float, uint32_t>>
sq_search(float* base, float* query, size_t base_number, size_t vecdim, size_t k,
          const SQIndex& sq_index, size_t rerank_p) {

    // 编码查询向量
    std::vector<uint8_t> query_code(vecdim);
    sq_index.encode_query(query, query_code.data());
    const uint8_t* qc = query_code.data();

    // ---- 粗排阶段 ----
    // max-heap，保留 p 个最小 uint8 距离的候选
    std::priority_queue<std::pair<uint32_t, uint32_t>> coarse_q;

    for (size_t i = 0; i < base_number; ++i) {
        uint32_t dis = sq_l2_distance_simd(
            sq_index.codes.data() + i * vecdim, qc, vecdim);

        if (coarse_q.size() < rerank_p) {
            coarse_q.push({dis, (uint32_t)i});
        } else if (dis < coarse_q.top().first) {
            coarse_q.push({dis, (uint32_t)i});
            coarse_q.pop();
        }
    }

    // ---- 精排阶段 ----
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