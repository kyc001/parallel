# ANN final comprehensive report

## Goal

Create a full-score-oriented integrated ANN parallelization final report under
`ann-final/`, fusing SIMD, pthread/OpenMP, MPI, and GPU coursework into one
coherent research report rather than concatenating previous lab reports.

The report should make the advanced ANN topic competitive for full credit by
showing a unified system view, credible experiment evidence, profiling-level
analysis, and a real final-project experiment that accounts for at least 20%
of the final work instead of only adding report prose.

## Confirmed Facts

- The selected advanced topic is ANN / ANNS, not the default Gaussian
  elimination topic.
- The final report must be no more than 30 counted pages. Cover, table of
  contents, references, and AI usage report do not count toward this limit.
- The course requirement explicitly asks for fusion across SIMD,
  pthread/OpenMP, MPI, and CUDA/GPU work, not a stitched collection of previous
  reports.
- The report must state which parts come from ordinary coursework and which
  parts are new final-project content.
- Relevant existing materials are present in:
  - `ann-SIMD/` for SIMD, SQ/PQ/FastScan, AVX2/NEON, and profiling evidence.
  - `ann-pthread-omp/` for Pthread/OpenMP, IVF/IVF-PQ/HNSW, scheduling,
    granularity, false sharing, P/E-core affinity, and report figures.
  - `ann-mpi/` for distributed IVF-PQ, block-HNSW, IVF+HNSW, HNSW-on-HNSW,
    communication/merge analysis, scalability, and VTune notes.
  - `ann-gpu/` and the current `ann-final/report/` seed for CUDA batch ANN,
    GEMM/cuBLAS, Top-k, grouped-IVF, HIP learning notes, and static profiling.
  - `lab1-CPU架构编程/` for profiling methodology and low-level analysis style.
- The reference report `ann-final/并行第六次作业参考.pdf` has 31 PDF pages and
  uses a broad "algorithm families first, parallel acceleration later"
  structure: HNSW, KD-Tree, IVF, PQ, ScaNN, LSH, combinations, then SIMD /
  Pthread / OpenMP / MPI / CUDA. It is useful as a coverage checklist, but its
  parallel-fusion content starts late and visible PDF link boxes make the
  layout less polished.
- `ann-final/report/main.tex` currently appears to be a GPU lab report copy,
  so the final deliverable requires substantial restructuring.
- Existing worktree changes outside this task must be preserved and not
  reverted.

## Requirements

- Produce a Chinese research report source under `ann-final/report/` with a
  unified ANN-system narrative spanning offline indexing, online search,
  Recall@K evaluation, and latency/throughput measurement.
- Reorganize previous lab material around architectural and algorithmic axes:
  distance computation, candidate-set reduction, query/data parallelism,
  distributed partitioning, GPU batching, memory layout, and Top-k merging.
- Include cross-architecture comparison across SIMD, multi-core
  Pthread/OpenMP, MPI cluster, and GPU implementations, using repository result
  artifacts or explicitly cited run logs.
- Include at least 20% new final-project content, including a reproducible new
  ANN experiment under `ann-final/`. The preferred final experiment is an
  adaptive IVF-PQ search-budget policy that chooses `nprobe` and rerank budget
  per query from centroid-distance ambiguity, then compares recall-latency
  trade-offs against fixed-budget baselines.
- Discuss KD-tree only as a background/negative design choice for DEEP100K:
  because 96-dimensional vectors make axis-aligned tree pruning weak, KD-tree
  is not the main innovation path for this final integrated parallelization
  project.
- Preserve traceability from report tables/figures to result files, scripts, or
  code outputs.
- Include an AI usage report outside the counted body pages.
- Keep report claims conservative when evidence is missing or platform-specific.
- Build or otherwise validate the LaTeX/PDF deliverable when local tooling is
  available, and document any validation that cannot run locally.

## Out of Scope

- Re-running all semester experiments from scratch unless existing evidence is
  insufficient for a required final-report claim.
- Changing unrelated old lab reports except when copying or adapting stable
  assets into `ann-final/report/`.
- Reverting or cleaning unrelated dirty worktree changes.
- Altering encrypted course submission scripts.

## Acceptance Criteria

- [ ] `ann-final/report/main.tex` is a coherent final ANN comprehensive report,
      not a GPU-only report.
- [ ] A new final experiment is implemented under `ann-final/experiments/`,
      compiles locally when the C++ toolchain is available, and writes curated
      result artifacts under `ann-final/report/results/`.
- [ ] The report explicitly labels ordinary coursework content versus new
      final-project content and includes the new experiment as part of the
      final 20% contribution.
- [ ] The report covers SIMD, Pthread/OpenMP, MPI, and GPU with both algorithm
      design and experiment-analysis depth.
- [ ] Key tables/figures include dataset, platform, parameters, recall metric,
      latency unit, and source-result trace.
- [ ] The report contains profiling or low-level bottleneck analysis informed
      by existing VTune/perf/CUDA event/static-resource materials.
- [ ] The report respects the 30 counted-page limit as far as local PDF tooling
      can verify.
- [ ] Final validation includes LaTeX build or a documented reason build could
      not be completed.
- [ ] Existing unrelated worktree changes remain untouched.

## Open Questions

- Resolved: emphasize evidence-backed integrated analysis as the primary
  "new 20%" final-project contribution. New content should include the unified
  ANN system framework, cross-architecture comparison, pipeline figure,
  bottleneck attribution table, and previous-work vs new-content declaration.
  Additional small asset generation is acceptable only when it supports this
  integrated report, not as a risky late implementation detour.

## Notes

- Keep `prd.md` focused on requirements, constraints, and acceptance criteria.
- Lightweight tasks can remain PRD-only.
- For complex tasks, add `design.md` for technical design and `implement.md` for execution planning before `task.py start`.
