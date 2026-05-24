# Plotting and Script Guidelines

## Python Plot Scripts

Plot scripts are small, direct generators rather than reusable packages. The
pattern in `OT-协程技术调研/plot_results.py` is representative:

- Import `matplotlib.pyplot`, `matplotlib`, `numpy`, and `os` as needed.
- Set Chinese-capable fonts with `matplotlib.rcParams['font.sans-serif']`.
- Set `axes.unicode_minus = False` for Chinese plots with negative values.
- Create the local `fig/` directory before saving.
- Use explicit labels, colors, units, and `plt.tight_layout()`.
- Save figures with stable filenames and close each figure.

Keep scripts runnable from their owning directory unless the task changes the
workflow. If a script uses relative output like `fig/io_throughput.png`, note
that in any automation that calls it from another working directory.

## Data Sources

This repo has both measured CSV/text outputs and small hard-coded plotting data
blocks. Hard-coded data is acceptable for one-off reports, but it must be
clearly tied to measured results in comments, as `OT-协程技术调研/plot_results.py`
does with dates and benchmark descriptions.

For larger or repeated experiments, prefer reading a result CSV and generating
plots from it, as done by report asset scripts under `ann-pthread-omp/scripts/`
and `ann-SIMD/report/fig/`.

## Visual Style

Use clear, publication-oriented charts:

- Label axes with units.
- Use readable figure sizes, commonly around `(8, 5)` or `(10, 5)`.
- Annotate bars or points when exact values are important for the report.
- Remove unnecessary top/right spines when the existing script style does so.
- Use log scales only when the comparison spans orders of magnitude and the
  axis label/title makes that clear.

Avoid decorative-only plots. Every figure should support a claim in the report
or slides.

## Script Output Messages

Print generated file paths at the end of scripts so the user can see what was
created. Keep these messages short and avoid dumping raw data unless the script
is specifically a summarizer.

## Cross-Platform Script Care

PowerShell and Bash scripts coexist. When adding automation:

- Use `.ps1` for Windows-specific tooling such as VTune or affinity masks.
- Use `.sh` for Linux/Kunpeng/qsub workflows.
- Keep commands relative to the lab directory.
- Avoid assuming WSL, MSYS2, oneAPI, or CUDA is installed unless the script name
  and comments make the dependency explicit.
