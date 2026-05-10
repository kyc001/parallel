# ANN Pthread + OpenMP 并行化设计文档

Date: 2026-05-10

## 1. 目标

在 ann-pthread-omp 目录下完成 ANN 的 Pthread 和 OpenMP 并行化实现，覆盖要求.md 中所有基础要求和进阶要求，目标满分（基础 90% + 进阶 10%）。

## 2. 平台约束

- **本机**: Windows 11, Intel i9-13900H, AVX2+FMA, 数据 `../files/`, Shell: PowerShell/Bash
- **鲲鹏服务器**: AArch64/NEON, 数据 `/anndata/`, 编译流程 `cp mains/<variant>.cc main.cc && g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++17 && bash test.sh 1 1`
- **关键**: 服务器上用 ann-pthread-omp 内容替换 ann_original，main.cc 必须在根目录且作为编译入口

## 3. 根目录文件约定

- `hnswlib/` — HNSW 库，不修改内部源码
- `flat_scan.h` — 串行基线 flat_search()，内容禁止修改
- `main.cc` — 编译入口，不手写维护，由运行脚本从 `mains/` 对应变体 `cp` 覆盖生成
- `qsub.sh` — PBS 提交脚本
- `test.sh` — 测试框架，禁止修改
- **SIMD 头文件** — 移入 `simd/` 子目录，根目录只保留 ann_original 原有文件

## 4. 目录结构

```
ann-pthread-omp/
├── hnswlib/                  # 不动
├── flat_scan.h               # 不动（串行基线）
├── main.cc                   # 编译入口（脚本 cp 覆盖）
├── qsub.sh                   # 不动
├── test.sh                   # 不动
│
├── simd/                      # SIMD 距离计算头文件（从根目录移入）
│   ├── flat_scan_simd.h
│   ├── flat_scan_avx2.h / flat_scan_avx2_blocked.h / flat_scan_avx2_topkarr.h
│   ├── sq_scan_simd.h / sq_scan_avx2.h
│   ├── pq_scan_simd.h / pq_scan_avx2.h
│   ├── pq_blocked_neon.h / pq_blocked_avx2.h
│   ├── pq_fastscan_simd.h / pq_fastscan_neon.h / pq_fastscan_avx2.h / pq_fastscan_avx2_safe.h
│   └── ann_bench_common.h
│
├── Makefile                  # 一键编译
├── run_all.sh                # 一键运行（本机 Bash）
├── run_all_kunpeng.sh        # 一键运行（鲲鹏，逐个 cp+test.sh）
├── run_all.ps1               # 一键运行（本机 PowerShell）
│
├── files/                    # 数据目录（本地链接到 ../files/）
│
├── report/                   # 实验报告 LaTeX
│   ├── main.tex
│   ├── reference.bib
│   ├── style/
│   └── fig/
│
├── pthread/                  # Pthread 并行框架
│   ├── thread_pool.h             # 纯 pthread 原语线程池 (pthread_mutex_t + pthread_cond_t)
│   ├── flat_scan_pthread.h       # Flat 并行（static/dynamic/pool × inter/intra）
│   ├── sq_scan_pthread.h         # SQ 并行
│   ├── pq_scan_pthread.h         # PQ 并行
│   └── pq_fastscan_pthread.h     # FastScan 并行
│
├── omp/                      # OpenMP 并行框架
│   ├── flat_scan_omp.h
│   ├── sq_scan_omp.h
│   ├── pq_scan_omp.h
│   └── pq_fastscan_omp.h
│
├── ivf/                      # IVF 全部实现
│   ├── ivf_index.h               # IVF 索引结构 + KMeans 构建 (SIMD)
│   ├── ivf_scan_simd.h           # IVF 搜索 SIMD
│   ├── ivf_pq_simd.h             # IVF-PQ 搜索 SIMD（两种构建方式）
│   ├── ivf_scan_pthread.h        # IVF Pthread 并行
│   ├── ivf_scan_omp.h            # IVF OMP 并行
│   ├── ivf_pq_pthread.h          # IVF-PQ Pthread
│   └── ivf_pq_omp.h              # IVF-PQ OMP
│
├── hnsw/                     # HNSW 并行搜索
│   ├── hnsw_search_pthread.h     # query 级并行（public API）
│   └── hnsw_search_omp.h         # query 级并行（public API）
│
├── mains/                    # 所有 main_*.cc 变体（脚本 cp 到 main.cc）
│   ├── main_baseline.cc
│   ├── simd/
│   │   ├── main_flat.cc, main_sq.cc, main_pq.cc, main_fastscan.cc
│   ├── omp/
│   │   ├── inter/  {flat,sq,pq,fastscan}.cc  (4)
│   │   └── intra/  {flat,sq,pq,fastscan}.cc  (4)
│   ├── pthread/
│   │   ├── static/inter/  (4)    static/intra/  (4)
│   │   ├── dynamic/inter/ (4)    dynamic/intra/ (4)
│   │   └── pool/inter/    (4)    pool/intra/    (4)
│   ├── ivf/
│   │   ├── simd/          {ivf,ivfpq}.cc
│   │   ├── omp/inter+intra/
│   │   └── pthread/static+dynamic+pool×inter+intra/
│   └── hnsw/
│       ├── baseline.cc, omp.cc, pthread.cc
│
├── scripts/                  # 辅助脚本
├── results/                  # 基准测试结果
└── build/                    # 编译产物
```

