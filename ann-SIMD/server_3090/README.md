# 3090 AVX-512 bench

Run on the Xeon 8358 docker container after cloning this repo. Goal:
complete the 128-bit NEON -> 256-bit AVX2 -> 512-bit AVX-512 scaling
story for the report.

## What you need

- Access to the container with AVX-512F available (check with
  `grep -q avx512f /proc/cpuinfo`). If the container hides it, this bench
  cannot run and the report will skip the 512-bit data point.
- DEEP100K data at `./files/` relative to the `ann/` repo root
  (same files as on Kunpeng: DEEP100K.base.100k.fbin / .query.fbin /
  .gt.query.100k.top100.bin).
- A recent GCC or Clang with AVX-512 support.

## Run

```
cd ann/
bash server_3090/run_3090_avx512.sh
```

The script builds two binaries (serial baseline + AVX-512 Flat) and
runs both on DEEP100K (first 2000 queries, k=10). Results land in
`bench_results/server_3090_xeon_8358/`.

## What to paste back into the report

One line per file from `bench_results/server_3090_xeon_8358/*.csv`:

```
mode,k,recall,latency_us
baseline,10,<recall>,<latency>
flat_avx512,10,<recall>,<latency>
```

The report's cross-platform table should then be extended with a
"3090 AVX-512" column.
