# Add Non-blocking MPI Communication Experiment

## Goal

Implement non-blocking MPI communication variants for the ANN MPI lab to fulfill the advanced requirement "不同MPI编程方法（阻塞通信 vs. 非阻塞通信）" and provide performance comparison evidence for the report.

## User Request

- Add non-blocking communication implementation to `ann-mpi/`
- Compare blocking vs non-blocking MPI performance
- Analyze communication-computation overlap benefits
- Keep existing blocking implementation intact
- Record results for report evidence

## Requirements

### Core Implementation

1. Add non-blocking broadcast and gather functions:
   - Implement `MPI_Ibcast` for query broadcast
   - Implement `MPI_Igather` for candidate gathering
   - Use `MPI_Wait` / `MPI_Waitall` for synchronization
   - Explore computation-communication overlap opportunities

2. Provide command-line control:
   - Add a flag or mode parameter to switch between blocking/non-blocking
   - Default to blocking mode to preserve existing behavior
   - Example: `./main <params> --nonblocking` or environment variable

3. Maintain output compatibility:
   - Print the same metrics: recall, latency, local search time, comm+merge time
   - Add a field indicating communication mode (blocking/non-blocking)

### Experimental Validation

1. Run the same parameter sets with both modes:
   - IVF-PQ: `np=8, threads=2, nlist=16, nprobe=4, p=1000, query_n=2000`
   - Block-HNSW: `np=8, threads=2, m=16, ef=50, query_n=2000`
   - IVF+HNSW nested: `np=8, threads=2, nlist=16, nprobe=4, ef=50, query_n=2000`

2. Test on both platforms:
   - Windows local (MS-MPI)
   - Kunpeng server (ARM)

3. Record results:
   - Save blocking vs non-blocking comparison under `results/`
   - Include timing breakdown: total latency, local search, comm+merge
   - Document any performance differences and analysis

### Documentation

1. Update `README.md` with non-blocking mode usage
2. Update `results/full_score_checklist.md` to include advanced requirement evidence
3. Add comparison table showing blocking vs non-blocking performance

## Known Context

- Current implementation uses blocking `MPI_Bcast` at `main.cc:447-452`
- Current implementation uses blocking `MPI_Gather` at `main.cc:489-504`
- All four algorithm modes (IVF-PQ, block-HNSW, IVF+HNSW, HNSW-on-HNSW) share the same communication pattern
- Existing results are in `ann-mpi/results/`

## Acceptance Criteria

- [ ] Non-blocking communication functions are implemented in `main.cc`
- [ ] Command-line or environment variable controls blocking/non-blocking mode
- [ ] All four algorithm modes work with non-blocking communication
- [ ] Local Windows validation completes successfully
- [ ] Kunpeng server validation completes successfully
- [ ] Results comparing blocking vs non-blocking are recorded under `results/`
- [ ] `README.md` documents the new mode
- [ ] `full_score_checklist.md` updated with advanced requirement evidence
- [ ] No regression in existing blocking mode behavior

## Out of Scope

- Single-sided communication (MPI_Put/MPI_Get) - can be added later if needed
- MPI_Init_thread multi-threading support - current OpenMP hybrid is sufficient
- Rewriting the entire communication layer - minimal changes preferred

## Success Metrics

- Non-blocking mode compiles and runs on both platforms
- Performance comparison data is available for report
- Existing blocking mode remains unchanged and functional
- Clear evidence for "不同MPI编程方法" advanced requirement
