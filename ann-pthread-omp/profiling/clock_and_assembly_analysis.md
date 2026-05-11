# Clock and Assembly Analysis

## Environment

- CPU reported by Windows CIM: 13th Gen Intel(R) Core(TM) i9-13900H, 14 cores / 20 logical processors.
- Nominal `MaxClockSpeed`: 2600 MHz. Turbo frequency is workload dependent, so cycle estimates below use the nominal clock only for scale.
- Compiler: MSYS2 `g++` 14.2.0.
- Disassembler: GNU `objdump` 2.44.
- Timing source: benchmark code uses `std::chrono::high_resolution_clock`, reports total query time divided by 2000 DEEP100K queries.

## Clock-Level Observations

| Kernel point | Recall@10 | us/query | Approx cycles/query at 2.6 GHz |
|---|---:|---:|---:|
| PQ dynamic inter, `p=100` | 0.70780 | 85.43275 | 222k |
| PQ dynamic inter, `p=1000` | 0.98335 | 136.47185 | 355k |
| PQ dynamic inter, `p=2000` | 0.99560 | 183.35245 | 477k |
| IVF-PQ local, `nprobe=4,p=1000` | 0.95945 | 61.31540 | 159k |
| IVF-PQ local, `nprobe=16,p=1000` | 0.99545 | 118.86060 | 309k |
| IVF-HNSW nested OMP, `nprobe=4` | 0.94705 | 177.98880 | 463k |
| IVF-HNSW nested OMP, `nprobe=8` | 0.97770 | 252.74055 | 657k |
| IVF-HNSW nested OMP, `nprobe=16` | 0.98315 | 445.28595 | 1.16M |

The clock data matches the algorithmic model. Raising `p` in PQ mainly increases the exact rerank work after the compressed scan, so recall rises smoothly and latency grows moderately. IVF-PQ local mode reaches 95%+ recall with less latency than global mode because local quantizers reduce per-list quantization error; `nprobe=16` costs about 1.94x the `nprobe=4` latency for a 0.036 recall gain. IVF-HNSW nested search is dominated by searching more sub-indexes, so `nprobe` has a stronger latency cost than PQ `p`.

## Assembly Evidence

Generated snippets:

- `profiling/asm_pq_avx2_snippet.txt`
- `profiling/asm_ivfpq_avx2_snippet.txt`
- `profiling/asm_hnsw_avx2_snippet.txt`
- `profiling/symbols_pq.txt`
- `profiling/symbols_ivfpq.txt`

Key findings:

- PQ and IVF-PQ hot distance loops contain AVX2/FMA instructions such as `vmovups ymm`, `vfmadd231ps`, `vaddps`, `vhaddps`, and `vextractf128`, confirming that the x86 build uses 256-bit vectorized dot-product/L2 kernels.
- The dynamic inter-query variants show `pthread_create`/`pthread_join` around the query partition, but the hot inner loops are independent per query; this matches the strong scaling of inter-query runs.
- IVF-PQ assembly contains both pthread calls and vectorized distance fragments. That supports the report conclusion that it mixes query-level parallelism with SIMD kernels, then becomes limited by candidate memory traffic and rerank cost.
- HNSW nested snippets show vectorized distance instructions but many scalar/control-flow sections, consistent with graph traversal being less SIMD-friendly than regular Flat/PQ/IVF scans.

## VTune Status

`vtune` and `amplxe-cl` were not found in PATH on this Windows machine, so no VTune result directory can be honestly produced here. The runnable collection script is `profiling/run_vtune_hotspots.ps1`; on a VTune-enabled machine it can collect hotspots for any built diagnostic executable, for example:

```powershell
.\profiling\run_vtune_hotspots.ps1 -Target .\build\pq_dynamic_inter_diag.exe -TargetArgs 16,1000 -ResultDir profiling\vtune-pq-p1000
```

The expected VTune hotspots to inspect are:

- PQ / IVF-PQ: LUT build, ADC code scan, final exact rerank, and heap maintenance.
- IVF: selected inverted-list scan and local heap merge.
- HNSW: neighbor expansion, visited-set updates, and candidate priority-queue operations.