## 5. 并行策略

### 5.1 两种并行粒度

- **Inter-query（主策略）**: 查询级并行。N 条查询分给 T 个线程，每个线程独立运行完整搜索管线。无共享状态，同步开销最小，适合批量查询。**实现**: 线程函数接收查询起止索引，独立计时和结果收集。
- **Intra-query（补充）**: 查询内并行。单条查询时 base 向量集分给多线程，每线程维护局部 top-k 堆，最后 merge。适合查询数少、base 大、单查询延迟敏感场景。
- **不嵌套**: 默认不同时开启 inter + intra，避免线程过量竞争。报告明确说明选择依据。

### 5.2 Pthread 三种调度

| 方式 | 任务分配 | 同步机制 | 适用场景 |
|------|---------|---------|---------|
| **Static** | 静态等分 partition | pthread_join 汇总 | Flat/SQ 计算均匀时最优 |
| **Dynamic** | std::atomic 计数器抢任务 | atomic fetch_add | IVF 倒排链长度不均、HNSW 搜索路径差异大 |
| **Pool** | pthread_mutex_t + pthread_cond_t 任务队列 | cond_wait 唤醒 | 减少线程创建/销毁开销，适合反复提交任务 |

报告措辞：Dynamic 使用 C++ `std::atomic`（语义等价于 pthread 思路下的原子操作）；Pool 使用纯 pthread 原语（`pthread_mutex_t`、`pthread_cond_t`、`pthread_t`）。

### 5.3 OMP 调度

- Inter-query: 默认 `schedule(static)` 用于 Flat/SQ 计算均匀场景；IVF/HNSW 额外测试 `schedule(dynamic)` 和 `schedule(guided)` 对比
- Intra-query: `#pragma omp parallel for` + 每线程局部 heap + 最后串行 merge
- 报告对比 schedule 策略对负载均衡和性能的影响

### 5.4 top-k / top-p / nprobe

- **Flat 全量扫描**: p=k，每线程维护局部 top-k，merge 后即为精确 top-k，不需要 p>k
- **PQ/ADC**: p>k 控制粗排候选数量，p 越大 recall 越高但 latency 越大，报告绘制 recall-latency 曲线
- **IVF**: nprobe 控制粗排阶段访问的簇数量（扫描范围），top-p 控制精排阶段每线程保留的候选数，最终 rerank 得到 top-k
- **报告分析**: p 和 nprobe 各自对 recall 和 latency 的影响，tradeoff 曲线

## 6. 算法实现范围

