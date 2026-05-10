param(
    [string]$Threads = "1,2,4,8,16",
    [string]$ResultDir = "results/windows"
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path "build" | Out-Null
New-Item -ItemType Directory -Force -Path $ResultDir | Out-Null

$threadList = $Threads.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
$flags = @("-O2", "-mavx2", "-mfma", "-fopenmp", "-lpthread", "-std=c++17", "-I.")

$variants = @(
    "mains/omp/inter/main_flat.cc",
    "mains/omp/intra/main_flat.cc",
    "mains/pthread/static/inter/main_flat.cc",
    "mains/pthread/static/intra/main_flat.cc",
    "mains/pthread/dynamic/inter/main_flat.cc",
    "mains/pthread/dynamic/intra/main_flat.cc",
    "mains/pthread/pool/inter/main_flat.cc",
    "mains/pthread/pool/intra/main_flat.cc",
    "mains/omp/inter/main_sq.cc",
    "mains/omp/intra/main_sq.cc",
    "mains/pthread/static/inter/main_sq.cc",
    "mains/pthread/static/intra/main_sq.cc",
    "mains/pthread/dynamic/inter/main_sq.cc",
    "mains/pthread/dynamic/intra/main_sq.cc",
    "mains/pthread/pool/inter/main_sq.cc",
    "mains/pthread/pool/intra/main_sq.cc",
    "mains/omp/inter/main_pq.cc",
    "mains/omp/intra/main_pq.cc",
    "mains/pthread/static/inter/main_pq.cc",
    "mains/pthread/static/intra/main_pq.cc",
    "mains/pthread/dynamic/inter/main_pq.cc",
    "mains/pthread/dynamic/intra/main_pq.cc",
    "mains/pthread/pool/inter/main_pq.cc",
    "mains/pthread/pool/intra/main_pq.cc",
    "mains/omp/inter/main_fastscan.cc",
    "mains/omp/intra/main_fastscan.cc",
    "mains/pthread/static/inter/main_fastscan.cc",
    "mains/pthread/static/intra/main_fastscan.cc",
    "mains/pthread/dynamic/inter/main_fastscan.cc",
    "mains/pthread/dynamic/intra/main_fastscan.cc",
    "mains/pthread/pool/inter/main_fastscan.cc",
    "mains/pthread/pool/intra/main_fastscan.cc",
    "mains/ivf/simd/main_ivf.cc",
    "mains/ivf/omp/inter/main_ivf.cc",
    "mains/ivf/omp/intra/main_ivf.cc",
    "mains/ivf/pthread/dynamic/inter/main_ivf.cc",
    "mains/ivf/pthread/dynamic/intra/main_ivf.cc",
    "mains/ivf/simd/main_ivfpq.cc",
    "mains/ivf/omp/inter/main_ivfpq.cc",
    "mains/ivf/omp/intra/main_ivfpq.cc",
    "mains/ivf/pthread/dynamic/inter/main_ivfpq.cc",
    "mains/ivf/pthread/dynamic/intra/main_ivfpq.cc",
    "mains/hnsw/main_baseline.cc",
    "mains/hnsw/main_multi_entry_omp.cc",
    "mains/hnsw/main_multi_entry_static.cc",
    "mains/hnsw/main_layer0_omp.cc"
)

foreach ($src in $variants) {
    if (-not (Test-Path -LiteralPath $src)) { continue }
    $name = ($src -replace "^mains/", "") -replace "\.cc$", ""
    $name = $name -replace "[\\/]", "_"
    Write-Host "==> $name"
    Copy-Item -LiteralPath $src -Destination "main.cc" -Force
    & g++ "main.cc" "-o" "build/run_one.exe" @flags
    if ($LASTEXITCODE -ne 0) { throw "compile failed: $src" }

    foreach ($t in $threadList) {
        $out = Join-Path $ResultDir "${name}_t${t}.txt"
        if ($src -like "*ivfpq*") {
            & ".\build\run_one.exe" $t 16 4 100 global *> $out
        } elseif ($src -like "*ivf*") {
            & ".\build\run_one.exe" $t 16 4 *> $out
        } elseif ($src -like "*hnsw*") {
            & ".\build\run_one.exe" $t 50 16 4 *> $out
        } elseif ($src -like "*main_pq.cc" -or $src -like "*main_sq.cc") {
            & ".\build\run_one.exe" $t 100 *> $out
        } elseif ($src -like "*main_fastscan.cc") {
            & ".\build\run_one.exe" $t 1000 *> $out
        } else {
            & ".\build\run_one.exe" $t *> $out
        }
    }
}
