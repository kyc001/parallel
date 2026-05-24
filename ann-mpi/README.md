# ANN MPI Lab

This directory is the MPI version of the ANN coursework experiment.

## Entry Points

- `main.cc`: MPI + OpenMP ANN submission entry.
- `Makefile`: builds the server MPI binary with `mpic++`; `make local` builds
  a no-MPI fallback for local smoke tests.
- `qsub_mpi.sh`: PBS submission script required by the MPI guide.

Old copied `test.sh`, `qsub.sh`, report outputs, profiling outputs, and build
artifacts were removed because this lab is submitted manually with `mpic++` and
`qsub_mpi.sh`.

## Algorithms

Default IVF-PQ mode:

```bash
./main <threads> <nlist> <nprobe> <rerank_p> <query_n> local
```

Block HNSW mode:

```bash
./main <threads> <hnsw_m> <ef> <unused_p> <query_n> hnsw
```

IVF + HNSW nested mode:

```bash
./main <threads> <nlist> <nprobe> <ef> <query_n> ivf-hnsw
```

HNSW-on-HNSW mode:

```bash
./main <threads> <nblocks> <nprobe_blocks> <ef> <query_n> hnsw-on-hnsw
```

All modes partition base vectors across MPI ranks, broadcast queries, search
locally, gather local top-k candidates, and merge final top-k results on rank 0.

## Local Validation

PowerShell:

```powershell
cd D:\Study\26sp\parallel\ann-mpi
.\scripts\run_local_cross_platform.ps1
```

## Kunpeng Server

```bash
cd ~/ann-mpi
make clean
make
ANN_DATA_PATH=/anndata /usr/local/bin/mpiexec -np 2 ./main 2 16 4 1000 200 local
ANN_DATA_PATH=/anndata /usr/local/bin/mpiexec -np 2 ./main 2 16 50 1000 200 hnsw
ANN_DATA_PATH=/anndata /usr/local/bin/mpiexec -np 2 ./main 2 16 4 50 200 ivf-hnsw
ANN_DATA_PATH=/anndata /usr/local/bin/mpiexec -np 2 ./main 2 16 16 50 200 hnsw-on-hnsw
NP=2 OMP_NUM_THREADS=2 QUERY_N=200 scripts/run_kunpeng_smoke.sh
NP=2 OMP_NUM_THREADS=2 QUERY_N=200 scripts/submit_kunpeng_pbs_smoke.sh
```

The program also falls back to `files/` when `ANN_DATA_PATH` is unset, matching
the course script convention.

## Result Records

Save command transcripts under `results/`. Useful fields printed by `main.cc`:

- `average recall`
- `average latency (us)`
- `max local search latency (us)`
- `comm+merge latency (us)`

The same cross-platform experiment uses `np=2`, `threads=2`, `query_n=200`,
IVF-PQ `(nlist=16,nprobe=4,p=1000)`, block-HNSW `(m=16,ef=50)`, and
IVF+HNSW nested `(nlist=16,nprobe=4,m=16,ef=50)`, and HNSW-on-HNSW
`(nblocks=16,nprobe_blocks=16,m=16,ef=50)`.
The comparison table is saved in `results/cross_platform_summary.txt`; the
assignment-by-assignment evidence checklist is saved in
`results/full_score_checklist.md`.
