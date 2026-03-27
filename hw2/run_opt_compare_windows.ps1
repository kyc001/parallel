param()

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$binDir = Join-Path $projectRoot "bin"
$outDir = Join-Path $projectRoot "results\\opt_levels"

New-Item -ItemType Directory -Force -Path $binDir | Out-Null
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$commonSources = @(
    "src/benchmark.cpp",
    "src/data_utils.cpp",
    "src/environment.cpp",
    "src/matrix_experiment.cpp",
    "src/profile.cpp",
    "src/sum_experiment.cpp",
    "src/opt_compare_driver.cpp"
) | ForEach-Object { Join-Path $projectRoot $_ }

$sharedFlags = @(
    "-std=c++17",
    "-march=native",
    "-fno-tree-vectorize",
    "-fno-tree-slp-vectorize",
    "-Wall",
    "-Wextra",
    "-Wpedantic",
    "-g",
    "-fno-omit-frame-pointer"
)

$binO0 = Join-Path $binDir "lab1_optcmp_O0.exe"
$binO3 = Join-Path $binDir "lab1_optcmp_O3.exe"

Write-Host "[opt-compare] building O0 driver"
& g++ @sharedFlags "-O0" @commonSources -o $binO0
Write-Host "[opt-compare] building O3 driver"
& g++ @sharedFlags "-O3" @commonSources -o $binO3

$matrixSizes = @(64, 128, 256, 384, 512, 768, 1024, 1536, 2048)
$sumSizes = @(1024, 4096, 16384, 65536, 262144, 1048576, 4194304, 8388608)
$matrixAlgorithms = @("naive", "row_major", "row_major_unrolled4")
$sumAlgorithms = @("naive", "superscalar2", "superscalar4", "pairwise")

$csvPath = Join-Path $outDir "opt_level_results.csv"
"opt_level,kind,algorithm,n,iterations,total_ms,avg_ms,checksum" | Set-Content -Path $csvPath

function Invoke-Case {
    param(
        [string]$OptLevel,
        [string]$Binary,
        [string]$Kind,
        [string]$Algorithm,
        [UInt64]$N
    )

    Write-Host ("[{0}] {1} {2} n={3}" -f $OptLevel, $Kind, $Algorithm, $N)
    $line = & $Binary $Kind $Algorithm $N 2>> $null
    if (-not $line) {
        throw "No output from $Binary for $Kind $Algorithm $N"
    }
    "$OptLevel,$line" | Add-Content -Path $csvPath
}

foreach ($case in @(
    @{ Level = "O0"; Binary = $binO0 },
    @{ Level = "O3"; Binary = $binO3 }
)) {
    foreach ($algorithm in $matrixAlgorithms) {
        foreach ($n in $matrixSizes) {
            Invoke-Case -OptLevel $case.Level -Binary $case.Binary -Kind "matrix" -Algorithm $algorithm -N $n
        }
    }
    foreach ($algorithm in $sumAlgorithms) {
        foreach ($n in $sumSizes) {
            Invoke-Case -OptLevel $case.Level -Binary $case.Binary -Kind "sum" -Algorithm $algorithm -N $n
        }
    }
}

Write-Host "[opt-compare] wrote" $csvPath
