#pragma once

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <immintrin.h>
#include <numeric>
#include <queue>
#include <vector>

#include "pq_blocked_avx2.h"

namespace ann_fs {

inline float fs_horizontal_sum256(__m256 v) {
    const __m128 hi = _mm256_extractf128_ps(v, 1);
    const __m128 lo = _mm256_castps256_ps128(v);
    __m128 s = _mm_add_ps(hi, lo);
    s = _mm_hadd_ps(s, s);
    s = _mm_hadd_ps(s, s);
    return _mm_cvtss_f32(s);
}

inline float fs_ip_distance(const float* a, const float* b, size_t d) {
    __m256 s0 = _mm256_setzero_ps();
    __m256 s1 = _mm256_setzero_ps();
    __m256 s2 = _mm256_setzero_ps();
    __m256 s3 = _mm256_setzero_ps();
    size_t i = 0;

    for (; i + 32 <= d; i += 32) {
        s0 = _mm256_fmadd_ps(_mm256_loadu_ps(a + i),      _mm256_loadu_ps(b + i),      s0);
        s1 = _mm256_fmadd_ps(_mm256_loadu_ps(a + i + 8),  _mm256_loadu_ps(b + i + 8),  s1);
        s2 = _mm256_fmadd_ps(_mm256_loadu_ps(a + i + 16), _mm256_loadu_ps(b + i + 16), s2);
        s3 = _mm256_fmadd_ps(_mm256_loadu_ps(a + i + 24), _mm256_loadu_ps(b + i + 24), s3);
    }

    const __m256 s = _mm256_add_ps(_mm256_add_ps(s0, s1), _mm256_add_ps(s2, s3));
    float ip = fs_horizontal_sum256(s);
    for (; i < d; ++i) {
        ip += a[i] * b[i];
    }
    return 1.0f - ip;
}

struct FastScanIndex {
    int M = 16;
    int Ks = 16;
    int dsub = 6;
    int padded_Ks = 0;
    int N = 0;
    int d = 96;
    std::vector<std::vector<float>> centroids;
    std::vector<std::vector<float>> centroids_soa;
    std::vector<uint8_t> codes_packed;
    int nblk = 0;
};

static inline void train_fastscan(FastScanIndex& idx, const float* base, int N, int d) {
    idx.N = N;
    idx.d = d;
    idx.nblk = (N + 31) / 32;
    idx.padded_Ks = ann_pq_blocked_avx2::padded_ksub(idx.Ks);
    idx.centroids.assign(idx.M, std::vector<float>(static_cast<size_t>(idx.Ks) * idx.dsub, 0.0f));
    idx.centroids_soa.assign(
        idx.M, std::vector<float>(static_cast<size_t>(idx.padded_Ks) * idx.dsub, 0.0f));

    const int niter = 12;
    std::vector<int> assign(static_cast<size_t>(N), 0);

    for (int m = 0; m < idx.M; ++m) {
        for (int k = 0; k < idx.Ks; ++k) {
            std::memcpy(&idx.centroids[m][static_cast<size_t>(k) * idx.dsub],
                        base + static_cast<size_t>(k) * d + static_cast<size_t>(m) * idx.dsub,
                        static_cast<size_t>(idx.dsub) * sizeof(float));
        }
        ann_pq_blocked_avx2::build_soa_from_aos(
            idx.centroids[m].data(), idx.Ks, idx.dsub, idx.padded_Ks,
            idx.centroids_soa[m].data());

        for (int it = 0; it < niter; ++it) {
            for (int i = 0; i < N; ++i) {
                const float* x = base + static_cast<size_t>(i) * d + static_cast<size_t>(m) * idx.dsub;
                assign[static_cast<size_t>(i)] = ann_pq_blocked_avx2::argmin_l2_blocked(
                    x, idx.centroids_soa[m].data(), idx.Ks, idx.dsub, idx.padded_Ks, 16);
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
            ann_pq_blocked_avx2::build_soa_from_aos(
                idx.centroids[m].data(), idx.Ks, idx.dsub, idx.padded_Ks,
                idx.centroids_soa[m].data());
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
            raw[static_cast<size_t>(m) * N + i] = static_cast<uint8_t>(
                ann_pq_blocked_avx2::argmin_l2_blocked(
                    x, idx.centroids_soa[m].data(), idx.Ks, idx.dsub, idx.padded_Ks, 16));
        }
    }

    idx.codes_packed.assign(static_cast<size_t>(idx.M / 2) * nblk * 32, 0);
    for (int mm = 0; mm < idx.M / 2; ++mm) {
        const int m0 = 2 * mm;
        const int m1 = m0 + 1;
        for (int blk = 0; blk < nblk; ++blk) {
            for (int lane = 0; lane < 32; ++lane) {
                const int i = blk * 32 + lane;
                const uint8_t lo = (i < N) ? (raw[static_cast<size_t>(m0) * N + i] & 0x0F) : 0;
                const uint8_t hi = (i < N) ? (raw[static_cast<size_t>(m1) * N + i] & 0x0F) : 0;
                idx.codes_packed[(static_cast<size_t>(mm) * nblk + blk) * 32 + lane] =
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
            if (dist < lo) {
                lo = dist;
            }
            if (dist > hi) {
                hi = dist;
            }
        }
        const float scale = (hi > lo) ? (15.0f / (hi - lo)) : 1.0f;
        for (int k = 0; k < idx.Ks; ++k) {
            int qv = static_cast<int>(std::lround((lut_f[k] - lo) * scale));
            qv = std::max(0, std::min(15, qv));
            lut_u8[static_cast<size_t>(m) * idx.Ks + k] = static_cast<uint8_t>(qv);
        }
    }
}

static inline void fastscan_batch32(const uint8_t* codes_packed,
                                    const uint8_t* lut_u8,
                                    int M,
                                    int nblk,
                                    int blk,
                                    uint8_t* out_dis) {
    __m256i acc = _mm256_setzero_si256();
    const __m256i mask_lo = _mm256_set1_epi8(0x0F);

    for (int mm = 0; mm < M / 2; ++mm) {
        const __m128i lut0 = _mm_loadu_si128(
            reinterpret_cast<const __m128i*>(lut_u8 + static_cast<size_t>(2 * mm) * 16));
        const __m128i lut1 = _mm_loadu_si128(
            reinterpret_cast<const __m128i*>(lut_u8 + static_cast<size_t>(2 * mm + 1) * 16));
        const __m256i lv0 = _mm256_broadcastsi128_si256(lut0);
        const __m256i lv1 = _mm256_broadcastsi128_si256(lut1);

        const __m256i packed = _mm256_loadu_si256(
            reinterpret_cast<const __m256i*>(
                codes_packed + (static_cast<size_t>(mm) * nblk + blk) * 32));
        const __m256i c0 = _mm256_and_si256(packed, mask_lo);
        const __m256i c1 = _mm256_and_si256(_mm256_srli_epi16(packed, 4), mask_lo);
        const __m256i d0 = _mm256_shuffle_epi8(lv0, c0);
        const __m256i d1 = _mm256_shuffle_epi8(lv1, c1);

        acc = _mm256_adds_epu8(acc, d0);
        acc = _mm256_adds_epu8(acc, d1);
    }

    _mm256_storeu_si256(reinterpret_cast<__m256i*>(out_dis), acc);
}

static inline std::priority_queue<std::pair<float, uint32_t>>
fastscan_search(const FastScanIndex& idx, const float* base,
                const float* query, size_t k, int p) {
    std::vector<uint8_t> lut_u8;
    build_lut_u8(idx, query, lut_u8);

    std::vector<uint8_t> all_dis(static_cast<size_t>(idx.nblk) * 32, 0);
    for (int blk = 0; blk < idx.nblk; ++blk) {
        fastscan_batch32(idx.codes_packed.data(), lut_u8.data(), idx.M, idx.nblk,
                         blk, all_dis.data() + static_cast<size_t>(blk) * 32);
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
