# Backend Directory Structure

## Repository Shape

This is a single-repo coursework workspace. Directories are organized by lab or
topic rather than by one application package:

- `lab1-CPU架构编程/src/` contains small C++ benchmark modules split into
  headers and implementation files, for example `benchmark.cpp`,
  `matrix_experiment.cpp`, `sum_experiment.cpp`, and `main.cpp`.
- `ann-SIMD/` contains the SIMD ANN lab, with root-level submission entries
  such as `main.cc`, `main_fastscan.cc`, and architecture-specific scan
  headers such as `flat_scan_avx2.h`, `pq_fastscan_neon.h`, and
  `sq_scan_simd.h`.
- `ann-pthread-omp/` contains the later ANN parallelization lab. Root files
  keep course entry points (`main.cc`, `Makefile`, `test.sh`, `qsub.sh`), while
  implementation variants are grouped by strategy.
- `ann_original/` is the upstream/baseline ANN source. Treat vendored
  `hnswlib/` trees under `ann_original/`, `ann-SIMD/`, and
  `ann-pthread-omp/` as external reference code unless the task explicitly
  targets them.
- `results/`, `ann-pthread-omp/results/`, `lab1-CPU架构编程/results/`, and
  `bench_results/` style directories contain measured outputs. Keep summaries
  and curated CSVs when they document the report; avoid committing raw profiler
  project directories or transient logs.

## ANN Parallelization Layout

`ann-pthread-omp/` is the most structured code area:

- `simd/` stores vectorized scan kernels and shared benchmark utilities,
  including `simd/ann_bench_common.h`.
- `pthread/` stores Pthread and `std::thread` implementations, including
  shared infrastructure like `pthread/thread_pool.h`.
- `omp/` stores OpenMP variants for flat, SQ, PQ, and FastScan search.
- `ivf/` stores IVF and IVF-PQ indexes and search variants.
- `hnsw/` stores project-specific HNSW parallel search strategies.
- `mains/` stores many reproducible `main_*.cc` drivers grouped by algorithm,
  execution model, scheduling policy, and inter/intra-query strategy.
- `tools/` stores standalone sweep or diagnostic programs such as
  `sweep_omp_schedule.cc`, `sweep_ivf_nlist.cc`, and
  `false_sharing_demo.cc`.
- `scripts/` stores report/plot generators.
- `report/` stores the LaTeX report source and generated figures.

When adding a new ANN variant, put the reusable kernel in the matching
algorithm/model directory and add only a thin driver under `mains/`. Avoid
copying a full `main.cc` unless the course submission entry point itself needs
to change.

## Lab1 C++ Layout

`lab1-CPU架构编程/src/` uses a conventional header/implementation split:

- `main.cpp` orchestrates output directory creation, environment capture, and
  experiment execution.
- `benchmark.*` owns timing, CPU affinity, hardware-counter helpers, and
  anti-optimization helpers.
- `data_utils.*` owns deterministic input generation and diff helpers.
- `matrix_experiment.*`, `sum_experiment.*`, and `profile.*` own individual
  experiment families.
- Separate drivers such as `perf_driver.cpp` and `opt_compare_driver.cpp`
  exist for specialized runs.

Follow this split when extending Lab1: put reusable measurement helpers in
`benchmark.*`, deterministic data helpers in `data_utils.*`, and experiment
logic in the relevant experiment module.

## Scripts and Reports

Script entry points live beside the lab they operate on:

- Windows automation uses `.ps1` files such as
  `ann-pthread-omp/run_all.ps1` and
  `lab1-CPU架构编程/run_vtune_windows.ps1`.
- Linux/Kunpeng automation uses `.sh` files such as
  `ann-pthread-omp/run_all_kunpeng.sh` and `ann-SIMD/run_fastscan_kunpeng.sh`.
- Plot/report generators live under the owning topic, for example
  `OT-协程技术调研/plot_results.py` and
  `ann-pthread-omp/scripts/gen_report_assets.py`.

Keep generated figures under each report's `fig/` or `report/fig/` directory
so LaTeX/Typst sources can reference them with stable relative paths.
