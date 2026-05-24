# Implementation Plan

## Checklist

- [x] Confirm local MSYS2 C++ compiler availability.
- [x] Install/confirm local MS-MPI SDK/runtime.
- [x] Confirm Kunpeng SSH access through jump host.
- [x] Replace copied Pthread/OpenMP `main.cc` with MPI + OpenMP ANN entry.
- [x] Add `qsub_mpi.sh` for PBS MPI submission.
- [x] Clean copied intermediate/generated directories.
- [x] Rebuild local no-MPI fallback.
- [x] Rebuild local MPI binary.
- [x] Run local IVF-PQ MPI smoke.
- [x] Run local block-HNSW MPI smoke.
- [x] Sync clean `ann-mpi/` source to the Kunpeng server.
- [x] Build with `mpic++` on Kunpeng.
- [x] Run direct and PBS MPI validation on Kunpeng.
- [x] Save local and server results under `ann-mpi/results/`.
- [x] Run the same IVF-PQ and block-HNSW parameter set on Windows local and
      Kunpeng for cross-platform comparison.

## Result Records

- `ann-mpi/results/local_smoke.txt`: local no-MPI build, local MPI build,
  IVF-PQ MPI smoke, and block-HNSW MPI smoke. Observed MPI IVF-PQ Recall@10
  `0.85000`, latency `233.82500 us`; block-HNSW Recall@10 `0.90500`,
  latency `108.00500 us`.
- `ann-mpi/results/kunpeng_smoke.txt`: direct Kunpeng `mpic++` build and
  `mpiexec -np 2` smoke runs. Observed IVF-PQ Recall@10 `0.95650`, latency
  `411.59749 us`; block-HNSW Recall@10 `1.00000`, latency `264.42528 us`.
- `ann-mpi/results/kunpeng_pbs_smoke.txt`: PBS smoke job
  `26848.master_ubss1`, submitted with
  `qsub -v NP=2,OMP_NUM_THREADS=2,QUERY_N=200,NLIST=16,NPROBE=4,RERANK_P=1000,HNSW_M=16,HNSW_EF=50 qsub_mpi.sh`.
  Observed IVF-PQ Recall@10 `0.95650`, latency `702.38233 us`; block-HNSW
  Recall@10 `1.00000`, latency `259.40418 us`.
- `ann-mpi/results/local_cross_platform.txt`: Windows local MS-MPI run with
  the same `np=2`, `threads=2`, `query_n=200`, IVF-PQ, and block-HNSW
  parameters used on Kunpeng. Observed IVF-PQ Recall@10 `0.95650`, latency
  `248.07400 us`; block-HNSW Recall@10 `1.00000`, latency `137.30300 us`.
- `ann-mpi/results/cross_platform_summary.txt`: one-table comparison of
  Windows local, Kunpeng direct `mpiexec`, and Kunpeng PBS `qsub` runs.

## Local Validation Commands

```powershell
cd D:\Study\26sp\parallel\ann-mpi
$env:ANN_DATA_PATH='D:\Study\26sp\parallel\files'
New-Item -ItemType Directory -Force build | Out-Null
g++ main.cc -o build/main_no_mpi.exe -O2 -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma -DANN_NO_MPI
mpic++ main.cc -o build/main_mpi_compile.exe -O2 -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma
& 'C:\Program Files\Microsoft MPI\Bin\mpiexec.exe' -n 2 .\build\main_mpi_compile.exe 1 4 2 100 20 local
& 'C:\Program Files\Microsoft MPI\Bin\mpiexec.exe' -n 2 .\build\main_mpi_compile.exe 1 8 20 100 20 hnsw
.\scripts\run_local_cross_platform.ps1
```

## Server Validation Commands

```bash
cd /home/s2413575/ann-mpi
make clean
make
ANN_DATA_PATH=/anndata /usr/local/bin/mpiexec -np 2 ./main 2 16 4 1000 200 local
ANN_DATA_PATH=/anndata /usr/local/bin/mpiexec -np 2 ./main 2 16 50 1000 200 hnsw
NP=2 OMP_NUM_THREADS=2 QUERY_N=200 scripts/run_kunpeng_smoke.sh
NP=2 OMP_NUM_THREADS=2 QUERY_N=200 scripts/submit_kunpeng_pbs_smoke.sh
```

## Remote Access Command Shape

```bash
sshpass -p s2413575 ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o 'ProxyCommand=sshpass -p s2413575 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 9001 -W %h:%p s2413575@10.137.144.91' \
  s2413575@192.168.90.141 'hostname; pwd; uname -m'
```

Confirmed output on 2026-05-25:

```text
master_ubss1
/home/s2413575
aarch64
```
