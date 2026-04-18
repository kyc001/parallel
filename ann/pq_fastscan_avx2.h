#pragma once
// PQ FastScan (André et al. VLDB 2015): 4-bit PQ + _mm256_shuffle_epi8
// Ks=16, M=16, dsub=6 (96/16). SoA codes, batch 32 vectors, uint8 saturated add.
#include <immintrin.h>
#include <vector>
#include <queue>
#include <cstdint>
#include <cstring>
#include <algorithm>
#include <cmath>

namespace ann_fs {

// 本文件自带的精排 IP 距离（避免依赖其他头文件，保证独立可编译）
static inline float fs_horizontal_sum256(__m256 v) {
    __m128 hi = _mm256_extractf128_ps(v, 1);
    __m128 lo = _mm256_castps256_ps128(v);
    __m128 s = _mm_add_ps(hi, lo);
    s = _mm_hadd_ps(s, s);
    s = _mm_hadd_ps(s, s);
    return _mm_cvtss_f32(s);
}
static inline float fs_ip_distance(const float* a, const float* b, size_t d) {
    __m256 s0 = _mm256_setzero_ps(), s1 = _mm256_setzero_ps();
    __m256 s2 = _mm256_setzero_ps(), s3 = _mm256_setzero_ps();
    size_t i = 0;
    for (; i + 32 <= d; i += 32) {
        s0 = _mm256_fmadd_ps(_mm256_loadu_ps(a+i),    _mm256_loadu_ps(b+i),    s0);
        s1 = _mm256_fmadd_ps(_mm256_loadu_ps(a+i+8),  _mm256_loadu_ps(b+i+8),  s1);
        s2 = _mm256_fmadd_ps(_mm256_loadu_ps(a+i+16), _mm256_loadu_ps(b+i+16), s2);
        s3 = _mm256_fmadd_ps(_mm256_loadu_ps(a+i+24), _mm256_loadu_ps(b+i+24), s3);
    }
    __m256 s = _mm256_add_ps(_mm256_add_ps(s0, s1), _mm256_add_ps(s2, s3));
    float ip = fs_horizontal_sum256(s);
    for (; i < d; ++i) ip += a[i] * b[i];
    return 1.0f - ip;
}

struct FastScanIndex {
    int M = 16, Ks = 16, dsub = 6;
    int N = 0, d = 96;
    std::vector<std::vector<float>> centroids;  // M x (Ks * dsub)
    std::vector<uint8_t> codes_packed;          // (M/2) * nblk * 32 bytes
    int nblk = 0;
};

// ---------- 训练: per-segment k-means, Ks=16 ----------
static void train_fastscan(FastScanIndex& idx, const float* base, int N, int d) {
    idx.N = N; idx.d = d;
    idx.nblk = (N + 31) / 32;
    idx.centroids.assign(idx.M, std::vector<float>(idx.Ks * idx.dsub, 0.0f));
    const int niter = 12;
    std::vector<int> assign(N);
    for (int m = 0; m < idx.M; ++m) {
        for (int k = 0; k < idx.Ks; ++k)
            std::memcpy(&idx.centroids[m][k * idx.dsub],
                        base + (size_t)k * d + m * idx.dsub,
                        idx.dsub * sizeof(float));
        for (int it = 0; it < niter; ++it) {
            for (int i = 0; i < N; ++i) {
                const float* x = base + (size_t)i * d + m * idx.dsub;
                float best = 1e30f; int bk = 0;
                for (int k = 0; k < idx.Ks; ++k) {
                    const float* c = &idx.centroids[m][k * idx.dsub];
                    float s = 0;
                    for (int j = 0; j < idx.dsub; ++j) { float t = x[j]-c[j]; s += t*t; }
                    if (s < best) { best = s; bk = k; }
                }
                assign[i] = bk;
            }
            std::vector<float> sum(idx.Ks * idx.dsub, 0.0f);
            std::vector<int> cnt(idx.Ks, 0);
            for (int i = 0; i < N; ++i) {
                const float* x = base + (size_t)i * d + m * idx.dsub;
                int k = assign[i]; cnt[k]++;
                for (int j = 0; j < idx.dsub; ++j) sum[k*idx.dsub+j] += x[j];
            }
            for (int k = 0; k < idx.Ks; ++k) if (cnt[k])
                for (int j = 0; j < idx.dsub; ++j)
                    idx.centroids[m][k*idx.dsub+j] = sum[k*idx.dsub+j] / cnt[k];
        }
    }
}

// ---------- 编码 + SoA 打包 (2 codes/byte) ----------
static void encode_fastscan(FastScanIndex& idx, const float* base) {
    int N = idx.N, d = idx.d, nblk = idx.nblk;
    std::vector<uint8_t> raw((size_t)idx.M * N, 0);
    for (int m = 0; m < idx.M; ++m)
        for (int i = 0; i < N; ++i) {
            const float* x = base + (size_t)i * d + m * idx.dsub;
            float best = 1e30f; int bk = 0;
            for (int k = 0; k < idx.Ks; ++k) {
                const float* c = &idx.centroids[m][k * idx.dsub];
                float s = 0;
                for (int j = 0; j < idx.dsub; ++j) { float t = x[j]-c[j]; s += t*t; }
                if (s < best) { best = s; bk = k; }
            }
            raw[(size_t)m * N + i] = (uint8_t)bk;
        }
    idx.codes_packed.assign((size_t)(idx.M / 2) * nblk * 32, 0);
    for (int mm = 0; mm < idx.M / 2; ++mm) {
        int m0 = 2*mm, m1 = 2*mm + 1;
        for (int blk = 0; blk < nblk; ++blk)
            for (int lane = 0; lane < 32; ++lane) {
                int i = blk * 32 + lane;
                uint8_t lo = (i < N) ? (raw[(size_t)m0*N+i] & 0x0F) : 0;
                uint8_t hi = (i < N) ? (raw[(size_t)m1*N+i] & 0x0F) : 0;
                idx.codes_packed[((size_t)mm*nblk + blk)*32 + lane] = lo | (hi << 4);
            }
    }
}

// ---------- LUT 量化 (per-segment [0,15]) ----------
static void build_lut_u8(const FastScanIndex& idx, const float* query,
                         std::vector<uint8_t>& lut_u8) {
    lut_u8.assign((size_t)idx.M * idx.Ks, 0);
    for (int m = 0; m < idx.M; ++m) {
        const float* q = query + m * idx.dsub;
        float lo = 1e30f, hi = -1e30f;
        float lut_f[16];
        for (int k = 0; k < idx.Ks; ++k) {
            const float* c = &idx.centroids[m][k * idx.dsub];
            float s = 0;
            for (int j = 0; j < idx.dsub; ++j) { float t = q[j]-c[j]; s += t*t; }
            lut_f[k] = s;
            if (s < lo) lo = s; if (s > hi) hi = s;
        }
        float scale = (hi > lo) ? (15.0f / (hi - lo)) : 1.0f;
        for (int k = 0; k < idx.Ks; ++k) {
            int v = (int)std::round((lut_f[k] - lo) * scale);
            v = std::max(0, std::min(15, v));
            lut_u8[m * idx.Ks + k] = (uint8_t)v;
        }
    }
}

// ---------- 批 32 FastScan 核心 ----------
static inline void fastscan_batch32(
    const uint8_t* codes_packed, const uint8_t* lut_u8,
    int M, int nblk, int blk, uint8_t* out_dis)
{
    __m256i acc = _mm256_setzero_si256();
    __m256i mask_lo = _mm256_set1_epi8(0x0F);
    int MM = M / 2;
    for (int mm = 0; mm < MM; ++mm) {
        __m128i lut0 = _mm_loadu_si128((const __m128i*)(lut_u8 + (2*mm)*16));
        __m128i lut1 = _mm_loadu_si128((const __m128i*)(lut_u8 + (2*mm+1)*16));
        __m256i lv0 = _mm256_broadcastsi128_si256(lut0);
        __m256i lv1 = _mm256_broadcastsi128_si256(lut1);

        __m256i packed = _mm256_loadu_si256(
            (const __m256i*)(codes_packed + ((size_t)mm*nblk + blk)*32));
        __m256i c0 = _mm256_and_si256(packed, mask_lo);
        __m256i c1 = _mm256_and_si256(_mm256_srli_epi16(packed, 4), mask_lo);

        __m256i d0 = _mm256_shuffle_epi8(lv0, c0);
        __m256i d1 = _mm256_shuffle_epi8(lv1, c1);

        acc = _mm256_adds_epu8(acc, d0);
        acc = _mm256_adds_epu8(acc, d1);
    }
    _mm256_storeu_si256((__m256i*)out_dis, acc);
}

// ---------- 主搜索 ----------
static std::priority_queue<std::pair<float, uint32_t>>
fastscan_search(const FastScanIndex& idx, const float* base,
                const float* query, size_t k, int p)
{
    int N = idx.N, d = idx.d, M = idx.M, nblk = idx.nblk;
    std::vector<uint8_t> lut_u8;
    build_lut_u8(idx, query, lut_u8);

    std::vector<uint8_t> all_dis((size_t)nblk * 32);
    for (int blk = 0; blk < nblk; ++blk)
        fastscan_batch32(idx.codes_packed.data(), lut_u8.data(),
                         M, nblk, blk, all_dis.data() + (size_t)blk*32);

    if (p > N) p = N;
    std::vector<uint32_t> cand(N);
    for (int i = 0; i < N; ++i) cand[i] = i;
    std::nth_element(cand.begin(), cand.begin()+p, cand.end(),
        [&](uint32_t a, uint32_t b){ return all_dis[a] < all_dis[b]; });
    cand.resize(p);

    std::priority_queue<std::pair<float, uint32_t>> heap;
    for (uint32_t i : cand) {
        float dis = fs_ip_distance(base + (size_t)i*d, query, d);
        if (heap.size() < k) heap.emplace(dis, i);
        else if (dis < heap.top().first) { heap.pop(); heap.emplace(dis, i); }
    }
    return heap;
}

} // namespace ann_fs