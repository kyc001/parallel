# Design: ANN Final Comprehensive Report

## Deliverable Boundary

The implementation target is the final-coursework report under
`ann-final/report/`, with `main.tex` as the primary source and `main.pdf` as the
coursework PDF deliverable when the LaTeX toolchain is available.

The report should be a new integrated ANN research report. It may reuse stable
text, figures, and measured results from earlier labs, but the organization and
argument must be rebuilt around the final assignment: one ANN system, multiple
parallel architectures, and a clear distinction between semester coursework and
new final-project content.

## Report Architecture

Use a structure that makes fusion visible:

1. Title page, table of contents, and abstract.
2. Problem definition and evaluation method:
   ANN / ANNS definition, DEEP100K, `Recall@10`, latency in us/query, online vs
   wall-clock timing where applicable.
3. Integrated ANN system view:
   offline preprocessing/index construction, online query path, distance
   computation, candidate reduction, Top-k merge, recall evaluation.
4. Algorithm and architecture design:
   - SIMD: Flat, SQ, PQ, FastScan; vector width, memory layout, Top-k branch.
   - Pthread/OpenMP: inter-query vs intra-query, scheduling, thread pools,
     IVF/IVF-PQ/HNSW.
   - MPI: data partitioning, local search, global merge, hybrid MPI+OpenMP,
     blocking vs non-blocking communication.
   - GPU: batch GEMM/cuBLAS, device Top-k, grouped-IVF, data-transfer timing.
5. Unified experiment matrix:
   platforms, compilers, dataset, query count, parameters, and source result
   files.
6. Cross-architecture results:
   compare recall-latency trade-offs and explain why each architecture wins or
   loses for specific ANN subproblems.
7. Profiling and bottleneck synthesis:
   use VTune/perf/CUDA event/static-resource evidence to connect bottlenecks to
   memory bandwidth, SIMD utilization, synchronization, graph traversal,
   communication, and Top-k merge.
8. New-content declaration:
   a table mapping previous coursework work vs final-project additions.
9. Conclusion and future work.
10. References and AI usage report outside the counted body pages.

## Evidence Sources

Use measured artifacts already present in the repository unless a required
claim lacks support.

| Area | Primary evidence |
|---|---|
| SIMD | `ann-SIMD/report/main.tex`, `ann-SIMD/bench_results/windows_i9_13900h/RESULTS.md`, `ann-SIMD/bench_results/kunpeng_server/RESULTS.md`, `ann-SIMD/bench_results/windows_i9_13900h/full_score/*.csv`, `ann-SIMD/report/fig/*.png` |
| Pthread/OpenMP | `ann-pthread-omp/report/main.tex`, `ann-pthread-omp/results/local_summary.csv`, `local_best.csv`, `local_best_by_granularity.csv`, `local_hnsw_best.csv`, `omp_schedule_sweep.txt`, `false_sharing.txt`, `ann-pthread-omp/report/fig/*.pdf` |
| MPI | `ann-mpi/report/main.tex`, `ann-mpi/results/cross_platform_summary.txt`, `parameter_sweep_*.csv`, `scalability_*.csv`, `blocking_vs_nonblocking_summary.md`, `vtune_notes.md`, `ann-mpi/report/fig/*.pdf` |
| GPU | `ann-gpu/report/main.tex`, `ann-gpu/report/results/gpu_variants_repeat_20260620_summary.csv`, `cuobjdump_resource.txt`, `main_sm89.ptx`, `ann-gpu/report/fig/*.png` |
| Profiling style | `lab1-CPU架构编程/report/main.tex`, `lab1-CPU架构编程/results/`, and the ANN VTune/CUDA evidence above |
| Reference report | `ann-final/并行第六次作业参考.pdf` for a coverage checklist and examples of algorithm-family exposition |

## New Final-Project Content

The final contribution must include one new reproducible experiment, plus the
integrated synthesis layer that makes the old and new work read as one system.

