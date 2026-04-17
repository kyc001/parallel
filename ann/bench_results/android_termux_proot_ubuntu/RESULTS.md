# Android Termux PRoot Ubuntu Benchmark Results

Platform: Android tablet, Termux + PRoot Ubuntu, ARM AArch64 with NEON `asimd` and `asimddp`.

## E1: Alignment

The alignment experiment uses Flat-SIMD and reports the median total latency of 2000 queries across 5 runs. The 64B-aligned allocation takes 6,238,505 us, default `new float[]` takes 6,143,142 us, and the 1-byte-offset unaligned allocation takes 6,668,860 us. The unaligned case still runs correctly, confirming ARMv8 NEON's hardware tolerance for unaligned vector loads. However, the 1-byte offset is about 6.45% slower than the 64B-aligned baseline, which is consistent with extra cost from cache-line splits or less favorable memory access alignment.

## E2: Prefetch

The prefetch experiment uses Flat-SIMD and reports the median total latency of 2000 queries across 5 runs. The no-prefetch baseline is 6,219,560 us, while prefetch distances 4, 8, 16, and 32 produce speedups of 0.99980x, 0.92106x, 0.95905x, and 0.96018x. On this platform, explicit software prefetch does not improve the sequential full-scan workload. This suggests that the hardware prefetcher already handles the base-vector streaming pattern well, and extra prefetch instructions can add overhead or compete for cache capacity.

## E3: Problem Size

The scaling experiment reports median average latency per query and recall across 5 runs for each N. Serial Flat and Flat-SIMD both scale approximately linearly with N, matching the expected O(N*d) full-scan cost. At N=100000, Flat-SIMD reduces latency from 7859.00 us to 2839.61 us, giving about 2.77x speedup over scalar Flat in this run. SQ-SIMD with p=100 is fastest at full scale, reaching 1257.02 us with 0.99995 recall; PQ-SIMD with p=1000 reaches 1717.04 us but recall drops to 0.98355 due to product quantization error. For N < 100000, recall is measured against the original 100K groundtruth, so recall is naturally lower because many true neighbors are outside the truncated base subset.

## E4: Tradeoff Figures

`fig1_sq_tradeoff.png` and `fig2_pq_tradeoff.png` plot latency-recall curves using log-scaled latency. SQ-SIMD keeps recall at 0.99995 for all p values, so increasing p mainly increases rerank cost without improving recall on this dataset. PQ-SIMD shows a clearer latency-recall tradeoff: small p is very fast but loses recall, while larger p recovers near-exact recall with higher latency. These figures support using SQ when recall stability is the priority and PQ when a tunable speed-recall tradeoff is desired.
