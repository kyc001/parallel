# Backend Quality Guidelines

## Preserve Reproducibility

Every code change in this repo should keep experiments reproducible:

- Record the data path or keep using the shared `ANN_DATA_PATH` resolution.
- Keep thread counts, schedule policies, `nlist`, `nprobe`, rerank `p`, and
  recall cutoffs visible in either code, output, or result filenames.
- When changing benchmark logic, update the corresponding report source or
  handover note if the old numbers are no longer valid.

## Verify Correctness Before Speed

Performance code still needs a correctness check:

- ANN variants should report Recall@10 against the provided ground truth before
  comparing latency.
- `ann-pthread-omp/tests/pq_final_assignment_test.cc` is the local example of a
  focused regression test: it builds synthetic data, recomputes expected PQ
  assignments, and exits non-zero on mismatch.
- Lab1 experiments use deterministic data generation in
  `lab1-CPU架构编程/src/data_utils.cpp`, which makes diffs stable.

Add small synthetic tests for algorithmic changes where possible. Do not rely
only on "it ran faster" for correctness.

## Portability Expectations

The repo targets multiple environments:

- Windows local development and PowerShell scripts.
- Linux/macOS shell scripts for local runs.
- Kunpeng/AArch64 server runs with NEON and PBS-style `qsub.sh` submission.
- x86 systems with AVX2/FMA.

Keep platform assumptions local and explicit. If a change only works on one
platform, name that in the file, script, and report text.

## C++ Style

Follow the local C++ style:

- Headers use `#pragma once`.
- Standard includes appear before local includes in many ANN files; Lab1 files
  include their matching local header first.
- Prefer `size_t` for vector counts and dimensions, with explicit casts when
  calling intrinsic helpers that require `int`.
- Use RAII containers (`std::vector`, `std::unique_ptr`) for owned data.
- Keep hot loops simple and avoid hidden allocations inside per-query work.
- Clamp thread counts to at least one, as in
  `ann-pthread-omp/mains/flat_bench_common.h::ParseThreads`.

## Parallel-Code Review Checks

Before accepting Pthread/OpenMP changes, check:

- Work partitioning covers all queries or base-vector ranges exactly once.
- Shared result vectors are either pre-sized by query or protected by a clear
  synchronization strategy.
- Thread-pool tasks signal completion for every queued item.
- OpenMP schedules are intentional and documented when benchmarked.
- No false-sharing-prone shared counters are added in hot loops without padding
  or aggregation.

## Validation Commands

Use the smallest command that verifies the touched area:

- `make` in `ann-pthread-omp/` builds the variant matrix selected for the
  current architecture.
- `bash run_all.sh` or `./run_all.ps1` runs full local ANN sweeps.
- `bash test.sh 2 1` is the course submission path for ANN jobs.
- Lab1 uses the local build/run scripts under `lab1-CPU架构编程/`.
- LaTeX reports should be rebuilt with the same engine already used by that
  report, usually XeLaTeX plus BibTeX when citations changed.

If a command cannot be run locally because of data, compiler, or cluster
requirements, say exactly what was not run and why.

## LaTeX/PDF Report Validation

Course reports are deliverables, not disposable generated output. When adding
or substantially editing a report under a lab's `report/` directory:

- Keep the source and final PDF together, for example
  `ann-mpi/report/main.tex` and `ann-mpi/report/main.pdf`.
- Rebuild with the report's existing engine, usually:
  `latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex`.
- Check the compiled PDF metadata/page count with `pdfinfo`, especially when
  the user gives a page limit.
- Search the LaTeX log for `LaTeX Error`, `Undefined`, `Overfull`, and missing
  citation/reference warnings. Fix overfull boxes that indicate visible table,
  path, or diagram overflow.
- Use `pdftotext -layout` for a quick text sanity check, then render spot-check
  pages with `pdftoppm` and inspect the title page, dense tables/figures, and
  final page for overlap or garbling.
- Leave auxiliary files (`*.aux`, `*.log`, `*.toc`, `*.xdv`, etc.) ignored;
  commit only source, stable assets, and the final PDF unless a task explicitly
  asks for build logs.
