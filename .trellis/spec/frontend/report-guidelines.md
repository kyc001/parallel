# Report Guidelines

## LaTeX Report Pattern

LaTeX reports follow the course-template structure visible in
`lab0-并行体系结构调研/report/main.tex`:

- `\documentclass[a4paper]{article}`.
- Template inputs from `style/ch_xelatex.tex` and `style/scala.tex`.
- Chinese typesetting via `ctex`.
- Common packages such as `graphicx`, `booktabs`, `tikz`, `float`, `geometry`,
  `natbib`, and `fancyhdr`.
- A title page with `NKU.png`, course/lab metadata, author info, and date.
- Tables use `booktabs` (`\toprule`, `\midrule`, `\bottomrule`).
- Figures and tables carry `\caption{...}` and `\label{...}` for references.

When adding sections, keep the surrounding report's language and typography
style. Do not switch one report to a different template unless the task is a
template migration.

## Citations

Use the local bibliography file for each report:

- `reference.bib` in the lab report directories.
- `references.bib` in `OT-协程技术调研/`.

Add `\cite{...}` references for factual external claims, especially hardware
rankings, benchmark numbers from public sources, or architecture claims. Keep
the bibliography entry near related existing entries and preserve the report's
existing citation style.

## Figures

Prefer generated or measured figures over decorative images. Figures should:

- Live in the report's `fig/` directory.
- Be referenced with stable relative paths.
- Include a caption that explains what is measured and the platform or dataset
  when relevant.
- Use consistent units with the surrounding tables.

If a figure comes from a script, update the script and regenerate the figure
rather than editing the bitmap by hand.

## Tables and Experimental Claims

Tables often summarize measured performance, as in the ANN reports and Lab1
outputs. Keep tables tied to result files or documented handover data:

- Name the platform (`Windows 11 i9-13900H`, Kunpeng/AArch64, etc.).
- Name the dataset (`DEEP100K`, query count, `k=10`) when relevant.
- Separate latency and recall columns.
- Use the same unit label in text, table headers, and plot axes.

Avoid changing a report number without updating the source result artifact or
adding a note explaining why the number changed.

## Typst Slides

`OT-协程技术调研/slides.typ` is a Typst deliverable. Keep Typst-specific edits in
the `.typ` source and do not translate it into LaTeX unless the task asks for a
format conversion.

## Template Boundaries

Files under `参考模板/` are examples. Do not alter them while editing an active
lab report unless the task explicitly targets the template.
