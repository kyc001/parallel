// Microbenchmark: gather-based ADC vs shuffle-based FastScan ADC.
// Motivation: report section 3.5 argues that on x86 gather is slower than
// shuffle for PQ lookup. Previously this was asserted in prose only;
// this bench provides measured numbers.
//
// Setup: M=8 sub-codebooks, Ks=256 (standard PQ). We fabricate:
//   - a LUT of shape [M][256] float
//   - N=100000 encoded rows of shape [M] uint8
// and time three scan variants:
//   (a) scalar baseline: plain 8-way scalar lookup + add
//   (b) gather: _mm256_i32gather_ps, 8 centroids per instruction
//   (c) shuffle (FastScan-style): M=16 4-bit codes pre-packed, 16-entry
//       LUT per segment, _mm256_shuffle_epi8 + saturating adds (the LUT
//       quantization differs, but the *scan cost* is comparable).
//
// Output: CSV on stdout.

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <immintrin.h>
#include <iomanip>
#include <iostream>
#include <random>
#include <vector>

static constexpr int M = 8;
static constexpr int Ks = 256;

static float adc_scalar(const uint8_t* code, const float* lut) {
    float s = 0.0f;
    for (int m = 0; m < M; ++m) s += lut[m * Ks + code[m]];
    return s;
}

static float adc_gather(const uint8_t* code, const float* lut) {
    // Build an int32 gather index: m*Ks + code[m].
    alignas(32) int32_t idx[8];
    for (int m = 0; m < M; ++m) idx[m] = m * Ks + static_cast<int>(code[m]);
    __m256i vidx = _mm256_load_si256(reinterpret_cast<const __m256i*>(idx));
    __m256 v = _mm256_i32gather_ps(lut, vidx, 4);
    // Reduce 8 floats to scalar.
    __m128 lo = _mm256_castps256_ps128(v);
    __m128 hi = _mm256_extractf128_ps(v, 1);
    __m128 s = _mm_add_ps(lo, hi);
    s = _mm_hadd_ps(s, s);
    s = _mm_hadd_ps(s, s);
    return _mm_cvtss_f32(s);
}

// FastScan-style shuffle: M'=16, Ks'=16, codes packed 2-per-byte (nibbles).
// For fair scan-cost comparison we only time the inner lookup+accumulate.
static constexpr int Mp = 16;
static constexpr int Ksp = 16;

// Process B=32 encoded vectors per shuffle iteration (typical batch size).
static void adc_shuffle_batch(const uint8_t* packed, int n,
                              const uint8_t* lut_small, uint16_t* out_sums) {
    // packed: n rows, each row Mp/2=8 bytes.
    // For simplicity, scan one row at a time but use shuffle for the LUT.
    __m256i mask_lo = _mm256_set1_epi8(0x0f);
    for (int r = 0; r < n; ++r) {
        const uint8_t* row = packed + static_cast<size_t>(r) * (Mp / 2);
        __m256i acc_lo = _mm256_setzero_si256();
        __m256i acc_hi = _mm256_setzero_si256();
        for (int pair = 0; pair < Mp / 2; pair += 2) {
            // Load two sub-LUTs (16 bytes each) into ymm lanes.
            __m256i lut0 = _mm256_broadcastsi128_si256(
                _mm_loadu_si128(reinterpret_cast<const __m128i*>(
                    lut_small + pair * Ksp)));
            __m256i lut1 = _mm256_broadcastsi128_si256(
                _mm_loadu_si128(reinterpret_cast<const __m128i*>(
                    lut_small + (pair + 1) * Ksp)));
            // Pack the two code bytes for this pair into one byte.
            uint8_t packed_byte0 = row[pair];
            uint8_t packed_byte1 = row[pair + 1];
            __m256i c = _mm256_set1_epi16(
                static_cast<int16_t>(packed_byte0 | (packed_byte1 << 8)));
            __m256i c0 = _mm256_and_si256(c, mask_lo);
            __m256i c1 = _mm256_and_si256(_mm256_srli_epi16(c, 4), mask_lo);
            __m256i d0 = _mm256_shuffle_epi8(lut0, c0);
            __m256i d1 = _mm256_shuffle_epi8(lut1, c1);
            acc_lo = _mm256_adds_epu8(acc_lo, d0);
            acc_hi = _mm256_adds_epu8(acc_hi, d1);
        }
        // Reduce first byte of each lane (enough for the bench; in real
        // FastScan we would widen to epu16 and sum properly).
        uint8_t lanes[32];
        _mm256_storeu_si256(reinterpret_cast<__m256i*>(lanes),
                            _mm256_adds_epu8(acc_lo, acc_hi));
        uint16_t s = 0;
        for (int i = 0; i < 16; ++i) s += lanes[i];
        out_sums[r] = s;
    }
}

int main(int argc, char** argv) {
    const int N = (argc > 1) ? std::atoi(argv[1]) : 100000;
    const int repeat = (argc > 2) ? std::atoi(argv[2]) : 5;

    std::mt19937 rng(42);
    std::uniform_real_distribution<float> ud(-1.0f, 1.0f);
    std::uniform_int_distribution<int> ui(0, 255);

    std::vector<float> lut(static_cast<size_t>(M) * Ks);
    for (auto& v : lut) v = ud(rng);
    std::vector<uint8_t> codes(static_cast<size_t>(N) * M);
    for (auto& v : codes) v = static_cast<uint8_t>(ui(rng));

    // Small LUT + packed codes for shuffle variant.
    std::vector<uint8_t> lut_small(static_cast<size_t>(Mp) * Ksp);
    for (auto& v : lut_small) v = static_cast<uint8_t>(ui(rng) & 0x0f);
    std::vector<uint8_t> codes_packed(static_cast<size_t>(N) * (Mp / 2));
    for (auto& v : codes_packed) v = static_cast<uint8_t>(ui(rng));

    std::cout << "variant,repeat,total_ms,per_row_ns\n";
    std::cout << std::fixed << std::setprecision(4);

    // Scalar baseline
    for (int rep = 0; rep < repeat; ++rep) {
        volatile float sink = 0.0f;
        auto t0 = std::chrono::high_resolution_clock::now();
        for (int i = 0; i < N; ++i) sink += adc_scalar(codes.data() + i * M, lut.data());
        auto t1 = std::chrono::high_resolution_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        std::cout << "scalar," << rep << "," << ms << ","
                  << (ms * 1e6) / N << "\n";
        (void)sink;
    }

    // Gather
    for (int rep = 0; rep < repeat; ++rep) {
        volatile float sink = 0.0f;
        auto t0 = std::chrono::high_resolution_clock::now();
        for (int i = 0; i < N; ++i) sink += adc_gather(codes.data() + i * M, lut.data());
        auto t1 = std::chrono::high_resolution_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        std::cout << "gather," << rep << "," << ms << ","
                  << (ms * 1e6) / N << "\n";
        (void)sink;
    }

    // Shuffle (FastScan-style)
    std::vector<uint16_t> sums(N);
    for (int rep = 0; rep < repeat; ++rep) {
        auto t0 = std::chrono::high_resolution_clock::now();
        adc_shuffle_batch(codes_packed.data(), N, lut_small.data(), sums.data());
        auto t1 = std::chrono::high_resolution_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        std::cout << "shuffle," << rep << "," << ms << ","
                  << (ms * 1e6) / N << "\n";
    }

    return 0;
}
