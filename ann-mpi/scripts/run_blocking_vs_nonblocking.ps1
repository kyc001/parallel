# Blocking vs Non-blocking MPI Communication Comparison
# Windows local MS-MPI

$ErrorActionPreference = "Continue"
$env:ANN_DATA_PATH = "D:\Study\26sp\parallel\files"

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$output_file = "results/blocking_vs_nonblocking_local_$timestamp.txt"

Write-Host "Running blocking vs non-blocking comparison on Windows local..."
Write-Host "Output: $output_file"

# Ensure results directory exists
New-Item -ItemType Directory -Force results | Out-Null

# Common parameters
$np = 8
$threads = 2
$query_n = 2000

# IVF-PQ parameters
$nlist = 16
$nprobe = 4
$rerank_p = 1000

# HNSW parameters
$hnsw_m = 16
$ef = 50

# Nested IVF+HNSW parameters (uses both IVF and HNSW params)

# HNSW-on-HNSW parameters
$nblocks = 16
$nprobe_blocks = 16

$mpiexec = "C:\Program Files\Microsoft MPI\Bin\mpiexec.exe"

# Start output file
@"
Blocking vs Non-blocking MPI Communication Comparison
Platform: Windows local (MS-MPI)
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Parameters: np=$np, threads=$threads, query_n=$query_n

"@ | Out-File -FilePath $output_file -Encoding utf8

# Function to run experiment
function Run-Experiment {
    param($mode, $algo, $args)

    Write-Host "Running $mode $algo..."

    if ($mode -eq "nonblocking") {
        $env:USE_NONBLOCKING_MPI = "1"
    } else {
        Remove-Item env:USE_NONBLOCKING_MPI -ErrorAction SilentlyContinue
    }

    $output = & $mpiexec -n $np .\build\main_mpi.exe @args 2>&1
    $result = $output | Out-String

    "=== $mode - $algo ===" | Out-File -FilePath $output_file -Append -Encoding utf8
    $result | Out-File -FilePath $output_file -Append -Encoding utf8
    "" | Out-File -FilePath $output_file -Append -Encoding utf8
}

# Run all experiments
Run-Experiment "blocking" "IVF-PQ" @($threads, $nlist, $nprobe, $rerank_p, $query_n, "local")
Run-Experiment "nonblocking" "IVF-PQ" @($threads, $nlist, $nprobe, $rerank_p, $query_n, "local")

Run-Experiment "blocking" "block-HNSW" @($threads, $hnsw_m, $ef, $rerank_p, $query_n, "hnsw")
Run-Experiment "nonblocking" "block-HNSW" @($threads, $hnsw_m, $ef, $rerank_p, $query_n, "hnsw")

Run-Experiment "blocking" "IVF+HNSW" @($threads, $nlist, $nprobe, $ef, $query_n, "ivf-hnsw")
Run-Experiment "nonblocking" "IVF+HNSW" @($threads, $nlist, $nprobe, $ef, $query_n, "ivf-hnsw")

Run-Experiment "blocking" "HNSW-on-HNSW" @($threads, $nblocks, $nprobe_blocks, $ef, $query_n, "hnsw-on-hnsw")
Run-Experiment "nonblocking" "HNSW-on-HNSW" @($threads, $nblocks, $nprobe_blocks, $ef, $query_n, "hnsw-on-hnsw")

# Clean up environment
Remove-Item env:USE_NONBLOCKING_MPI -ErrorAction SilentlyContinue

Write-Host "Done! Results saved to $output_file"
