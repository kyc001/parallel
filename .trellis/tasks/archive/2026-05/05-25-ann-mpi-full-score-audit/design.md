# Design

## Scope

This is a focused reinforcement pass over `ann-mpi/`, not a rewrite of the
previously completed MPI lab. The existing IVF-PQ and block-HNSW modes remain
the baseline. The new work adds IVF+HNSW nested and HNSW-on-HNSW graph modes,
plus a report-ready full-score evidence checklist.

## Algorithm Modes

- IVF-PQ mode:
  `./main <threads> <nlist> <nprobe> <rerank_p> <query_n> local`
- Block-HNSW mode:
  `./main <threads> <hnsw_m> <ef> <unused_p> <query_n> hnsw`
- IVF+HNSW nested mode:
  `./main <threads> <nlist> <nprobe> <ef> <query_n> ivf-hnsw`
- HNSW-on-HNSW mode:
  `./main <threads> <nblocks> <nprobe_blocks> <ef> <query_n> hnsw-on-hnsw`

The nested mode reuses `hnsw/hnsw_ivf_nested.h`: each MPI rank builds an IVF
over its local shard, then builds a HNSW index inside each non-empty local IVF
list. During search, queries are broadcast to all ranks; each rank probes local
IVF lists, searches their HNSW indexes, packs local top-k candidates, and rank
0 merges candidates exactly like the other modes.

The HNSW-on-HNSW mode reuses local HNSW utilities: each rank splits its local
shard into balanced blocks, builds one top-level HNSW over block centroids, and
builds one HNSW inside each block. Search first chooses blocks through the
top-level graph, then searches selected block-level HNSWs in parallel with
OpenMP. With `nprobe_blocks=16` in the smoke setting it searches every local
block and serves as the assignment option C coverage and recall-latency
trade-off evidence.

## Output Contract

All modes print:

- variant label;
- `mpi_procs`;
- `nthreads`;
- algorithm parameters;
- `query_n`;
- `average recall`;
- `average latency (us)`;
- `max local search latency (us)`;
- `comm+merge latency (us)`.

This keeps results directly comparable and report-table friendly.

## Scripts

- `qsub_mpi.sh` runs IVF-PQ, block-HNSW, nested IVF+HNSW, and HNSW-on-HNSW in
  one PBS job.
- `scripts/run_kunpeng_smoke.sh` mirrors those direct `mpiexec` runs.
- `scripts/run_local_cross_platform.ps1` mirrors the same parameter set on
  Windows with MS-MPI.

## Evidence

`ann-mpi/results/full_score_checklist.md` maps requirement bullets to code
locations and recorded result files. This file is the report/defense guide.
