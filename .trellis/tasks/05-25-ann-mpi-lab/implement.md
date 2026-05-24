# Implementation Plan

## Checklist

- [x] Confirm local MSYS2 C++ compiler availability.
- [x] Install/confirm local MS-MPI SDK/runtime.
- [x] Confirm Kunpeng SSH access through jump host.
- [x] Replace copied Pthread/OpenMP `main.cc` with MPI + OpenMP ANN entry.
- [x] Add `qsub_mpi.sh` for PBS MPI submission.
- [ ] Clean copied intermediate/generated directories.
- [ ] Rebuild local no-MPI fallback.
- [ ] Rebuild local MPI binary.
- [ ] Run local IVF-PQ MPI smoke.
- [ ] Run local block-HNSW MPI smoke.
- [ ] Sync clean `ann-mpi/` source to the Kunpeng server.
- [ ] Build with `mpic++` on Kunpeng.
- [ ] Run direct or PBS MPI validation on Kunpeng.
- [ ] Save local and server results under `ann-mpi/results/`.

## Local Validation Commands

```powershell
cd D:\Study\26sp\parallel\ann-mpi
$env:ANN_DATA_PATH='D:\Study\26sp\parallel\files'
g++ main.cc -o build/main_no_mpi.exe -O2 -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma -DANN_NO_MPI
mpic++ main.cc -o build/main_mpi_compile.exe -O2 -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma
& 'C:\Program Files\Microsoft MPI\Bin\mpiexec.exe' -n 2 .\build\main_mpi_compile.exe 1 4 2 100 20 local
& 'C:\Program Files\Microsoft MPI\Bin\mpiexec.exe' -n 2 .\build\main_mpi_compile.exe 1 8 20 100 20 hnsw
```

## Server Validation Commands

```bash
cd /home/s2413575/ann-mpi
make clean
make
ANN_DATA_PATH=/anndata /usr/local/bin/mpiexec -np 2 ./main 2 16 4 1000 200 local
ANN_DATA_PATH=/anndata /usr/local/bin/mpiexec -np 2 ./main 2 16 50 1000 200 hnsw
qsub qsub_mpi.sh
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
