param(
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

function Find-VTune {
    $candidates = @(
        "C:\Program Files (x86)\Intel\oneAPI\vtune\latest\bin64\vtune.exe",
        "C:\Program Files (x86)\Intel\oneAPI\vtune\2025.10\bin64\vtune.exe",
        "C:\Program Files (x86)\Intel\oneAPI\vtune\2025.9\bin64\vtune.exe",
        "C:\Program Files (x86)\Intel\oneAPI\vtune\2025.4\bin64\vtune.exe"
    )

    foreach ($path in $candidates) {
        if (Test-Path $path) {
            return $path
        }
    }

    $searchRoot = "C:\Program Files (x86)\Intel\oneAPI\vtune"
    if (Test-Path $searchRoot) {
        $found = Get-ChildItem -Path $searchRoot -Recurse -Filter vtune.exe -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending |
            Select-Object -First 1 -ExpandProperty FullName
        if ($found) {
            return $found
        }
    }

    throw "vtune.exe not found. Install Intel VTune Profiler first."
}

function Export-VTuneReports {
    param(
        [string]$Vtune,
        [string]$ResultDir,
        [string]$Prefix
    )

    & $Vtune -report summary -result-dir $ResultDir -report-output "${Prefix}_summary.csv" -format csv -csv-delimiter comma
    & $Vtune -report hotspots -result-dir $ResultDir -report-output "${Prefix}_hotspots.csv" -format csv -csv-delimiter comma
}

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$resultsDir = Join-Path $projectRoot "results"
$vtuneRoot = Join-Path $resultsDir "vtune_cli"
$binDir = Join-Path $projectRoot "bin"
$driver = Join-Path $binDir "lab1_perf.exe"

if (-not $SkipBuild) {
    & (Join-Path $projectRoot "build_windows.ps1") -WithDriver
}

if (-not (Test-Path $driver)) {
    throw "Missing $driver. Run build_windows.ps1 first."
}

$vtune = Find-VTune
New-Item -ItemType Directory -Force -Path $vtuneRoot | Out-Null

$driverCheck = Join-Path (Split-Path -Parent $vtune) "amplxe-sepreg.exe"
if (Test-Path $driverCheck) {
    & $driverCheck -c | Tee-Object -FilePath (Join-Path $vtuneRoot "sampling_driver_check.txt")
}

$collections = @(
    @{
        Name = "matrix_naive_memory_access"
        Analysis = "memory-access"
        Kind = "matrix"
        Algorithm = "naive"
        N = "2048"
        Repeat = "8"
    },
    @{
        Name = "matrix_row_major_unrolled4_memory_access"
        Analysis = "memory-access"
        Kind = "matrix"
        Algorithm = "row_major_unrolled4"
        N = "2048"
        Repeat = "256"
    },
    @{
        Name = "sum_naive_uarch"
        Analysis = "uarch-exploration"
        Kind = "sum"
        Algorithm = "naive"
        N = "1048576"
        Repeat = "1024"
    },
    @{
        Name = "sum_superscalar4_uarch"
        Analysis = "uarch-exploration"
        Kind = "sum"
        Algorithm = "superscalar4"
        N = "1048576"
        Repeat = "4096"
    }
)

foreach ($item in $collections) {
    $resultDir = Join-Path $vtuneRoot $item.Name
    if (Test-Path $resultDir) {
        Remove-Item -LiteralPath $resultDir -Recurse -Force
    }

    & $vtune -collect $item.Analysis -result-dir $resultDir -- $driver $item.Kind $item.Algorithm $item.N $item.Repeat
    Export-VTuneReports -Vtune $vtune -ResultDir $resultDir -Prefix (Join-Path $vtuneRoot $item.Name)
}
