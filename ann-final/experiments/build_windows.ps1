$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root
New-Item -ItemType Directory -Force -Path "build" | Out-Null

g++ -O3 -std=c++11 -I. -fopenmp -mavx2 -mfma opq_ivfpq.cc -o build\opq_ivfpq.exe -lpthread
g++ -O3 -std=c++11 -I. -fopenmp -mavx2 -mfma adaptive_ivfpq.cc -o build\adaptive_ivfpq.exe -lpthread

$vcvars = "C:\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if (!(Test-Path $vcvars)) {
  throw "vcvars64.bat not found at $vcvars; set up MSVC Build Tools before building CUDA runner."
}

cmd /C "call `"$vcvars`" >nul && nvcc -O3 -std=c++11 -x cu -I. gpu_hybrid.cu -o build\gpu_hybrid.exe -lcublas"
