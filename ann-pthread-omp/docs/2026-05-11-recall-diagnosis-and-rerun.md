# 2026-05-11 Recall Diagnosis and Rerun List

## Root Cause

The low recall groups have two causes:

1. Real implementation bug in `PQIndex::build()`: after the final Lloyd centroid update, `codes` were written from assignments computed against the previous centroids. This is fixed in both x86 AVX2 and ARM NEON headers:
   - `simd/pq_scan_avx2.h`
   - `simd/pq_scan_simd.h`

2. Parameter issue: the original core matrix used `p=100` for PQ and IVF-PQ. On DEEP100K Recall@10, `p=100` is a fast low-recall operating point, not a 95%+ operating point.

Regression test:

```powershell
g++ tests/pq_final_assignment_test.cc -o build/pq_final_assignment_test.exe -O2 -std=c++17 -I. -mavx2 -mfma
.\build\pq_final_assignment_test.exe
```

Build check:

```powershell
g++ main.cc -o build/unified_check.exe -O2 -fopenmp -lpthread -std=c++17 -I. -mavx2 -mfma
```

## Fresh Diagnostic Results

Commands wrote raw outputs to `results/diagnostics/`.

### PQ, `pthread_dynamic_inter`, 16 threads

| p | Recall@10 | Latency us/query |
|---:|---:|---:|
| 100 | 0.70780 | 85.43275 |
| 300 | 0.89185 | 99.45480 |
| 500 | 0.94575 | 101.70130 |
| 1000 | 0.98335 | 136.47185 |
| 2000 | 0.99560 | 183.35245 |

Recommendation: use `p=1000` for the main high-recall PQ matrix, and keep `p=100,300,500,1000,2000` as the latency-recall sweep.

### IVF-PQ, `pthread_dynamic_inter`, 16 threads

| mode | nprobe | p | Recall@10 | Latency us/query |
|---|---:|---:|---:|---:|
| global | 4 | 100 | 0.68805 | 28.34265 |
| global | 4 | 1000 | 0.94715 | 83.17715 |
| global | 4 | 2000 | 0.95975 | 90.92045 |
| global | 16 | 1000 | 0.98070 | 110.69900 |
| local | 4 | 1000 | 0.95945 | 61.31540 |
| local | 16 | 1000 | 0.99545 | 118.86060 |

Recommendation: use `mode=local,nprobe=4,p=1000` as the default high-recall IVF-PQ point. Use `mode=local,nprobe=16,p=1000` when the report needs a 99%+ recall point. Use global/local comparison as an algorithm-design discussion rather than a single "winner" claim.

### IVF-HNSW nested, OMP, 4 threads

| nprobe | Recall@10 | Latency us/query |
|---:|---:|---:|
| 4 | 0.94705 | 177.98880 |
| 8 | 0.97770 | 252.74055 |
| 16 | 0.98315 | 445.28595 |

Recommendation: use `nprobe=8` as the default nested HNSW operating point; keep `nprobe=4` as the low-latency/low-recall point.

## Experiments That Must Be Rerun

Rerun these before treating their data as final:

- All PQ matrix results generated with `p=100`, because the old values are below the 95% target and were produced before the final-assignment fix.
- All IVF-PQ results using `PQIndex`, including both `global` and `local` modes, because they depend on the fixed PQ encoding path.
- ARM NEON PQ and IVF-PQ results on Kunpeng, because `simd/pq_scan_simd.h` changed.
- IVF-HNSW nested results if they are presented as high-recall results; old `nprobe=4` values are valid only as a low-latency point.

Do not rerun solely for this PQ fix:

- Flat, SQ, IVF-only, and HNSW baseline/multi-entry/edge/layer0 results.
- FastScan, unless changing its own parameters. Its separate FastScan index already recomputes assignments against final centroids.

## Final Reproducible Scripts

The temporary rerun results have been folded back into the formal local result set under `results/local/`. The clean reproducible entry points are:

```powershell
.\run_all.ps1
```

```bash
bash run_all_kunpeng_part1.sh
bash run_all_kunpeng_part2.sh
```

The Kunpeng scripts are split only because the server job time window is limited. Both scripts still go through `run_all_kunpeng.sh`, which precompiles the selected phases and submits `qsub.sh` directly. This avoids the legacy `test.sh` recompile path, whose fixed `-std=c++11`/missing `-I.` command is incompatible with the current unified benchmark.
