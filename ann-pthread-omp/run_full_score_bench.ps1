# Pin all benchmarks to P-cores via processor affinity so numbers match
# the rest of the report (which is all P-core bound). Affinity mask
# 0xFFFF covers logical cores 0..15 (i9-13900H P-cores + HT siblings).
#
# Generates CSVs under bench_results/windows_i9_13900h/full_score/.

$ErrorActionPreference = "Stop"

$out_dir = "bench_results/windows_i9_13900h/full_score"
New-Item -ItemType Directory -Force -Path $out_dir | Out-Null

function Run-Pinned {
    param(
        [string]$Exe,
        [string]$ExArgs,
        [string]$OutFile,
        [string]$ErrFile
    )
    Write-Host "[pcore] $Exe $ExArgs -> $OutFile"
    $splitArgs = @()
    if ($ExArgs -and $ExArgs.Trim().Length -gt 0) {
        $splitArgs = $ExArgs.Split(' ') | Where-Object { $_ -ne '' }
    }
    if ($splitArgs.Count -gt 0) {
        $p = Start-Process -FilePath $Exe -ArgumentList $splitArgs `
            -RedirectStandardOutput $OutFile -RedirectStandardError $ErrFile `
            -PassThru -NoNewWindow
    } else {
        $p = Start-Process -FilePath $Exe `
            -RedirectStandardOutput $OutFile -RedirectStandardError $ErrFile `
            -PassThru -NoNewWindow
    }
    $p.ProcessorAffinity = [IntPtr]::new(0xFFFF)
    $p.WaitForExit()
    if ($p.ExitCode -ne 0) {
        Write-Host "  (!) exit=$($p.ExitCode), see $ErrFile"
    }
}

# 1. Core-5 configurations x 5 repeats (mean +/- std)
Run-Pinned "./main_win_ext.exe" "baseline --k=10 --repeat=5 --tag=baseline" `
    "$out_dir/core5_baseline.csv" "$out_dir/core5_baseline.log"
Run-Pinned "./main_win_ext.exe" "flat --k=10 --repeat=5 --tag=flat" `
    "$out_dir/core5_flat.csv" "$out_dir/core5_flat.log"
Run-Pinned "./main_win_ext.exe" "sq --k=10 --p=100 --repeat=5 --tag=sq_p100" `
    "$out_dir/core5_sq.csv" "$out_dir/core5_sq.log"
Run-Pinned "./main_win_ext.exe" "pq --k=10 --p=1000 --repeat=5 --tag=pq_p1000" `
    "$out_dir/core5_pq.csv" "$out_dir/core5_pq.log"
Run-Pinned "./main_win_fastscan_ext.exe" "--p=1000 --k=10 --repeat=5" `
    "$out_dir/core5_fastscan.csv" "$out_dir/core5_fastscan.log"

# 2. FastScan full p-sweep (now pinned)
Run-Pinned "./main_win_fastscan_ext.exe" "--p=40,100,500,1000,2000,5000,10000,50000,100000 --k=10 --repeat=1" `
    "$out_dir/fastscan_full_p_pcore.csv" "$out_dir/fastscan_full_p_pcore.log"

# 3. Recall@1 / Recall@10 / Recall@100
foreach ($k in @(1, 10, 100)) {
    Run-Pinned "./main_win_ext.exe" "flat --k=$k --repeat=1 --tag=flat_k$k" `
        "$out_dir/recall_flat_k${k}.csv" "$out_dir/recall_flat_k${k}.log"
    Run-Pinned "./main_win_ext.exe" "sq --k=$k --p=100 --repeat=1 --tag=sq_k${k}" `
        "$out_dir/recall_sq_k${k}.csv" "$out_dir/recall_sq_k${k}.log"
    Run-Pinned "./main_win_ext.exe" "pq --k=$k --p=1000 --repeat=1 --tag=pq_k${k}" `
        "$out_dir/recall_pq_k${k}.csv" "$out_dir/recall_pq_k${k}.log"
    Run-Pinned "./main_win_fastscan_ext.exe" "--p=1000 --k=$k --repeat=1" `
        "$out_dir/recall_fastscan_k${k}.csv" "$out_dir/recall_fastscan_k${k}.log"
}

# 4. Scale sweep (pinned)
foreach ($N in @(10000, 25000, 50000, 100000)) {
    foreach ($mode in @("baseline", "flat", "sq", "pq")) {
        $p_arg = ""
        if ($mode -eq "sq") { $p_arg = "--p=100" }
        if ($mode -eq "pq") { $p_arg = "--p=1000" }
        Run-Pinned "./main_win_ext.exe" "$mode --k=10 --N=$N $p_arg --tag=${mode}_N${N}" `
            "$out_dir/scale_${mode}_N${N}.csv" "$out_dir/scale_${mode}_N${N}.log"
    }
}

# 5. Flat-blocked
Run-Pinned "./main_win_ext.exe" "flat_blocked --k=10 --repeat=5 --tag=flat_blocked" `
    "$out_dir/flat_blocked.csv" "$out_dir/flat_blocked.log"

# 6. Top-k fixed-array vs priority_queue (already built bench)
Run-Pinned "./analysis/bench_topk.exe" "2000 5" `
    "$out_dir/topk_pinned.csv" "$out_dir/topk_pinned.log"

# 7. SoA vs AoS (already micro, rerun pinned)
Run-Pinned "./analysis/bench_soa_vs_aos.exe" "100000 5" `
    "$out_dir/soa_vs_aos_pinned.csv" "$out_dir/soa_vs_aos_pinned.log"

# 8. Gather vs Shuffle
Run-Pinned "./analysis/bench_gather_vs_shuffle.exe" "100000 5" `
    "$out_dir/gather_vs_shuffle_pinned.csv" "$out_dir/gather_vs_shuffle_pinned.log"

Write-Host "ALL DONE. Outputs in $out_dir"
