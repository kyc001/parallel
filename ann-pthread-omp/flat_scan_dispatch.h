#pragma once
#if defined(__AVX2__)
  #include "flat_scan_avx2.h"
#elif defined(__aarch64__) || defined(__ARM_NEON)
  #include "flat_scan_simd.h"
#else
  #include "flat_scan.h"
#endif
