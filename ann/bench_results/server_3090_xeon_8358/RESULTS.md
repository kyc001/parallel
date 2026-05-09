# Xeon Platinum 8358 AVX-512 result record

## Environment

- CPU/platform: Xeon Platinum 8358 container
- ISA: AVX-512F + BW + DQ
- OS/kernel: Ubuntu 20.04.3 LTS, Linux 5.15.0-60-generic
- Compiler flag used by the benchmark entry: `-O3 -mavx512f`
- Dataset: DEEP100K, first 2000 queries, `k=10`
- Perf/VTune sampling: unavailable in the container

## Results

| mode | k | Recall@10 | latency_us |
|---|---:|---:|---:|
| baseline | 10 | 0.99995 | 7208.06 |
| flat_avx512 | 10 | 0.99995 | 1865.11 |

Flat-AVX-512 speedup over the same-container serial baseline:

`7208.06 / 1865.11 = 3.86x`

The corresponding benchmark entry points are:

- `server_3090/run_3090_avx512.sh`
- `server_3090/main_3090_avx512.cc`
- `server_3090/flat_scan_avx512.h`
