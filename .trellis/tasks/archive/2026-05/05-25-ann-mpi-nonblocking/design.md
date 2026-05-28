# Technical Design

## Overview

This design adds non-blocking MPI communication as an optional mode to the existing ANN MPI implementation. The goal is to demonstrate communication-computation overlap potential while keeping the proven blocking path intact.

## Implementation Strategy

### 1. Communication Mode Control

Add an environment variable `USE_NONBLOCKING_MPI` to control the mode:

```cpp
bool use_nonblocking = (std::getenv("USE_NONBLOCKING_MPI") != nullptr);
```

**Rationale**: Environment variable is simpler than adding a new command-line argument, and it works seamlessly with existing scripts and PBS submissions.

### 2. Non-blocking Broadcast

**Current blocking code** (`main.cc:447-452`):
```cpp
MPI_Bcast(queries.data(), query_n * query_d, MPI_FLOAT, 0, MPI_COMM_WORLD);
```

**Non-blocking replacement**:
```cpp
MPI_Request bcast_req;
MPI_Ibcast(queries.data(), query_n * query_d, MPI_FLOAT, 0, MPI_COMM_WORLD, &bcast_req);
// Optionally overlap with index building or other prep work
MPI_Wait(&bcast_req, MPI_STATUS_IGNORE);
```

**Overlap opportunity**: In the current design, queries are broadcast before the timed online phase. There's limited overlap potential here because index building happens before broadcast. However, non-blocking still demonstrates the API usage.

### 3. Non-blocking Gather

**Current blocking code** (`main.cc:489-504`):
```cpp
MPI_Gather(local_candidates.data(), local_size, MPI_UINT64_T,
           all_candidates.data(), local_size, MPI_UINT64_T, 0, MPI_COMM_WORLD);
```

**Non-blocking replacement**:
```cpp
MPI_Request gather_req;
MPI_Igather(local_candidates.data(), local_size, MPI_UINT64_T,
            all_candidates.data(), local_size, MPI_UINT64_T, 0, MPI_COMM_WORLD, &gather_req);
// Optionally overlap with local post-processing
MPI_Wait(&gather_req, MPI_STATUS_IGNORE);
```

**Overlap opportunity**: After packing local candidates, non-root ranks could potentially do cleanup or prepare for the next query batch while gather is in progress. In the current single-batch design, overlap is limited.

### 4. Code Structure

Wrap communication in helper functions to avoid code duplication:

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

void GatherCandidates(uint64_t* send_buf, uint64_t* recv_buf, size_t count, bool nonblocking) {
    if (nonblocking) {
        MPI_Request req;
        MPI_Igather(send_buf, count, MPI_UINT64_T, recv_buf, count, MPI_UINT64_T, 0, MPI_COMM_WORLD, &req);
        MPI_Wait(&req, MPI_STATUS_IGNORE);
    } else {
        MPI_Gather(send_buf, count, MPI_UINT64_T, recv_buf, count, MPI_UINT64_T, 0, MPI_COMM_WORLD);
    }
}
```

### 5. Output Changes

Add a field to indicate communication mode:

```cpp
std::cout << "comm_mode=" << (use_nonblocking ? "nonblocking" : "blocking") << "\n";
```

This makes it easy to distinguish results in logs.

## Performance Expectations

### Realistic Expectations

In the current single-batch query design with pre-built indexes:
- **Limited overlap potential**: Queries are broadcast before search, and candidates are gathered after search completes
- **Expected result**: Non-blocking may show similar or slightly different timing due to MPI implementation details, but dramatic speedup is unlikely without restructuring the computation flow

### What This Demonstrates

1. **API knowledge**: Shows understanding of non-blocking MPI primitives
2. **Comparison methodology**: Provides empirical data on blocking vs non-blocking for this workload
3. **Advanced requirement fulfillment**: Directly addresses "不同MPI编程方法（阻塞通信 vs. 非阻塞通信）"

### Report Analysis Points

- Non-blocking communication is most beneficial when computation can overlap with communication
- In this ANN search workload with pre-built indexes and single query batches, overlap opportunities are limited
- Future optimizations could explore pipelined query batches or asynchronous index updates to better leverage non-blocking communication

## Testing Strategy

1. **Functional correctness**: Verify non-blocking mode produces identical recall results
2. **Performance measurement**: Run identical parameter sets with both modes
3. **Cross-platform validation**: Test on Windows and Kunpeng to ensure portability

## Rollback Plan

If non-blocking mode causes issues:
- Default behavior remains blocking (no environment variable set)
- Existing scripts and results are unaffected
- Can disable non-blocking code path with a simple `#ifdef` if needed

## Files to Modify

1. `main.cc`: Add helper functions and mode control
2. `README.md`: Document `USE_NONBLOCKING_MPI` environment variable
3. `results/full_score_checklist.md`: Add advanced requirement evidence
4. Scripts (optional): Add variants that set `USE_NONBLOCKING_MPI=1`
