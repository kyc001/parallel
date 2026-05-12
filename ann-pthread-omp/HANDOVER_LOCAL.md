# HANDOVER_LOCAL.md — ann-pthread-omp 本地工作上下文

> 本地工作副本，未入 git。每次跑实验、改源码或编辑 `report/main.tex` 后立即更新此文档。

**Last updated:** 2026-05-12 (更新: C++11 兼容 + include 路径修复 + AI 报告重写)

## 当前状态总览

- 项目：ANN Pthread / OpenMP 实验报告（SIMD 实验 ann-SIMD 的并行化扩展）
- 项目根：`d:\Study\26sp\parallel\ann-pthread-omp\`
- 主线评测平台：鲲鹏 920（ARM NEON）；本地 i9-13900H AVX2 作对照 + 全部新增 sweep 实验平台
- 报告：`report/main.tex`，最新 21 页 PDF，xelatex + bibtex 编译通过
- 数据集：DEEP100K（N=100k, d=96, 前 2000 query, k=10）

## 本轮 (2026-05-12) 新增工作

### 1. 报告内容补强（在用户重写 557 行精简版基础上 → 当前 21 页）

- §3.2 调度小节加入 3 段并行代码片段（Pthread dynamic worker / OMP for / OMP intra heap merge）
- §4.2 IVF — inverted list dynamic 分配代码 + nprobe=4 退化分析
- §4.3 HNSW — multi-entry OMP 代码 + "为何 t=4 比 t=1 慢"微观原因
- §6.1 tab:best 加「vs 同变体 t=1 加速比」列（11 行数据全部实测，含 FastScan 19.10× 加注释）
- §6.5 OpenMP schedule × chunk size 二维扫描（新增）
- §6.6 负载均衡定量分析（inverted list 长度直方图 + TikZ 画图）
- §6.7 N × T 交叉表（新增）
- §6.8 虚假共享对照实验（新增）
- §6.9 P-core / E-core 亲和性实验（新增）
- §6.10 Recall-Latency Trade-off（原 §6.5）
- HNSW 章节补 ef sweep 表 + TikZ 曲线
- 附录 A：AI 使用报告完整扩写（声明 / 场景清单 / 关键 prompt / 复核结论）
- 附录 B：复现协议（5 个新增 sweep 的完整命令） + local_summary 精选 22 行

### 2. 新增工具（tools/）

| 文件 | 用途 | 输出 |
|---|---|---|
| `tools/dump_ivf_hist.cc` | dump IVF inverted list 长度分布 | `results/ivf_list_histogram.csv` |
| `tools/sweep_omp_schedule.cc` | OMP schedule×chunk 运行时切换 sweep | `results/omp_schedule_sweep.txt` |
| `tools/sweep_n_threads.cc` | N×T 二维 sweep | `results/n_t_sweep.txt` |
| `tools/false_sharing_demo.cc` | 紧凑 vs padded 64B 对照 | `results/false_sharing.txt` |
| `tools/sweep_hnsw_ef.cc` | HNSW ef sweep | `results/hnsw_ef_sweep.txt` |

复现命令汇总在报告附录 B.1。

### 3. 项目根 `main.cc`

按助教规定写了单一可执行入口，包装鲲鹏侧 Recall@10>0.95 下最快配置：
`ivfpq_local_pthread_dynamic_inter, t=16, nlist=16, nprobe=4, p=1000`（鲲鹏 136.63 μs / Recall 0.9597）。

编译：`g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++17 -I.`
提交：`sh test.sh 2 1`

## 关键实验数据（直接可复用）

### inverted list 长度分布（nlist=16, KMeans, DEEP100K base）
- min=2173, median=5011, max=16921, mean=6250, stddev=3804
- max/mean = 2.71× （证明负载严重不均）

### OMP schedule × chunk sweep（Flat inter, T=16）
最快：`guided,8` 287.87 μs  
最慢：`static,256` 428.74 μs  
默认 `static (no chunk)` 318.17 μs 也较好

### N × T 交叉表（Flat inter, OMP static, μs/query）
| N | T=1 | T=2 | T=4 | T=8 | T=16 |
|---|---|---|---|---|---|
| 10k | 115.27 | 47.53 | 23.95 | 16.87 | 11.73 |
| 50k | 3841.78 | 602.37 | 180.54 | 142.10 | 103.79 |
| 100k | 8416.51 | 4059.09 | 1115.15 | 476.16 | 443.71 |

注：T=1 不包含 batch / prefetch 路径，比主线 flat_pthread_dynamic_inter_t1=3312 μs 偏高。

### 虚假共享对照（30M ++value/线程）
| T | 紧凑 ms | padded ms | FS/pad |
|---|---|---|---|
| 2 | 0.97 | 0.41 | 2.36× |
| 4 | 0.55 | 0.14 | 3.98× |
| 8 | 0.95 | 0.38 | 2.52× |
| 16 | 1.84 | 0.24 | 7.81× |

### P/E 亲和性（Flat inter, OMP static, N=100k）
| 配置 | T | latency μs | mask |
|---|---|---|---|
| Default | 16 | 256.01 | -- |
| P-only | 12 | 305.65 | 0xFFF |
| E-only | 8 | 934.10 | 0xFF000 |
| P+E all | 20 | 249.41 | 0xFFFFF |

E-core/P-core 单核算力比 ~ 1:3。

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

1. **MSYS2 GCC libgomp 不支持 OMP_PLACES affinity** —— 报错 "Affinity not supported on this configuration"。改用 Windows `cmd /AFFINITY <mask>` 启动进程。
2. **LaTeX caption 内 `\path{...}` fragile** —— 报错 "Url Error -> url used in a moving argument"。改用 `\texttt{simd/flat\_scan.h}` 自己转义下划线。
3. **TikZ \pgfmathsetmacro 在 \foreach 大数值下 dimension overflow** —— 把 size/4000 等比例预计算成 cm 值，直接传入。
4. **OMP `schedule(runtime)` + `OMP_SCHEDULE` 在 MSYS2 工作正常** —— 用此方法在不重新编译的情况下 sweep schedule 策略。
5. **\path 在 lstlisting 内是安全的**，问题只在 caption / heading 等 moving arg。
6. **C++17 → C++11 迁移** —— `std::filesystem` 替换为 POSIX `access()` + `system("mkdir -p")` + 字符串拼接。所有代码现在用 `-std=c++11` 编译。
7. **跨目录 include 路径** —— 148 处 `#include "simd/..."` 等改为相对路径 `#include "../simd/..."`，同目录 include 保持原样。现在无需 `-I.` 即可编译，与助教规定的 `g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++11` 完全一致。
8. **main.cc 线程数** —— 鲲鹏上 IVF-PQ local 最快配置是 t=8 (134.48 μs)，不是 t=16 (136.63 μs)。main.cc 已修正为 t=8。

## 未完成 / 后续可补

- VTune Hotspots / Thread Timeline / Microarch Exploration 三张截图导出（需手动开 VTune GUI）
- VTune Memory Access analysis（同上，需手动）
- intra-query top-p sweep（需要修改 IVF intra 接口暴露 top-p_t 参数）
- IVF-PQ p-sweep 曲线（固定 nprobe=4，扫描 p）
- `docs/` follow-up: SQ/PQ/FastScan 统一 p-sweep, 鲲鹏 perf/PMU, HNSW 无锁 visited

## 报告与代码版本核对

- 报告 `report/main.tex` 当前 ~970 行，21 页 PDF
- 引用一致性：所有 `\ref{...}` 已通过两次 xelatex + bibtex + 第三次 xelatex 解析完毕，无 undefined refs
- 警告：caption 内的 μ 字符（lmroman 缺 glyph） — 不影响 PDF 显示（被 ctex/fontspec 接管）

## 复现路径

本地：`make` + `powershell -ExecutionPolicy Bypass -File run_all.ps1`  
鲲鹏：`bash run_all_kunpeng_part1.sh && bash run_all_kunpeng_part2.sh`  
课程框架入口：`sh test.sh 2 1`
