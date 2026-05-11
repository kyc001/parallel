#!/usr/bin/env bash
# 鲲鹏服务器一键实验脚本
# 用法: bash run_all_kunpeng.sh
# 支持续跑：中断后重新执行即可从上次断点继续
set -euo pipefail

RESUME_FILE="results/kunpeng_checkpoint.txt"

echo "==> 复制统一实验入口到 main.cc"
cp mains/unified_bench.cc main.cc

if [ -f "$RESUME_FILE" ]; then
    LAST=$(cat "$RESUME_FILE")
    echo "==> 检测到断点: $LAST，从该阶段继续"
else
    LAST=""
    echo "==> 全新运行"
fi

echo "==> 提交 qsub 作业 (bash test.sh 2 1)"
bash test.sh 2 1

echo "==> 提交完成。qstat 查看状态；中断后重新执行即可续跑"
