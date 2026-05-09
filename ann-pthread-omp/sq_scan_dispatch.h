#pragma once
#if defined(__AVX2__)
  #include "sq_scan_avx2.h"
#elif defined(__aarch64__) || defined(__ARM_NEON)
  #include "sq_scan_simd.h"
#else
  #error "sq_scan_dispatch.h requires AVX2 on x86 or NEON on AArch64."
#endif
