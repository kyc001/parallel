#pragma once

#include <algorithm>
#include <cfloat>
#include <cstddef>
#include <immintrin.h>

namespace ann_pq_blocked_avx2 {

constexpr int kLaneWidth = 8;

inline int padded_ksub(int ksub) {
    return ((ksub + kLaneWidth - 1) / kLaneWidth) * kLaneWidth;
}

inline void build_soa_from_aos(const float* aos, int ksub, int dsub,
                               int padded, float* soa) {
    std::fill(soa, soa + static_cast<size_t>(dsub) * padded, 0.0f);
    for (int j = 0; j < dsub; ++j) {
        float* row = soa + static_cast<size_t>(j) * padded;
        for (int c = 0; c < ksub; ++c) {
            row[c] = aos[static_cast<size_t>(c) * dsub + j];
        }
    }
}

inline int argmin_l2_blocked(const float* x, const float* soa, int ksub, int dsub,
                             int padded, int tile_size) {
    if (tile_size < kLaneWidth) {
        tile_size = kLaneWidth;
    }

    alignas(32) float tmp[kLaneWidth];
    float best_dist = FLT_MAX;
    int best_centroid = 0;

    for (int block = 0; block < ksub; block += tile_size) {
        const int block_end = std::min(block + tile_size, ksub);
        for (int c = block; c < block_end; c += kLaneWidth) {
            __m256 acc = _mm256_setzero_ps();
            for (int j = 0; j < dsub; ++j) {
                const __m256 xv = _mm256_set1_ps(x[j]);
                const __m256 cv = _mm256_loadu_ps(
                    soa + static_cast<size_t>(j) * padded + c);
                const __m256 diff = _mm256_sub_ps(cv, xv);
                acc = _mm256_fmadd_ps(diff, diff, acc);
            }
            _mm256_storeu_ps(tmp, acc);

            const int lanes = std::min(kLaneWidth, block_end - c);
            for (int lane = 0; lane < lanes; ++lane) {
                if (tmp[lane] < best_dist) {
                    best_dist = tmp[lane];
                    best_centroid = c + lane;
                }
            }
        }
    }

    return best_centroid;
}

inline void build_dot_lut_blocked(const float* x, const float* soa, int ksub,
                                  int dsub, int padded, float* lut,
                                  int tile_size) {
    if (tile_size < kLaneWidth) {
        tile_size = kLaneWidth;
    }

    alignas(32) float tmp[kLaneWidth];
    for (int block = 0; block < ksub; block += tile_size) {
        const int block_end = std::min(block + tile_size, ksub);
        for (int c = block; c < block_end; c += kLaneWidth) {
            __m256 acc = _mm256_setzero_ps();
            for (int j = 0; j < dsub; ++j) {
                const __m256 xv = _mm256_set1_ps(x[j]);
                const __m256 cv = _mm256_loadu_ps(
                    soa + static_cast<size_t>(j) * padded + c);
                acc = _mm256_fmadd_ps(xv, cv, acc);
            }
            _mm256_storeu_ps(tmp, acc);

            const int lanes = std::min(kLaneWidth, block_end - c);
            for (int lane = 0; lane < lanes; ++lane) {
                lut[c + lane] = tmp[lane];
            }
        }
    }
}

inline void build_l2_lut_blocked(const float* x, const float* soa, int ksub,
                                 int dsub, int padded, float* lut,
                                 int tile_size) {
    if (tile_size < kLaneWidth) {
        tile_size = kLaneWidth;
    }

    alignas(32) float tmp[kLaneWidth];
    for (int block = 0; block < ksub; block += tile_size) {
        const int block_end = std::min(block + tile_size, ksub);
        for (int c = block; c < block_end; c += kLaneWidth) {
            __m256 acc = _mm256_setzero_ps();
            for (int j = 0; j < dsub; ++j) {
                const __m256 xv = _mm256_set1_ps(x[j]);
                const __m256 cv = _mm256_loadu_ps(
                    soa + static_cast<size_t>(j) * padded + c);
                const __m256 diff = _mm256_sub_ps(cv, xv);
                acc = _mm256_fmadd_ps(diff, diff, acc);
            }
            _mm256_storeu_ps(tmp, acc);

            const int lanes = std::min(kLaneWidth, block_end - c);
            for (int lane = 0; lane < lanes; ++lane) {
                lut[c + lane] = tmp[lane];
            }
        }
    }
}

}  // namespace ann_pq_blocked_avx2
