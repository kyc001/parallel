param(
    [int]$Threads = 2,
    [int]$HnswM = 16,
    [int]$Ef = 50,
    [int]$UnusedP = 1000,
    [int]$QueryN = 2000,
    [string]$Mode = "hnsw",
    [string]$VtunePath = "C:\Program Files (x86)\Intel\oneAPI\vtune\latest\bin64\vtune.exe",
    [int]$TimeoutSeconds = 600,
    [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$mpiexecCandidates = @(
    "C:\Program Files\Microsoft MPI\Bin\mpiexec.exe",
    "C:\Program Files (x86)\Microsoft SDKs\MPI\Bin\mpiexec.exe"
)
$MPIEXEC = $mpiexecCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $MPIEXEC) {
    throw "mpiexec not found. Install MS-MPI or add mpiexec.exe to PATH."
}
if (-not (Test-Path -LiteralPath $VtunePath)) {
    throw "VTune CLI not found: $VtunePath"
}

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$BuildDir = Join-Path $RepoRoot "build"
$Binary = Join-Path $BuildDir "main_mpi_profile.exe"
$ExportDir = Join-Path $RepoRoot "results\vtune_exports"
$RawResultDir = Join-Path $RepoRoot "results\vtune_hotspots_mpi_rank0"
$Rank0Wrapper = Join-Path $BuildDir "vtune_rank0.cmd"
$CollectLog = Join-Path $ExportDir "hotspots_mpi_collect_log.txt"
$SummaryOut = Join-Path $ExportDir "hotspots_mpi_summary.txt"
$FunctionsOut = Join-Path $ExportDir "hotspots_mpi_functions.csv"
$Manifest = Join-Path $ExportDir "hotspots_mpi_manifest.txt"
$MpiStdout = Join-Path $ExportDir "hotspots_mpi_stdout.txt"
$MpiStderr = Join-Path $ExportDir "hotspots_mpi_stderr.txt"
$DefaultDataPath = Join-Path (Split-Path $RepoRoot -Parent) "files"

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
New-Item -ItemType Directory -Force -Path $ExportDir | Out-Null

if (-not $env:ANN_DATA_PATH) {
    $env:ANN_DATA_PATH = $DefaultDataPath
}

Push-Location $RepoRoot
try {
    if (-not $SkipBuild) {
        Write-Host "[build] mpic++ main.cc -> build\main_mpi_profile.exe"
        mpic++ main.cc -o $Binary -O2 -g -std=c++11 -I. -fopenmp -lpthread -mavx2 -mfma
    }

    if (Test-Path -LiteralPath $RawResultDir) {
        Remove-Item -LiteralPath $RawResultDir -Recurse -Force
    }

    $header = @(
        "Date: $(Get-Date -Format o)",
        "Working directory: $RepoRoot",
        "ANN_DATA_PATH: $env:ANN_DATA_PATH",
        "MPIEXEC: $MPIEXEC",
        "VTune: $VtunePath",
        "Collection: hotspots",
        "Mode: rank0-wrapped MPI profile",
        "Target args: $Threads $HnswM $Ef $UnusedP $QueryN $Mode",
        ""
    )
    $header | Set-Content -Encoding UTF8 $CollectLog

    @(
        "@echo off",
        "set `"ANN_DATA_PATH=$env:ANN_DATA_PATH`"",
        "`"$VtunePath`" -collect hotspots -knob sampling-mode=sw -result-dir `"$RawResultDir`" -- `"$Binary`" %*",
        "exit /b %ERRORLEVEL%"
    ) | Set-Content -Encoding ASCII $Rank0Wrapper

    $mpiArgs = @(
        "-env", "ANN_DATA_PATH", $env:ANN_DATA_PATH,
        "-n", "1",
        "cmd.exe", "/d", "/s", "/c", $Rank0Wrapper, "$Threads", "$HnswM", "$Ef", "$UnusedP", "$QueryN", $Mode,
        ":",
        "-env", "ANN_DATA_PATH", $env:ANN_DATA_PATH,
        "-n", "1",
        $Binary, "$Threads", "$HnswM", "$Ef", "$UnusedP", "$QueryN", $Mode
    )

    "`n> $MPIEXEC $($mpiArgs -join ' ')" | Tee-Object -FilePath $CollectLog -Append | Out-Null
    Remove-Item -LiteralPath $MpiStdout, $MpiStderr -Force -ErrorAction SilentlyContinue
    $mpiProcess = Start-Process -FilePath $MPIEXEC -ArgumentList $mpiArgs -PassThru `
        -NoNewWindow -RedirectStandardOutput $MpiStdout -RedirectStandardError $MpiStderr
    try {
        Wait-Process -Id $mpiProcess.Id -Timeout $TimeoutSeconds -ErrorAction Stop
    } catch {
        "`n[timeout] MPI VTune collection exceeded ${TimeoutSeconds}s; terminating process tree." |
            Tee-Object -FilePath $CollectLog -Append | Out-Null
        & taskkill.exe /PID $mpiProcess.Id /T /F 2>&1 |
            Tee-Object -FilePath $CollectLog -Append | Out-Null
        throw "MPI VTune collection timed out after ${TimeoutSeconds}s. See $CollectLog"
    }
    if (Test-Path -LiteralPath $MpiStdout) {
        Get-Content -LiteralPath $MpiStdout | Tee-Object -FilePath $CollectLog -Append | Out-Null
    }
    if (Test-Path -LiteralPath $MpiStderr) {
        Get-Content -LiteralPath $MpiStderr | Tee-Object -FilePath $CollectLog -Append | Out-Null
    }
    if ($mpiProcess.ExitCode -ne 0) {
        throw "MPI VTune collection failed with exit code $($mpiProcess.ExitCode). See $CollectLog"
    }

    Write-Host "[export] summary"
    & $VtunePath -report summary -result-dir $RawResultDir -report-output $SummaryOut -format text
    if ($LASTEXITCODE -ne 0) {
        throw "VTune summary export failed."
    }

    Write-Host "[export] hotspots"
    & $VtunePath -report hotspots -result-dir $RawResultDir -report-output $FunctionsOut -format csv -csv-delimiter comma -limit 30
    if ($LASTEXITCODE -ne 0) {
        throw "VTune hotspots export failed."
    }

    @(
        "Date: $(Get-Date -Format o)",
        "Raw result directory: $RawResultDir",
        "Profiled rank: rank 0 in a 2-rank MPI job",
        "Rank 0 wrapper: $Rank0Wrapper",
        "Peer rank: plain $Binary $Threads $HnswM $Ef $UnusedP $QueryN $Mode",
        "ANN_DATA_PATH: $env:ANN_DATA_PATH",
        "Exports:",
        "  - results/vtune_exports/hotspots_mpi_summary.txt",
        "  - results/vtune_exports/hotspots_mpi_functions.csv",
        "  - results/vtune_exports/hotspots_mpi_collect_log.txt",
        "  - results/vtune_exports/hotspots_mpi_stdout.txt",
        "  - results/vtune_exports/hotspots_mpi_stderr.txt"
    ) | Set-Content -Encoding UTF8 $Manifest

    Write-Host "[done] MPI hotspots collection completed."
    Write-Host "[done] Manifest: $Manifest"
} finally {
    Pop-Location
}
