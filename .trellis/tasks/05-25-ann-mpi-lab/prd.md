# Implement ANN MPI Lab

## Goal

Complete the ANN MPI experiment in `ann-mpi/` with a clean submission
workspace, reproducible local validation, and Kunpeng server validation.

## User Request

- Work in `D:\Study\26sp\parallel\ann-mpi`, copied from the previous ANN
  Pthread/OpenMP experiment.
- Clean useless intermediate/generated files while preserving code.
- Implement the MPI experiment according to `ann-mpi/要求.md`.
- Follow `ann-mpi/提交指南.md`: compile with `mpic++`, submit with
  `qsub_mpi.sh`, and use server account `s2413575`.
- Keep the two-platform workflow: validate locally first, then sync to the
  Kunpeng server and run there.
- Run the same experiment parameter set on both Windows local and the Kunpeng
  server so the report can compare platforms directly.
- Record results promptly and keep runs reproducible.

## Requirements

- Provide a working `main.cc` MPI submission entry.
- Cover IVF/IVF-PQ MPI requirements:
  - partition base vectors across MPI ranks;
  - broadcast query vectors;
  - perform local ANN search on each rank;
  - gather/merge local top-k candidates on rank 0;
  - report Recall@10, per-query latency, local search time, and communication
    plus merge overhead.
- Provide hybrid MPI + OpenMP parallelism inside each rank.
- Include a graph-index path for the assignment's HNSW option, using block
  HNSW across MPI ranks and top-k merge on rank 0.
- Keep local fallback validation possible without MPI headers via
  `-DANN_NO_MPI`.
- Add or update server submission scripts for PBS.
- Clean copied build artifacts, old report/result/profiling outputs, and local
  installer/test noise.
- Preserve reusable source code directories and assignment documents.
- Record local and server commands/results under stable files so the report can
  cite exact evidence.
- Include a cross-platform comparison using identical MPI process count,
  OpenMP thread count, query count, IVF-PQ parameters, and block-HNSW
  parameters on both platforms.

## Known Environment

- Local Windows has MSYS2 `g++`, MS-MPI SDK/runtime, and Microsoft
  `mpiexec.exe`.
- Server access was confirmed on 2026-05-25 through the configured jump host:
  `s2413575 -> master_ubss1`, remote cwd `/home/s2413575`, architecture
  `aarch64`.

## Acceptance Criteria

- [ ] `ann-mpi/` no longer contains copied intermediate build/report/profiling
      noise from the previous experiment.
- [ ] `main.cc` builds locally in no-MPI mode and MPI mode.
- [ ] Local small-scale MPI smoke run completes with `mpiexec -n 2`.
- [ ] `qsub_mpi.sh` matches the MPI submission guide and uses project path
      `ann-mpi`.
- [ ] Server copy, `mpic++` build, and PBS or direct MPI validation complete,
      or any server blocker is recorded with exact command output.
- [ ] Reproducible commands and observed outputs are recorded in
      `ann-mpi/results/`.
- [ ] Windows local and Kunpeng results include the same IVF-PQ and block-HNSW
      experiment parameters and are summarized for direct comparison.

## Out of Scope

- Writing the final lab report unless requested separately.
- Re-running every previous Pthread/OpenMP/SIMD benchmark matrix.
- Preserving old copied report PDFs or profiling databases from the prior lab.
