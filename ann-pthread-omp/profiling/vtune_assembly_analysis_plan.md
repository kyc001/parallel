# VTune and Assembly Analysis Plan

This is the analysis checklist to run after the local and Kunpeng high-recall reruns are complete. VTune is available locally (`Intel VTune Profiler 2025.10.0`), but collection is intentionally deferred so experiment reruns can finish first.

## Targets

Use high-recall representative points:

| Target | Command arguments | Purpose |
|---|---|---|
| PQ dynamic inter | `16 1000` | Analyze PQ LUT build, ADC scan, exact rerank, heap maintenance. |
| IVF-PQ local dynamic inter | `16 16 4 1000 local` | Analyze IVF coarse selection plus local PQ scan and rerank. |
| IVF-PQ global dynamic inter | `16 16 4 2000 global` | Compare global quantizer behavior and larger rerank set. |
| IVF-HNSW nested OMP | `4 50 16 8` | Analyze graph traversal, candidate queues, branch/control-flow costs. |

## VTune Reports To Export

For each target:

1. `hotspots`: top functions, CPU time, thread utilization.
2. `uarch-exploration`: CPI, Retiring, Back-End Bound, Memory Bound, Core Bound.
3. `memory-access` if collection is stable: DRAM Bound, LLC misses, bandwidth pressure.

The report should follow the Lab1 style: timing table first, assembly snippets second, VTune Top-Down metrics third, then a short explanation tying the three together.

## Assembly Checks

Keep the existing snippets:

- `profiling/asm_pq_avx2_snippet.txt`
- `profiling/asm_ivfpq_avx2_snippet.txt`
- `profiling/asm_hnsw_avx2_snippet.txt`

Confirm:

- PQ and IVF-PQ distance kernels contain AVX2/FMA instructions such as `vmovups`, `vfmadd231ps`, `vaddps`, and horizontal reductions.
- IVF-PQ mixes SIMD distance fragments with pointer-heavy list scanning and rerank heap operations.
- HNSW nested contains SIMD distance fragments but more scalar branches and priority-queue control flow, explaining weaker SIMD efficiency.

## Report Questions

- Does PQ become memory-bound after ADC lookup and rerank, or is rerank still core-bound at `p=1000`?
- Does IVF-PQ local reduce quantization error enough to justify its higher build complexity?
- Are thread stalls concentrated in heap merge / candidate queue sections or in distance computation?
- Does HNSW nested spend most cycles in graph traversal, distance computation, or synchronization/control flow?
