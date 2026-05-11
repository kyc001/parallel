#!/usr/bin/env bash
# 补跑鲲鹏缺失的 24 条实验（直接运行 main，跳过 test.sh）
# 用法: bash run_kunpeng_missing_24.sh
# 前提: files -> /anndata 已建立
set -euo pipefail

mkdir -p results/kunpeng

NLIST=16; NPROBE=4; P=1000; EF=50

run_one() {
    local src=$1 label=$2 t=$3; shift 3
    local exe="tmp_miss.exe"
    local outfile="results/kunpeng/${label}_t${t}.txt"
    if [ -f "$outfile" ]; then
        echo "  [skip] $outfile"
        return
    fi
    g++ "$src" -o "$exe" -O2 -fopenmp -lpthread -std=c++17 -I. 2>/dev/null
    ./"$exe" "$t" "$@" > "$outfile" 2>/dev/null
    echo "  [done] $outfile"
    rm -f "$exe"
}

echo "=== 1/3 FastScan intra (16 条) ==="
for T in 1 4 8 16; do
    run_one mains/omp/intra/main_fastscan.cc               fastscan_omp_intra              $T $P
    run_one mains/pthread/static/intra/main_fastscan.cc    fastscan_pthread_static_intra    $T $P
    run_one mains/pthread/dynamic/intra/main_fastscan.cc   fastscan_pthread_dynamic_intra   $T $P
    run_one mains/pthread/pool/intra/main_fastscan.cc      fastscan_pthread_pool_intra      $T $P
done

echo "=== 2/3 IVF pthread_pool_intra (5 条) ==="
for T in 1 2 4 8 16; do
    run_one mains/ivf/pthread/pool/intra/main_ivf.cc       ivf_pthread_pool_intra          $T $NLIST $NPROBE
done

echo "=== 3/3 HNSW baseline t=4,8,16 (3 条) ==="
for T in 4 8 16; do
    run_one mains/hnsw/main_baseline.cc                    hnsw_baseline                   $T $EF
done

echo "=== 完成，共 24 条 ==="
