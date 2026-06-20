# Presentation Quality Guidelines

## Build or Syntax Check Edited Documents

When local tooling is available, rebuild edited deliverables:

- LaTeX reports generally need XeLaTeX; run BibTeX too when citations changed.
- Typst slides should be rebuilt from the `.typ` source when `slides.pdf`
  changes.
- Plot scripts should be rerun when a generated figure changes.

If the toolchain is unavailable, report exactly what was not run and why.

## Diff Checks With Generated PDFs

`git diff --check` is useful for text sources, but generated PDFs are binary
artifacts and can produce false-positive `trailing whitespace` reports from
compressed PDF bytes. For report/slide tasks:

- Run source-level whitespace checks on edited text files such as `.tex`,
  `.typ`, `.md`, `.py`, and `.bib`.
- Treat `git diff --check` findings inside `.pdf` files as binary false
  positives, then validate the PDF through rebuild and rendered-page inspection
  instead.
- Do not edit a generated PDF by hand to satisfy whitespace checks.

## Source/PDF Consistency

Because final PDFs are part of coursework deliverables, source and PDF should
match when both are edited. Do not regenerate a PDF for an unrelated dirty
source file. The current tree has user modifications in
`ann-pthread-omp/report/main.tex` and `ann-pthread-omp/report/main.pdf`; treat
those as existing work unless explicitly asked to edit that report.

## Beamer Slide Checks

When customizing Beamer section or cover frames on top of a stock theme such as
Madrid, inspect rendered PNGs rather than trusting source spacing alone. Default
headline/navigation templates can still appear on `plain`-looking section pages
and visually collide with custom top bars or large section numbers. For custom
section pages, locally clear `headline` or replace the section number with an
in-frame label, then rebuild twice so total page numbers and navigation files are
stable.

## Report Review Checklist

Before considering a report edit complete, check:

- Figures referenced in `\includegraphics` exist at the referenced path.
- `\label{...}` values are unique and referenced with the right type.
- Tables fit the page width and use consistent units.
- Bibliography keys used in `\cite{...}` exist in the local `.bib`.
- New claims about measured performance have a result file, code output, or
  explicit source.
- Generated figure filenames match the script outputs.
- When a report includes generated PDF/PNG figures, finish the plot-generation
  command before starting LaTeX. Do not run plotting and `latexmk` in parallel,
  because LaTeX can read a figure while the script is rewriting it and produce
  a transient missing/corrupt image error.

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
