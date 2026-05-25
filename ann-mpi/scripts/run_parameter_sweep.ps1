# Parameter sweep experiments for report
# Tests different parameter combinations to generate recall-latency curves

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$resultFile = "results/parameter_sweep_$timestamp.txt"

$mpiexecCandidates = @(
    "C:\Program Files\Microsoft MPI\Bin\mpiexec.exe",
    "C:\Program Files (x86)\Microsoft SDKs\MPI\Bin\mpiexec.exe"
)
$MPIEXEC = $mpiexecCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $MPIEXEC) {
    $cmd = Get-Command mpiexec -ErrorAction SilentlyContinue
    if ($cmd) { $MPIEXEC = $cmd.Source }
}
if (-not $MPIEXEC) {
    throw "mpiexec not found. Install MS-MPI or add mpiexec.exe to PATH."
}

function Invoke-MpiRun {
    param(
        [string[]]$Arguments
    )

    $stdoutPath = [System.IO.Path]::GetTempFileName()
    $stderrPath = [System.IO.Path]::GetTempFileName()
    try {
        $process = Start-Process -FilePath $MPIEXEC `
            -ArgumentList $Arguments `
            -NoNewWindow `
            -Wait `
            -PassThru `
            -RedirectStandardOutput $stdoutPath `
            -RedirectStandardError $stderrPath
        $output = (Get-Content -Raw -ErrorAction SilentlyContinue $stdoutPath) +
                  (Get-Content -Raw -ErrorAction SilentlyContinue $stderrPath)
        if ($process.ExitCode -ne 0) {
            throw "mpiexec failed with exit code $($process.ExitCode). Output:`n$output"
        }
        return $output
    } finally {
        Remove-Item -Force $stdoutPath, $stderrPath -ErrorAction SilentlyContinue
    }
}

# Ensure results directory exists
if (-not (Test-Path "results")) {
    New-Item -ItemType Directory -Path "results" | Out-Null
}

# Set data path
$env:ANN_DATA_PATH = "D:\Study\26sp\parallel\files"

# Fixed parameters
$NP = 8
$THREADS = 2
$QUERY_N = 2000

Write-Host "=== Parameter Sweep Experiments ===" | Tee-Object -FilePath $resultFile
Write-Host "Timestamp: $timestamp" | Tee-Object -FilePath $resultFile -Append
Write-Host "Fixed: np=$NP, threads=$THREADS, query_n=$QUERY_N" | Tee-Object -FilePath $resultFile -Append
Write-Host "MPIEXEC=$MPIEXEC" | Tee-Object -FilePath $resultFile -Append
Write-Host "" | Tee-Object -FilePath $resultFile -Append

# Build
Write-Host "Building..." | Tee-Object -FilePath $resultFile -Append
if (Test-Path "main.exe") { Remove-Item -Force "main.exe" }
mpic++ main.cc -o main -O2 -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma 2>&1 | Out-Null
Write-Host "Build complete`n" | Tee-Object -FilePath $resultFile -Append

# 1. IVF-PQ: Sweep nprobe (nlist=16 fixed)
Write-Host "=== IVF-PQ: nprobe sweep (nlist=16) ===" | Tee-Object -FilePath $resultFile -Append
$nlist = 16
foreach ($nprobe in @(1, 2, 4, 8, 16)) {
    Write-Host "Running IVF-PQ with nlist=$nlist, nprobe=$nprobe..." | Tee-Object -FilePath $resultFile -Append
    $output = Invoke-MpiRun @("-np", "$NP", "./main", "$THREADS", "$nlist", "$nprobe", "1000", "$QUERY_N", "local")
    $output | Tee-Object -FilePath $resultFile -Append
    Write-Host "" | Tee-Object -FilePath $resultFile -Append
}

# 2. IVF-PQ: Sweep nlist (nprobe=4 fixed)
Write-Host "=== IVF-PQ: nlist sweep (nprobe=4) ===" | Tee-Object -FilePath $resultFile -Append
$nprobe = 4
foreach ($nlist in @(8, 16, 32, 64)) {
    Write-Host "Running IVF-PQ with nlist=$nlist, nprobe=$nprobe..." | Tee-Object -FilePath $resultFile -Append
    $output = Invoke-MpiRun @("-np", "$NP", "./main", "$THREADS", "$nlist", "$nprobe", "1000", "$QUERY_N", "local")
    $output | Tee-Object -FilePath $resultFile -Append
    Write-Host "" | Tee-Object -FilePath $resultFile -Append
}

# 3. Block-HNSW: Sweep ef (M=16 fixed)
Write-Host "=== Block-HNSW: ef sweep (M=16) ===" | Tee-Object -FilePath $resultFile -Append
$M = 16
foreach ($ef in @(10, 20, 50, 100, 200)) {
    Write-Host "Running Block-HNSW with M=$M, ef=$ef..." | Tee-Object -FilePath $resultFile -Append
    $output = Invoke-MpiRun @("-np", "$NP", "./main", "$THREADS", "$M", "$ef", "1000", "$QUERY_N", "hnsw")
    $output | Tee-Object -FilePath $resultFile -Append
    Write-Host "" | Tee-Object -FilePath $resultFile -Append
}

# 4. IVF+HNSW: Sweep nprobe (nlist=16, ef=50 fixed)
Write-Host "=== IVF+HNSW: nprobe sweep (nlist=16, ef=50) ===" | Tee-Object -FilePath $resultFile -Append
$nlist = 16
$ef = 50
foreach ($nprobe in @(1, 2, 4, 8, 16)) {
    Write-Host "Running IVF+HNSW with nlist=$nlist, nprobe=$nprobe, ef=$ef..." | Tee-Object -FilePath $resultFile -Append
    $output = Invoke-MpiRun @("-np", "$NP", "./main", "$THREADS", "$nlist", "$nprobe", "$ef", "$QUERY_N", "ivf-hnsw")
    $output | Tee-Object -FilePath $resultFile -Append
    Write-Host "" | Tee-Object -FilePath $resultFile -Append
}

# 5. HNSW-on-HNSW: Sweep nprobe_blocks (nblocks=16, ef=50 fixed)
Write-Host "=== HNSW-on-HNSW: nprobe_blocks sweep (nblocks=16, ef=50) ===" | Tee-Object -FilePath $resultFile -Append
$nblocks = 16
$ef = 50
foreach ($nprobe_blocks in @(1, 2, 4, 8, 16)) {
    Write-Host "Running HNSW-on-HNSW with nblocks=$nblocks, nprobe=$nprobe_blocks, ef=$ef..." | Tee-Object -FilePath $resultFile -Append
    $output = Invoke-MpiRun @("-np", "$NP", "./main", "$THREADS", "$nblocks", "$nprobe_blocks", "$ef", "$QUERY_N", "hnsw-on-hnsw")
    $output | Tee-Object -FilePath $resultFile -Append
    Write-Host "" | Tee-Object -FilePath $resultFile -Append
}

Write-Host "=== Parameter sweep complete ===" | Tee-Object -FilePath $resultFile -Append
Write-Host "Results saved to: $resultFile" | Tee-Object -FilePath $resultFile -Append
