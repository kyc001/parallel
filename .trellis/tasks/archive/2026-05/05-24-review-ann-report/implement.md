# Implementation Notes

## Completed Work

- Created `ann-mpi/report/main.tex` using the same broad LaTeX style as the
  previous ANN SIMD and Pthread/OpenMP reports.
- Copied the shared `NKU.png` title-page asset into `ann-mpi/report/`.
- Generated `ann-mpi/report/main.pdf`.
- Kept the report focused on MPI-specific requirements instead of repeating
  all SIMD/Pthread background:
  - MPI base partitioning and load-balance logic.
  - Query broadcast, local search, candidate gather, and rank-0 top-k merge.
  - MPI + OpenMP hybrid boundary.
  - IVF-PQ, block-HNSW, IVF+HNSW, and HNSW-on-HNSW modes.
  - Windows, Kunpeng direct, and Kunpeng PBS measured results.
  - Communication/merge overhead and recall-latency trade-off analysis.

## Validation

- Built with:
  `latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex`
- Checked page count with `pdfinfo`: 11 pages, under the current 30-page limit.
- Checked LaTeX log for `Overfull`, `Undefined`, and error patterns. No
  overfull boxes or undefined references remain.
- Rendered pages with `pdftoppm` and visually inspected title page, main
  structure/results pages, reproducibility/results pages, and final reference
  page.
- Extracted text with `pdftotext -layout` and confirmed Chinese title,
  abstract, result table, full-score section, and conclusion are readable.
