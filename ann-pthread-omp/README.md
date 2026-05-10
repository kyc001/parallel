# ANN Pthread + OpenMP 并行化

并行程序设计 Lab3 — ANN 近似最近邻搜索的 Pthread + OpenMP 多线程并行优化。

## 最终提交入口

`main.cc` 由运行脚本从 `mains/` 对应变体 `cp` 覆盖生成，不手写维护。

鲲鹏服务器提交：

```bash
bash test.sh 2 1    # 参数：选题序号=2 (pthread-omp)，节点数=1
```

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
├── test.sh / qsub.sh      # 服务器提交脚本（不可修改）
├── run_all.sh             # 本机一键运行
├── run_all_kunpeng.sh     # 鲲鹏一键运行
├── run_all.ps1            # 本机 PowerShell 一键运行
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

或手动：

```bash
cp mains/pthread/static/inter/main_flat.cc main.cc
g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++17 -I. -mavx2 -mfma
./main 4                     # 参数：线程数
```

## 平台

- **本机**: Windows 11, Intel i9-13900H, AVX2+FMA, 数据 `../files/`
- **鲲鹏服务器**: AArch64/NEON, 数据 `/anndata/`, 提交 `bash test.sh 2 1`
