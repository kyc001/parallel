# Data and Build Guidelines

## Data Location Conventions

ANN benchmarks read the DEEP100K files by convention:

- Query data: `DEEP100K.query.fbin`
- Ground truth: `DEEP100K.gt.query.100k.top100.bin`
- Base vectors: `DEEP100K.base.100k.fbin`

`ann-pthread-omp/simd/ann_bench_common.h` defines the canonical resolution
order:

- `ANN_DATA_PATH`, when set, wins.
- `ANN_DEFAULT_DATA_PATH`, when compiled in, is the fallback.
- Windows uses `../files/`.
- Linux checks Kunpeng `/anndata/` and otherwise uses local `files/`.

Use this helper instead of hard-coding new paths. If a new tool needs data, add
the same environment-variable escape hatch and keep local/Kunpeng behavior
compatible with existing drivers.

## Binary Input Readers

Binary `.fbin` readers follow the pattern in
`ann-pthread-omp/simd/ann_bench_common.h`: read two `uint32_t` header fields
for `n` and `d`, allocate `n * d`, then read the payload. On failure, throw or
return a clear diagnostic naming the file path.

Keep the type explicit at the call site:

```cpp
auto queries = ann_bench::LoadData<float>(path + "DEEP100K.query.fbin", n, d);
auto gt = ann_bench::LoadData<int>(path + "DEEP100K.gt.query.100k.top100.bin", gt_n, gt_dim);
```

## Build Flags

The common ANN build profile is optimization-first C++ with OpenMP and Pthread:

- `ann-pthread-omp/Makefile` uses `-O2 -std=c++11 -I. -fopenmp -lpthread`.
- On x86, the Makefile adds `-mavx2 -mfma`; on ARM/AArch64 it omits AVX flags.
- Some handover notes mention C++17 experiments, but the portable submission
  path intentionally migrated back to C++11 where possible.

Do not introduce `std::filesystem`, C++20 APIs, or compiler-specific extensions
in submission paths unless the task explicitly narrows the target platform.
`lab1-CPU架构编程/src/fs_compat.hpp` exists because portability has already
been a real issue.

## Platform Branches

Use compile-time platform checks for low-level system APIs:

- `lab1-CPU架构编程/src/benchmark.cpp` separates `_WIN32` affinity behavior
  from Linux `sched_setaffinity` and `perf_event_open`.
- SIMD code keeps AVX2 and NEON implementations in separate headers such as
  `ann-SIMD/flat_scan_avx2.h` and `ann-SIMD/pq_fastscan_neon.h`.
- `ann-pthread-omp/Makefile` filters unsupported `mains/` entries by detected
  architecture.

Prefer adding a platform-specific file or guarded function over scattering
large `#ifdef` blocks through algorithm code.

## Benchmark Entry Points

Preserve existing course/reproduction entry points:

- `ann-pthread-omp/main.cc` is the representative final submission entry.
- `ann-pthread-omp/mains/` holds the complete matrix of variants used by
  `Makefile` and run scripts.
- `ann-SIMD/main.cc` and sibling `main_*.cc` files mirror SIMD assignment
  variants.
- `lab1-CPU架构编程/src/main.cpp` writes `results/` and runs all Lab1
  experiment groups.

New benchmark drivers should print `average recall` and `average latency (us)`
when they are ANN-search variants, matching `ann-pthread-omp/mains/*.cc` and
`ann-pthread-omp/main.cc`.

## Generated Outputs

Curated outputs live in `results/*.csv`, `ann-pthread-omp/results/`, or report
figure directories. Raw profiler databases, local executables, object files,
and LaTeX intermediates belong to ignored paths. Check `.gitignore` before
adding a new generated file pattern.
