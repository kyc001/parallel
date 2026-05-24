# Error Handling Guidelines

## Command-Line Tools

Small benchmark executables use simple process-level failure handling:

- Print a concise diagnostic to `std::cerr`.
- Return non-zero from `main`.
- Include relevant dimensions, file names, or platform limitations in the
  message.

Examples already in the repo:

- `lab1-CPU架构编程/src/main.cpp` wraps all experiments in `try/catch`,
  prints `benchmark failed: ...`, and returns `1`.
- `ann-pthread-omp/mains/flat_bench_common.h` returns `2` on base/query
  dimension mismatch and prints both dimensions.
- `ann-pthread-omp/main.cc` checks `base_d != query_d` before benchmarking and
  returns `1`.

Follow that style for standalone tools. Do not abort with assertions for
recoverable input or environment problems.

## Library-Like Helpers

Reusable helpers may throw when the caller is a benchmark driver that already
has a top-level handler:

- `ann-pthread-omp/simd/ann_bench_common.h::LoadData` throws
  `std::runtime_error` when a binary file cannot be opened, its header cannot
  be read, or its payload is incomplete.
- Lab1 helpers report unavailable hardware counters by returning a
  `PerfReadings` object with `available = false` and `error` populated rather
  than crashing on Windows or restricted Linux environments.

When adding shared helpers, choose either exception-based failure or explicit
status fields and keep the pattern consistent with the owning module.

## Platform Limitations

Platform limitations are normal in this repo and should be reported as
capabilities, not hidden:

- Windows profiling may require external VTune collection.
- Linux `perf_event_open` can fail because of kernel permissions.
- OpenMP offload and SYCL experiments in `ann-pthread-omp/tools/` may be
  source-only when the local toolchain cannot compile them.

Document such limits in the handover/report or result notes instead of making
the build silently skip important evidence.

## Shell and PowerShell Scripts

Scripts should fail early enough that incomplete benchmark runs are obvious:

- Bash scripts should use clear `echo`/`printf` diagnostics before long-running
  compile or submit steps.
- PowerShell scripts should check whether generated binaries and expected
  result files exist before summarizing.
- Avoid deleting result directories unless the script is explicitly a clean
  operation; many reports depend on checked-in summaries.

## Avoid These Patterns

- Do not ignore failed file opens for benchmark datasets.
- Do not print only `failed` without the file, command, or platform involved.
- Do not hard-code one local absolute path when `ANN_DATA_PATH` or relative
  course paths can serve the same purpose.
- Do not use assertions to enforce user-controlled arguments such as thread
  counts; clamp or reject them with a diagnostic.
