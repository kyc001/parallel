$RAW_DIR = "bench_results\windows_i9_13900h\raw"
$OUT     = "bench_results\windows_i9_13900h\win_avx2_summary.txt"

if (-not (Test-Path $RAW_DIR)) {
    Write-Error "$RAW_DIR does not exist"; exit 1
}

function Extract-Result($file) {
    $labelMatch   = Select-String -Path $file -Pattern '^(baseline_serial_flat|flat_avx2|sq_avx2.*|pq_avx2.*)' | Select-Object -First 1
    $recallMatch  = Select-String -Path $file -Pattern 'average recall:\s*([\d.]+)' | Select-Object -First 1
    $latencyMatch = Select-String -Path $file -Pattern 'average latency[^:]*:\s*([\d.]+)' | Select-Object -First 1

    $label   = if ($labelMatch)   { $labelMatch.Line.Trim() }                  else { "N/A" }
    $recall  = if ($recallMatch)  { $recallMatch.Matches[0].Groups[1].Value }  else { "N/A" }
    $latency = if ($latencyMatch) { $latencyMatch.Matches[0].Groups[1].Value } else { "N/A" }

    $name = [System.IO.Path]::GetFileNameWithoutExtension($file)
    "{0,-25}`t{1,-40}`t{2}`t{3}" -f $name, $label, $recall, $latency
}

$lines = @()
$lines += "# Windows i9-13900H AVX2 Benchmark Summary"
$lines += "# Generated: $(Get-Date)"
$lines += "# Dataset: DEEP100K (100K x 96D), k=10, 2000 queries"
$lines += "#"
$lines += "{0,-25}`t{1,-40}`t{2}`t{3}" -f "file","label","recall","latency_us"
$lines += "---"

$files = @()
$files += "$RAW_DIR\baseline.txt"
$files += "$RAW_DIR\flat_avx2.txt"
foreach ($p in 100,200,500,1000,2000,5000,10000,50000,100000) { $files += "$RAW_DIR\sq_p$p.txt" }
foreach ($p in 100,200,500,1000,2000,5000,10000,50000,100000) { $files += "$RAW_DIR\pq_p$p.txt" }

foreach ($f in $files) {
    if (Test-Path $f) { $lines += (Extract-Result $f) }
}

$lines | Out-File -FilePath $OUT -Encoding UTF8
Write-Host "Wrote: $OUT`n"
Get-Content $OUT