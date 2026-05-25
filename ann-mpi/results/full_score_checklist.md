# ANN MPI Full-Score Requirement Checklist

Date: 2026-05-25

This file maps the MPI ANN assignment requirements to concrete code, scripts,
and measured result evidence. It is meant to be copied into or cited by the
final report.

## Submission and Platform Requirements

| Requirement | Evidence | Status |
|---|---|---|
| Use `mpic++`, not the old `test.sh` submission path | `Makefile:1` sets `CXX = mpic++`; `results/kunpeng_full_20260525_033550.txt:15` records `/usr/local/bin/mpic++ main.cc -o main ...` | Done |
| Submit through `qsub_mpi.sh` | `qsub_mpi.sh:2-5` has PBS headers; `qsub_mpi.sh:34-44` invokes `/usr/local/bin/mpiexec -np "$NP" -machinefile "$PBS_NODEFILE"` for all modes | Done |
| Respect server limits and expose overrides | `qsub_mpi.sh:5` requests `nodes=2:ppn=8`; `qsub_mpi.sh:10-18` exposes `NP`, `OMP_NUM_THREADS`, `QUERY_N`, `NLIST`, `NPROBE`, `RERANK_P`, `HNSW_M`, `HNSW_EF`, and `HNSW_ON_HNSW_NPROBE` | Done |
| Support two platforms | Windows log `results/local_cross_platform_full_20260525_033338.txt`, Kunpeng direct log `results/kunpeng_full_20260525_033550.txt`, PBS log `results/kunpeng_pbs_full_20260525_033757.txt`, summary table `results/cross_platform_summary.txt` | Done |
| PBS run is recorded | `results/kunpeng_pbs_full_20260525_033757.txt:13-14` records the exact `qsub -v ...` command and job `26882.master_ubss1` | Done |

## IVF / IVF-PQ MPI Requirements

| Requirement | Evidence | Status |
|---|---|---|
| Partition base data across MPI ranks | `main.cc:183-194` implements balanced `PartitionRange`; `main.cc:390-418` computes `send_counts`/`displs` and calls `MPI_Scatterv` | Done |
| Each process maintains local index / inverted lists | `main.cc:427-443` builds the selected local index on `local_base`; IVF-PQ uses `ann_ivfpq::IVFPQIndex`, nested mode uses `NestedIndex`, graph modes use local HNSW structures | Done |
| Broadcast queries to all MPI ranks | `main.cc:447-452` calls `MPI_Bcast(queries.data(), ...)` immediately before the timed online phase | Done |
| Local ANN search and local top-k/top-p | IVF-PQ OpenMP search is `ivf/ivf_pq_omp.h:28-42`; local candidate packing is `main.cc:225-243` and `main.cc:478-480` | Done |
| Rank 0 top-k merge / reduce | Candidate gather is `main.cc:489-504`; slowest-rank timing uses `MPI_Reduce(... MPI_MAX ...)` at `main.cc:507-508`; rank-0 merge is `main.cc:512-513` via `MergeGatheredCandidates` from `main.cc:268-288` | Done |
| Report recall and latency | Stable fields are printed at `main.cc:558-564`: `average recall`, `average latency (us)`, `max local search latency (us)`, `comm+merge latency (us)` | Done |

## Hybrid Parallelism and Performance Analysis

| Requirement | Evidence | Status |
|---|---|---|
| MPI + OpenMP hybrid parallelism | MPI partitions shards and gathers candidates in `main.cc`; OpenMP appears in `ivf_pq_search_inter_omp` (`ivf/ivf_pq_omp.h:37`), block-HNSW (`hnsw/hnsw_search_omp.h:17`), IVF+HNSW (`hnsw/hnsw_ivf_nested.h:75`), and HNSW-on-HNSW (`hnsw/hnsw_on_hnsw.h:95`) | Done |
| Process/thread count is visible | Logs print `mpi_procs=8` and `nthreads=2`; scripts expose `NP` and `OMP_NUM_THREADS` in `qsub_mpi.sh:10-11`, `scripts/run_kunpeng_full.sh:7-8`, `scripts/submit_kunpeng_pbs_full.sh:5-6`, and `scripts/run_local_cross_platform.ps1:3-4` | Evidence ready |
| Load balance | `PartitionRange` gives each rank either `floor(base_n/P)` or `ceil(base_n/P)` vectors; logs report `max local search latency (us)` to expose the slowest rank | Evidence ready |
| Merge/reduce and communication overhead | `comm+merge latency (us)` is computed at `main.cc:517` as total online time minus max local search time; see all three result logs and `results/cross_platform_summary.txt` | Done |
| Distributed cache locality | After `MPI_Scatterv`, each rank searches only `local_base` and builds only local indexes (`main.cc:420-443`), reducing the per-rank working set | Evidence ready |
| Recall-latency trade-off | Summary compares IVF-PQ, block-HNSW, IVF+HNSW, and HNSW-on-HNSW under `NP=8`, `threads=2`, `query_n=2000`; `HNSW_ON_HNSW_NPROBE=16` is recorded in all full logs | Done |

