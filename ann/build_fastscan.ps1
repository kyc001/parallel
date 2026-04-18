# 单独编译, 不影响 main_avx2.exe
New-Item -ItemType Directory -Force -Path "bench_results\windows_i9_13900h\fastscan" | Out-Null
g++ main_win_fastscan.cc -o main_fs.exe `
    -O2 -mavx2 -mfma -std=c++17 -Wno-ignored-attributes
if ($LASTEXITCODE -eq 0) { Write-Host "build OK: main_fs.exe" -ForegroundColor Green }