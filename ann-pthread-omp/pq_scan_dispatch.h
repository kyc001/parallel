#pragma once
#if defined(__AVX2__)
  #include "pq_scan_avx2.h"
#elif defined(__aarch64__) || defined(__ARM_NEON)
  #include "pq_scan_simd.h"
#else
  #error "pq_scan_dispatch.h requires AVX2 on x86 or NEON on AArch64."
#endif
