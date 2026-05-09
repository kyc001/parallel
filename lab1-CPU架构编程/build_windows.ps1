param(
    [switch]$WithDriver
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$binDir = Join-Path $projectRoot "bin"
$resultsDir = Join-Path $projectRoot "results"

New-Item -ItemType Directory -Force -Path $binDir | Out-Null
New-Item -ItemType Directory -Force -Path $resultsDir | Out-Null

$commonSources = @(
    "src/benchmark.cpp",
    "src/data_utils.cpp",
    "src/environment.cpp",
    "src/matrix_experiment.cpp",
    "src/profile.cpp",
    "src/sum_experiment.cpp"
) | ForEach-Object { Join-Path $projectRoot $_ }

$commonFlags = @(
    "-std=c++17",
    "-O3",
    "-march=native",
    "-fno-tree-vectorize",
    "-fno-tree-slp-vectorize",
    "-Wall",
    "-Wextra",
    "-Wpedantic",
    "-Winvalid-pch",
    "-g",
    "-fno-omit-frame-pointer"
)

$benchmarkTarget = Join-Path $binDir "lab1_benchmark.exe"
$driverTarget = Join-Path $binDir "lab1_perf.exe"

& g++ @commonFlags @commonSources (Join-Path $projectRoot "src/main.cpp") -o $benchmarkTarget
& g++ @commonFlags @commonSources (Join-Path $projectRoot "src/perf_driver.cpp") -o $driverTarget

if ($WithDriver) {
    Write-Host "Built:" $benchmarkTarget
    Write-Host "Built:" $driverTarget
}
