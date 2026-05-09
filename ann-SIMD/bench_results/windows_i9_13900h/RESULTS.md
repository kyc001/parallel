# Windows i9-13900H AVX2 Results

Date: 2026-04-18

## Environment

- Platform: Windows 11 on 13th Gen Intel Core i9-13900H, Raptorlake-P.
- ISA target: AVX2 256-bit SIMD plus FMA.
- Compiler: MinGW-w64 g++ 14.2.0.
- Build: `g++ main_win_avx2.cc -o main_win_avx2.exe -O2 -mavx2 -mfma -fopenmp -lpthread -std=c++11`.
- Dataset: DEEP100K, 100K base vectors, 96 float32 dimensions.
- Benchmark: 2000 queries, k=10, single-thread P-core run.
- Data path: local Windows `./files/`; Kunpeng `/anndata/` paths are unchanged.

## Speed Results

### Baseline and Flat

| Version | Recall@10 | Latency (us) | Speedup vs Baseline |
|---|---:|---:|---:|
| baseline_serial_flat | 0.99995 | 4571.62 | 1.00x |
| flat_avx2 | 0.99995 | 1756.11 | 2.60x |

### SQ-AVX2 Sweep

| rerank_p | Recall@10 | Latency (us) | Speedup vs Baseline |
|---:|---:|---:|---:|
| 100 | 0.99995 | 427.01 | 10.71x |
| 200 | 0.99995 | 469.31 | 9.74x |
| 500 | 0.99995 | 609.16 | 7.50x |
| 1000 | 0.99995 | 808.63 | 5.65x |
| 2000 | 0.99995 | 1159.41 | 3.94x |
| 5000 | 0.99995 | 2368.87 | 1.93x |
| 10000 | 0.99995 | 4066.32 | 1.12x |
| 50000 | 0.99995 | 11572.16 | 0.40x |
| 100000 | 0.99995 | 18507.05 | 0.25x |

### PQ-AVX2 Sweep

| rerank_p | Recall@10 | Latency (us) | Speedup vs Baseline |
|---:|---:|---:|---:|
| 100 | 0.70860 | 398.53 | 11.47x |
| 200 | 0.83360 | 665.06 | 6.87x |
| 500 | 0.94595 | 838.17 | 5.45x |
| 1000 | 0.98330 | 761.99 | 6.00x |
| 2000 | 0.99550 | 1640.21 | 2.79x |
| 5000 | 0.99965 | 3042.08 | 1.50x |
| 10000 | 0.99995 | 3344.43 | 1.37x |
| 50000 | 0.99995 | 13508.39 | 0.34x |
| 100000 | 0.99995 | 15893.12 | 0.29x |

## VTune Microarchitecture Analysis

### Hotspots

Flat-AVX2 Hotspots is almost entirely concentrated in the flat scan loop.
VTune reports the hot function as `func@0x140001b60` because this MinGW build
does not provide full symbol/debug information. In the P-core pinned run, that
function accounts for 2.828s CPU time, with the next function at only 0.015s.

### UArch Summary

| Version | CPI | Retiring | Front-End Bound | Bad Speculation | Back-End Bound | Memory Bound | Key vector/core signal |
|---|---:|---:|---:|---:|---:|---:|---|
| flat_avx2, P-core pinned | 0.904 P-core | 19.5% | 1.5% | 7.6% | 71.4% | 56.3% | 256-bit FP vector 33.8% uOps |
| sq_avx2, p=100 | 0.307 P-core | 47.5% | 5.9% | 23.7% | 23.0% | 8.7% | 256-bit int vector 28.6% uOps, 3+ ports 51.1% |
| pq_avx2, p=1000 | 0.270 P-core | 68.5% | 8.0% | 6.8% | 16.7% | 0.6% | 3+ ports 85.9% |

Machine Clears are visible in the raw flat and SQ reports: raw flat shows 18.6%
Pipeline Slots in Machine Clears, SQ shows 12.5%, and the P-core pinned flat
run shows 7.3%. The likely source is the `priority_queue` top-k update branch,
especially the `if (dis < q.top().first)` path and its store/load dependency.

### P-Core Pinning Effect

| Metric | Raw flat | P-core pinned flat |
|---|---:|---:|
| Average CPU Frequency | 1.484 GHz | 5.086 GHz |
| CPI Rate | 1.117 | 0.905 overall / 0.904 P-core |
| Retiring | 19.5% | 19.5% |
| Front-End Bound | 2.9% | 1.5% |
| Bad Speculation | 18.6% | 7.6% |
| Back-End Bound | 59.0% | 71.4% |
| Memory Bound | 34.6% | 56.3% |
| DRAM Bound | 36.7% | 49.1% |
| Memory Bandwidth | 78.1% of clockticks | 91.9% of clockticks |

P-core pinning removes the low-frequency mixed-core artifact and exposes the
true flat-scan bottleneck: the AVX2 loop is hard DRAM bandwidth-bound.

### Memory Access, Flat P-Core

| Metric | Value |
|---|---:|
| Loads | 6,413,392,396 |
| Stores | 48,401,452 |
| LLC Miss Count | 448,438,265 |
| DRAM observed maximum bandwidth | 42.1 GB/s |
| DRAM average bandwidth | 9.639 GB/s |
| Platform maximum DRAM bandwidth | 71.0 GB/s |

The observed 42.1 GB/s peak is about 59.3% of the platform maximum 71.0 GB/s,
while the uarch report flags Memory Bandwidth at 91.9% of clockticks.

## Cross-Platform Comparison

| Version | i9 AVX2 (us) | Kunpeng NEON (us) | Tablet NEON (us) | i9 vs Kunpeng | i9 vs Tablet |
|---|---:|---:|---:|---:|---:|
| baseline | 4571.62 | 16120.74 | 8282.96 | 3.53x | 1.81x |
| flat | 1756.11 | 5821.16 | 2596.54 | 3.31x | 1.48x |
| sq p=100 | 427.01 | 2422.68 | 1087.87 | 5.67x | 2.55x |
| pq p=1000 | 761.99 | 1984.35 | 1520.52 | 2.60x | 2.00x |

## Key Conclusions

- Flat-AVX2 is hard DRAM bandwidth-bound on the i9-13900H P-core run: Memory
  Bandwidth reaches 91.9% of clockticks and Back-End Bound reaches 71.4%.
- SQ-AVX2 is the most balanced speed/recall point. The p=100 setting keeps full
  recall and reaches 10.71x speedup, with strong 256-bit integer SIMD usage.
- PQ-AVX2 has the highest retiring rate at 68.5%; the ADC lookup loop is very
  efficient, although full program elapsed time includes k-means index build.
- AVX2 doubles NEON vector width from 128-bit to 256-bit, but the real gain is
  workload-dependent: bandwidth and top-k heap maintenance make the end-to-end
  improvement non-linear, roughly 1.5x to 2.5x for the core SIMD comparisons.
- The remaining Machine Clears are likely tied to the `priority_queue` top-k
  branch and store/load dependency in the heap update path.

## TODO

- Optional Day 14: evaluate AVX-512 on the x86 server if that platform is used.
- Optional: rebuild the Windows binary with debug symbols for cleaner VTune
  function names.
- Optional: replace the heap-based top-k maintenance with a flatter selection
  structure to reduce Machine Clears.
