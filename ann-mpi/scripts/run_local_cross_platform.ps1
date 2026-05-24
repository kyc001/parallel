param(
    [string]$Log = "results/local_cross_platform.txt",
    [int]$Np = 2,
    [int]$Threads = 2,
    [int]$QueryN = 200,
    [int]$HnswOnHnswNprobe = 16,
    [string]$DataPath = "D:\Study\26sp\parallel\files",
    [string]$Mpiexec = "C:\Program Files\Microsoft MPI\Bin\mpiexec.exe"
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force (Split-Path -Parent $Log) | Out-Null
New-Item -ItemType Directory -Force "build" | Out-Null
$env:ANN_DATA_PATH = $DataPath

function Write-LogLine {
    param([string]$Line)
    Add-Content -LiteralPath $Log -Value $Line
}

function Invoke-Logged {
    param(
        [string]$Label,
        [string]$Command,
        [string[]]$ArgumentList
    )

    Write-LogLine "---"
    Write-LogLine "STEP: $Label"
    Write-LogLine "COMMAND: $Command $($ArgumentList -join ' ')"

    $stdoutPath = [System.IO.Path]::GetTempFileName()
    $stderrPath = [System.IO.Path]::GetTempFileName()

    try {
        $process = Start-Process -FilePath $Command -ArgumentList $ArgumentList `
            -NoNewWindow -Wait -PassThru `
            -RedirectStandardOutput $stdoutPath `
            -RedirectStandardError $stderrPath
        $code = $process.ExitCode

        $stdout = Get-Content -LiteralPath $stdoutPath -Raw
        $stderr = Get-Content -LiteralPath $stderrPath -Raw
        if ($stdout) {
            Add-Content -LiteralPath $Log -Value $stdout.TrimEnd()
        }
        if ($stderr) {
            Add-Content -LiteralPath $Log -Value $stderr.TrimEnd()
        }
    } finally {
        Remove-Item -LiteralPath $stdoutPath, $stderrPath -Force -ErrorAction SilentlyContinue
    }

    Write-LogLine "EXIT: $code"

    if ($code -ne 0) {
        throw "$Label failed with exit code $code"
    }
}

Set-Content -LiteralPath $Log -Value @(
    "Local cross-platform validation",
    "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "Host: Windows local",
    "MPIEXEC=$Mpiexec",
    "MPICXX=mpic++",
    "NP=$Np",
    "THREADS=$Threads",
    "QUERY_N=$QueryN",
    "HNSW_ON_HNSW_NPROBE=$HnswOnHnswNprobe",
    "ANN_DATA_PATH=$DataPath",
    "",
    "This run uses the same algorithm parameters as results/kunpeng_smoke.txt."
)

Invoke-Logged "compile no-MPI fallback" "g++" @(
    "main.cc", "-o", "build/main_no_mpi.exe", "-O2", "-std=c++11", "-I.",
    "-fopenmp", "-lpthread", "-mavx2", "-mfma", "-DANN_NO_MPI"
)

Invoke-Logged "compile MPI binary" "mpic++" @(
    "main.cc", "-o", "build/main_mpi_cross_platform.exe", "-O2",
    "-std=c++11", "-I.", "-fopenmp", "-lpthread", "-mavx2", "-mfma"
)

Invoke-Logged "MPI IVF-PQ cross-platform run" $Mpiexec @(
    "-n", "$Np", ".\build\main_mpi_cross_platform.exe", "$Threads",
    "16", "4", "1000", "$QueryN", "local"
)

Invoke-Logged "MPI block-HNSW cross-platform run" $Mpiexec @(
    "-n", "$Np", ".\build\main_mpi_cross_platform.exe", "$Threads",
    "16", "50", "1000", "$QueryN", "hnsw"
)

Invoke-Logged "MPI IVF+HNSW nested cross-platform run" $Mpiexec @(
    "-n", "$Np", ".\build\main_mpi_cross_platform.exe", "$Threads",
    "16", "4", "50", "$QueryN", "ivf-hnsw"
)

Invoke-Logged "MPI HNSW-on-HNSW cross-platform run" $Mpiexec @(
    "-n", "$Np", ".\build\main_mpi_cross_platform.exe", "$Threads",
    "16", "$HnswOnHnswNprobe", "50", "$QueryN", "hnsw-on-hnsw"
)

Get-Content -LiteralPath $Log | Select-Object -Last 80
