#!/bin/bash
# 鲲鹏 920 一键采集脚本
# 用法: bash kunpeng_collect.sh
# 输出: results/kunpeng/sysinfo.txt + 补充实验结果

set -e
RESULTS="results/kunpeng"
mkdir -p "$RESULTS"

echo "=== 鲲鹏系统信息采集 ==="

# 1. CPU 信息
echo "[1/5] 采集 CPU 信息..."
lscpu > "$RESULTS/sysinfo.txt" 2>/dev/null || echo "lscpu 不可用" >> "$RESULTS/sysinfo.txt"
echo "---" >> "$RESULTS/sysinfo.txt"
cat /proc/cpuinfo | grep -E "model name|Features|cpu MHz|CPU part" | head -20 >> "$RESULTS/sysinfo.txt" 2>/dev/null
echo "---" >> "$RESULTS/sysinfo.txt"
nproc >> "$RESULTS/sysinfo.txt" 2>/dev/null

# 2. 内存信息
echo "[2/5] 采集内存信息..."
free -h >> "$RESULTS/sysinfo.txt" 2>/dev/null
echo "---" >> "$RESULTS/sysinfo.txt"

# 3. Cache 信息
echo "[3/5] 采集 Cache 信息..."
if [ -d /sys/devices/system/cpu/cpu0/cache ]; then
    for idx in /sys/devices/system/cpu/cpu0/cache/index*; do
        echo "$(cat $idx/type 2>/dev/null) L$(cat $idx/level 2>/dev/null): $(cat $idx/size 2>/dev/null), $(cat $idx/ways_of_associativity 2>/dev/null)-way" >> "$RESULTS/sysinfo.txt"
    done
fi

echo "系统信息已保存到 $RESULTS/sysinfo.txt"
cat "$RESULTS/sysinfo.txt"

echo ""
echo "=== 补充实验 ==="

# 4. IVF nlist sweep (如果还没跑过)
if [ ! -f "$RESULTS/ivf_nlist_sweep.txt" ]; then
    echo "[4/5] 运行 IVF nlist sweep..."
    g++ tools/sweep_ivf_nlist.cc -o build/sweep_ivf_nlist.exe -O2 -fopenmp -lpthread -std=c++11 -I.
    for nlist in 4 8 16 32 64 128 256; do
        ./build/sweep_ivf_nlist.exe $nlist >> "$RESULTS/ivf_nlist_sweep.txt"
    done
else
    echo "[4/5] IVF nlist sweep 已存在，跳过"
fi

# 5. PQ p sweep — 鲲鹏的 PQ 实验已在主线 run_all_kunpeng 脚本中完成
# sweep_pq_p.cc 依赖 AVX2 头文件 (immintrin.h)，无法在 ARM 上编译
# 如需鲲鹏侧 PQ p-sweep 数据，请用 pthread/pq_scan_pthread.h 中的 NEON 路径
echo "[5/5] PQ p sweep 需要 AVX2，跳过（鲲鹏数据已在主线实验中采集）"

echo ""
echo "=== 采集完成 ==="
echo "请将以下文件内容发回:"
echo "  1. $RESULTS/sysinfo.txt"
echo "  2. $RESULTS/ivf_nlist_sweep.txt (如已存在则无需)"
echo "  3. $RESULTS/pq_p_sweep.txt (如已存在则无需)"
