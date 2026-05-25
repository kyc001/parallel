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

### MPI ANN Submission Contract

MPI ANN labs use `ann-mpi/` as the owning directory and keep the submission
entry at `ann-mpi/main.cc`.

Signatures:

- Server build: `mpic++ main.cc -o main -O2 -std=c++11 -I. -fopenmp -lpthread`
- `ann-mpi/Makefile` must set `CXX = mpic++`, not `CXX ?= mpic++`, because
  GNU make's built-in `CXX=g++` can otherwise select `g++` and fail on
  `#include "mpi.h"`.
- Local no-MPI fallback:
  `g++ main.cc -o build/main_no_mpi.exe -O2 -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma -DANN_NO_MPI`
- IVF-PQ run:
  `mpiexec -np <np> ./main <threads> <nlist> <nprobe> <rerank_p> <query_n> local`
- Block-HNSW run:
  `mpiexec -np <np> ./main <threads> <hnsw_m> <ef> <unused_p> <query_n> hnsw`
- IVF+HNSW nested run:
  `mpiexec -np <np> ./main <threads> <nlist> <nprobe> <ef> <query_n> ivf-hnsw`
- HNSW-on-HNSW run:
  `mpiexec -np <np> ./main <threads> <nblocks> <nprobe_blocks> <ef> <query_n> hnsw-on-hnsw`
- PBS smoke:
  `qsub -v NP=<np>,OMP_NUM_THREADS=<threads>,QUERY_N=<query_n>,NLIST=<nlist>,NPROBE=<nprobe>,RERANK_P=<p>,HNSW_M=<m>,HNSW_EF=<ef>,HNSW_ON_HNSW_NPROBE=<nprobe_blocks> qsub_mpi.sh`

Environment contracts:

- Kunpeng data should be selected with `ANN_DATA_PATH=/anndata` when
  `/anndata` exists.
- PBS scripts should accept `NP`, `OMP_NUM_THREADS`, `QUERY_N`, `NLIST`,
  `NPROBE`, `RERANK_P`, `HNSW_M`, `HNSW_EF`, and `HNSW_ON_HNSW_NPROBE`
  overrides so small smoke jobs are reproducible without editing the script.
- Kunpeng automation scripts that connect through the jump host must read the
  server password from `KUNPENG_PASSWORD`; do not hard-code credentials in new
  scripts or committed reproduction commands.
- Result logs for MPI ANN runs must include MPI process count, OpenMP thread
  count, algorithm parameters, Recall@10, average latency, max local search
  latency, communication plus merge latency, and per-rank search latency.
- Blocking/non-blocking communication comparisons must print `comm_mode` and
  preserve identical algorithm parameters between the two runs.
- Full-score MPI ANN result logs should cover IVF-PQ, block-HNSW, IVF+HNSW
  nested, and HNSW-on-HNSW when those modes are present. HNSW-on-HNSW is
  expected to be a recall-latency trade-off datapoint rather than the fastest
  path when `HNSW_ON_HNSW_NPROBE` probes all blocks.
- Windows PowerShell scripts that run MS-MPI should launch `mpiexec.exe` with
  `Start-Process`, redirect stdout/stderr to temporary files, and check the
  process exit code after completion. Direct calls such as
  `& $MPIEXEC ... 2>&1 | Tee-Object ...` can turn normal MPI/runtime stderr
  progress messages into `NativeCommandError`/`RemoteException` and abort a
  valid benchmark.
- VTune wrappers around MPI launchers must include a timeout and process-tree
  cleanup path. MS-MPI child wrapping can hang before benchmark output when
  command quoting or profiler injection fails, so scripts should fail with a
  saved log instead of waiting indefinitely.

Validation/error matrix:

- Missing MPI compiler/runtime -> record the failed `mpic++` or `mpiexec`
  command and exit code in `ann-mpi/results/`.
- Missing `/anndata` on Kunpeng -> fall back only to an explicit
  `ANN_DATA_PATH` or staged `/home/$USER/files`; do not silently invent a new
  data path.
- Missing `KUNPENG_PASSWORD` in automation -> print a short diagnostic and
  return non-zero before opening any SSH connection.
- PBS queue/job failure -> save `qsub`, `qstat`, `test.o`, and `test.e`
  excerpts in `ann-mpi/results/kunpeng_pbs_smoke.txt`.
- Windows MPI script stderr/progress output -> capture it as run evidence, but
  fail only when the launched process exit code is non-zero or required result
  fields such as Recall/latency are missing.

Good/base/bad cases:

- Good: direct `mpiexec -np 2` and PBS smoke both finish and emit the stable
  latency/recall/per-rank fields for every selected mode; PBS full sweeps are
  used for report-visible Kunpeng results when the task requires queue runs.
- Base: local Windows uses MS-MPI for MPI compile/run and `-DANN_NO_MPI` for a
  single-process fallback compile.
- Bad: old copied `test.sh`, `qsub.sh`, `build/`, report outputs, or transfer
  archives are kept in the MPI submission directory; new automation scripts
  commit plaintext server passwords.

Tests required:

- Local `-DANN_NO_MPI` compile.
- Local MPI compile plus `mpiexec -n 2` smoke for IVF-PQ, block-HNSW,
  IVF+HNSW nested, and HNSW-on-HNSW.
- Kunpeng `mpic++` build and direct or PBS `mpiexec -np 2` smoke.
- Full-report runs should also rerun the parser/plot script after all logs are
  collected and before LaTeX compilation.
- Windows full-report scripts should be syntax-checked with PowerShell's parser
  after edits, especially when they build `cmd /AFFINITY`, MS-MPI, or VTune
  command lines.

Wrong vs correct:

```bash
# Wrong: assumes course data is copied into the source tree.
scp -r files compute-node:/home/$USER/

# Correct: prefer the shared Kunpeng data mount, with explicit fallback.
export ANN_DATA_PATH=/anndata
/usr/local/bin/mpiexec -np 2 ./main 2 16 4 1000 200 local

# Wrong: commits credentials in a reproduction script.
PASSWORD="server-password"

# Correct: require the caller to provide credentials through the environment.
export KUNPENG_PASSWORD="<server-password>"
python scripts/run_kunpeng_pbs_sweep_auto.py
```

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
