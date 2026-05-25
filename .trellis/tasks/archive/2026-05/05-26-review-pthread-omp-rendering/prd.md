# Deep review pthread-omp report rendering

## Goal

Deeply review ann-pthread-omp report for data logic, PDF rendering, formula/symbol issues, and visible LaTeX escape artifacts such as backslash underscores.

## Requirements

- Review `ann-pthread-omp/report/main.tex`, generated figures, and rendered `ann-pthread-omp/report/main.pdf`.
- Search for visible LaTeX escape artifacts in the PDF text, especially `\_`, backslashes before symbols, broken code identifiers, and formula fragments that should be rendered as math or monospace text.
- Inspect key rendered PDF pages visually for formula, symbol, table, caption, and layout issues, including overfull lines, clipped code/table cells, and awkward page breaks.
- Re-check high-risk data logic from the previous review: speedup denominators, IVF-PQ inter/intra plots, table 21 speedups, assembly snippets, and cross-platform figure/table wording.
- Apply fixes directly to `main.tex` and/or report asset scripts/figures when issues are confirmed.
- Rebuild `main.pdf` after fixes and verify the final PDF text/rendering.
- Do not modify unrelated OT, MPI, or workspace WIP files.

## Acceptance Criteria

- [x] PDF text extraction no longer shows unintended `\_` artifacts in prose/captions/table labels where plain code-style underscores should appear.
- [x] Formula and symbol rendering is checked for obvious broken tokens, missing math mode, bad microsecond notation, and malformed references.
- [x] Figures/tables involved in prior fixes still render correctly, including IVF-PQ in mechanism plots and table 21 labels/speedup notes.
- [x] LaTeX build completes successfully with `latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex`.
- [x] Key pages are rendered to images and visually inspected for clipping/overlap/awkward escapes.
- [x] Remaining warnings or residual risks are summarized clearly.

## Notes

- Keep `prd.md` focused on requirements, constraints, and acceptance criteria.
- Lightweight tasks can remain PRD-only.
- For complex tasks, add `design.md` for technical design and `implement.md` for execution planning before `task.py start`.
