# Implementation Plan

## Checklist

- [x] Add IVF+HNSW nested mode to `main.cc`.
- [x] Add HNSW-on-HNSW mode to cover graph-index option C.
- [x] Update PBS and reproducibility scripts to run all four modes.
- [x] Add full-score requirement-to-evidence checklist.
- [x] Compile locally in no-MPI and MPI modes.
- [x] Run local four-mode cross-platform validation.
- [x] Sync and run Kunpeng direct four-mode smoke.
- [x] Sync and run Kunpeng PBS four-mode smoke.
- [x] Clean generated `build/` artifacts.
- [x] Run final diff/status checks.

## Result Records

- Local: `ann-mpi/results/local_cross_platform.txt`
  - `ivfpq_local_mpi_omp_inter`, Recall@10 `0.95650`, latency `229.98250 us`.
  - `block_hnsw_mpi_omp_multi_entry`, Recall@10 `1.00000`, latency `269.52450 us`.
  - `ivf_hnsw_nested_mpi_omp`, Recall@10 `0.95400`, latency `154.56800 us`.
  - `hnsw_on_hnsw_mpi_omp`, Recall@10 `1.00000`, latency `461.18750 us`.
- Kunpeng direct: `ann-mpi/results/kunpeng_smoke.txt`
  - `ivfpq_local_mpi_omp_inter`, Recall@10 `0.95650`, latency `360.83221 us`.
  - `block_hnsw_mpi_omp_multi_entry`, Recall@10 `1.00000`, latency `277.39286 us`.
  - `ivf_hnsw_nested_mpi_omp`, Recall@10 `0.95400`, latency `567.97028 us`.
  - `hnsw_on_hnsw_mpi_omp`, Recall@10 `1.00000`, latency `1851.95684 us`.
- Kunpeng PBS: `ann-mpi/results/kunpeng_pbs_smoke.txt`
  - job `26866.master_ubss1`.
  - `ivfpq_local_mpi_omp_inter`, Recall@10 `0.95650`, latency `438.50303 us`.
  - `block_hnsw_mpi_omp_multi_entry`, Recall@10 `1.00000`, latency `260.82397 us`.
  - `ivf_hnsw_nested_mpi_omp`, Recall@10 `0.95400`, latency `512.36391 us`.
  - `hnsw_on_hnsw_mpi_omp`, Recall@10 `1.00000`, latency `1741.80984 us`.
- Summary table: `ann-mpi/results/cross_platform_summary.txt`.
- Full-score checklist: `ann-mpi/results/full_score_checklist.md`.

## Validation Commands

```powershell
cd D:\Study\26sp\parallel\ann-mpi
$env:ANN_DATA_PATH='D:\Study\26sp\parallel\files'
.\scripts\run_local_cross_platform.ps1
```

```bash
cd ~/ann-mpi
NP=2 THREADS=2 QUERY_N=200 HNSW_ON_HNSW_NPROBE=16 scripts/run_kunpeng_smoke.sh
NP=2 OMP_NUM_THREADS=2 QUERY_N=200 HNSW_ON_HNSW_NPROBE=16 scripts/submit_kunpeng_pbs_smoke.sh
```

## Risk Notes

- HNSW-on-HNSW with `nprobe_blocks=16` gives Recall@10 `1.00000`, but it is
  slower, especially on Kunpeng. Use it as option C and recall-latency
  trade-off evidence, not as the fastest path.
- Keep old validated IVF-PQ and block-HNSW behavior unchanged.
