# Strong scaling experiments: test np=1,2,4,8
# Measures parallel efficiency and communication overhead scaling

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$resultFile = "results/scalability_$timestamp.txt"

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
$THREADS = 2
$QUERY_N = 2000

Write-Host "=== Strong Scaling Experiments ===" | Tee-Object -FilePath $resultFile
Write-Host "Timestamp: $timestamp" | Tee-Object -FilePath $resultFile -Append
Write-Host "Fixed: threads=$THREADS, query_n=$QUERY_N" | Tee-Object -FilePath $resultFile -Append
Write-Host "MPIEXEC=$MPIEXEC" | Tee-Object -FilePath $resultFile -Append
Write-Host "" | Tee-Object -FilePath $resultFile -Append

# Build
Write-Host "Building..." | Tee-Object -FilePath $resultFile -Append
if (Test-Path "main.exe") { Remove-Item -Force "main.exe" }
mpic++ main.cc -o main -O2 -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma 2>&1 | Out-Null
Write-Host "Build complete`n" | Tee-Object -FilePath $resultFile -Append

# Test configurations
$configs = @(
    @{name="IVF-PQ"; args="16 4 1000"; mode="local"},
    @{name="Block-HNSW"; args="16 50 1000"; mode="hnsw"},
    @{name="IVF+HNSW"; args="16 4 50"; mode="ivf-hnsw"},
    @{name="HNSW-on-HNSW"; args="16 8 50"; mode="hnsw-on-hnsw"}
)

foreach ($config in $configs) {
    Write-Host "=== $($config.name): np scaling ===" | Tee-Object -FilePath $resultFile -Append

    foreach ($np in @(1, 2, 4, 8)) {
        Write-Host "Running $($config.name) with np=$np..." | Tee-Object -FilePath $resultFile -Append
        $cmdArgs = @("$THREADS") + $config.args.Split() + @("$QUERY_N", $config.mode)
        $output = Invoke-MpiRun (@("-np", "$np", "./main") + $cmdArgs)
        $output | Tee-Object -FilePath $resultFile -Append
        Write-Host "" | Tee-Object -FilePath $resultFile -Append
    }
    Write-Host "" | Tee-Object -FilePath $resultFile -Append
}

Write-Host "=== Scalability experiments complete ===" | Tee-Object -FilePath $resultFile -Append
Write-Host "Results saved to: $resultFile" | Tee-Object -FilePath $resultFile -Append