### 主线（满分核心，全量实验矩阵）
1. **Flat-SIMD + 多线程** (2分): inter + intra, static/dynamic/pool + OMP, 线程数 1/2/4/8/16
2. **PQ-SIMD + 多线程** (2分): LUT 构建并行 + ADC 查表并行, 线程数不宜过多（memory-bound）
3. **IVF-SIMD baseline + 多线程** (2+4=6分): 粗排+精排并行, nprobe 调参, dynamic 调度重点分析
4. **IVF-PQ-SIMD baseline + 多线程** (3+5=8分): 两种构建方式对比, memory-bound 分析, 负优化诊断

### 扩展加分（采样实验矩阵，线程数 1/4/8/16）
5. **SQ-SIMD + 多线程**: 作为补充量化方法，与 PQ 对比 compute-bound vs memory-bound
6. **FastScan + 多线程**: shuffle-LUT 查表累加的并行化，重点分析 memory-bound 瓶颈
7. **HNSW 并行** (2分): 第一档基于 hnswlib public API 做 query 级并行；多入口点作为可选探索，通过封装而非修改 hnswlib 内部实现

### 进阶要求
8. 跨平台 x86 (AVX2) vs ARM (NEON) 对比实验与分析
9. LLM 辅助编程记录作为报告附录

## 7. 实验矩阵（分层）

### 核心完整矩阵（Flat, PQ, IVF, IVF-PQ）
- 串行 baseline vs SIMD vs Pthread(static/dynamic/pool) vs OpenMP(static/dynamic/guided)
- 线程数: 1, 2, 4, 8, 16
- inter-query vs intra-query
- recall-latency 曲线（含不同 p/nprobe 参数扫描）
- 加速比与伸缩性折线图
- 负优化现象及原因解释（结合 cache miss、内存带宽、线程同步开销）

### 补充采样矩阵（SQ, FastScan, HNSW）
- 代表性线程数: 1, 4, 8, 16
- 代表性策略: inter-query static + OMP static
- 重点对比：不同算法在 compute-bound / memory-bound / 图搜索下的并行特征

## 8. 构建系统

### Makefile
- 默认目标: 编译所有变体到 build/
- 平台检测: `uname -m` / `gcc -dumpmachine`
- x86: `-mavx2 -mfma -O2`
- ARM: `-O2` (NEON intrinsics)
- 公共 flag: `-fopenmp -lpthread -std=c++17 -I.`

### 运行脚本
- `run_all.sh`: 本机一键运行，遍历核心矩阵所有组合，自动收集结果
- `run_all_kunpeng.sh`: 鲲鹏一键运行，逐个 `cp mains/<variant>.cc main.cc` + `bash test.sh 1 1`，收集 result_*.txt
- `run_all.ps1`: 本机 PowerShell 版本

## 9. 数据路径

```cpp
// ann_bench_common.h 中 DefaultDataPath()
#ifdef _WIN32
    return "../files/";   // ann-pthread-omp/../files/ = parallel/files/
#else
    return "/anndata/";   // 服务器数据目录
#endif
```

## 10. 实现顺序

按"先保主线可编译 → 扩展算法 → 铺实验矩阵"推进：

1. **基础设施**: 更新 ann_bench_common.h 数据路径, 创建 pthread/thread_pool.h, 创建子目录结构
2. **Flat 主线**: flat_scan_pthread.h + flat_scan_omp.h + 全部 12 个 mains（static/dynamic/pool × inter/intra + omp inter/intra）
3. **PQ 主线**: pq_scan_pthread.h + pq_scan_omp.h + 全部 12 个 mains
4. **IVF 主线**: IVF 索引+搜索 SIMD baseline, ivf_scan_pthread.h + ivf_scan_omp.h, 全部 mains
5. **IVF-PQ 主线**: IVF-PQ SIMD baseline, 两种构建方式, pthread + omp 并行, 全部 mains
6. **扩展**: SQ, FastScan, HNSW 并行化
7. **脚本**: Makefile, run_all.sh, run_all_kunpeng.sh, run_all.ps1
8. **实验**: 按矩阵运行, 收集数据, 撰写报告
