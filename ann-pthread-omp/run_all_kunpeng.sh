#!/usr/bin/env bash
# 鲲鹏服务器一键实验脚本
# 用法: bash run_all_kunpeng.sh
# 将 unified_bench.cc 作为 main.cc 编译，一次 qsub 跑完所有实验矩阵
set -euo pipefail

echo "==> 复制统一实验入口到 main.cc"
cp mains/unified_bench.cc main.cc

echo "==> 编译 (仅编译，不在登录节点运行)"
g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++17 -I.

echo "==> 提交 qsub 作业 (bash test.sh 2 1)"
bash test.sh 2 1

echo "==> 提交完成，等待作业结束后查看 test.o / test.e"
echo "    结果格式: RESULT <algo> <strategy> t=<n> recall=<r> latency_us=<us> [params]"