Primary experiment: adaptive IVF-PQ search budget. Reuse the existing
`ann-pthread-omp` IVF-PQ index and scan/rerank helpers, but add a final-specific
driver under `ann-final/experiments/`. The driver computes each query's distance
margin between its nearest and second-nearest IVF centroids. Queries with small
margins are treated as ambiguous and get a larger `nprobe`/rerank budget; clear
queries get a smaller budget. The experiment compares this adaptive policy with
fixed-budget IVF-PQ baselines using the same DEEP100K, `Recall@10`, and
microseconds-per-query metrics used in earlier labs.

KD-tree is not the main experiment. It can be mentioned as an explored but
rejected option because 96-dimensional ANN data weakens KD-tree pruning and the
tree traversal pattern is less aligned with the repository's SIMD, MPI, and GPU
fusion story than IVF-PQ/HNSW.

The report-level synthesis remains substantive and clearly marked:

- A unified taxonomy of ANN acceleration levers:
  "faster distance" vs "fewer candidates" vs "more queries at once" vs
  "distributed partition and merge".
- An end-to-end ANN pipeline figure that places SIMD, OpenMP/Pthread, MPI, and
  GPU at different pipeline stages.
- A consolidated recall-latency table across the four architecture families
  using representative result rows.
- A cross-architecture bottleneck table:
  DRAM-bound flat scan, SIMD-friendly quantization, inter-query multi-core
  scaling, MPI compute dominance, graph traversal synchronization, GPU Top-k
  and candidate organization.
- A "coursework vs new content" table with page/section references.
- A new-experiment table showing fixed low/medium/high budgets versus the
  adaptive policy, including policy query counts and recall/latency.

This approach satisfies the requirement that the report is fused and newly
planned. It avoids over-claiming a new algorithm without enough time or cluster
access, while still adding high-value analysis not present in any single
previous report.

## Reference Report Takeaways

The senior reference report is useful for checking that common ANN method
families are not omitted: HNSW, KD-Tree, IVF, PQ, ScaNN, LSH, IVF+PQ, and
IVF+HNSW. It also demonstrates that concise pseudocode blocks can make index
construction and query flow easier to read.

Do not copy its organization directly. It spends most body pages on algorithm
families before introducing parallel acceleration, while this final report must
foreground the fusion of SIMD, multi-core, MPI, and GPU experiments. Also avoid
visible hyperlink/reference boxes in the PDF; configure `hyperref` so links are
black and borderless.

## Data and Figure Flow

- Copy or reference existing stable figures into `ann-final/report/fig/` only
  when the final report uses them.
- Prefer generating final-specific consolidated charts from CSV/text summaries
  through a small script under `ann-final/report/` if time permits.
- Keep tables close to their source files by naming result artifacts in captions
  or nearby prose.
- Do not edit old report PDFs or figures as source of truth.

## Compatibility and Validation

- Preserve the existing LaTeX style where possible: Chinese `ctexart`,
  `booktabs`, `graphicx`, `hyperref`, and compact tables.
- Use XeLaTeX / latexmk if installed:
  `latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex`.
- Validate page count with `pdfinfo` if available. Remember that cover, table
  of contents, references, and AI usage report do not count toward the 30-page
  body limit.
- Search the log for `LaTeX Error`, missing figures, `Undefined`, and overfull
  boxes after compiling.

## Risks

- The current `ann-final/report/main.tex` is GPU-specific, so small edits would
  leave the final report structurally wrong. It should be replaced or heavily
  rewritten.
- Existing working-tree changes include unrelated user edits/deletions; avoid
  broad cleanup.
- Some paths and Chinese filenames may display as mojibake in PowerShell.
  Prefer exact paths already known and avoid mechanical encoding rewrites.
- Result values from different labs may use slightly different hardware and
  timing definitions. The final report must compare them with explicit
  platform and timing labels rather than pretending they are one controlled
  benchmark.
