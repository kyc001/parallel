$ErrorActionPreference = 'Stop'

$annDir = Split-Path -Parent $PSScriptRoot
Set-Location $annDir

$outDir = Join-Path $annDir 'local_results\manual_vs_autovec'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$exePath = Join-Path $outDir 'manual_vs_autovec.exe'
$vecLog = Join-Path $outDir 'vectorization.log'
$resTxt = Join-Path $outDir 'results.txt'

$compile = Start-Process -FilePath 'g++' `
  -ArgumentList @(
    'analysis\manual_vs_autovec.cc',
    '-o', $exePath,
    '-O3', '-mavx2', '-mfma', '-std=c++17',
    '-Wall', '-Wextra', '-Wno-unused-parameter',
    '-fopt-info-vec-optimized', '-fopt-info-vec-missed'
  ) `
  -NoNewWindow -Wait -PassThru `
  -RedirectStandardError $vecLog
if ($compile.ExitCode -ne 0) {
  throw "g++ failed with exit code $($compile.ExitCode)"
}

$run = Start-Process -FilePath $exePath `
  -NoNewWindow -Wait -PassThru `
  -RedirectStandardOutput $resTxt
if ($run.ExitCode -ne 0) {
  throw "manual_vs_autovec.exe failed with exit code $($run.ExitCode)"
}

Get-Content $resTxt
Write-Host ""
Write-Host "Results written to $resTxt"
Write-Host "Vectorization log written to $vecLog"
