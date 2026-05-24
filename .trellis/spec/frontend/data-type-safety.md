# Data and Type Safety

## Units and Numeric Precision

Reports combine C++ benchmark outputs, Python plots, and LaTeX tables. Keep
numeric meaning stable across all three:

- ANN latency is usually microseconds per query; label it as `us`,
  `latency_us`, or `average latency (us)`.
- Recall is a fraction, usually printed to five decimal places for ANN runs.
- Lab profiling metrics need explicit units (`cycles`, `instructions`,
  `cache misses`, `ms`, `MB`).
- Do not mix total runtime and per-query/runtime-per-task values in one column.

When converting units for a plot or table, note the conversion in a code comment
or table caption.

## Dataset Dimensions

ANN reports and code assume DEEP100K dimensions are read from binary headers.
If a report states query count, base count, vector dimension, or `k`, verify it
against the benchmark code or result artifact. `ann-pthread-omp/main.cc`
explicitly limits queries to the first 2000 and uses `k = 10`; keep report
claims consistent with that behavior.

## Table Consistency

For performance tables:

- Keep platform labels exact enough to reproduce (`i9-13900H`, Kunpeng 920,
  AArch64/NEON, x86 AVX2).
- Use the same algorithm labels as code output, such as
  `ivfpq_local_pthread_dynamic_inter`.
- Include parameters that materially affect the result (`t`, `nlist`,
  `nprobe`, `p`, schedule/chunk, `ef`).

## Encoding

Some existing Chinese text displays as mojibake in the current terminal. Avoid
large mechanical rewrites of report prose for encoding cleanup during unrelated
tasks. When creating new files or new sections, use UTF-8 and keep command
names, paths, and numeric data ASCII where possible.

## Bibliographic Data

For external facts, prefer bibliography-backed claims over bare URLs in prose.
If using changing facts such as TOP500 rankings, include the concrete list date
in the report text and bibliography metadata.
