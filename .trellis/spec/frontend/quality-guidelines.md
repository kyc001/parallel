# Presentation Quality Guidelines

## Build or Syntax Check Edited Documents

When local tooling is available, rebuild edited deliverables:

- LaTeX reports generally need XeLaTeX; run BibTeX too when citations changed.
- Typst slides should be rebuilt from the `.typ` source when `slides.pdf`
  changes.
- Plot scripts should be rerun when a generated figure changes.

If the toolchain is unavailable, report exactly what was not run and why.

## Source/PDF Consistency

Because final PDFs are part of coursework deliverables, source and PDF should
match when both are edited. Do not regenerate a PDF for an unrelated dirty
source file. The current tree has user modifications in
`ann-pthread-omp/report/main.tex` and `ann-pthread-omp/report/main.pdf`; treat
those as existing work unless explicitly asked to edit that report.

## Report Review Checklist

Before considering a report edit complete, check:

- Figures referenced in `\includegraphics` exist at the referenced path.
- `\label{...}` values are unique and referenced with the right type.
- Tables fit the page width and use consistent units.
- Bibliography keys used in `\cite{...}` exist in the local `.bib`.
- New claims about measured performance have a result file, code output, or
  explicit source.
- Generated figure filenames match the script outputs.

## Plot Review Checklist

For plot/script changes, check:

- The script creates its output directory.
- Axes include units.
- Hard-coded data includes a comment tying it to a measured run or source.
- Fonts support Chinese labels when Chinese text is present.
- Figures are closed after saving to avoid cross-figure state leaks.

## Avoid These Patterns

- Do not edit generated PDFs without updating the source when the source is
  available.
- Do not change result tables based on memory alone; trace the number to a
  result file or rerun.
- Do not use decorative figures that do not support a report claim.
- Do not commit LaTeX intermediates or profiler databases.
- Do not rewrite template files under `参考模板/` while working on an active lab
  report.
