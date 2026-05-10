#!/usr/bin/env bash
# 鲲鹏服务器一键实验脚本 (ann-pthread-omp)
# 用法: bash run_all_kunpeng.sh
set -euo pipefail

echo "==> 复制统一实验入口到 main.cc"
cp mains/unified_bench.cc main.cc

echo "==> 提交 qsub 作业 (bash test_pthread_omp.sh 2 1)"
bash test_pthread_omp.sh 2 1

echo "==> 提交完成。用 qstat 查看状态，结束后 test.o 中为实验结果"
