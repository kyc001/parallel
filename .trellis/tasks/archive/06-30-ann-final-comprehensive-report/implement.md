# Implementation Plan: ANN Final Comprehensive Report

## Phase 1: Evidence and Outline

- [x] Confirm user preference for the final "new 20%" strategy.
- [x] Read the current `ann-final/report/main.tex` enough to preserve useful
      GPU sections and remove GPU-only framing.
- [x] Use `ann-final/并行第六次作业参考.pdf` as a coverage checklist, especially
      for algorithm-family terminology and pseudocode style, without copying
      its algorithm-first organization.
- [x] Extract reusable result rows and figure paths from:
      `ann-SIMD`, `ann-pthread-omp`, `ann-mpi`, and `ann-gpu`.
- [x] Decide which existing figures to copy/reference and which consolidated
      tables to hand-author from curated CSV/text summaries.

## Phase 1b: New Final Experiment

- [x] Inspect existing IVF-PQ helper APIs in `ann-pthread-omp/ivf/` and the
      representative driver in `ann-pthread-omp/main.cc`.
- [x] Add `ann-final/experiments/adaptive_ivfpq.cc` as a standalone benchmark
      driver that reuses existing IVF-PQ data structures and reports
      `average recall` plus `average latency (us)`.
- [x] Implement fixed low/medium/high baselines and an adaptive centroid-margin
      policy in the same binary so all methods share the same index build.
- [x] Run the benchmark on local DEEP100K data and save CSV/text evidence under
      `ann-final/report/results/`.
- [x] Reflect the result in the final report and clearly label it as new final
      work.

## Phase 2: Report Rewrite

- [x] Replace the GPU-lab title/abstract/frame with final ANN comprehensive
      report framing.
- [x] Write the integrated problem, system pipeline, and evaluation sections.
- [x] Write the four architecture sections:
      SIMD, Pthread/OpenMP, MPI, GPU.
- [x] Add unified comparison tables and final-project new-content declaration.
- [x] Add profiling synthesis using VTune/perf/CUDA event/static-resource
      evidence.
- [x] Update references and AI usage report.
- [x] Configure PDF links as black/borderless to avoid visible red boxes in the
      final rendered document.

## Phase 3: Assets

- [x] Ensure every `\includegraphics` target exists under
      `ann-final/report/fig/` or a stable relative path.
- [x] Copy selected stable figures from previous reports only when referenced.
- [x] Add `ann-final/report/gen_adaptive_fig.py` for the final adaptive
      IVF-PQ recall-latency chart generated from CSVs.
- [x] Keep generated chart filenames stable and descriptive.

## Phase 4: Validation

- [x] Run a source-level sanity check for missing figure paths and citation keys.
- [x] Build with:
      `latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex`
      from `ann-final/report/`, if available.
- [x] `latexmk` was available, so the direct XeLaTeX fallback was not needed.
- [x] Check page count with `pdfinfo main.pdf` if available.
- [x] Search the LaTeX log for errors, undefined refs/citations, missing files,
      and severe overfull boxes.
- [x] Run whitespace checks on edited text sources, excluding generated PDFs and
      imported profiler logs.

## Review Gates

- [x] Before starting implementation, user has approved the planned new-content
      strategy and Trellis task has been started.
- [x] Before final response, report source and PDF status are consistent:
      either both updated or source updated with a clear note that PDF build was
      unavailable.

## Rollback Points

- Before replacing `ann-final/report/main.tex`, keep a patch-level mental
  boundary: all changes are within `ann-final/report/` and the Trellis task
  directory.
- Do not alter previous lab reports as part of rollback; copied assets in
  `ann-final/report/fig/` can be removed if the final report no longer uses
  them.
- Do not touch unrelated root `results/` deletions, `.gitignore`, or existing
  task state outside this new task.
