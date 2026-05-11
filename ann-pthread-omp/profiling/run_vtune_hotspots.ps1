param(
    [string]$Target = ".\build\pq_dynamic_inter_diag.exe",
    [string[]]$TargetArgs = @("16", "1000"),
    [string]$ResultDir = "profiling\vtune-pq-p1000"
)

$ErrorActionPreference = "Stop"

$vtune = Get-Command vtune -ErrorAction SilentlyContinue
if (-not $vtune) {
    $vtune = Get-Command amplxe-cl -ErrorAction SilentlyContinue
}

if (-not $vtune) {
    throw "Intel VTune CLI was not found in PATH. Install VTune or run this script on a machine where vtune/amplxe-cl is available."
}

New-Item -ItemType Directory -Force (Split-Path $ResultDir -Parent) | Out-Null

& $vtune.Source -collect hotspots -result-dir $ResultDir -- $Target @TargetArgs
& $vtune.Source -report hotspots -r $ResultDir -format text -report-output "$ResultDir\hotspots.txt"

