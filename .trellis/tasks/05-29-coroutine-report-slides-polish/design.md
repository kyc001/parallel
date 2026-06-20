# Design: 优化协程调研报告与展示 slides

## Delivery Shape

Primary deliverable is `OT-协程技术调研/slides.typ`, generated as `slides.pdf`.
Secondary deliverable is `OT-协程技术调研/report.tex`, generated as `report.pdf`.

The design principle is "presentation first, report as backing material":
slides should carry the live 15-minute talk, while the report records the
deeper explanation and evidence that cannot fit on stage.

## Slides Narrative

Use a 5-part talk arc:

1. Opening thesis: 协程解决的是等待方式，不是 CPU 魔法
2. Why: 从进程、线程、事件循环到协程
3. What/How: 有栈与无栈，状态机与栈切换
4. Languages: Go/Java 有栈路线 vs C++/Python/C#/Rust 无栈路线
5. Evidence/Choice: 本机实验、坑、选型决策树

Target 16-19 pages:

- Cover and thesis page
- Agenda / route map
- 3-4 pages for evolution and mental model
- 4-5 pages for mechanisms and language comparison
- 4-5 pages for experiments and caveats
- 2-3 pages for selection, summary, AI use, references

## Visual System

- Keep Typst/touying as the slide engine.
- Prefer native Typst components and light custom helpers over external images for diagrams.
- Use a restrained academic-tech palette: deep navy/blue text, white background, cyan/green/orange accents for categories and warnings.
- Avoid dense all-text slides; convert repeated bullets into:
  - timeline rows
  - comparison cards
  - compact tables
  - callout strips
  - simple box-and-arrow diagrams
- Keep chart assets from `fig/` where they represent measured data.

## Report Design

Retain LaTeX `ctexart` because the current report already compiles with XeLaTeX.
Deepen the current report without changing its core data source:

- Update title-page author to 柯云超.
- Add a stronger introduction and contribution summary.
- Expand mechanism explanation with clearer stackful/stackless comparisons.
- Align section order with the slide talk arc.
- Improve experimental interpretation and caveats.
- Preserve bibliography build through `references.bib`.

## Compatibility

- Existing file paths and generated PDFs remain stable.
- No new package manager or build system is introduced.
- Typst imports should stay compatible with the currently installed `touying:0.6.1`.
- If a Typst drawing helper proves brittle, fall back to table/grid based diagrams.

## Validation Strategy

- Compile slides with `typst compile slides.typ slides.pdf`.
- Compile report with XeLaTeX + BibTeX + XeLaTeX passes.
- Render PDFs to PNG via `pdftoppm` and inspect representative pages visually.
- Use text extraction or quick grep/log checks for author, unresolved refs, warnings, and accidental placeholder text.

## Risks

- Typst slides can compile but still look crowded; mitigate by rendering and inspecting pages.
- Chinese font availability may vary; preserve the existing SimSun fallback.
- Some current table content is too wide for slides; convert wide comparisons into grouped cards.
