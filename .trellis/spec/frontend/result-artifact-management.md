# Result Artifact Management

## Source of Truth

For reports, source of truth is usually a combination of:

- Measurement scripts and benchmark drivers.
- Curated `results/*.csv` or `.txt` summaries.
- Plot scripts that convert summaries into `fig/*.png` or `.pdf`.
- Report source files (`main.tex`, `report.tex`, `slides.typ`).
- Generated final PDFs for coursework submission.

Keep these artifacts aligned. If a report table changes because a benchmark was
rerun, update the corresponding result summary or add a note in the report
source/handover file.

## What to Commit

Commit:

- Report sources and bibliography files.
- Final PDFs when they are coursework deliverables.
- Curated CSV/text summaries that support report claims.
- Generated figures referenced by reports or slides.
- Small tests or scripts needed to reproduce a result.

Avoid committing:

- C/C++ build products.
- Raw profiler databases and temporary analysis directories.
- LaTeX intermediate files.
- Local one-off logs.
- Large data files already represented by `files/` or external cluster paths,
  unless the assignment requires them.

The existing `.gitignore` documents these boundaries.

## Naming Conventions

Use names that encode the experiment enough to remain understandable later:

- `local_summary.csv`, `local_best.csv`, and `local_best_by_granularity.csv`
  summarize local ANN runs.
- `stdthread_comparison.txt`, `omp_schedule_sweep.txt`, and
  `false_sharing.txt` name the experiment directly.
- Figure names such as `io_throughput.png` and `memory_usage.png` state the
  plotted metric.

Avoid generic names like `new_result.txt` or `plot1.png` in committed work.

## Handover Notes

`ann-pthread-omp/HANDOVER_LOCAL.md` is a real local context file for the ANN
parallelization work. When a task changes experiment status, toolchain limits,
or report reproduction instructions in that area, update the handover note
unless the user asks for a narrower change.

## Protect User Work

Generated PDFs and report sources may already be modified by the user. Check
`git status` before replacing them. If the source/PDF pair is dirty and the
task is unrelated, leave both untouched.
