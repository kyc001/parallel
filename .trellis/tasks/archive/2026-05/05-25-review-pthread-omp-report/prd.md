# Review pthread-omp report

## Goal

Review ann-pthread-omp report for data, logic, caption, and formatting issues without modifying unrelated files.

## Requirements

- Review `ann-pthread-omp/report/main.tex` and the rendered `main.pdf`.
- Cross-check report claims against available CSV results and figure-generation scripts when possible.
- Prioritize hard issues: inconsistent numeric claims, wrong captions, missing plotted series, stale wording, table/figure mismatches, and LaTeX/PDF formatting defects.
- Apply the user-approved fixes for the confirmed report issues.
- Include lower-risk polish issues only after hard issues.
- Do not modify unrelated files or regenerate unrelated artifacts during the review.

## Acceptance Criteria

- [ ] Findings are ordered by severity and include concrete section/table/figure references.
- [ ] Each numeric or plotting concern is backed by source evidence from TeX, CSV, generated PDF text, or scripts.
- [ ] The response clearly separates must-fix issues from optional wording/polish suggestions.
- [ ] The approved fixes are reflected in `ann-pthread-omp/report/main.tex` and rebuilt into `main.pdf`.
- [ ] If no issue is found in an area, the remaining residual risk is stated briefly.

## Notes

- Keep `prd.md` focused on requirements, constraints, and acceptance criteria.
- Lightweight tasks can remain PRD-only.
- For complex tasks, add `design.md` for technical design and `implement.md` for execution planning before `task.py start`.
