#pragma once

#include <algorithm>
#include <arm_neon.h>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <numeric>
#include <queue>
#include <vector>

namespace ann_fs {

constexpr int kFastScanNeonBlockSize = 16;

inline float fs_horizontal_sum128(float32x4_t v) {
    const float32x2_t sum2 = vadd_f32(vget_low_f32(v), vget_high_f32(v));
    const float32x2_t sum1 = vpadd_f32(sum2, sum2);
    return vget_lane_f32(sum1, 0);
}

inline float fs_ip_distance(const float* a, const float* b, size_t d) {
    float32x4_t sum0 = vdupq_n_f32(0.0f);
    float32x4_t sum1 = vdupq_n_f32(0.0f);
    float32x4_t sum2 = vdupq_n_f32(0.0f);
    float32x4_t sum3 = vdupq_n_f32(0.0f);

    size_t i = 0;
    for (; i + 16 <= d; i += 16) {
        sum0 = vmlaq_f32(sum0, vld1q_f32(a + i),      vld1q_f32(b + i));
        sum1 = vmlaq_f32(sum1, vld1q_f32(a + i + 4),  vld1q_f32(b + i + 4));
        sum2 = vmlaq_f32(sum2, vld1q_f32(a + i + 8),  vld1q_f32(b + i + 8));
        sum3 = vmlaq_f32(sum3, vld1q_f32(a + i + 12), vld1q_f32(b + i + 12));
    }
    for (; i + 4 <= d; i += 4) {
        sum0 = vmlaq_f32(sum0, vld1q_f32(a + i), vld1q_f32(b + i));
    }

    const float32x4_t sum = vaddq_f32(vaddq_f32(sum0, sum1), vaddq_f32(sum2, sum3));
    float ip = fs_horizontal_sum128(sum);
    for (; i < d; ++i) {
        ip += a[i] * b[i];
    }
    return 1.0f - ip;
}

struct FastScanIndex {
    int M = 16;
    int Ks = 16;
    int dsub = 6;
    int N = 0;
    int d = 96;
    int nblk = 0;
    std::vector<std::vector<float>> centroids;
    std::vector<uint8_t> codes_packed;
};

static inline void train_fastscan(FastScanIndex& idx, const float* base, int N, int d) {
    idx.N = N;
    idx.d = d;
    idx.nblk = (N + kFastScanNeonBlockSize - 1) / kFastScanNeonBlockSize;
    idx.centroids.assign(idx.M, std::vector<float>(static_cast<size_t>(idx.Ks) * idx.dsub, 0.0f));

    const int niter = 12;
    std::vector<int> assign(static_cast<size_t>(N), 0);

    for (int m = 0; m < idx.M; ++m) {
        for (int k = 0; k < idx.Ks; ++k) {
            std::memcpy(&idx.centroids[m][static_cast<size_t>(k) * idx.dsub],
                        base + static_cast<size_t>(k) * d + static_cast<size_t>(m) * idx.dsub,
                        static_cast<size_t>(idx.dsub) * sizeof(float));
        }

        for (int it = 0; it < niter; ++it) {
            for (int i = 0; i < N; ++i) {
                const float* x = base + static_cast<size_t>(i) * d + static_cast<size_t>(m) * idx.dsub;
                float best = 1e30f;
                int best_k = 0;
                for (int k = 0; k < idx.Ks; ++k) {
                    const float* c = &idx.centroids[m][static_cast<size_t>(k) * idx.dsub];
                    float dist = 0.0f;
                    for (int j = 0; j < idx.dsub; ++j) {
                        const float diff = x[j] - c[j];
                        dist += diff * diff;
                    }
                    if (dist < best) {
                        best = dist;
                        best_k = k;
                    }
                }
                assign[static_cast<size_t>(i)] = best_k;
            }

            std::vector<float> sum(static_cast<size_t>(idx.Ks) * idx.dsub, 0.0f);
            std::vector<int> count(static_cast<size_t>(idx.Ks), 0);
            for (int i = 0; i < N; ++i) {
                const float* x = base + static_cast<size_t>(i) * d + static_cast<size_t>(m) * idx.dsub;
                const int cls = assign[static_cast<size_t>(i)];
                ++count[static_cast<size_t>(cls)];
                for (int j = 0; j < idx.dsub; ++j) {
                    sum[static_cast<size_t>(cls) * idx.dsub + j] += x[j];
                }
            }

            for (int k = 0; k < idx.Ks; ++k) {
                if (count[static_cast<size_t>(k)] == 0) {
                    continue;
                }
                const float inv = 1.0f / static_cast<float>(count[static_cast<size_t>(k)]);
                for (int j = 0; j < idx.dsub; ++j) {
                    idx.centroids[m][static_cast<size_t>(k) * idx.dsub + j] =
                        sum[static_cast<size_t>(k) * idx.dsub + j] * inv;
                }
            }
        }
    }
}

static inline void encode_fastscan(FastScanIndex& idx, const float* base) {
    const int N = idx.N;
    const int d = idx.d;
    const int nblk = idx.nblk;

    std::vector<uint8_t> raw(static_cast<size_t>(idx.M) * N, 0);
    for (int m = 0; m < idx.M; ++m) {
        for (int i = 0; i < N; ++i) {
            const float* x = base + static_cast<size_t>(i) * d + static_cast<size_t>(m) * idx.dsub;
            float best = 1e30f;
            int best_k = 0;
            for (int k = 0; k < idx.Ks; ++k) {
                const float* c = &idx.centroids[m][static_cast<size_t>(k) * idx.dsub];
                float dist = 0.0f;
                for (int j = 0; j < idx.dsub; ++j) {
                    const float diff = x[j] - c[j];
                    dist += diff * diff;
                }
                if (dist < best) {
                    best = dist;
                    best_k = k;
                }
            }
            raw[static_cast<size_t>(m) * N + i] = static_cast<uint8_t>(best_k);
        }
    }

    idx.codes_packed.assign(static_cast<size_t>(idx.M / 2) * nblk * kFastScanNeonBlockSize, 0);
    for (int mm = 0; mm < idx.M / 2; ++mm) {
        const int m0 = 2 * mm;
        const int m1 = m0 + 1;
        for (int blk = 0; blk < nblk; ++blk) {
            for (int lane = 0; lane < kFastScanNeonBlockSize; ++lane) {
                const int i = blk * kFastScanNeonBlockSize + lane;
                const uint8_t lo = (i < N) ? (raw[static_cast<size_t>(m0) * N + i] & 0x0F) : 0;
                const uint8_t hi = (i < N) ? (raw[static_cast<size_t>(m1) * N + i] & 0x0F) : 0;
                idx.codes_packed[(static_cast<size_t>(mm) * nblk + blk) * kFastScanNeonBlockSize + lane] =
                    static_cast<uint8_t>(lo | static_cast<uint8_t>(hi << 4));
            }
        }
    }
}

static inline void build_lut_u8(const FastScanIndex& idx, const float* query,
                                std::vector<uint8_t>& lut_u8) {
    lut_u8.assign(static_cast<size_t>(idx.M) * idx.Ks, 0);
    for (int m = 0; m < idx.M; ++m) {
        const float* q = query + static_cast<size_t>(m) * idx.dsub;
        float lo = 1e30f;
        float hi = -1e30f;
        float lut_f[16];

        for (int k = 0; k < idx.Ks; ++k) {
            const float* c = &idx.centroids[m][static_cast<size_t>(k) * idx.dsub];
            float dist = 0.0f;
            for (int j = 0; j < idx.dsub; ++j) {
                const float diff = q[j] - c[j];
                dist += diff * diff;
            }
            lut_f[k] = dist;
            lo = std::min(lo, dist);
            hi = std::max(hi, dist);
        }

        const float scale = (hi > lo) ? (15.0f / (hi - lo)) : 1.0f;
        for (int k = 0; k < idx.Ks; ++k) {
            int qv = static_cast<int>(std::lround((lut_f[k] - lo) * scale));
            qv = std::max(0, std::min(15, qv));
            lut_u8[static_cast<size_t>(m) * idx.Ks + k] = static_cast<uint8_t>(qv);
        }
    }
}

static inline void fastscan_batch16(const uint8_t* codes_packed,
                                    const uint8_t* lut_u8,
                                    int M,
                                    int nblk,
                                    int blk,
                                    uint8_t* out_dis) {
    uint8x16_t acc = vdupq_n_u8(0);
    const uint8x16_t mask_lo = vdupq_n_u8(0x0F);

    for (int mm = 0; mm < M / 2; ++mm) {
        const uint8x16_t lut0 = vld1q_u8(lut_u8 + static_cast<size_t>(2 * mm) * 16);
        const uint8x16_t lut1 = vld1q_u8(lut_u8 + static_cast<size_t>(2 * mm + 1) * 16);
        const uint8x16_t packed = vld1q_u8(
            codes_packed + (static_cast<size_t>(mm) * nblk + blk) * kFastScanNeonBlockSize);

        const uint8x16_t c0 = vandq_u8(packed, mask_lo);
        const uint8x16_t c1 = vandq_u8(vshrq_n_u8(packed, 4), mask_lo);
        const uint8x16_t d0 = vqtbl1q_u8(lut0, c0);
        const uint8x16_t d1 = vqtbl1q_u8(lut1, c1);

        acc = vqaddq_u8(acc, d0);
        acc = vqaddq_u8(acc, d1);
    }

    vst1q_u8(out_dis, acc);
}

static inline std::priority_queue<std::pair<float, uint32_t>>
fastscan_search(const FastScanIndex& idx, const float* base,
                const float* query, size_t k, int p) {
    std::vector<uint8_t> lut_u8;
    build_lut_u8(idx, query, lut_u8);

    std::vector<uint8_t> all_dis(static_cast<size_t>(idx.nblk) * kFastScanNeonBlockSize, 0);
    for (int blk = 0; blk < idx.nblk; ++blk) {
        fastscan_batch16(idx.codes_packed.data(), lut_u8.data(), idx.M, idx.nblk,
                         blk, all_dis.data() + static_cast<size_t>(blk) * kFastScanNeonBlockSize);
    }

    size_t candidate_count = static_cast<size_t>(std::max<int>(p, static_cast<int>(k)));
    candidate_count = std::min(candidate_count, static_cast<size_t>(idx.N));

    std::vector<uint32_t> cand(static_cast<size_t>(idx.N));
    std::iota(cand.begin(), cand.end(), 0U);
    if (candidate_count < cand.size()) {
        std::nth_element(
            cand.begin(), cand.begin() + static_cast<std::ptrdiff_t>(candidate_count), cand.end(),
            [&](uint32_t a, uint32_t b) { return all_dis[a] < all_dis[b]; });
        cand.resize(candidate_count);
    }

    std::priority_queue<std::pair<float, uint32_t>> heap;
    for (uint32_t idx_i : cand) {
        const float dis = fs_ip_distance(base + static_cast<size_t>(idx_i) * idx.d, query, idx.d);
        if (heap.size() < k) {
            heap.emplace(dis, idx_i);
        } else if (dis < heap.top().first) {
            heap.pop();
            heap.emplace(dis, idx_i);
        }
    }
    return heap;
}

}  // namespace ann_fs
