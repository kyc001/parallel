# Logging and Output Guidelines

## Console Output Is Part of the Experiment Contract

Most runnable code is benchmark code, so console output doubles as machine- or
human-readable experiment evidence. Preserve the stable fields already used by
drivers and scripts:

- Variant label, for example `ivfpq_local_pthread_dynamic_inter`.
- Thread count as `nthreads=<value>`.
- Algorithm parameters such as `nlist`, `nprobe`, `p`, `mode`, or schedule.
- `average recall: <value>`.
- `average latency (us): <value>`.

`ann-pthread-omp/main.cc` and `ann-pthread-omp/mains/flat_bench_common.h` are
the reference style.

## Precision and Units

Use fixed precision where comparisons go into tables:

- ANN drivers print floating values with `std::fixed << std::setprecision(5)`.
- Latency is normally microseconds per query for ANN search.
- Lab1 profiling outputs use explicit CSV/result labels under `results/`.

Always include units in result labels or column names (`latency_us`, `ms`,
`MB`, `cycles`, `instructions`). Avoid mixing total runtime and per-query
runtime under the same field name.

## Result Files

When writing text or CSV summaries:

- Put them under the owning lab's `results/` or `bench_results/` directory.
- Include enough parameters to reproduce the run.
- Keep filenames specific, as in
  `ann-pthread-omp/results/stdthread_comparison.txt` and
  `ann-pthread-omp/results/omp_schedule_sweep.txt`.
- For plot generators, write figures into the local `fig/` or `report/fig/`
  directory expected by the corresponding document source.

## Diagnostics

Diagnostics should go to stderr in C++ when they indicate a failed run. Normal
benchmark summaries should go to stdout so scripts can capture them.

For scripts, plain progress messages are acceptable, but keep final summaries
structured enough to paste into reports or parse into CSV. Avoid verbose
per-item logs inside hot benchmark loops.

## Encoding Note

Several older README/report files show mojibake when read in the current
terminal, but source paths, command names, and result fields are still usable.
When editing documentation, keep new English spec text in UTF-8 and avoid
rewriting unrelated Chinese report content just to normalize encoding.
