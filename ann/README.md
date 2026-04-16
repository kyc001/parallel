# ANNS SIMD 实验（Lab2）

并行程序设计 Lab2 — SIMD 编程实验，选题 **ANN（近似最近邻搜索）**。

## 📋 项目概述

- **平台**：ARM（鲲鹏 920 服务器 / 平板 Termux），使用 **NEON** 指令集
- **数据集**：DEEP100K（96 维，100K 条 float32 向量，IP 内积距离）
- **评分**：基础要求上限 90%（13.5 分），进阶加分 10%（1.5 分）
- **报告**：≤ 15 页，含算法设计、伪代码、实验数据与分析、Git 链接

## 📁 项目结构

```

ann/

├── [main.cc](http://main.cc)                # 主程序（数据加载、查询测试、recall/latency 计算）

├── flat_scan.h            # 原始串行 flat search（baseline）

├── flat_scan_simd.h       # Flat-SIMD：NEON 加速 IP 距离（4路展开）

├── sq_scan_simd.h         # SQ-SIMD：uint8 标量量化 + 两阶段检索

├── pq_scan_simd.h         # PQ-SIMD：乘积量化 + ADC 查表 + 两阶段检索

├── hnswlib/               # hnswlib 库（从 GitHub clone）

├── files/                 # 数据文件目录（已在 .gitignore 中排除）

│   ├── DEEP100K.base.100k.fbin      # 37MB - base 向量

│   ├── DEEP100K.query.fbin           # 3.7MB - 查询向量

│   └── [DEEP100K.gt.query.100k.top](http://DEEP100K.gt.query.100k.top)100.bin  # 7.7MB - groundtruth

├── [analyze.cc](http://analyze.cc)             # 汇编分析用的独立测试文件

├── bench_[optlevel.cc](http://optlevel.cc)      # 不同优化等级性能对比测试

├── asm_analysis.txt       # 关键函数汇编代码

├── neon_stats.txt         # NEON 指令统计

├── vec_report.txt         # 编译器自动向量化报告

├── autovec_analysis.txt   # 自动向量化分析

├── optlevel_perf.txt      # 不同优化等级性能数据

└── .gitignore             # 排除 files/ 和编译产物

```

## 🚀 快速开始

### 环境要求

- ARM AArch64 平台（支持 NEON asimd）
- g++（支持 C++11）
- 数据文件放在 `files/` 目录下

### 编译运行

```

g++ [main.cc](http://main.cc) -o main -O2 -fopenmp -lpthread -std=c++11

./main

```

### 切换不同算法版本

修改 `main.cc` 中的 `#include` 和查询调用：

| 版本 | include 文件 | 查询函数 | 额外参数 |
|---|---|---|---|
| 串行 Baseline | `flat_scan.h` | `flat_search(base, query, N, d, k)` | 无 |
| Flat-SIMD | `flat_scan_simd.h` | `flat_search(base, query, N, d, k)` | 无 |
| SQ-SIMD | `sq_scan_simd.h` | `sq_search(base, query, N, d, k, sq_index, p)` | 需构建 SQIndex |
| PQ-SIMD | `pq_scan_simd.h` | `pq_search(base, query, N, d, k, pq_index, p)` | 需构建 PQIndex |

SQ/PQ 版本需要在查询循环前构建索引：
```

// SQ

SQIndex sq_index;

sq_[index.build](http://index.build)(base, base_number, vecdim);

// PQ

PQIndex pq_index;

pq_[index.build](http://index.build)(base, base_number, vecdim, 8, 256, 20); // M=8, ksub=256, niter=20

```

## 📊 实验结果

### 核心对比

| 版本 | Recall@10 | Latency (μs) | 加速比 |
|---|---|---|---|
| 串行 Flat | 0.99995 | 8282.96 | 1.00x |
| Flat-SIMD | 0.99995 | 2596.54 | **3.19x** |
| SQ-SIMD (p=1000) | 0.99995 | 1875.51 | **4.42x** |
| SQ-SIMD (p=100) | 0.99995 | 1087.87 | **7.61x** |
| PQ-SIMD (p=1000) | 0.98355 | 1520.52 | **5.45x** |

### SQ-SIMD Latency-Recall Tradeoff

| p | Recall | Latency (μs) |
|---|---|---|
| 100 | 0.99995 | 1087.87 |
| 200 | 0.99995 | 1387.96 |
| 500 | 0.99995 | 1856.89 |
| 1000 | 0.99995 | 2399.20 |
| 2000 | 0.99995 | 3449.92 |
| 5000 | 0.99995 | 5649.49 |
| 10000 | 0.99995 | 10293.17 |

### PQ-SIMD Latency-Recall Tradeoff (M=8)

| p | Recall | Latency (μs) |
|---|---|---|
| 100 | 0.70930 | 842.05 |
| 200 | 0.83835 | 924.83 |
| 500 | 0.94740 | 1178.43 |
| 1000 | 0.98355 | 1520.52 |
| 2000 | 0.99550 | 2488.09 |
| 5000 | 0.99980 | 4180.43 |
| 10000 | 0.99995 | 7268.55 |

### 汇编分析：不同优化等级性能

| 优化等级 | Serial (ns/call) | SIMD (ns/call) | 加速比 |
|---|---|---|---|
| -O0 | 468.62 | 269.90 | 1.74x |
| -O1 | 120.81 | 31.65 | 3.82x |
| -O2 | 90.85 | 29.53 | 3.08x |
| -O3 | 96.92 | 26.19 | 3.70x |

## 🖥️ 开发环境

### 本地开发环境（平板 Termux）

- **设备**：荣耀平板 9（ARM 8核）
- **系统**：Termux + PRoot-Distro
- **CPU 特性**：asimd, asimddp（支持 NEON + Dot Product）
- **工作目录**：`/data/data/com.termux/files/home/workspace/parallel_repo/ann/`
- **注意**：`main.cc` 中数据路径为 `./files/`

### 远程运行环境

- 远程服务器地址、账号、跳板机、项目路径和数据路径不写入仓库。
- 在服务器或其他平台运行时，请按课程平台说明或私有文档配置数据路径。

## ⚠️ 提交注意事项

1. 只能通过 `bash test.sh 1 1` 提交，禁止直接运行程序
2. 新增文件均为 `.h` 格式（header-only）
3. 提交前按目标平台配置 `main.cc` 中的数据路径
4. 禁止修改 `test.sh`、禁止将 `test_gt` 作为答案输出
5. 本地验证正确性后再提交，避免死循环导致服务器崩溃

## 🔧 Git 使用

```

# 提交更改

git add -A

git commit -m "your message"

git push origin master


```

## 📝 关键技术笔记

- 96 维是 4 的倍数，NEON `float32x4_t` 无需处理尾部
- 平板支持 `asimddp`（dot product），可用 `vdotq_u32` 加速 uint8 距离计算
- `-O2` 下编译器不会自动向量化串行 IP 距离；`-O3` 会但效果不如手写 SIMD
- PQ 的 `adc_distance` 因间接索引（gather）无法 SIMD 化，保持标量执行
- SQ 量化精度极高，所有 p 值下 recall 保持 0.99995
- PQ 量化误差较大，小 p 值 recall 下降，但粗排速度远快于 SQ
