# Presentation Directory Structure

## Report Locations

Reports live beside the lab or topic they document:

- `lab0-并行体系结构调研/report/` contains a LaTeX report with
  `main.tex`, `reference.bib`, `NKU.png`, `style/`, and `fig/`.
- `lab1-CPU架构编程/report/` follows the same LaTeX report shape.
- `ann-SIMD/report/` contains the SIMD lab report, references, styles, and
  generated figures.
- `ann-pthread-omp/report/` contains the Pthread/OpenMP ANN report.
- `OT-协程技术调研/` keeps both report and presentation files at topic root,
  including `main.tex`, `report.tex`, `slides.typ`, `references.bib`, and
  `fig/`.
- `参考模板/` contains source templates. Treat these as templates, not active
  reports.

Keep new report assets under the owning report directory unless they are shared
templates.

## Figure and Plot Assets

Figure directories are local to the document:

- `lab0-并行体系结构调研/report/fig/`
- `OT-协程技术调研/fig/`
- `ann-SIMD/report/fig/`
- `ann-pthread-omp/report/fig/`

Plot scripts should write into the figure directory consumed by the document.
For example, `OT-协程技术调研/plot_results.py` creates `fig/*.png` next to the
topic's report/slides.

## Bibliography and Style Files

LaTeX reports normally keep:

- `main.tex` as the primary source.
- `reference.bib` or `references.bib` for citations.
- `style/ch_xelatex.tex`, `style/scala.tex`, and related style inputs copied
  from the course template.
- `NKU.png` for the title-page logo.

Do not move style files unless all `\input{...}` paths are updated. Prefer
editing report content over changing copied template styles.

## Generated Documents

Generated PDFs such as `main.pdf`, `report.pdf`, and `slides.pdf` are checked
in for coursework deliverables. LaTeX intermediates (`*.aux`, `*.bbl`,
`*.blg`, `*.log`, etc.) are ignored and should not be committed.

When the task edits source and PDF together, verify that the PDF corresponds to
the source change. The current working tree already has edits in
`ann-pthread-omp/report/main.tex` and `main.pdf`; treat them as user work unless
the task explicitly asks to change that report.
