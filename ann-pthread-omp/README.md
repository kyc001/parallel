# ANN Pthread + OpenMP 并行化

并行程序设计 Lab3 — ANN 近似最近邻搜索的 Pthread + OpenMP 多线程并行优化。

## 最终提交入口

`main.cc` 由运行脚本从 `mains/` 对应变体 `cp` 覆盖生成，不手写维护。

鲲鹏服务器提交：

```bash
bash run_all_kunpeng_part1.sh
bash run_all_kunpeng_part2.sh
```

Both Kunpeng scripts call `run_all_kunpeng.sh`, which precompiles `main` with C++17 flags and submits `qsub.sh` directly from bash. The older `test.sh` wrapper is kept only as a compatibility artifact.

## 算法覆盖

| 算法 | SIMD 内核 | Pthread | OpenMP | 调度方式 |
|---|---|---|---|---|
| Flat | AVX2 / NEON | static/dynamic/pool × inter/intra | inter/intra | 全量 |
| SQ | AVX2 / NEON | static/dynamic/pool × inter/intra | inter/intra | 全量 |
| PQ | AVX2 / NEON | static/dynamic/pool × inter/intra | inter/intra | 全量 |
| FastScan | AVX2 / NEON | static/dynamic/pool × inter/intra | inter/intra | 全量 |
| IVF | AVX2 / NEON | static/dynamic/pool × inter/intra | inter/intra | 全量 |
| IVF-PQ | AVX2 / NEON | static/dynamic/pool × inter/intra | inter/intra | 全量 (global/local 双模式) |
| HNSW | hnswlib 内部 API | 多入口/边划分/Layer0 | 多入口/边划分/Layer0/IVF嵌套 | 代表性 |

## 目录结构

```text
ann-pthread-omp/
├── main.cc                # 编译入口（由脚本 cp 覆盖生成）
├── flat_scan.h            # 串行基线（不可修改）
├── test.sh / qsub.sh      # server submission helpers; maintained entry is run_all_kunpeng*.sh
├── run_all.ps1            # 本机 PowerShell 全量一键运行，并刷新 results/*.csv
├── run_all.sh             # Bash 全量运行
├── run_all_kunpeng.sh     # 鲲鹏提交引擎（由 part1/part2 调用）
├── run_all_kunpeng_part1.sh # 鲲鹏全量实验第一段
├── run_all_kunpeng_part2.sh # 鲲鹏全量实验第二段
├── Makefile               # 一键编译所有变体
│
├── simd/                  # SIMD 距离计算头文件
├── pthread/               # Pthread 并行实现 + 线程池
├── omp/                   # OpenMP 并行实现
├── ivf/                   # IVF / IVF-PQ 索引 + SIMD + 并行搜索
├── hnsw/                  # HNSW 图搜索并行策略
├── hnswlib/               # HNSW 原始库（不修改源码）
│
├── mains/                 # 所有 main_*.cc 变体（~64 个）
│   ├── simd/              # 旧 SIMD 参考入口
│   ├── omp/inter/ intra/
│   ├── pthread/static/dynamic/pool × inter/intra/
│   ├── ivf/simd/ omp/ pthread/
│   └── hnsw/
│
├── results/local/         # 本机实验结果
├── report/                # 实验报告 LaTeX
└── build/                 # 编译产物
```

## 本机编译运行

```bash
make                          # 编译所有变体到 build/
bash run_all.sh               # 一键运行核心矩阵
```

Windows / PowerShell：

```powershell
.\run_all.ps1                 # 输出到 results/local，并刷新 local_summary.csv 等汇总
```

或手动：

```bash
cp mains/pthread/static/inter/main_flat.cc main.cc
g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++17 -I. -mavx2 -mfma
./main 4                     # 参数：线程数
```

## 平台

- **本机**: Windows 11, Intel i9-13900H, AVX2+FMA, 数据 `../files/`
- **Kunpeng server**: AArch64/NEON, data `/anndata/`, submit with `bash run_all_kunpeng_part1.sh` and `bash run_all_kunpeng_part2.sh`
