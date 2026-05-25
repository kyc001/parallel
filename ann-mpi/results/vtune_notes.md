# VTune profiling notes

Date: 2026-05-25

## Symbolized Hotspots

- Tool: Intel VTune Profiler 2025.10.0
- Target binary: `build/main_no_mpi_profile.exe`
- Build command:

```text
g++ main.cc -o build/main_no_mpi_profile.exe -O2 -g -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma -DANN_NO_MPI
```

- Collection command:

```text
vtune -collect hotspots -result-dir results/vtune_hotspots_hnsw_profile -- .\build\main_no_mpi_profile.exe 2 16 50 1000 2000 hnsw
```

- Exported files:
  - `results/vtune_exports/hotspots_profile_summary.txt`
  - `results/vtune_exports/hotspots_profile_functions.csv`
  - `results/vtune_exports/hotspots_profile_collect_log.txt`

Target program output during profiling:

- Recall@10: `0.99985`
- Average latency: `178.50710 us/query`

Key VTune summary values:

- Elapsed Time: `20.450 s`
- CPU Time: `19.922 s`
- Effective Time: `16.713 s`
- Spin Time: `3.209 s`
- Total Thread Count: `2`

Top hotspots:

| Function | Module | CPU Time | Share |
|---|---|---:|---:|
| `_Z13_mm256_mul_psDv8_fS_` | `main_no_mpi_profile.exe` | 3.218 s | 16.2% |
| `pthread_mutex_lock` | `libwinpthread-1.dll` | 2.664 s | 13.4% |
| `hnswlib::HierarchicalNSW<float>::searchBaseLayer` | `main_no_mpi_profile.exe` | 2.493 s | 12.5% |
| `InnerProductSIMD16ExtAVX` | `main_no_mpi_profile.exe` | 2.098 s | 10.5% |
| `_Z13_mm256_add_psDv8_fS_` | `main_no_mpi_profile.exe` | 1.663 s | 8.3% |

Interpretation: the distance kernel is vectorized and visible in the top
hotspots, but HNSW graph traversal, priority queues, and runtime
synchronization also consume substantial time.

## Assembly evidence

Assembly excerpt:

- `results/vtune_exports/assembly_excerpt.txt`

Command:

```text
objdump -Cd -Mintel build\main_no_mpi_profile.exe
```

Important observations:

- `InnerProductSIMD16ExtAVX` uses `vmovups ymm`, `vmulps`, `vaddps`,
  `vextractf128`, `vshufps`, `vaddss`, and `vzeroupper`.
- The AVX loop advances by `0x40` bytes, i.e. 16 floats per iteration. With
  96-dimensional DEEP100K vectors, one distance computation uses six 16-float
  AVX chunks.
- `BuildIndex` dispatches to `InnerProductSIMD16ExtAVX` and
  `InnerProductDistanceSIMD16ExtAVX` after `AVXCapable()`.
- `hnsw_search_multi_entry_omp` and `searchBaseLayer` contain many conditional
  branches and priority-queue paths, matching the Hotspots evidence that graph
  traversal and candidate maintenance remain bottlenecks around the SIMD
  distance kernel.

## uarch-exploration hardware counters

`uarch-exploration` was first attempted in the non-elevated Windows session:

```text
vtune -collect uarch-exploration -result-dir results\vtune_uarch_hnsw_profile -- .\build\main_no_mpi_profile.exe 2 16 50 1000 2000 hnsw
```

That run failed with:

```text
Cannot enable Hardware Event-Based Sampling or Hardware Tracing.
Run the product as administrator to collect hardware events.
```

The ordinary-session driver check also requires elevation:

```text
"C:\Program Files (x86)\Intel\oneAPI\vtune\latest\bin64\amplxe-sepreg.exe" -c
```

The non-elevated diagnostic log is saved in:

- `results/vtune_exports/uarch_collect_log.txt`

The same workload was then collected from an administrator session through:

```text
scripts\run_vtune_uarch_admin.cmd
```

The sampling driver check succeeded:

- `User has admin rights: OK`
- `sepdrv5 service is running`
- `sepdal service is running`
- `vtss service...OK`

The administrator collection succeeded and exported:

- `results/vtune_exports/uarch_admin_summary.txt`
- `results/vtune_exports/uarch_admin_top_down.txt`
- `results/vtune_exports/uarch_admin_hw_events.csv`
- `results/vtune_exports/uarch_admin_hotspots.csv`
- `results/vtune_exports/uarch_admin_collect_log.txt`
- `results/vtune_exports/sampling_driver_check.txt`

Key summary values from `uarch_admin_summary.txt`:

| Metric | Value |
|---|---:|
| Elapsed Time | 49.970 s |
| Clockticks | 12,105,790,000 |
| Instructions Retired | 8,242,240,000 |
| CPI Rate | 1.469 |
| MUX Reliability | 0.952 |
| E-core Retiring | 19.7% |
| E-core Front-End Bound | 9.0% |
| E-core Bad Speculation | 11.2% |
| E-core Back-End Bound | 60.1% |
| E-core Memory Bound | 50.4% |
| E-core L1 Bound | 12.1% |
| E-core Load STLB Miss | 11.2% |
| E-core DRAM Bound | 30.1% |

Most clockticks and retired instructions landed on E-cores
(`11,929,085,000` E-core clockticks vs `176,705,000` P-core clockticks), so the
report interprets the E-core Top-Down tree. Function-level exports reinforce the
same conclusion: `searchBaseLayer` shows high memory/TLB pressure and bad
speculation, while AVX intrinsic wrappers remain visible as distance-kernel
hotspots.

Raw VTune result directories are intentionally kept separate from the curated
text/CSV exports.
