# 编程模型对比实验: Pthread vs OpenMP vs std::thread vs SYCL vs OpenMP offload
# 前提: 安装 Intel oneAPI Base Toolkit, 在 "Intel oneAPI Command Prompt" 中运行
# 用法: powershell -ExecutionPolicy Bypass -File run_programming_model_comparison.ps1

$ErrorActionPreference = "Stop"
$resultDir = "results/local"
New-Item -ItemType Directory -Force -Path $resultDir | Out-Null
New-Item -ItemType Directory -Force -Path "build" | Out-Null

Write-Host "============================================"
Write-Host "  编程模型对比实验"
Write-Host "============================================"

# 1. 编译所有变体
Write-Host "`n[1/5] 编译 std::thread..."
g++ tools/sweep_stdthread.cc -o build/sweep_stdthread.exe -O2 -fopenmp -lpthread -std=c++11 -I. -mavx2 -mfma
if ($LASTEXITCODE -ne 0) { throw "std::thread compile failed" }

Write-Host "[2/5] 编译 Pthread (flat_scan_pthread)..."
# 已包含在 sweep_stdthread.cc 中

Write-Host "[3/5] 编译 OpenMP (flat_scan_omp)..."
# 已包含在 sweep_stdthread.cc 中

Write-Host "[4/5] 编译 SYCL..."
icpx -fsycl -O2 -std=c++17 -I. tools/flat_scan_sycl.cpp -o build/flat_scan_sycl.exe 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  SYCL 编译失败，尝试 CPU-only 模式..."
    icpx -fsycl -fsycl-targets=spir64_x86_64 -O2 -std=c++17 -I. tools/flat_scan_sycl.cpp -o build/flat_scan_sycl.exe 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Host "  SYCL 编译失败，跳过" }
}

Write-Host "[5/5] 编译 OpenMP offload..."
icpx -fiopenmp -O2 -std=c++17 -I. tools/flat_scan_omp_offload.cpp -o build/flat_scan_omp_offload.exe 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  OpenMP offload 编译失败，尝试基础模式..."
    icpx -fiopenmp -fopenmp-targets=spir64 -O2 -std=c++17 -I. tools/flat_scan_omp_offload.cpp -o build/flat_scan_omp_offload.exe 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Host "  OpenMP offload 编译失败，跳过" }
}

# 2. 运行实验
Write-Host "`n===== 运行实验 =====`n"
$threads = 1, 4, 8, 16

# std::thread vs Pthread vs OpenMP (已有工具)
Write-Host "--- std::thread / Pthread / OpenMP ---"
foreach ($t in $threads) {
    Write-Host "  t=$t ..."
    $out = "$resultDir/programming_model_comparison_t${t}.txt"
    build/sweep_stdthread.exe $t > $out 2>&1
    Get-Content $out
}

# SYCL
if (Test-Path "build/flat_scan_sycl.exe") {
    Write-Host "`n--- SYCL ---"
    build/flat_scan_sycl.exe > "$resultDir/sycl_result.txt" 2>&1
    Get-Content "$resultDir/sycl_result.txt"
}

# OpenMP offload
if (Test-Path "build/flat_scan_omp_offload.exe") {
    Write-Host "`n--- OpenMP offload ---"
    build/flat_scan_omp_offload.exe > "$resultDir/omp_offload_result.txt" 2>&1
    Get-Content "$resultDir/omp_offload_result.txt"
}

Write-Host "`n============================================"
Write-Host "  实验完成！结果保存在 $resultDir/"
Write-Host "============================================"