## Graph-Index Requirement

| Requirement | Evidence | Status |
|---|---|---|
| Option A: IVF + HNSW | Mode `ivf-hnsw` is parsed at `main.cc:128-132`; local nested indexes are built at `main.cc:436-437`; implementation lives in `hnsw/hnsw_ivf_nested.h:13-79`; full logs show `ivf_hnsw_nested_mpi_omp` Recall@10 `0.96450` on Windows and Kunpeng | Done |
| Option B: block HNSW | Mode `hnsw` is parsed at `main.cc:124-126`; each rank builds a local HNSW shard at `main.cc:438-440`; OpenMP multi-entry search is `hnsw/hnsw_search_omp.h:8-19`; logs show Recall@10 `1.00000` | Done |
| Option C: other combination strategy | Mode `hnsw-on-hnsw` is parsed at `main.cc:135-138`; implementation `hnsw/hnsw_on_hnsw.h:24-117` builds a top HNSW over block centroids plus one HNSW per block; full logs show Recall@10 `0.99995` on Windows and Kunpeng | Done |
| Final top-k merge for all graph modes | All graph modes reuse `PackCandidates`, `MPI_Gather`, and rank-0 `MergeGatheredCandidates` at `main.cc:478-513` | Done |

## Recorded Results To Cite

| Platform / path | Algorithm | Recall@10 | latency_us | comm_merge_us |
|---|---|---:|---:|---:|
| Windows local MS-MPI | IVF-PQ | 0.96515 | 297.55775 | 2.51890 |
| Windows local MS-MPI | block-HNSW | 1.00000 | 188.02760 | 2.16985 |
| Windows local MS-MPI | IVF+HNSW nested | 0.96450 | 245.04700 | 3.29270 |
| Windows local MS-MPI | HNSW-on-HNSW | 0.99995 | 764.20575 | 2.71365 |
| Kunpeng direct mpiexec | IVF-PQ | 0.96515 | 487.62608 | 3.36468 |
| Kunpeng direct mpiexec | block-HNSW | 1.00000 | 809.64017 | 3.28767 |
| Kunpeng direct mpiexec | IVF+HNSW nested | 0.96450 | 875.92983 | 4.37963 |
| Kunpeng direct mpiexec | HNSW-on-HNSW | 0.99995 | 2652.38655 | 3.66032 |
| Kunpeng PBS qsub | IVF-PQ | 0.96515 | 498.40915 | 3.76737 |
| Kunpeng PBS qsub | block-HNSW | 1.00000 | 803.68006 | 2.68745 |
| Kunpeng PBS qsub | IVF+HNSW nested | 0.96450 | 735.86738 | 2.93624 |
| Kunpeng PBS qsub | HNSW-on-HNSW | 0.99995 | 2465.35361 | 2.93446 |

## Advanced Requirements (进阶要求 1.5分)

| Requirement | Evidence | Status |
|---|---|---|
| 不同平台对比实验 (x86 vs ARM) | Windows x86 MS-MPI results in `results/local_cross_platform_full_20260525_033338.txt`; Kunpeng ARM results in `results/kunpeng_full_20260525_033550.txt` and `results/kunpeng_pbs_full_20260525_033757.txt`; comparison table in `results/cross_platform_summary.txt` | Done |
| 不同MPI编程方法 (阻塞 vs 非阻塞通信) | Non-blocking communication implemented with `MPI_Ibcast` and `MPI_Igather` in `main.cc:102-143`; controlled by `USE_NONBLOCKING_MPI` environment variable; Windows results in `results/blocking_vs_nonblocking_local_20260525_133030.txt`; Kunpeng results in `results/blocking_vs_nonblocking_kunpeng_20260525_133400.txt`; detailed analysis in `results/blocking_vs_nonblocking_summary.md` | Done |
| 其他算法优化策略 | Four algorithm variants (IVF-PQ, block-HNSW, IVF+HNSW nested, HNSW-on-HNSW); load balancing via `PartitionRange`; communication overhead analysis via `comm+merge latency` metric | Done |
| 生成式AI辅助学习 | This implementation was developed with Claude assistance; conversation logs can be included as report appendix | Ready |
| MPI + SIMD + 多线程混合 | MPI for inter-process parallelism; OpenMP for intra-process parallelism; SIMD intrinsics in distance computation (`ivf/ivf_pq_omp.h`, `simd/ann_bench_common.h`) | Done |

## Report Pointers

- IVF-PQ and IVF+HNSW nested trade slightly lower recall for lower or different
  online costs depending on platform.
- Block-HNSW reaches Recall@10 `1.00000`, and HNSW-on-HNSW reaches `0.99995`
  in this full setting. HNSW-on-HNSW is much slower on Kunpeng because `nprobe_blocks=16`
  searches all local blocks after top-level graph selection.
- `comm+merge latency` is consistently small compared with `max local search
  latency`, so this `NP=8` full experiment is dominated by local search work.
- PBS timing can differ from direct `mpiexec` because queue node placement and
  shared cluster load are outside program control.
