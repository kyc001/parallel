$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$textFile = "results/hybrid_layout_$timestamp.txt"
$csvFile = "results/hybrid_layout_$timestamp.csv"

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

$env:ANN_DATA_PATH = "D:\Study\26sp\parallel\files"

function Invoke-MpiRun {
    param(
        [Parameter(Mandatory = $true)][int]$Np,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

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
        Remove-Item -LiteralPath $stdout, $stderr -Force -ErrorAction SilentlyContinue
    }
}

function Parse-Metrics {
    param(
        [Parameter(Mandatory = $true)][string]$Output
    )

    function Get-MatchValue {
        param([string]$Pattern, [int]$Group = 1)
        $match = [regex]::Match($Output, $Pattern)
        if ($match.Success -and $match.Groups.Count -gt $Group) {
            return $match.Groups[$Group].Value
        }
        return ""
    }

    $header = Get-MatchValue '(?m)^([^\r\n]*mpi_procs=[^\r\n]*)$'
    $recall = Get-MatchValue 'average recall:\s*([0-9.]+)'
    $latency = Get-MatchValue 'average latency \(us\):\s*([0-9.]+)'
    $maxLocal = Get-MatchValue 'max local search latency \(us\):\s*([0-9.]+)'
    $commMerge = Get-MatchValue 'comm\+merge latency \(us\):\s*([0-9.]+)'
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

    return [pscustomobject]@{
        header        = $header
        recall        = $recall
        latency_us    = $latency
        max_local_us  = $maxLocal
        comm_merge_us = $commMerge
        rank_min_us   = $rankMin
        rank_max_us   = $rankMax
        rank_mean_us  = $rankMean
        imbalance     = $imbalance
        per_rank_us   = $perRankLine.Trim()
    }
}

$layouts = @(
    @{ worker_budget = 8;  np = 1; threads = 8  },
    @{ worker_budget = 8;  np = 2; threads = 4  },
    @{ worker_budget = 8;  np = 4; threads = 2  },
    @{ worker_budget = 8;  np = 8; threads = 1  },
    @{ worker_budget = 16; np = 1; threads = 16 },
    @{ worker_budget = 16; np = 2; threads = 8  },
    @{ worker_budget = 16; np = 4; threads = 4  },
    @{ worker_budget = 16; np = 8; threads = 2  }
)

$configs = @(
    @{ algorithm = "IVF-PQ";       args = @("16", "4", "1000", "2000", "local") },
    @{ algorithm = "Block-HNSW";   args = @("16", "50", "1000", "2000", "hnsw") },
    @{ algorithm = "IVF+HNSW";     args = @("16", "4", "50", "2000", "ivf-hnsw") },
    @{ algorithm = "HNSW-on-HNSW"; args = @("16", "4", "50", "2000", "hnsw-on-hnsw") }
)

$header = @"
Hybrid MPI x OpenMP layout sweep
Platform: Windows local (MS-MPI)
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
ANN_DATA_PATH: $env:ANN_DATA_PATH
MPIEXEC: $MPIEXEC

"@
$header | Out-File -FilePath $textFile -Encoding utf8

"platform,algorithm,worker_budget,layout,np,nthreads,recall,latency_us,max_local_us,comm_merge_us,rank_min_us,rank_max_us,rank_mean_us,imbalance,header,per_rank_us" |
    Out-File -FilePath $csvFile -Encoding utf8

Write-Host "Building MPI binary..."
mpic++ main.cc -o build/main_mpi.exe -O2 -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma
Write-Host "Build complete."

foreach ($config in $configs) {
    foreach ($layout in $layouts) {
        $case = "{0} budget={1} np={2} threads={3}" -f `
            $config.algorithm, $layout.worker_budget, $layout.np, $layout.threads
        Write-Host "Running $case..."
        "===" | Out-File -FilePath $textFile -Append -Encoding utf8
        "CASE: $case" | Out-File -FilePath $textFile -Append -Encoding utf8

        $args = @("$($layout.threads)") + $config.args
        $output = Invoke-MpiRun -Np $layout.np -Arguments $args
        $output | Out-File -FilePath $textFile -Append -Encoding utf8

        $metrics = Parse-Metrics -Output $output
        $layoutLabel = "{0}x{1}" -f $layout.np, $layout.threads
        $row = [pscustomobject]@{
            platform      = "Windows MS-MPI"
            algorithm     = $config.algorithm
            worker_budget = $layout.worker_budget
            layout        = $layoutLabel
            np            = $layout.np
            nthreads      = $layout.threads
            recall        = $metrics.recall
            latency_us    = $metrics.latency_us
            max_local_us  = $metrics.max_local_us
            comm_merge_us = $metrics.comm_merge_us
            rank_min_us   = $metrics.rank_min_us
            rank_max_us   = $metrics.rank_max_us
            rank_mean_us  = $metrics.rank_mean_us
            imbalance     = $metrics.imbalance
            header        = $metrics.header
            per_rank_us   = $metrics.per_rank_us
        }
        $row | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 |
            Out-File -FilePath $csvFile -Append -Encoding utf8
        "" | Out-File -FilePath $textFile -Append -Encoding utf8
    }
}

Write-Host "Hybrid layout sweep complete."
Write-Host "Text log: $textFile"
Write-Host "CSV: $csvFile"
