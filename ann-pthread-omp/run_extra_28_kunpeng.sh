#!/usr/bin/env bash
# 补跑 unified_bench 未覆盖的 28 条实验（直接运行，跳过 test.sh）
# 用法: bash run_extra_28_kunpeng.sh
set -euo pipefail

mkdir -p results/kunpeng

NLIST=16
NPROBE=4
P=1000
EF=50

# 编译并运行，结果写入 results/kunpeng/
run_one() {
    local src=$1 exe=$2 label=$3 t=$4
    shift 4
    local outfile="results/kunpeng/${label}_t${t}.txt"
    if [ -f "$outfile" ]; then
        echo "  [skip] $outfile 已存在"
        return
    fi
    g++ "$src" -o "$exe" -O2 -fopenmp -lpthread -std=c++17 -I. 2>/dev/null
    ./"$exe" "$t" "$@" > "$outfile" 2>/dev/null
    echo "  [done] $outfile"
    rm -f "$exe"
}

echo "=== 1/7 FastScan intra (16 条) ==="
for T in 1 4 8 16; do
    run_one mains/omp/intra/main_fastscan.cc         tmp_fs "fastscan_omp_intra"         $T $P
    run_one mains/pthread/static/intra/main_fastscan.cc  tmp_fs "fastscan_pthread_static_intra"  $T $P
    run_one mains/pthread/dynamic/intra/main_fastscan.cc tmp_fs "fastscan_pthread_dynamic_intra" $T $P
    run_one mains/pthread/pool/intra/main_fastscan.cc    tmp_fs "fastscan_pthread_pool_intra"    $T $P
done

echo "=== 2/7 IVF pthread_pool_intra (5 条) ==="
for T in 1 2 4 8 16; do
    run_one mains/ivf/pthread/pool/intra/main_ivf.cc tmp_ivf "ivf_pthread_pool_intra" $T $NLIST $NPROBE
done

echo "=== 3/7 IVF simd_serial t=2,4,8,16 (4 条) ==="
for T in 2 4 8 16; do
    run_one mains/ivf/simd/main_ivf.cc tmp_ivf "ivf_simd" $T $NLIST $NPROBE
done

echo "=== 4/7 HNSW baseline t=2,4,8,16 (4 条) ==="
for T in 2 4 8 16; do
    run_one mains/hnsw/main_baseline.cc tmp_hnsw "hnsw_baseline" $T $EF
done

echo "=== 全部完成，共 29 条 ==="
ls results/kunpeng/fastscan_*_intra_*.txt results/kunpeng/ivf_pthread_pool_intra_*.txt results/kunpeng/ivf_simd_t{2,4,8,16}.txt results/kunpeng/hnsw_baseline_t{2,4,8,16}.txt 2>/dev/null | wc -l
