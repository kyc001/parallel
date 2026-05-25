#!/bin/bash
# Blocking vs Non-blocking MPI Communication Comparison
# Kunpeng ARM server

set -e

ANN_DATA_PATH=${ANN_DATA_PATH:-/anndata}
timestamp=$(date +%Y%m%d_%H%M%S)
output_file="results/blocking_vs_nonblocking_kunpeng_${timestamp}.txt"

echo "Running blocking vs non-blocking comparison on Kunpeng..."
echo "Output: $output_file"

# Ensure results directory exists
mkdir -p results

# Common parameters
np=8
threads=2
query_n=2000

# IVF-PQ parameters
nlist=16
nprobe=4
rerank_p=1000

# HNSW parameters
hnsw_m=16
ef=50

# HNSW-on-HNSW parameters
nblocks=16
nprobe_blocks=16

mpiexec=/usr/local/bin/mpiexec

# Start output file
cat > "$output_file" <<EOF
Blocking vs Non-blocking MPI Communication Comparison
Platform: Kunpeng ARM server
Date: $(date '+%Y-%m-%d %H:%M:%S')
Parameters: np=$np, threads=$threads, query_n=$query_n

EOF

# Function to run experiment
run_experiment() {
    local mode=$1
    local algo=$2
    shift 2
    local args=("$@")

    echo "Running $mode $algo..."

    if [ "$mode" = "nonblocking" ]; then
        export USE_NONBLOCKING_MPI=1
    else
        unset USE_NONBLOCKING_MPI
    fi

    echo "=== $mode - $algo ===" >> "$output_file"
    ANN_DATA_PATH=$ANN_DATA_PATH $mpiexec -np $np ./main "${args[@]}" >> "$output_file" 2>&1
    echo "" >> "$output_file"
}

# Run all experiments
run_experiment "blocking" "IVF-PQ" $threads $nlist $nprobe $rerank_p $query_n local
run_experiment "nonblocking" "IVF-PQ" $threads $nlist $nprobe $rerank_p $query_n local

run_experiment "blocking" "block-HNSW" $threads $hnsw_m $ef $rerank_p $query_n hnsw
run_experiment "nonblocking" "block-HNSW" $threads $hnsw_m $ef $rerank_p $query_n hnsw

run_experiment "blocking" "IVF+HNSW" $threads $nlist $nprobe $ef $query_n ivf-hnsw
run_experiment "nonblocking" "IVF+HNSW" $threads $nlist $nprobe $ef $query_n ivf-hnsw

run_experiment "blocking" "HNSW-on-HNSW" $threads $nblocks $nprobe_blocks $ef $query_n hnsw-on-hnsw
run_experiment "nonblocking" "HNSW-on-HNSW" $threads $nblocks $nprobe_blocks $ef $query_n hnsw-on-hnsw

# Clean up environment
unset USE_NONBLOCKING_MPI

echo "Done! Results saved to $output_file"
