# HANDOVER_LOCAL.md — ann-pthread-omp 本地工作上下文

> 本地工作副本，未入 git。每次跑实验、改源码或编辑 `report/main.tex` 后立即更新此文档。

**Last updated:** 2026-05-24 (更新: 报告压缩到 25 页 + 编程模型代表性实测 + SYCL/OpenMP offload 环境修复记录)

## 当前状态总览

- 项目：ANN Pthread / OpenMP 实验报告（SIMD 实验 ann-SIMD 的并行化扩展）
- 项目根：`d:\Study\26sp\parallel\ann-pthread-omp\`
- 主线评测平台：鲲鹏 920（ARM NEON）；本地 i9-13900H AVX2 作对照 + 全部新增 sweep 实验平台
- 报告：`report/main.tex`，最新 25 页 PDF，xelatex + bibtex 编译通过
- 数据集：DEEP100K（N=100k, d=96, 前 2000 query, k=10）
- 进阶项覆盖：5/6（多平台对比、std::thread 三方对比、AI 辅助、其他优化、编程工具对比分析）

## 本轮 (2026-05-24) 新增工作

### 1. 编程模型对比（进阶项第 5 项）

**std::thread vs Pthread vs OpenMP 三方对比**（Flat inter-query, Recall@10=0.99995）：

i9-13900H 本地数据：
| 方法 | T=1 | T=4 | T=8 | T=16 |
|---|---|---|---|---|
| std::thread | 6859.00 | 642.77 | 467.18 | 307.24 |
| Pthread dynamic | 9054.76 | 692.96 | 378.16 | 337.33 |
| OpenMP static | 8858.90 | 1492.31 | 356.51 | 357.38 |

鲲鹏 920 旧数据（来自 `results/kunpeng/stdthread_comparison.txt`，最终报告的补充表仅采用本地代表性实测）：
| 方法 | T=1 | T=2 | T=4 | T=8 |
|---|---|---|---|---|
| std::thread | 11983 | 3712 | 2183 | 1131 |
| Pthread | 10870 | 4026 | 1941 | 1115 |
| OpenMP | 9414 | 6006 | 3639 | 1625 |

### 2. SYCL 与 OpenMP Offload/CUDA 代码与环境状态

已创建代表性样本文件：
- `tools/flat_scan_sycl.cpp` — SYCL Flat scan（需 Intel oneAPI icpx 编译器）
- `tools/flat_scan_omp_offload.cpp` — OpenMP offload Flat scan（需支持 GPU offload 的编译器）
- `tools/flat_scan_cuda.cu` — CUDA Flat scan（需 nvcc，已有但课程不要求 CUDA）

**当前工具链状态**：
- OpenMP target host fallback 可编译运行：`results/omp_target_host_result.txt`，运行时 `OpenMP target devices=0`，不是 GPU 结果。
- Clang OpenMP NVIDIA target 已尝试 `--cuda-path` + `--offload-arch=sm_89`，失败于缺少 `libomptarget-nvptx.bc`。
- CUDA toolkit / `nvcc` 存在，但缺 MSVC `cl.exe`；尝试静默补装 VS C++ tools 被当前非提升权限进程拒绝，返回 5007。
- `clang-cl` / Clang CUDA 路线也尝试过，失败于 CUDA runtime 与 MinGW 头文件冲突。
- SYCL/oneAPI 仍缺 `icpx`/`dpcpp` 和 SYCL headers；conda-forge win-64 未找到可用 `dpcpp`/SYCL 编译器，Intel channel 返回 403。

报告正文“补充实验说明”已改为实测 + 环境修复尝试摘要，不再保留附录 C 大段未编译代码。

### 3. 报告进阶项说明更新

- §进阶项说明 从 4 项扩展到 5 项
- 更新本地 std::thread / Pthread / OpenMP 代表性实测表
- 新增 OpenMP target host fallback 结果与 GPU/SYCL/CUDA 真实编译失败记录
- 删除附录 C 大段未编译代码，保留正文中的工具链边界和 PCIe 分析

### 4. 新增脚本

- `run_programming_model_comparison.ps1` — 编程模型一键对比脚本（需 Intel oneAPI）

## 上一轮 (2026-05-12) 工作（保留）

### 报告内容（从 21 页扩展到 28 页）

- §3.2 调度小节加入 3 段并行代码片段
- §4.2 IVF — inverted list dynamic 分配代码 + nprobe=4 退化分析
- §4.3 HNSW — multi-entry OMP 代码 + "为何 t=4 比 t=1 慢"微观原因
- §6.1 tab:best 加「vs 同变体 t=1 加速比」列
- §6.5 OpenMP schedule × chunk size 二维扫描
- §6.6 负载均衡定量分析（inverted list 长度直方图 + TikZ 画图）
- §6.7 N × T 交叉表
- §6.8 虚假共享对照实验
- §6.9 P-core / E-core 亲和性实验
- §6.10 Recall-Latency Trade-off
- §6.11 跨平台对比（i9 vs 鲲鹏）
- HNSW ef sweep 表 + TikZ 曲线
- 附录 A：AI 使用报告
- 附录 B：复现协议 + local_summary 精选 22 行
- 附录 C：SYCL + OpenMP offload 代码（新增）

### 工具（tools/）

| 文件 | 用途 | 输出 |
|---|---|---|
| `tools/dump_ivf_hist.cc` | dump IVF inverted list 长度分布 | `results/ivf_list_histogram.csv` |
| `tools/sweep_omp_schedule.cc` | OMP schedule×chunk 运行时切换 sweep | `results/omp_schedule_sweep.txt` |
| `tools/sweep_n_threads.cc` | N×T 二维 sweep | `results/n_t_sweep.txt` |
| `tools/false_sharing_demo.cc` | 紧凑 vs padded 64B 对照 | `results/false_sharing.txt` |
| `tools/sweep_hnsw_ef.cc` | HNSW ef sweep | `results/hnsw_ef_sweep.txt` |
| `tools/sweep_stdthread.cc` | std::thread vs Pthread vs OpenMP 三方对比 | `results/stdthread_comparison.txt` |
| `tools/flat_scan_sycl.cpp` | SYCL Flat scan（未编译） | -- |
| `tools/flat_scan_omp_offload.cpp` | OpenMP offload Flat scan（未编译） | -- |
| `tools/flat_scan_cuda.cu` | CUDA Flat scan | -- |

### main.cc

鲲鹏侧 Recall@10>0.95 下最快配置：
`ivfpq_local_pthread_dynamic_inter, t=8, nlist=16, nprobe=4, p=1000`（鲲鹏 134.48 μs / Recall 0.9597）

编译：`g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++17 -I.`
提交：`sh test.sh 2 1`

## 关键实验数据（直接可复用）

### 鲲鹏 arm_neon_results.txt 最快 Top 5
| 排名 | 方法 | 延迟 (μs) | Recall |
|---|---|---|---|
| 1 | ivfpq_local pthread_dynamic_inter t=8 | 134.48 | 0.95970 |
| 2 | ivfpq_local pthread_pool_inter t=8 | 135.35 | 0.95970 |
| 3 | ivfpq_local pthread_dynamic_inter t=16 | 136.63 | 0.95970 |
| 4 | ivfpq_local pthread_static_inter t=8 | 137.64 | 0.95970 |
| 5 | ivfpq_local omp_inter t=8 | 139.89 | 0.95970 |

### inverted list 长度分布（nlist=16, KMeans, DEEP100K base）
- min=2173, median=5011, max=16921, mean=6250, stddev=3804
- max/mean = 2.71×

### OMP schedule × chunk sweep（Flat inter, T=16）
最快：`guided,8` 287.87 μs
最慢：`static,256` 428.74 μs

### N × T 交叉表（Flat inter, OMP static, μs/query）
| N | T=1 | T=2 | T=4 | T=8 | T=16 |
|---|---|---|---|---|---|
| 10k | 115.27 | 47.53 | 23.95 | 16.87 | 11.73 |
| 50k | 3841.78 | 602.37 | 180.54 | 142.10 | 103.79 |
| 100k | 8416.51 | 4059.09 | 1115.15 | 476.16 | 443.71 |

### 虚假共享对照（30M ++value/线程）
| T | 紧凑 ms | padded ms | FS/pad |
|---|---|---|---|
| 2 | 0.97 | 0.41 | 2.36× |
| 4 | 0.55 | 0.14 | 3.98× |
| 8 | 0.95 | 0.38 | 2.52× |
| 16 | 1.84 | 0.24 | 7.81× |

鲲鹏侧 false sharing 更严重（42--56×），因 ARM cache line 128B。

### P/E 亲和性（Flat inter, OMP static, N=100k）
| 配置 | T | latency μs | mask |
|---|---|---|---|
| Default | 16 | 256.01 | -- |
| P-only | 12 | 305.65 | 0xFFF |
| E-only | 8 | 934.10 | 0xFF000 |
| P+E all | 20 | 249.41 | 0xFFFFF |

### HNSW ef sweep（单线程, M=16, ef_c=120）
| ef | Recall@10 | latency μs |
|---|---|---|
| 10 | 0.78995 | 23.06 |
| 25 | 0.92135 | 41.93 |
| 50 | 0.96865 | 61.92 |
| 100 | 0.99070 | 136.32 |
| 200 | 0.99720 | 323.02 |
| 400 | 0.99940 | 402.27 |

## 已知坑（踩过的）

1. MSYS2 GCC libgomp 不支持 OMP_PLACES affinity —— 改用 Windows `cmd /AFFINITY <mask>`
2. LaTeX caption 内 `\path{...}` fragile —— 改用 `\texttt{...}` 手动转义
3. TikZ \pgfmathsetmacro 大数值 dimension overflow —— 预计算比例
4. OMP `schedule(runtime)` + `OMP_SCHEDULE` 在 MSYS2 工作正常
5. C++17 → C++11 迁移 —— `std::filesystem` 替换为 POSIX API
6. 跨目录 include 路径 —— 148 处改为相对路径
7. main.cc 线程数 —— 鲲鹏 IVF-PQ 最快是 t=8 (134.48 μs)，不是 t=16
8. `hnsw_mt_scaling.txt` 的 52μs 是 inter-query 吞吐量，不可与 intra-query 数据直接对比
9. LLVM/Clang 21.1.0 缺少 libomptarget，无法 OpenMP offload 到 NVIDIA GPU
10. Intel oneAPI 下载服务不可用，pip 的 dpcpp-cpp-rt 仅含运行时无编译器

## 复现路径

本地：`make` + `powershell -ExecutionPolicy Bypass -File run_all.ps1`
鲲鹏：`bash run_all_kunpeng_part1.sh && bash run_all_kunpeng_part2.sh`
课程框架入口：`sh test.sh 2 1`
编程模型对比：`powershell -ExecutionPolicy Bypass -File run_programming_model_comparison.ps1`（需 Intel oneAPI）
