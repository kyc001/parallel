#!/bin/bash
# 本地方差测量：对关键配置跑 5 次，计算 mean ± std
# 用法: bash local_variance.sh
# 输出: results/local_variance.txt

set -e
mkdir -p build results
OUT="results/local_variance.txt"

echo "=== 本地方差测量 (5 runs) ===" > "$OUT"

# 关键配置：表 4 的高召回最优行
CONFIGS=(
    "flat pthread_dynamic_inter 16"
    "sq pthread_dynamic_inter 16"
    "pq omp_inter 16"
    "fastscan pthread_dynamic_inter 16"
    "ivf pthread_pool_inter 16"
    "ivfpq_local pthread_pool_inter 16"
)

# 编译所有需要的入口
echo "编译中..."
for algo in flat sq pq fastscan ivf ivfpq; do
    src="mains/${algo}_bench.cc"
    if [ -f "$src" ]; then
        g++ "$src" -o "build/${algo}_bench.exe" -O2 -fopenmp -lpthread -std=c++11 -I. 2>/dev/null || true
    fi
done

for config in "${CONFIGS[@]}"; do
    read -r algo strategy threads <<< "$config"
    echo ""
    echo ">>> $algo $strategy t=$threads (5 runs)"
    echo "--- $algo $strategy t=$threads ---" >> "$OUT"

    # 找到对应的可执行文件
    exe=""
    for candidate in "build/${algo}_bench.exe" "build/${algo}_${strategy}_t${threads}.exe"; do
        if [ -f "$candidate" ]; then
            exe="$candidate"
            break
        fi
    done

    if [ -z "$exe" ]; then
        echo "  跳过（未找到可执行文件）"
        echo "  SKIPPED" >> "$OUT"
        continue
    fi

    for run in 1 2 3 4 5; do
        echo "  run $run/5 ..."
        $exe $threads >> "$OUT" 2>/dev/null || echo "  ERROR" >> "$OUT"
    done
done

echo ""
echo "结果已保存到 $OUT"
cat "$OUT"
