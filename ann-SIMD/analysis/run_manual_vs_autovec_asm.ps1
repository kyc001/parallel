$ErrorActionPreference = 'Stop'

$annDir = Split-Path -Parent $PSScriptRoot
Set-Location $annDir

$outDir = Join-Path $annDir 'local_results\manual_vs_autovec\asm'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$asmPath = Join-Path $outDir 'manual_vs_autovec_O3.s'
$objPath = Join-Path $outDir 'manual_vs_autovec_O3.o'
$dumpPath = Join-Path $outDir 'manual_vs_autovec_objdump.txt'
$vecLog = Join-Path $outDir 'vectorization.log'
$summaryPath = Join-Path $outDir 'summary.txt'

$compileAsm = Start-Process -FilePath 'g++' `
  -ArgumentList @(
    'analysis\manual_vs_autovec.cc',
    '-S', '-o', $asmPath,
    '-O3', '-mavx2', '-mfma', '-std=c++17',
    '-Wall', '-Wextra', '-Wno-unused-parameter',
    '-fverbose-asm',
    '-fopt-info-vec-optimized', '-fopt-info-vec-missed'
  ) `
  -NoNewWindow -Wait -PassThru `
  -RedirectStandardError $vecLog
if ($compileAsm.ExitCode -ne 0) {
  throw "g++ -S failed with exit code $($compileAsm.ExitCode)"
}

$compileObj = Start-Process -FilePath 'g++' `
  -ArgumentList @(
    'analysis\manual_vs_autovec.cc',
    '-c', '-o', $objPath,
    '-O3', '-mavx2', '-mfma', '-std=c++17',
    '-Wall', '-Wextra', '-Wno-unused-parameter'
  ) `
  -NoNewWindow -Wait -PassThru
if ($compileObj.ExitCode -ne 0) {
  throw "g++ -c failed with exit code $($compileObj.ExitCode)"
}

$dump = Start-Process -FilePath 'objdump' `
  -ArgumentList @('-Cd', '-Mintel', '--demangle', $objPath) `
  -NoNewWindow -Wait -PassThru `
  -RedirectStandardOutput $dumpPath
if ($dump.ExitCode -ne 0) {
  throw "objdump failed with exit code $($dump.ExitCode)"
}

@(
  '===== Vectorization Log ====='
  (Get-Content $vecLog)
  ''
  '===== ip_distance_auto / ip_distance_manual in objdump ====='
  (Select-String -Path $dumpPath -Pattern 'ip_distance_auto|ip_distance_manual|ip_distance_scalar_novec' -Context 0,30 | ForEach-Object { $_.ToString() })
) | Set-Content -Path $summaryPath

Write-Host "Assembly written to $asmPath"
Write-Host "Objdump written to $dumpPath"
Write-Host "Summary written to $summaryPath"
