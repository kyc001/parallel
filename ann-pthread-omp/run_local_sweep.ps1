param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (Test-Path "C:\msys64\usr\bin") {
    $env:PATH = "C:\msys64\usr\bin;$env:PATH"
}

$resultsDir = "results/i9"
New-Item -ItemType Directory -Force -Path $resultsDir | Out-Null

$env:OMP_PLACES = "cores"
$env:OMP_PROC_BIND = "close"
$env:OMP_SCHEDULE = "static"
$env:PTHREAD_POOL_CHUNK_INTER = "64"
$env:PTHREAD_POOL_CHUNK_INTRA = "1024"

$threadsList = if ($DryRun) { @(1, 12) } else { @(1, 2, 4, 6, 8, 12) }
$outCsv = Join-Path $resultsDir ($(if ($DryRun) { "lab3_pinned_dryrun.csv" } else { "lab3_pinned.csv" }))
$mainCsv = Join-Path $resultsDir "lab3.csv"
$backupCsv = Join-Path $resultsDir "lab3.csv.unpinned.bak"

if (Test-Path $backupCsv) {
    throw "Refusing to overwrite existing backup: $backupCsv"
}
if (Test-Path $outCsv) {
    Remove-Item $outCsv
}
if (Test-Path $mainCsv) {
    Move-Item $mainCsv $backupCsv
}

function Invoke-Pinned {
    param([string]$Exe, [int]$Threads, [string]$LogPath, [string]$ParModel)
    if ($ParModel -eq "omp" -or $ParModel -eq "serial") {
        $env:OMP_NUM_THREADS = [string]$Threads
        Remove-Item Env:PTHREAD_NUM_THREADS -ErrorAction SilentlyContinue
    } else {
        $env:PTHREAD_NUM_THREADS = [string]$Threads
        Remove-Item Env:OMP_NUM_THREADS -ErrorAction SilentlyContinue
    }
    if (-not (Test-Path ".\$Exe")) {
        throw "Missing executable: $Exe"
    }
    $cmd = 'start /AFFINITY 0xFFF /WAIT /B "" ".\{0}" > "{1}" 2>&1' -f $Exe, $LogPath
    cmd.exe /c $cmd
    if ($LASTEXITCODE -ne 0) {
        throw "$Exe failed with exit code $LASTEXITCODE"
    }
}

$serial = @("baseline.exe", "flatsimd.exe", "sqsimd.exe", "pqsimd.exe", "fastscan.exe")
$ompInter = @("omp_inter_flat.exe", "omp_inter_sq.exe", "omp_inter_pq.exe", "omp_inter_fastscan.exe")
$ompIntra = @("omp_intra_flat.exe", "omp_intra_sq.exe", "omp_intra_pq.exe", "omp_intra_fastscan.exe")
$paradigms = @("dynamic", "barrier", "pool")
$methods = @("flat", "sq", "pq", "fastscan")

$total = ($serial.Count + $ompInter.Count + $ompIntra.Count +
          2 * $paradigms.Count * $methods.Count) * $threadsList.Count
$idx = 0

function Run-One {
    param([string]$Exe, [int]$Threads, [string]$LogPath, [string]$ParModel)
    $script:idx += 1
    Write-Host "[$script:idx/$script:total] $Exe t=$Threads"
    Invoke-Pinned $Exe $Threads $LogPath $ParModel
}

try {
    foreach ($t in $threadsList) {
        foreach ($exe in $serial) {
            $name = [System.IO.Path]::GetFileNameWithoutExtension($exe)
            $log = Join-Path $resultsDir "pinned_serial_${name}_t${t}.log"
            Run-One $exe $t $log "serial"
        }
    }

    foreach ($exe in $ompInter) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($exe)
        foreach ($t in $threadsList) {
            Run-One $exe $t (Join-Path $resultsDir "pinned_${name}_t${t}.log") "omp"
        }
    }

    foreach ($exe in $ompIntra) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($exe)
        foreach ($t in $threadsList) {
            Run-One $exe $t (Join-Path $resultsDir "pinned_${name}_t${t}.log") "omp"
        }
    }

    foreach ($scope in @("inter", "intra")) {
        foreach ($paradigm in $paradigms) {
            foreach ($method in $methods) {
                $exe = "pthread_${paradigm}_${scope}_${method}.exe"
                foreach ($t in $threadsList) {
                    $log = Join-Path $resultsDir "pinned_pthread_${paradigm}_${scope}_${method}_t${t}.log"
                    Run-One $exe $t $log "pthread"
                }
            }
        }
    }

    if (-not (Test-Path $mainCsv)) {
        throw "Pinned run did not produce $mainCsv"
    }
    Move-Item $mainCsv $outCsv
    Write-Host "Wrote $outCsv"
}
finally {
    if (Test-Path $backupCsv) {
        if (Test-Path $mainCsv) {
            Move-Item $mainCsv "$outCsv.partial" -Force
        }
        Move-Item $backupCsv $mainCsv
    }
    Remove-Item Env:OMP_NUM_THREADS -ErrorAction SilentlyContinue
    Remove-Item Env:PTHREAD_NUM_THREADS -ErrorAction SilentlyContinue
}
