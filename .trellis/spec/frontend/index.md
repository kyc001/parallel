# Presentation and Report Guidelines

> Project-specific guidance for the user-facing deliverables: reports, slides,
> figures, plotting scripts, and result artifacts.

This repository has no browser frontend or React-style component layer. The
generated `frontend/` spec folder is repurposed for presentation/report work,
because those are the visible outputs users inspect.

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | Report, slide, figure, and template layout | Filled |
| [Report Guidelines](./report-guidelines.md) | LaTeX/Typst structure, citations, tables, and figures | Filled |
| [Plotting and Script Guidelines](./plotting-and-script-guidelines.md) | Python plotting and visualization scripts | Filled |
| [Result Artifact Management](./result-artifact-management.md) | How measured data, summaries, figures, and PDFs relate | Filled |
| [Quality Guidelines](./quality-guidelines.md) | Build checks, visual checks, and report review expectations | Filled |
| [Data and Type Safety](./data-type-safety.md) | Numeric precision, units, encodings, and table consistency | Filled |

## Pre-Development Checklist

- Identify the owning deliverable before editing: `report/main.tex`,
  `main.tex`, `report.tex`, `slides.typ`, plot scripts, or result CSVs.
- Check whether figures are generated from scripts or hand-authored before
  editing image files directly.
- Preserve relative paths to `style/`, `fig/`, `reference.bib`, and `NKU.png`
  assets.
- When changing cited claims, update the relevant `.bib` file or cite an
  existing entry already used by the document.
- Rebuild or at least syntax-check the edited document whenever the local
  toolchain is available.
