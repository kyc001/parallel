# Implement: 优化协程调研报告与展示 slides

## Checklist

- [x] Review current PDFs visually to identify the worst layout issues.
- [x] Rewrite `slides.typ` around the 5-part talk arc.
- [x] Add reusable Typst helpers for title chips, callouts, cards, timelines, and simple diagrams.
- [x] Replace dense slide tables/bullets with diagrams and compact comparisons.
- [x] Update author/date/institution metadata and AI use wording.
- [x] Deepen `report.tex` introduction, mechanism, language comparison, experiments, limitations, and conclusion.
- [x] Update author fields in `report.tex`.
- [x] Rebuild `slides.pdf`.
- [x] Rebuild `report.pdf`.
- [x] Render representative PDF pages to PNG and inspect for layout defects.
- [x] Run final git/status and artifact sanity checks.

## Validation Commands

From `OT-协程技术调研/`:

```powershell
typst compile slides.typ slides.pdf
xelatex -interaction=nonstopmode -halt-on-error report.tex
bibtex report
xelatex -interaction=nonstopmode -halt-on-error report.tex
xelatex -interaction=nonstopmode -halt-on-error report.tex
pdftoppm -png slides.pdf tmp_render/slides
pdftoppm -png report.pdf tmp_render/report
```

## Rollback Points

- `slides.typ` is the highest-risk file; keep changes self-contained and rebuild after major restructuring.
- `report.tex` can be reverted independently if slide work succeeds but report changes introduce LaTeX issues.
- Generated PDFs should only be considered final after their source rebuild succeeds.

## Review Gates

- Before implementation: user approves the visual direction and this plan.
- Before completion: latest PDFs compile and representative rendered pages look clean.
