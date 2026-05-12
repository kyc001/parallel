param(
    [string]$Threads = "1,2,4,8,16",
    [string]$ShortThreads = "1,4,8,16",
    [string]$ResultDir = "results/local",
    [int]$SqRerankP = 100,
    [int]$PqRerankP = 1000,
    [int]$IvfNlist = 16,
    [int]$IvfNprobe = 4,
    [int]$IvfpqNlist = 16,
    [int]$IvfpqNprobe = 4,
    [int]$IvfpqRerankP = 1000,
    [string]$IvfpqMode = "local",
    [int]$HnswEf = 50,
    [int]$HnswNlist = 16,
    [int]$HnswNprobe = 8,
    [switch]$SkipRun
)

$ErrorActionPreference = "Stop"
$culture = [System.Globalization.CultureInfo]::InvariantCulture

function Split-List([string]$value) {
    $value.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

function Get-VariantName([string]$src) {
    $p = $src -replace '\\','/'
    if ($p -match '^mains/hnsw/main_(.+)\.cc$') {
        return "hnsw_$($Matches[1])"
    }
    if ($p -match '^mains/ivf/simd/main_(ivfpq|ivf)\.cc$') {
        return "$($Matches[1])_simd"
    }
    if ($p -match '^mains/ivf/omp/(inter|intra)/main_(ivfpq|ivf)\.cc$') {
        return "$($Matches[2])_omp_$($Matches[1])"
    }
    if ($p -match '^mains/ivf/pthread/(static|dynamic|pool)/(inter|intra)/main_(ivfpq|ivf)\.cc$') {
        return "$($Matches[3])_pthread_$($Matches[1])_$($Matches[2])"
    }
    if ($p -match '^mains/omp/(inter|intra)/main_(flat|sq|pq|fastscan)\.cc$') {
        return "$($Matches[2])_omp_$($Matches[1])"
    }
    if ($p -match '^mains/pthread/(static|dynamic|pool)/(inter|intra)/main_(flat|sq|pq|fastscan)\.cc$') {
        return "$($Matches[3])_pthread_$($Matches[1])_$($Matches[2])"
    }
    throw "cannot derive variant name from $src"
}

function Parse-Meta([string]$line) {
    $meta = @{}
    foreach ($part in ($line -split ',' | Select-Object -Skip 1)) {
        if ($part.Trim() -match '^([^=]+)=(.+)$') {
            $meta[$Matches[1].Trim()] = $Matches[2].Trim()
        }
    }
    return $meta
}

function Parse-ResultFile([System.IO.FileInfo]$file) {
    if ($file.Name -like 'tradeoff_*') { return $null }
    $lines = Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue
    if (-not $lines) { return $null }

    $recallLine = $lines | Where-Object { $_ -match 'average recall:\s*([0-9.]+)' } | Select-Object -First 1
    $latLine = $lines | Where-Object { $_ -match 'average latency \(us\):\s*([0-9.]+)' } | Select-Object -First 1
    if (-not $recallLine -or -not $latLine) { return $null }
    $recallLine -match 'average recall:\s*([0-9.]+)' | Out-Null
    $recall = [double]::Parse($Matches[1], $culture)
    $latLine -match 'average latency \(us\):\s*([0-9.]+)' | Out-Null
    $latency = [double]::Parse($Matches[1], $culture)

    $labelLine = $lines |
        Where-Object {
            $s = $_.Trim()
            $s -and
            $s -notmatch '^(average recall|average latency|\[|load data|dimension:|usage:|error:)'
        } |
        Select-Object -First 1
    if (-not $labelLine) { return $null }

    $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $threads = 1
    if ($name -match '_t(\d+)$') { $threads = [int]$Matches[1] }
    $variant = $name -replace '_t\d+$',''
    $algorithm = if ($variant -like 'hnsw*') {
        'hnsw'
    } elseif ($variant -like 'ivfpq*') {
        'ivfpq'
    } elseif ($variant -like 'ivf*') {
        'ivf'
    } else {
        ($variant -split '_')[0]
    }
    $strategy = if ($variant -match 'pthread_dynamic') {
        'pthread_dynamic'
    } elseif ($variant -match 'pthread_static') {
        'pthread_static'
    } elseif ($variant -match 'pthread_pool') {
        'pthread_pool'
    } elseif ($variant -match '_omp') {
        'omp'
    } elseif ($variant -match 'baseline|simd') {
        'baseline'
    } else {
        ''
    }
    $granularity = if ($variant -match '_inter') {
        'inter'
    } elseif ($variant -match '_intra') {
        'intra'
    } else {
        ''
    }
    $meta = Parse-Meta $labelLine

    [pscustomobject]@{
        file = $file.Name
        algorithm = $algorithm
        variant = $variant
        label = (($labelLine -split ',')[0].Trim())
        strategy = $strategy
        granularity = $granularity
        threads = $threads
        recall = $recall
        latency_us = $latency
        speedup_vs_t1_same_variant = ''
        p = $meta['p']
        nlist = $meta['nlist']
        nprobe = $meta['nprobe']
        ef = $meta['ef']
        rerank_p = ''
        mode = $meta['mode']
    }
}

function Export-Summaries([string]$dir) {
    $rows = @(Get-ChildItem -LiteralPath $dir -Filter '*.txt' |
        ForEach-Object { Parse-ResultFile $_ } |
        Where-Object { $_ -ne $null } |
        Sort-Object algorithm, variant, threads)

    foreach ($group in ($rows | Group-Object variant)) {
        $t1 = $group.Group | Where-Object { $_.threads -eq 1 } | Sort-Object latency_us | Select-Object -First 1
        if ($t1) {
            foreach ($row in $group.Group) {
                $row.speedup_vs_t1_same_variant = [math]::Round($t1.latency_us / $row.latency_us, 4)
            }
        }
    }

    $root = Split-Path $dir -Parent
    $rows | Export-Csv -LiteralPath (Join-Path $root "local_summary.csv") -NoTypeInformation -Encoding UTF8

    $bestRows = foreach ($group in ($rows | Where-Object { $_.recall -ge 0.95 } | Group-Object algorithm)) {
        $best = $group.Group | Sort-Object latency_us | Select-Object -First 1
        $bestT1 = $group.Group | Where-Object { $_.threads -eq 1 } | Sort-Object latency_us | Select-Object -First 1
        [pscustomobject]@{
            algorithm = $group.Name
            best_variant = $best.variant
            threads = $best.threads
            recall = $best.recall
            latency_us = $best.latency_us
            t1_variant = $bestT1.variant
            t1_latency_us = $bestT1.latency_us
            speedup_vs_best_t1 = [math]::Round($bestT1.latency_us / $best.latency_us, 4)
        }
    }
    $bestRows | Sort-Object algorithm | Export-Csv -LiteralPath (Join-Path $root "local_best.csv") -NoTypeInformation -Encoding UTF8

    $granRows = foreach ($group in ($rows | Where-Object { $_.recall -ge 0.95 -and $_.granularity } | Group-Object algorithm, granularity)) {
        $best = $group.Group | Sort-Object latency_us | Select-Object -First 1
        [pscustomObject]@{
            algorithm = $best.algorithm
            granularity = $best.granularity
            best_variant = $best.variant
            threads = $best.threads
            recall = $best.recall
            latency_us = $best.latency_us
        }
    }
    $granRows | Sort-Object algorithm, granularity | Export-Csv -LiteralPath (Join-Path $root "local_best_by_granularity.csv") -NoTypeInformation -Encoding UTF8

    $hnswRows = foreach ($group in ($rows | Where-Object { $_.algorithm -eq 'hnsw' } | Group-Object variant)) {
        $best = $group.Group | Sort-Object latency_us | Select-Object -First 1
        [pscustomobject]@{
            variant = $best.variant
            threads = $best.threads
            recall = $best.recall
            latency_us = $best.latency_us
        }
    }
    $hnswRows | Sort-Object latency_us | Export-Csv -LiteralPath (Join-Path $root "local_hnsw_best.csv") -NoTypeInformation -Encoding UTF8

    if ($rows.Count -ne 278) {
        throw "expected 278 parsed local result rows, got $($rows.Count)"
    }
}

$threadList = Split-List $Threads
$shortThreadList = Split-List $ShortThreads
$flags = @("-O2", "-mavx2", "-mfma", "-fopenmp", "-lpthread", "-std=c++11", "-I.")

$variants = @(
    "mains/omp/inter/main_flat.cc",
    "mains/omp/intra/main_flat.cc",
    "mains/pthread/static/inter/main_flat.cc",
    "mains/pthread/static/intra/main_flat.cc",
    "mains/pthread/dynamic/inter/main_flat.cc",
    "mains/pthread/dynamic/intra/main_flat.cc",
    "mains/pthread/pool/inter/main_flat.cc",
    "mains/pthread/pool/intra/main_flat.cc",
    "mains/omp/inter/main_sq.cc",
    "mains/omp/intra/main_sq.cc",
    "mains/pthread/static/inter/main_sq.cc",
    "mains/pthread/static/intra/main_sq.cc",
    "mains/pthread/dynamic/inter/main_sq.cc",
    "mains/pthread/dynamic/intra/main_sq.cc",
    "mains/pthread/pool/inter/main_sq.cc",
    "mains/pthread/pool/intra/main_sq.cc",
    "mains/omp/inter/main_pq.cc",
    "mains/omp/intra/main_pq.cc",
    "mains/pthread/static/inter/main_pq.cc",
    "mains/pthread/static/intra/main_pq.cc",
    "mains/pthread/dynamic/inter/main_pq.cc",
    "mains/pthread/dynamic/intra/main_pq.cc",
    "mains/pthread/pool/inter/main_pq.cc",
    "mains/pthread/pool/intra/main_pq.cc",
    "mains/omp/inter/main_fastscan.cc",
    "mains/omp/intra/main_fastscan.cc",
    "mains/pthread/static/inter/main_fastscan.cc",
    "mains/pthread/static/intra/main_fastscan.cc",
    "mains/pthread/dynamic/inter/main_fastscan.cc",
    "mains/pthread/dynamic/intra/main_fastscan.cc",
    "mains/pthread/pool/inter/main_fastscan.cc",
    "mains/pthread/pool/intra/main_fastscan.cc",
    "mains/ivf/simd/main_ivf.cc",
    "mains/ivf/omp/inter/main_ivf.cc",
    "mains/ivf/omp/intra/main_ivf.cc",
    "mains/ivf/pthread/static/inter/main_ivf.cc",
    "mains/ivf/pthread/static/intra/main_ivf.cc",
    "mains/ivf/pthread/dynamic/inter/main_ivf.cc",
    "mains/ivf/pthread/dynamic/intra/main_ivf.cc",
    "mains/ivf/pthread/pool/inter/main_ivf.cc",
    "mains/ivf/pthread/pool/intra/main_ivf.cc",
    "mains/ivf/simd/main_ivfpq.cc",
    "mains/ivf/omp/inter/main_ivfpq.cc",
    "mains/ivf/omp/intra/main_ivfpq.cc",
    "mains/ivf/pthread/static/inter/main_ivfpq.cc",
    "mains/ivf/pthread/static/intra/main_ivfpq.cc",
    "mains/ivf/pthread/dynamic/inter/main_ivfpq.cc",
    "mains/ivf/pthread/dynamic/intra/main_ivfpq.cc",
    "mains/ivf/pthread/pool/inter/main_ivfpq.cc",
    "mains/ivf/pthread/pool/intra/main_ivfpq.cc",
    "mains/hnsw/main_baseline.cc",
    "mains/hnsw/main_multi_entry_omp.cc",
    "mains/hnsw/main_multi_entry_static.cc",
    "mains/hnsw/main_multi_entry_dynamic.cc",
    "mains/hnsw/main_multi_entry_pool.cc",
    "mains/hnsw/main_edge_omp.cc",
    "mains/hnsw/main_edge_static.cc",
    "mains/hnsw/main_layer0_omp.cc",
    "mains/hnsw/main_layer0_static.cc",
    "mains/hnsw/main_ivf_nested_omp.cc",
    "mains/hnsw/main_ivf_nested_static.cc"
)

New-Item -ItemType Directory -Force -Path "build" | Out-Null
New-Item -ItemType Directory -Force -Path $ResultDir | Out-Null

if (-not $SkipRun) {
    foreach ($src in $variants) {
        if (-not (Test-Path -LiteralPath $src)) { throw "missing source: $src" }
        $name = Get-VariantName $src
        Write-Host "==> $name"
        Copy-Item -LiteralPath $src -Destination "main.cc" -Force
        & g++ "main.cc" "-o" "build/run_one.exe" @flags
        if ($LASTEXITCODE -ne 0) { throw "compile failed: $src" }

        $runThreads = if ($name -like "sq_*" -or $name -like "fastscan_*" -or $name -like "hnsw_*") {
            $shortThreadList
        } else {
            $threadList
        }

        foreach ($t in $runThreads) {
            $out = Join-Path $ResultDir "${name}_t${t}.txt"
            if ($src -like "*ivfpq*") {
                & ".\build\run_one.exe" $t $IvfpqNlist $IvfpqNprobe $IvfpqRerankP $IvfpqMode *> $out
            } elseif ($src -like "*ivf*") {
                & ".\build\run_one.exe" $t $IvfNlist $IvfNprobe *> $out
            } elseif ($src -like "*hnsw*") {
                & ".\build\run_one.exe" $t $HnswEf $HnswNlist $HnswNprobe *> $out
            } elseif ($src -like "*main_pq.cc") {
                & ".\build\run_one.exe" $t $PqRerankP *> $out
            } elseif ($src -like "*main_sq.cc") {
                & ".\build\run_one.exe" $t $SqRerankP *> $out
            } elseif ($src -like "*main_fastscan.cc") {
                & ".\build\run_one.exe" $t 1000 *> $out
            } else {
                & ".\build\run_one.exe" $t *> $out
            }
            if ($LASTEXITCODE -ne 0) { throw "run failed: $src threads=$t" }
        }
    }
}

Export-Summaries $ResultDir
Write-Host "==> summaries refreshed under results/ (278 rows)"
