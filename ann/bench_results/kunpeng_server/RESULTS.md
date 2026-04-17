# Kunpeng 920 Server Benchmark Results

Platform: Huawei Kunpeng 920 server, ARM AArch64 with NEON.
Submission: `bash test.sh 1 1` on login node `master_ubss1`.
Data: DEEP100K (96-dim, N=100K, 2000 queries, k=10).

## Core Comparison

| Version | Recall@10 | Latency (μs) | Speedup vs Baseline |
|---|---:|---:|---:|
| Baseline Serial Flat | 0.99995 | 16120.74 | 1.00x |
| Flat-SIMD | 0.99995 | 5821.16 | 2.77x |
| SQ-SIMD (p=100) | 0.99995 | 2422.68 | 6.65x |
| PQ-SIMD (p=1000) | 0.98355 | 1984.35 | 8.12x |

## SQ-SIMD p Sweep

| p | Recall@10 | Latency (μs) |
|---:|---:|---:|
| 100 | 0.99995 | 2422.68 |
| 200 | 0.99995 | 2422.90 |
| 500 | 0.99995 | 2701.90 |
| 1000 | 0.99995 | 2997.13 |
| 2000 | 0.99995 | 3674.23 |
| 5000 | 0.99995 | 5391.92 |
| 10000 | 0.99995 | 8033.46 |
| 50000 | 0.99995 | 28138.01 |
| 100000 | 0.99995 | 40260.66 |

## PQ-SIMD p Sweep

| p | Recall@10 | Latency (μs) |
|---:|---:|---:|
| 100 | 0.70930 | 1224.20 |
| 200 | 0.83835 | 1315.36 |
| 500 | 0.94740 | 1566.47 |
| 1000 | 0.98355 | 1984.35 |
| 2000 | 0.99550 | 2693.58 |
| 5000 | 0.99980 | 4506.40 |
| 10000 | 0.99995 | 7586.31 |
| 50000 | 0.99995 | 23857.74 |
| 100000 | 0.99995 | 42163.42 |

## Key Findings

- Kunpeng baseline is about 1.95x slower than the tablet baseline (16120 μs vs 8282 μs).
- SIMD acceleration is more pronounced on Kunpeng: PQ-SIMD at p=100 reaches 13.17x speedup.
- Recall is identical across ARM platforms for matching p values, validating deterministic numerical behavior.
