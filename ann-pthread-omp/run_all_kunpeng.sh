#!/usr/bin/env bash
# 鲲鹏服务器一键实验脚本（不修改 test.sh / qsub.sh）
# 用法: bash run_all_kunpeng.sh
# 支持续跑：中断后重新执行，自动从 checkpoint 继续
set -euo pipefail

RESUME_FILE="results/kunpeng_checkpoint.txt"

echo "==> 复制统一实验入口到 main.cc"
cp mains/unified_bench.cc main.cc

# 预编译：test.sh 内部 g++ 缺少 -I. 会失败，
# 但其不检查返回值，仍会提交 qsub。我们预先编译好正确的 main
echo "==> 预编译 main（test.sh 缺少 -I.，我们用正确的 flags 先编译好）"
g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++17 -I.

if [ -f "$RESUME_FILE" ]; then
    echo "==> 检测到断点: $(cat $RESUME_FILE)，将从该阶段继续"
else
    echo "==> 全新运行"
fi

echo "==> 通过 test.sh 提交 qsub 作业"
bash test.sh 2 1

echo "==> 完成。中断后重新执行 bash run_all_kunpeng.sh 即可续跑"
