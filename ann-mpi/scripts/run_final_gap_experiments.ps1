$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$textFile = "results/final_gap_experiments_$timestamp.txt"
$csvFile = "results/final_gap_experiments_$timestamp.csv"

$mpiexecCandidates = @(
    "C:\Program Files\Microsoft MPI\Bin\mpiexec.exe",
    "C:\Program Files (x86)\Microsoft SDKs\MPI\Bin\mpiexec.exe"
)
$MPIEXEC = $mpiexecCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $MPIEXEC) {
    throw "mpiexec not found. Install MS-MPI or add mpiexec.exe to PATH."
}

if (-not (Test-Path "results")) {
    New-Item -ItemType Directory -Path "results" | Out-Null
}
if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}

if (-not $env:ANN_DATA_PATH) {
    $env:ANN_DATA_PATH = "D:\Study\26sp\parallel\files"
}

function Invoke-MpiRun {
    param(
        [Parameter(Mandatory = $true)][int]$Np,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [hashtable]$Environment = @{}
    )

    $oldValues = @{}
    foreach ($key in $Environment.Keys) {
        $oldValues[$key] = [Environment]::GetEnvironmentVariable($key, "Process")
        [Environment]::SetEnvironmentVariable($key, [string]$Environment[$key], "Process")
    }

    $stdout = New-TemporaryFile
    $stderr = New-TemporaryFile
    try {
        $mpiArgs = @("-n", "$Np", ".\build\main_mpi.exe") + $Arguments
        $process = Start-Process -FilePath $MPIEXEC -ArgumentList $mpiArgs -NoNewWindow `
            -Wait -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
        $output = ((Get-Content -LiteralPath $stdout -Raw -ErrorAction SilentlyContinue) + "`n" +
            (Get-Content -LiteralPath $stderr -Raw -ErrorAction SilentlyContinue))
        if ($process.ExitCode -ne 0) {
            throw "mpiexec failed with exit code $($process.ExitCode).`n$output"
        }
        return $output
    } finally {
        foreach ($key in $Environment.Keys) {
            [Environment]::SetEnvironmentVariable($key, $oldValues[$key], "Process")
        }
        Remove-Item -LiteralPath $stdout, $stderr -Force -ErrorAction SilentlyContinue
    }
}

function Parse-Metrics {
    param([Parameter(Mandatory = $true)][string]$Output)

    function Get-MatchValue {
        param([string]$Pattern, [int]$Group = 1)
        $match = [regex]::Match($Output, $Pattern)
        if ($match.Success -and $match.Groups.Count -gt $Group) {
            return $match.Groups[$Group].Value
        }
        return ""
    }

    $perRankLine = Get-MatchValue 'per-rank search latency \(us\):([^\r\n]+)'
    $rankValues = @()
    foreach ($match in [regex]::Matches($perRankLine, 'rank\d+=([0-9.]+)')) {
        $rankValues += [double]$match.Groups[1].Value
    }

    $rankMin = ""
    $rankMax = ""
    $rankMean = ""
    $imbalance = ""
    if ($rankValues.Count -gt 0) {
        $rankMin = ($rankValues | Measure-Object -Minimum).Minimum.ToString("F5")
        $rankMax = ($rankValues | Measure-Object -Maximum).Maximum.ToString("F5")
        $rankMeanValue = ($rankValues | Measure-Object -Average).Average
        $rankMean = $rankMeanValue.ToString("F5")
        if ($rankMeanValue -gt 0.0) {
            $imbalance = (($rankValues | Measure-Object -Maximum).Maximum / $rankMeanValue).ToString("F5")
        }
    }

    $threadLine = Get-MatchValue 'mpi_thread_requested=([^\r\n]+)'
    $requested = ""
    $provided = ""
    $threadMatch = [regex]::Match($threadLine, '^([^,]+),\s*mpi_thread_provided=(.+)$')
    if ($threadMatch.Success) {
        $requested = $threadMatch.Groups[1].Value.Trim()
        $provided = $threadMatch.Groups[2].Value.Trim()
    }

    return [pscustomobject]@{
        header        = Get-MatchValue '([^\r\n]*mpi_procs=[^\r\n]*)'
        comm_mode     = Get-MatchValue 'comm_mode=([^\r\n]+)'
        thread_req    = $requested
        thread_got    = $provided
        base_partition = Get-MatchValue '(?m)^base_partition=([^,\r\n]+)'
        recall        = Get-MatchValue 'average recall:\s*([0-9.]+)'
        latency_us    = Get-MatchValue 'average latency \(us\):\s*([0-9.]+)'
        max_local_us  = Get-MatchValue 'max local search latency \(us\):\s*([0-9.]+)'
        comm_merge_us = Get-MatchValue 'comm\+merge latency \(us\):\s*([0-9.]+)'
        rank_min_us   = $rankMin
        rank_max_us   = $rankMax
        rank_mean_us  = $rankMean
        imbalance     = $imbalance
        per_rank_us   = $perRankLine.Trim()
    }
}

