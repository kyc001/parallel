#pragma once

#if defined(__AVX2__)
#include "pq_fastscan_avx2_safe.h"
#elif defined(__aarch64__) || defined(__ARM_NEON)
#include "pq_fastscan_neon.h"
#else
#error "pq_fastscan_simd.h requires AVX2 on x86 or NEON on AArch64."
#endif
