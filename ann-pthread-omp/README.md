# ANN Pthread + OpenMP 并行化

并行程序设计 Lab3 — ANN 近似最近邻搜索的 Pthread + OpenMP 多线程并行优化。

## 最终提交入口

`main.cc` 当前配置为鲲鹏平台最快方案：**IVF-PQ local + pthread_dynamic_inter（t=8, nlist=16, nprobe=4, p=1000）**，延迟 134.48μs，Recall@10=0.9597。

```bash
bash test.sh 2 1
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
├── Makefile               # 一键编译所有变体
│
├── simd/                  # SIMD 距离计算头文件
├── pthread/               # Pthread 并行实现 + 线程池 + std::thread
├── omp/                   # OpenMP 并行实现
├── ivf/                   # IVF / IVF-PQ 索引 + SIMD + 并行搜索
├── hnsw/                  # HNSW 图搜索并行策略
├── hnswlib/               # HNSW 原始库（不修改源码）
│
├── mains/                 # 所有 main_*.cc 变体（~64 个）
│   ├── omp/inter/ intra/
│   ├── pthread/static/dynamic/pool × inter/intra/
│   ├── ivf/simd/ omp/ pthread/
│   └── hnsw/
│
├── tools/                 # 独立 benchmark / sweep 工具
│   ├── sweep_stdthread.cc # std::thread vs Pthread vs OpenMP 三方对比
│   ├── sweep_ivf_nlist.cc # IVF nlist 参数扫描
│   └── false_sharing_demo.cc  # 虚假共享对照实验
│
├── scripts/               # 报告图表生成
│   └── gen_report_assets.py   # 从 CSV 生成 PDF 图表
│
├── results/               # 实验结果
│   ├── local/             # 本机结果 (txt)
│   ├── kunpeng/           # 鲲鹏结果 (txt)
│   └── *.csv              # 汇总表
│
├── report/                # 实验报告 LaTeX
└── build/                 # 编译产物
```

## 脚本说明

### 核心运行脚本

| 脚本 | 用途 | 运行平台 |
|---|---|---|
| `test.sh` | 课程框架提交脚本，编译 main.cc 并通过 qsub 提交到计算节点 | 鲲鹏 (via PBS) |
| `qsub.sh` | PBS 作业脚本，被 test.sh 调用，负责 scp 可执行文件到计算节点并执行 | 鲲鹏 |
| `run_all.ps1` | 本机 PowerShell 全量运行，编译并执行所有 64 个变体 × 线程数，生成 results/local/ 和 CSV 汇总 | Windows 本机 |
| `run_all.sh` | Bash 版全量运行，功能同 run_all.ps1 | Linux/macOS 本机 |
| `run_all_kunpeng.sh` | 鲲鹏一键引擎：编译 unified_bench.cc，通过 qsub 提交，支持断点续传 | 鲲鹏 |
| `run_all_kunpeng_part1.sh` | 鲲鹏全量实验第一段：flat/sq/pq/fastscan/ivf | 鲲鹏 |
| `run_all_kunpeng_part2.sh` | 鲲鹏全量实验第二段：ivfpq_global/ivfpq_local/hnsw/hnsw_nested | 鲲鹏 |
| `Makefile` | 一键编译所有变体到 build/，自动检测 x86/ARM 平台 | 通用 |

### 补充实验脚本

| 脚本 | 用途 | 运行平台 |
|---|---|---|
| `kunpeng_collect.sh` | 鲲鹏系统信息采集（CPU/内存/Cache）+ IVF nlist 参数扫描 | 鲲鹏 |
| `kunpeng_deep.sh` | 鲲鹏深度实验：OMP schedule×chunk 扫描、N×T 交叉表、HNSW ef 扫描、虚假共享对照 | 鲲鹏 |
| `kunpeng_extra.sh` | 鲲鹏补充实验：HNSW 多入口线程伸缩、std::thread vs Pthread vs OpenMP 三方对比 | 鲲鹏 |
| `local_variance.sh` | 本地方差测量：对关键配置跑 5 次计算 mean±std | 本机 |
| `run_programming_model_comparison.ps1` | 编程模型对比：Pthread/OpenMP/std::thread/SYCL/OMP offload 一键运行 | Windows 本机 |

### 报告生成

| 脚本 | 用途 |
|---|---|
| `scripts/gen_report_assets.py` | 从 results/ CSV 生成报告图表 PDF（速度对比、调度对比、跨平台对比、trade-off 曲线等） |

### 工具 (tools/)

| 文件 | 用途 |
|---|---|
| `tools/sweep_stdthread.cc` | std::thread vs Pthread vs OpenMP 三方对比 benchmark |
| `tools/sweep_ivf_nlist.cc` | IVF nlist 参数扫描 benchmark |
| `tools/false_sharing_demo.cc` | 虚假共享对照实验（padded vs unpadded counter） |
| `tools/flat_scan_sycl.cpp` | SYCL Flat Scan 实现（需 Intel oneAPI 或支持 SYCL 的编译器） |
| `tools/flat_scan_omp_offload.cpp` | OpenMP offload Flat Scan 实现（需支持 GPU offload 的编译器） |
| `tools/flat_scan_cuda.cu` | CUDA Flat Scan 实现（需 NVIDIA CUDA Toolkit） |

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
- **Kunpeng server**: AArch64/NEON, 数据 `/anndata/`, submit with `bash run_all_kunpeng_part1.sh` and `bash run_all_kunpeng_part2.sh`
