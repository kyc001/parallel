# Kunpeng Server Results

This directory contains the primary benchmark data collected on the Huawei Kunpeng 920 ARM AArch64 server.

- `baseline_flat.csv`: serial Flat and Flat-SIMD core comparison.
- `sq_simd.csv`: SQ-SIMD p sweep parsed from `result_sqsimd.txt`.
- `pq_simd.csv`: PQ-SIMD p sweep parsed from `result_pqsimd.txt`.
- `RESULTS.md`: human-readable summary with core comparison, p sweeps, and findings.

The raw root-level `result_*.txt` files were folded into these structured outputs and removed from the project root.
