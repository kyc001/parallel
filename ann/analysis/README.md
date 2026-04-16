# Analysis Tools

This directory contains reproducible source files and scripts for the SIMD
assembly analysis used in the report.

- `analyze.cc`: standalone functions extracted from Flat-SIMD, SQ-SIMD, and
  PQ-SIMD for assembly generation and compiler vectorization reports.
- `bench_optlevel.cc`: microbenchmark for comparing scalar IP and NEON IP under
  `-O0`, `-O1`, `-O2`, and `-O3`.
- `run_asm_analysis.sh`: regenerates assembly, objdump, vectorization reports,
  and optimization-level performance data.
- `run_simpleperf_analysis.sh`: compiles a symbolized benchmark and tries
  `simpleperf stat`, `simpleperf record`, and `simpleperf report`.

Run from the repository root or from `ann/`:

```bash
bash ann/analysis/run_asm_analysis.sh
```

All generated text results are written to `ann/local_results/termux_arm64/`.
Generated binaries are written to `ann/local_results/termux_arm64/bin/`, which is
ignored by Git.

For simpleperf:

```bash
bash ann/analysis/run_simpleperf_analysis.sh
```

Its outputs are written to `ann/local_results/termux_arm64/simpleperf/`. On some
Termux/PRoot environments, Android kernel perf permissions can block profiling;
the script records those errors in the result files.
