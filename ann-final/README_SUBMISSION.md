# ANN Final Submission Notes

This directory contains the final integrated ANN coursework report and the new experiment runners.

## Main Deliverable

- Report PDF: `report/main.pdf`
- Report source: `report/main.tex`
- New experiment code:
  - `experiments/adaptive_ivfpq.cc`
  - `experiments/opq_ivfpq.cc`
  - `experiments/gpu_hybrid.cu`
- New result CSVs:
  - `report/results/adaptive_ivfpq_20260630.csv`
  - `report/results/opq_ivfpq.csv`
  - `report/results/opq_ivfpq_m_sweep.csv`
  - `report/results/gpu_hybrid.csv`
- Figure generator: `report/gen_final_figs.py`

## Platform

- CPU: 13th Gen Intel Core i9-13900H, AVX2/FMA
- GPU: NVIDIA GeForce RTX 4060 Laptop GPU
- CUDA: nvcc 12.4 + cuBLAS
- Python: `micromamba run -n test python`
- Dataset: DEEP100K under `../files` or `files` when running from the paths below

## Build

```powershell
cd ann-final\experiments
.\build_windows.ps1
```

## Reproduce New Experiments

```powershell
.\build\adaptive_ivfpq.exe 2000 8 ..\report\results

.\build\opq_ivfpq.exe --query_n=2000 --m=8 `
  --nprobe=2,4,8 --rerank_p=500,1000,1500 `
  --out=..\report\results\opq_ivfpq.csv

.\build\opq_ivfpq.exe --query_n=2000 --m=12,16 `
  --nprobe=4,8 --rerank_p=1000,1500 `
  --out=..\report\results\opq_ivfpq_m_sweep.csv

.\build\gpu_hybrid.exe --query_n=1,128,512,2000 `
  --candidate_p=100,300,500,1000 --chunk=64 `
  --out=..\report\results\gpu_hybrid.csv
```

## Regenerate Figures And PDF

```powershell
cd ..\report
.\run_figs.ps1
latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex
```
