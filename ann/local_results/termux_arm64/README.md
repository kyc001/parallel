# Termux ARM64 Local Results

This directory stores analysis outputs generated on the local ARM AArch64
Termux tablet environment. These files are useful for the report, but they are
kept separate from portable source code so server runs do not overwrite them.

Contents include:

- `analyze_O*.s`: assembly generated with different optimization levels.
- `asm_analysis.txt`: extracted key function assembly.
- `neon_stats.txt`: NEON instruction count summary.
- `vec_report.txt`: GCC vectorization report.
- `autovec_analysis.txt`: scalar auto-vectorization inspection.
- `optlevel_perf.txt`: scalar vs SIMD microbenchmark results.
- `analyze_objdump.txt`: binary-level disassembly.
- `all_analysis_output.txt`: combined terminal output from the analysis script.

Regenerate with:

```bash
bash ann/analysis/run_asm_analysis.sh
```

The `bin/` subdirectory contains local executable artifacts and is intentionally
ignored by Git.
