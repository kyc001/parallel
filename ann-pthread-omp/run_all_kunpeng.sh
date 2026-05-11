#!/usr/bin/env bash
# 鲲鹏服务器一键实验脚本（不修改 test.sh / qsub.sh / flat_scan.h）
# 用法: bash run_all_kunpeng.sh
# 支持续跑：中断后重新执行，自动从 checkpoint 继续
set -euo pipefail

PHASES="${ANN_PHASES:-}"
RESULT_FILE="${ANN_RESULTS_FILE:-results/kunpeng_results.txt}"
RESUME_FILE="${ANN_CKPT_FILE:-results/kunpeng_checkpoint.txt}"
DISABLE_CHECKPOINT="${ANN_DISABLE_CHECKPOINT:-0}"

# ---- 服务器初始化（幂等） ----
[ -e files ] || ln -s /anndata files
echo "==> files -> /anndata ($(readlink -f files 2>/dev/null || echo ok))"
echo "==> result file: $RESULT_FILE"
if [ -n "$PHASES" ]; then
    echo "==> selected phases: $PHASES"
else
    echo "==> selected phases: all"
fi

# ---- 复制入口 ----
echo "==> 复制统一实验入口到 main.cc"
cp mains/unified_bench.cc main.cc

# ---- 预编译 ----
# test.sh 内部 g++ 缺少 -I. 且用 -std=c++11，编译必失败。
# 但其不检查返回值仍会提交 qsub。我们预先用正确 flags 编译好 main，
# g++ 失败时不会删除已存在的 main 二进制。
echo "==> 预编译 main（-std=c++17 -I.）"
CONFIG_HEADER="build/ann_run_config.h"
mkdir -p build
cat > "$CONFIG_HEADER" <<EOF
#define ANN_DEFAULT_PHASES "$PHASES"
#define ANN_DEFAULT_RESULTS_FILE "$RESULT_FILE"
#define ANN_DEFAULT_CKPT_FILE "$RESUME_FILE"
#define ANN_DEFAULT_DISABLE_CHECKPOINT $DISABLE_CHECKPOINT
EOF
g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++17 -I. -include "$CONFIG_HEADER"

# ---- 续跑 ----
if [ -f "$RESUME_FILE" ]; then
    echo "==> 检测到断点: $(cat $RESUME_FILE)，将从该阶段继续"
else
    echo "==> 全新运行"
fi

# ---- 提交 ----
echo "==> 通过 test.sh 提交 qsub 作业"
bash test.sh 2 1

echo "==> 完成。中断后重新执行 bash run_all_kunpeng.sh 即可续跑"
