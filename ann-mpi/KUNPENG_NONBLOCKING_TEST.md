# Kunpeng Server Testing Guide for Non-blocking MPI

## Prerequisites

The code has been updated with non-blocking MPI communication support. You need to:
1. Sync the updated code to Kunpeng server
2. Rebuild the binary
3. Run the blocking vs non-blocking comparison

## Step 1: Sync Code to Kunpeng

From your local machine, sync the updated files:

```bash
# Option A: Using rsync (if available)
rsync -avz --exclude 'build/' --exclude 'results/' \
  ann-mpi/ s2413575@192.168.90.141:~/ann-mpi/

# Option B: Using scp for specific files
scp ann-mpi/main.cc s2413575@192.168.90.141:~/ann-mpi/
scp ann-mpi/scripts/run_blocking_vs_nonblocking_kunpeng.sh s2413575@192.168.90.141:~/ann-mpi/scripts/
```

## Step 2: SSH to Kunpeng Server

```bash
ssh s2413575@192.168.90.141
# Password: s2413575
```

## Step 3: Rebuild on Kunpeng

```bash
cd ~/ann-mpi
make clean
make
```

Expected output: `main` binary created successfully.

## Step 4: Run Smoke Test

Test both modes with a small query set:

```bash
# Test blocking mode (default)
ANN_DATA_PATH=/anndata /usr/local/bin/mpiexec -np 2 ./main 2 16 4 1000 200 local | grep -E "(comm_mode|average)"

# Test non-blocking mode
ANN_DATA_PATH=/anndata USE_NONBLOCKING_MPI=1 /usr/local/bin/mpiexec -np 2 ./main 2 16 4 1000 200 local | grep -E "(comm_mode|average)"
```

Expected: Both should show identical recall values, with `comm_mode=blocking` or `comm_mode=nonblocking`.

## Step 5: Run Full Comparison

```bash
cd ~/ann-mpi
chmod +x scripts/run_blocking_vs_nonblocking_kunpeng.sh
bash scripts/run_blocking_vs_nonblocking_kunpeng.sh
```

This will:
- Run all 4 algorithms (IVF-PQ, block-HNSW, IVF+HNSW, HNSW-on-HNSW)
- Test both blocking and non-blocking modes
- Save results to `results/blocking_vs_nonblocking_kunpeng_TIMESTAMP.txt`

Expected runtime: ~10-15 minutes for all 8 experiments.

## Step 6: Download Results

From your local machine:

```bash
scp s2413575@192.168.90.141:~/ann-mpi/results/blocking_vs_nonblocking_kunpeng_*.txt \
  ann-mpi/results/
```

## Verification Checklist

- [ ] Code synced to Kunpeng
- [ ] Binary rebuilt successfully
- [ ] Smoke test shows correct `comm_mode` output
- [ ] Smoke test shows identical recall for blocking/non-blocking
- [ ] Full comparison script completed
- [ ] Results downloaded to local `ann-mpi/results/`

## Troubleshooting

**Issue**: `make` fails with MPI errors
- **Solution**: Ensure you're using `mpic++` compiler. Check `Makefile` line 1.

**Issue**: `mpiexec` not found
- **Solution**: Use full path `/usr/local/bin/mpiexec`

**Issue**: Data files not found
- **Solution**: Ensure `ANN_DATA_PATH=/anndata` is set

**Issue**: Permission denied on script
- **Solution**: Run `chmod +x scripts/run_blocking_vs_nonblocking_kunpeng.sh`

## Alternative: Manual Testing

If the script doesn't work, run experiments manually:

```bash
cd ~/ann-mpi
ANN_DATA_PATH=/anndata

# Blocking IVF-PQ
/usr/local/bin/mpiexec -np 8 ./main 2 16 4 1000 2000 local > results/blocking_ivfpq.txt 2>&1

# Non-blocking IVF-PQ
USE_NONBLOCKING_MPI=1 /usr/local/bin/mpiexec -np 8 ./main 2 16 4 1000 2000 local > results/nonblocking_ivfpq.txt 2>&1

# Repeat for other algorithms...
```

## Expected Results

All algorithms should show:
- ✅ Identical recall values between blocking and non-blocking
- ✅ Similar latency (within ±10%)
- ✅ `comm_mode` field correctly indicates the mode

## Next Steps

After completing Kunpeng testing:
1. Create a combined summary comparing Windows and Kunpeng results
2. Update `full_score_checklist.md` with Kunpeng non-blocking evidence
3. Document findings in the report
