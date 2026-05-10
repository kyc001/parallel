# run_vtune_flat_pcore.ps1 - P-core pinned VTune re-run for flat
$ErrorActionPreference = "Stop"

# ========== 配置 ==========
$OutDir = "bench_results\windows_i9_13900h"
$Exe    = ".\main_win_avx2.exe"
# i9-13900H: bit 0-15 = 8 个 P-core × 2 SMT = 16 个逻辑核
$Affinity = [IntPtr]0xFFFF

# 自动找 vtune.exe
$VtuneCandidates = @(
    "C:\Program Files (x86)\Intel\oneAPI\vtune\latest\bin64\vtune.exe",
    "C:\Program Files\Intel\oneAPI\vtune\latest\bin64\vtune.exe"
)
$Vtune = $VtuneCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $Vtune) { Write-Error "vtune.exe not found"; exit 1 }
Write-Host "Using VTune: $Vtune"

# 管理员检查
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) { Write-Host "Administrator check: OK" } else { Write-Warning "Not admin — PMU may fail" }

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Run-Vtune($analysis, $resultDir, $reportKind, $reportFile) {
    Write-Host "`n==> Collecting $analysis into $resultDir (P-core pinned, AFFINITY=$Affinity)"
    if (Test-Path $resultDir) { Remove-Item -Recurse -Force $resultDir }

    # 启动 vtune（它会 fork 出 main_win_avx2.exe）
    $args = @("-collect", $analysis, "-result-dir", $resultDir, "--", $Exe, "flat")
    $proc = Start-Process -FilePath $Vtune -ArgumentList $args -PassThru -NoNewWindow
    # 立即设置 affinity，子进程会继承
    try {
        $proc.ProcessorAffinity = $Affinity
    } catch {
        Write-Warning "Could not set affinity on vtune: $_"
    }
    $proc.WaitForExit()
    if ($proc.ExitCode -ne 0) {
        Write-Warning "VTune $analysis exited with code $($proc.ExitCode)"
        return
    }

    $reportPath = Join-Path $OutDir $reportFile
    Write-Host "==> Exporting $reportKind report to $reportPath"
    & $Vtune -report $reportKind -result-dir $resultDir -report-output $reportPath -format text
    if (Test-Path $reportPath) {
        Write-Host "OK: $reportPath"
    } else {
        Write-Warning "Failed to generate $reportPath"
    }
}

Run-Vtune "hotspots"          "vtune_hotspots_flat_pcore" "hotspots" "vtune_hotspots_flat_pcore.txt"
Run-Vtune "uarch-exploration" "vtune_uarch_flat_pcore"    "summary"  "vtune_uarch_flat_pcore.txt"
Run-Vtune "memory-access"     "vtune_mem_flat_pcore"      "summary"  "vtune_mem_flat_pcore.txt"

Write-Host "`nGenerated reports:"
Get-ChildItem "$OutDir\vtune_*_flat_pcore.txt" | Format-Table Name, Length
Write-Host "Done."