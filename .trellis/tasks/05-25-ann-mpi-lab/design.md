# Design

## Workspace Shape

`ann-mpi/` keeps reusable ANN source directories from the previous experiment:
`simd/`, `ivf/`, `hnsw/`, `hnswlib/`, `pthread/`, `omp/`, `mains/`,
`tools/`, and `tests/`. Generated directories such as `build/`, `tmp/`,
old `report/`, old `results/`, copied `profiling/`, and copied `docs/` are
not part of the MPI submission source.

## Submission Entry

`main.cc` is the course submission entry. It supports two algorithm modes:

- Default IVF-PQ mode: `./main <threads> <nlist> <nprobe> <p> <query_n> local`.
- Block HNSW mode: `./main <threads> <hnsw_m> <ef> <p> <query_n> hnsw`.

`p` is kept in the HNSW command shape for argument compatibility but is not
used by HNSW search.

## MPI Data Flow

1. Rank 0 loads DEEP100K query, ground-truth, and base files using the shared
   `ann_bench::DefaultDataPath()` convention.
2. Rank 0 broadcasts metadata: query count, dimensions, ground-truth width, and
   base dimensions.
3. Base vectors are partitioned by contiguous ranges and scattered with
   `MPI_Scatterv`.
4. Queries are broadcast to all ranks immediately before the timed online
   phase.
5. Each rank builds a local index for its shard before the timed online phase.
6. Each rank searches all queries locally and packs local top-k candidates.
7. Rank 0 gathers candidate distance/id arrays, adds shard offsets to convert
   local ids to global ids, merges top-k, and computes Recall@10.

## Hybrid Parallelism

IVF-PQ uses OpenMP query-level parallelism inside each MPI rank via the existing
`ivf_pq_search_inter_omp` helper.

Block HNSW builds one local HNSW per rank and uses the existing OpenMP
multi-entry search helper inside each rank. Across ranks, independent HNSW
partitions are searched in parallel and merged on rank 0.

## Local Fallback

When compiled with `-DANN_NO_MPI`, the same entry runs as a single-process
fallback. This is for Windows/local code validation where MPI headers or runtime
may be missing. It prints the same result fields with `mpi_procs=1`.

## Reproducibility

Results should be saved under `ann-mpi/results/` as command transcripts. Each
result file must include the build command, run command, environment notes, and
the program output fields:

- variant label;
- MPI process count;
- thread count;
- algorithm parameters;
- query count;
- average recall;
- average latency;
- max local search latency;
- communication plus merge latency.