$header = @"
Final ANN MPI gap experiments
Platform: Windows local (MS-MPI)
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
ANN_DATA_PATH: $env:ANN_DATA_PATH
MPIEXEC: $MPIEXEC

"@
$header | Out-File -FilePath $textFile -Encoding utf8

"platform,experiment,case,algorithm,np,nthreads,recall,latency_us,max_local_us,comm_merge_us,rank_min_us,rank_max_us,rank_mean_us,imbalance,comm_mode,thread_requested,thread_provided,base_partition,header,per_rank_us" |
    Out-File -FilePath $csvFile -Encoding utf8

Write-Host "Building MPI binary..."
mpic++ main.cc -o build/main_mpi.exe -O2 -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma
Write-Host "Build complete."

$cases = @(
    @{
        experiment = "load_balance"
        case = "contiguous"
        algorithm = "Block-HNSW"
        np = 8
        threads = 2
        args = @("2", "16", "50", "1000", "2000", "hnsw")
        env = @{}
    },
    @{
        experiment = "load_balance"
        case = "shuffled"
        algorithm = "Block-HNSW"
        np = 8
        threads = 2
        args = @("2", "16", "50", "1000", "2000", "hnsw")
        env = @{ USE_SHUFFLED_BASE = "1"; BASE_SHUFFLE_SEED = "20260525" }
    },
    @{
        experiment = "thread_level"
        case = "funneled"
        algorithm = "IVF-PQ"
        np = 8
        threads = 2
        args = @("2", "16", "4", "1000", "2000", "local")
        env = @{}
    },
    @{
        experiment = "thread_level"
        case = "multiple"
        algorithm = "IVF-PQ"
        np = 8
        threads = 2
        args = @("2", "16", "4", "1000", "2000", "local")
        env = @{ USE_MPI_THREAD_MULTIPLE = "1" }
    }
)

foreach ($case in $cases) {
    $label = "{0} {1} {2}" -f $case.experiment, $case.case, $case.algorithm
    Write-Host "Running $label..."
    "===" | Out-File -FilePath $textFile -Append -Encoding utf8
    "CASE: $label" | Out-File -FilePath $textFile -Append -Encoding utf8
    $output = Invoke-MpiRun -Np $case.np -Arguments $case.args -Environment $case.env
    $output | Out-File -FilePath $textFile -Append -Encoding utf8

    $metrics = Parse-Metrics -Output $output
    $row = [pscustomobject]@{
        platform         = "Windows MS-MPI"
        experiment       = $case.experiment
        case             = $case.case
        algorithm        = $case.algorithm
        np               = $case.np
        nthreads         = $case.threads
        recall           = $metrics.recall
        latency_us       = $metrics.latency_us
        max_local_us     = $metrics.max_local_us
        comm_merge_us    = $metrics.comm_merge_us
        rank_min_us      = $metrics.rank_min_us
        rank_max_us      = $metrics.rank_max_us
        rank_mean_us     = $metrics.rank_mean_us
        imbalance        = $metrics.imbalance
        comm_mode        = $metrics.comm_mode
        thread_requested = $metrics.thread_req
        thread_provided  = $metrics.thread_got
        base_partition   = $metrics.base_partition
        header           = $metrics.header
        per_rank_us      = $metrics.per_rank_us
    }
    $row | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 |
        Out-File -FilePath $csvFile -Append -Encoding utf8
    "" | Out-File -FilePath $textFile -Append -Encoding utf8
}

Write-Host "Final gap experiments complete."
Write-Host "Text log: $textFile"
Write-Host "CSV: $csvFile"
