#pragma once

// Keep the historical include path stable for local Windows experiments.
// The actual AVX2 implementation lives in pq_fastscan_avx2_safe.h so that
// local binaries and the submission wrapper share the same code path.
#include "pq_fastscan_avx2_safe.h"
