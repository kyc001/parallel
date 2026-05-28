# Implementation Plan

## Checklist

### Phase 1: Code Implementation

- [ ] Add non-blocking communication helper functions to `main.cc`
  - `BroadcastQueries()` with blocking/non-blocking switch
  - `GatherCandidates()` with blocking/non-blocking switch
- [ ] Add environment variable check for `USE_NONBLOCKING_MPI`
- [ ] Replace direct `MPI_Bcast` call with `BroadcastQueries()` helper
- [ ] Replace direct `MPI_Gather` call with `GatherCandidates()` helper
- [ ] Add `comm_mode` field to output
- [ ] Verify code compiles in both blocking and non-blocking modes

### Phase 2: Local Validation

- [ ] Build on Windows with MSYS2/MS-MPI
- [ ] Run blocking mode smoke test (verify no regression)
- [ ] Run non-blocking mode smoke test (verify correctness)
- [ ] Compare recall values (should be identical)
- [ ] Record timing differences

### Phase 3: Full Experiments

- [ ] Create script `scripts/run_blocking_vs_nonblocking.ps1` for Windows
- [ ] Run full parameter set with blocking mode on Windows
- [ ] Run full parameter set with non-blocking mode on Windows
- [ ] Sync code to Kunpeng server
- [ ] Build on Kunpeng
- [ ] Run full parameter set with blocking mode on Kunpeng
- [ ] Run full parameter set with non-blocking mode on Kunpeng
- [ ] Save all results under `results/blocking_vs_nonblocking_*.txt`

### Phase 4: Analysis and Documentation

- [ ] Create comparison table in `results/blocking_vs_nonblocking_summary.md`
- [ ] Update `README.md` with non-blocking mode usage
- [ ] Update `results/full_score_checklist.md` with advanced requirement evidence
- [ ] Document findings: performance differences, overlap analysis, recommendations

## Implementation Details

### Helper Functions Location

Insert after line 100 in `main.cc` (after `ParseIntArg` function):

```cpp
void BroadcastQueries(float* data, size_t count, bool nonblocking) {
    if (nonblocking) {
        MPI_Request req;
        MPI_Ibcast(data, count, MPI_FLOAT, 0, MPI_COMM_WORLD, &req);
        MPI_Wait(&req, MPI_STATUS_IGNORE);
    } else {
        MPI_Bcast(data, count, MPI_FLOAT, 0, MPI_COMM_WORLD);
    }
}

void GatherCandidates(uint64_t* send_buf, uint64_t* recv_buf, size_t count, 
                      int rank, bool nonblocking) {
    if (nonblocking) {
        MPI_Request req;
        MPI_Igather(send_buf, count, MPI_UINT64_T, recv_buf, count, 
                    MPI_UINT64_T, 0, MPI_COMM_WORLD, &req);
        MPI_Wait(&req, MPI_STATUS_IGNORE);
    } else {
        MPI_Gather(send_buf, count, MPI_UINT64_T, recv_buf, count, 
                   MPI_UINT64_T, 0, MPI_COMM_WORLD);
    }
}
```

### Environment Variable Check

Add in `main()` after MPI initialization (around line 350):

```cpp
const bool use_nonblocking = (std::getenv("USE_NONBLOCKING_MPI") != nullptr);
if (rank == 0) {
    std::cout << "comm_mode=" << (use_nonblocking ? "nonblocking" : "blocking") << "\n";
}
```

### Replace Broadcast Call

Find line ~447-452, replace:
```cpp
MPI_Bcast(queries.data(), query_n * query_d, MPI_FLOAT, 0, MPI_COMM_WORLD);
```

With:
```cpp
BroadcastQueries(queries.data(), query_n * query_d, use_nonblocking);
```

### Replace Gather Call

Find line ~489-504, replace:
```cpp
MPI_Gather(local_candidates.data(), local_size, MPI_UINT64_T,
           all_candidates.data(), local_size, MPI_UINT64_T, 0, MPI_COMM_WORLD);
```

With:
```cpp
GatherCandidates(local_candidates.data(), all_candidates.data(), 
                 local_size, rank, use_nonblocking);
```

## Validation Commands

### Windows Local

```powershell
cd D:\Study\26sp\parallel\ann-mpi
$env:ANN_DATA_PATH='D:\Study\26sp\parallel\files'

# Rebuild
mpic++ main.cc -o build/main_mpi.exe -O2 -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma

# Test blocking mode (default)
& 'C:\Program Files\Microsoft MPI\Bin\mpiexec.exe' -n 2 .\build\main_mpi.exe 2 16 4 1000 200 local

# Test non-blocking mode
$env:USE_NONBLOCKING_MPI='1'
& 'C:\Program Files\Microsoft MPI\Bin\mpiexec.exe' -n 2 .\build\main_mpi.exe 2 16 4 1000 200 local
Remove-Item env:USE_NONBLOCKING_MPI
```

### Kunpeng Server

```bash
cd ~/ann-mpi
make clean
make

# Test blocking mode
ANN_DATA_PATH=/anndata /usr/local/bin/mpiexec -np 2 ./main 2 16 4 1000 200 local

# Test non-blocking mode
ANN_DATA_PATH=/anndata USE_NONBLOCKING_MPI=1 /usr/local/bin/mpiexec -np 2 ./main 2 16 4 1000 200 local
```

## Expected Output Changes

Each run should now print:
```
comm_mode=blocking
```
or
```
comm_mode=nonblocking
```

All other output fields remain the same.

## Success Criteria

- Code compiles without warnings
- Blocking mode produces identical results to before (no regression)
- Non-blocking mode produces identical recall values
- Timing data is collected for both modes on both platforms
- Documentation is updated with findings
