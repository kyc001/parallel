param(
  [int]$Threads = 2,
  [int]$HnswM = 16,
  [int]$Ef = 50,
  [int]$UnusedP = 1000,
  [int]$QueryN = 2000,
  [string]$Mode = "hnsw",
  [ValidateSet("detailed", "summary")]
  [string]$PmuCollectionMode = "detailed",
  [string]$VtunePath = "C:\Program Files (x86)\Intel\oneAPI\vtune\latest\bin64\vtune.exe",
  [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-IsAdministrator {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Restart-Elevated {
  $quotedScript = '"' + $PSCommandPath + '"'
  $argList = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", $quotedScript,
    "-Threads", $Threads,
    "-HnswM", $HnswM,
    "-Ef", $Ef,
    "-UnusedP", $UnusedP,
    "-QueryN", $QueryN,
    "-Mode", $Mode,
    "-PmuCollectionMode", $PmuCollectionMode,
    "-VtunePath", ('"' + $VtunePath + '"')
  )
  if ($SkipBuild) {
    $argList += "-SkipBuild"
  }
  Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList $argList
}

function Assert-PathUnder {
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][string]$Parent
  )
  $resolvedParent = [IO.Path]::GetFullPath($Parent)
  $fullPath = [IO.Path]::GetFullPath($Path)
  if (-not $fullPath.StartsWith($resolvedParent, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to modify path outside repository: $fullPath"
  }
}

if (-not (Test-IsAdministrator)) {
  Write-Host "[vtune] This collection needs administrator privileges; requesting elevation..."
  Restart-Elevated
  exit 0
}

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$BuildDir = Join-Path $RepoRoot "build"
$Binary = Join-Path $BuildDir "main_no_mpi_profile.exe"
$ExportDir = Join-Path $RepoRoot "results\vtune_exports"
$RawResultDir = Join-Path $RepoRoot "results\vtune_uarch_hnsw_admin"
$CollectLog = Join-Path $ExportDir "uarch_admin_collect_log.txt"
$DriverLog = Join-Path $ExportDir "sampling_driver_check.txt"
$Manifest = Join-Path $ExportDir "uarch_admin_manifest.txt"
$DefaultDataPath = Join-Path (Split-Path $RepoRoot -Parent) "files"

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
New-Item -ItemType Directory -Force -Path $ExportDir | Out-Null

if (-not (Test-Path -LiteralPath $VtunePath)) {
  throw "VTune CLI not found: $VtunePath"
}

if (-not $env:ANN_DATA_PATH) {
  $env:ANN_DATA_PATH = $DefaultDataPath
}

Push-Location $RepoRoot
try {
  function Invoke-Logged {
    param(
      [Parameter(Mandatory=$true)][string]$Exe,
      [Parameter(Mandatory=$true)][string[]]$Args,
      [Parameter(Mandatory=$true)][string]$LogPath
    )
    "`n> $Exe $($Args -join ' ')" | Tee-Object -FilePath $LogPath -Append | Out-Null
    & $Exe @Args *>&1 | Tee-Object -FilePath $LogPath -Append
    return $LASTEXITCODE
  }

  $targetArgs = @("$Threads", "$HnswM", "$Ef", "$UnusedP", "$QueryN", "$Mode")
  $header = @(
    "Date: $(Get-Date -Format o)",
    "Working directory: $RepoRoot",
    "ANN_DATA_PATH: $env:ANN_DATA_PATH",
    "VTune: $VtunePath",
    "Collection: uarch-exploration",
    "PMU mode: $PmuCollectionMode",
    "Target: $Binary $($targetArgs -join ' ')",
    ""
  )
  $header | Set-Content -Encoding UTF8 $CollectLog

  if (-not $SkipBuild) {
    Write-Host "[build] g++ main.cc -> build\main_no_mpi_profile.exe"
    $buildArgs = @("main.cc", "-o", $Binary, "-O2", "-g", "-std=c++11", "-I.", "-fopenmp", "-lpthread", "-mavx2", "-mfma", "-DANN_NO_MPI")
    $buildCode = Invoke-Logged -Exe "g++" -Args $buildArgs -LogPath $CollectLog
    if ($buildCode -ne 0) {
      throw "g++ build failed with exit code $buildCode"
    }
  }

  if (-not (Test-Path -LiteralPath $Binary)) {
    throw "Profile binary not found: $Binary"
  }

  $SepregPath = Join-Path (Split-Path $VtunePath -Parent) "amplxe-sepreg.exe"
  if (Test-Path -LiteralPath $SepregPath) {
    Write-Host "[driver] checking VTune sampling driver"
    & $SepregPath -c *>&1 | Tee-Object -FilePath $DriverLog
  } else {
    "amplxe-sepreg.exe not found next to vtune.exe: $SepregPath" | Set-Content -Encoding UTF8 $DriverLog
  }

  if (Test-Path -LiteralPath $RawResultDir) {
    Assert-PathUnder -Path $RawResultDir -Parent $RepoRoot
    Remove-Item -LiteralPath $RawResultDir -Recurse -Force
  }

  $collectArgs = @(
    "-collect", "uarch-exploration",
    "-knob", "pmu-collection-mode=$PmuCollectionMode",
    "-result-dir", $RawResultDir,
    "--", $Binary
  ) + $targetArgs

  Write-Host "[vtune] collecting uarch-exploration ($PmuCollectionMode)"
  $collectCode = Invoke-Logged -Exe $VtunePath -Args $collectArgs -LogPath $CollectLog
  if ($collectCode -ne 0) {
    throw "VTune uarch collection failed with exit code $collectCode. See $CollectLog"
  }

  $reports = @(
    @{ Name = "summary";  Format = "text"; Output = "uarch_admin_summary.txt" },
    @{ Name = "top-down"; Format = "text"; Output = "uarch_admin_top_down.txt" },
    @{ Name = "hw-events"; Format = "csv"; Output = "uarch_admin_hw_events.csv" },
    @{ Name = "hotspots"; Format = "csv"; Output = "uarch_admin_hotspots.csv" }
  )

  foreach ($report in $reports) {
    $outPath = Join-Path $ExportDir $report.Output
    $reportArgs = @(
      "-report", $report.Name,
      "-result-dir", $RawResultDir,
      "-report-output", $outPath,
      "-format", $report.Format
    )
    if ($report.Format -eq "csv") {
      $reportArgs += @("-csv-delimiter", "comma")
    }
    if ($report.Name -eq "hotspots") {
      $reportArgs += @("-limit", "30")
    }
    Write-Host "[export] $($report.Name) -> $($report.Output)"
    $reportCode = Invoke-Logged -Exe $VtunePath -Args $reportArgs -LogPath $CollectLog
    if ($reportCode -ne 0) {
      throw "VTune report export failed for $($report.Name) with exit code $reportCode"
    }
  }

  @(
    "Date: $(Get-Date -Format o)",
    "Raw result directory: $RawResultDir",
    "Target: $Binary $($targetArgs -join ' ')",
    "ANN_DATA_PATH: $env:ANN_DATA_PATH",
    "PMU collection mode: $PmuCollectionMode",
    "Exports:",
    "  - results/vtune_exports/uarch_admin_summary.txt",
    "  - results/vtune_exports/uarch_admin_top_down.txt",
    "  - results/vtune_exports/uarch_admin_hw_events.csv",
    "  - results/vtune_exports/uarch_admin_hotspots.csv",
    "  - results/vtune_exports/uarch_admin_collect_log.txt",
    "  - results/vtune_exports/sampling_driver_check.txt"
  ) | Set-Content -Encoding UTF8 $Manifest

  Write-Host "[done] VTune uarch collection and exports completed."
  Write-Host "[done] Manifest: $Manifest"
} finally {
  Pop-Location
}
