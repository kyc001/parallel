#!/bin/bash
# run_all.sh - 依次跑 4 个版本并保存结果

for variant in baseline flatsimd sqsimd pqsimd; do
    echo "==== Running $variant ===="
    cp main_${variant}.cc main.cc
    g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++11 || { echo "compile failed"; exit 1; }
    bash test.sh 1 1
    # 等 qsub 返回后 test.o 已生成
    cp test.o result_${variant}.txt
    echo "---- Result for $variant ----"
    cat result_${variant}.txt
    echo ""
done