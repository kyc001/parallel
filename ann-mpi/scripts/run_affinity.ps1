$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$textFile = "results/affinity_$timestamp.txt"
$csvFile = "results/affinity_$timestamp.csv"

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
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$AffinityMask = ""
    )

    $stdout = New-TemporaryFile
    $stderr = New-TemporaryFile
    try {
        if ($AffinityMask) {
            $argText = ($Arguments | ForEach-Object { '"' + ($_ -replace '"', '\"') + '"' }) -join " "
            $command = 'start "" /B /WAIT /AFFINITY {0} "{1}" -n {2} .\build\main_mpi.exe {3}' -f `
                $AffinityMask, $MPIEXEC, $Np, $argText
            $process = Start-Process -FilePath "cmd.exe" -ArgumentList @("/d", "/s", "/c", $command) -NoNewWindow `
                -Wait -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
        } else {
            $mpiArgs = @("-n", "$Np", ".\build\main_mpi.exe") + $Arguments
            $process = Start-Process -FilePath $MPIEXEC -ArgumentList $mpiArgs -NoNewWindow `
                -Wait -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
        }
        $output = ((Get-Content -LiteralPath $stdout -Raw -ErrorAction SilentlyContinue) + "`n" +
            (Get-Content -LiteralPath $stderr -Raw -ErrorAction SilentlyContinue))
        if ($process.ExitCode -ne 0) {
            throw "MPI run failed with exit code $($process.ExitCode).`n$output"
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

$affinityModes = @(
    @{ label = "default"; mask = ""       },
    @{ label = "p_only";  mask = "FFF"    },
    @{ label = "e_only";  mask = "FF000"  },
    @{ label = "p_e_all"; mask = "FFFFF"  }
)

$configs = @(
    @{ algorithm = "IVF-PQ";       np = 4; threads = 2; args = @("16", "4", "1000", "2000", "local") },
    @{ algorithm = "Block-HNSW";   np = 4; threads = 2; args = @("16", "50", "1000", "2000", "hnsw") },
    @{ algorithm = "IVF+HNSW";     np = 4; threads = 2; args = @("16", "4", "50", "2000", "ivf-hnsw") },
    @{ algorithm = "HNSW-on-HNSW"; np = 4; threads = 2; args = @("16", "4", "50", "2000", "hnsw-on-hnsw") }
)

$header = @"
Windows MPI affinity comparison
Platform: Windows local (MS-MPI)
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
ANN_DATA_PATH: $env:ANN_DATA_PATH
MPIEXEC: $MPIEXEC
Topology assumption: logical 0-11 = P-core HT, 12-19 = E-core

"@
$header | Out-File -FilePath $textFile -Encoding utf8

"platform,algorithm,affinity_mode,affinity_mask,np,nthreads,recall,latency_us,max_local_us,comm_merge_us,rank_min_us,rank_max_us,rank_mean_us,imbalance,header,per_rank_us" |
    Out-File -FilePath $csvFile -Encoding utf8

Write-Host "Building MPI binary..."
mpic++ main.cc -o build/main_mpi.exe -O2 -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma
Write-Host "Build complete."

foreach ($config in $configs) {
    foreach ($mode in $affinityModes) {
        $case = "{0} affinity={1} np={2} threads={3}" -f `
            $config.algorithm, $mode.label, $config.np, $config.threads
        Write-Host "Running $case..."
        "===" | Out-File -FilePath $textFile -Append -Encoding utf8
        "CASE: $case" | Out-File -FilePath $textFile -Append -Encoding utf8

        $args = @("$($config.threads)") + $config.args
        $output = Invoke-MpiRun -Np $config.np -Arguments $args -AffinityMask $mode.mask
        $output | Out-File -FilePath $textFile -Append -Encoding utf8

        $metrics = Parse-Metrics -Output $output
        $row = [pscustomobject]@{
            platform      = "Windows MS-MPI"
            algorithm     = $config.algorithm
            affinity_mode = $mode.label
            affinity_mask = $mode.mask
            np            = $config.np
            nthreads      = $config.threads
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

Write-Host "Affinity comparison complete."
Write-Host "Text log: $textFile"
Write-Host "CSV: $csvFile"
