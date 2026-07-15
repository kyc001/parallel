# 并行程序设计课程仓库

本仓库记录 2026 年春季“并行程序设计”课程的作业代码、实验报告、性能数据与期末研究工作。课程内容从并行体系结构与 CPU 微架构出发，逐步覆盖 SIMD、Pthread/OpenMP、MPI 和 CUDA，并以近似最近邻搜索（Approximate Nearest Neighbor Search, ANNS）作为贯穿后半学期的综合选题。

仓库不仅保留最终提交代码，还包含实验脚本、参数扫描结果、VTune/汇编分析、跨平台测试、LaTeX 报告和期末扩展实验，重点回答三个问题：

1. 一个算法应当选择什么并行粒度；
2. 优化后，系统瓶颈迁移到了哪里；
3. 如何同时看待延迟、吞吐、召回率、通信和数据搬运成本。

## 课程成绩

| 课程内容 | 得分 | 满分 | 得分率 |
| --- | ---: | ---: | ---: |
| 第一次作业：并行体系结构调研 | 4.9 | 5 | 98.0% |
| 第二次作业：CPU 架构编程 | 4.8 | 5 | 96.0% |
| OT：协程技术调研 | 3.3 | 4 | 82.5% |
| SIMD 编程实验 | 15.0 | 15 | 100.0% |
| 多线程编程实验 | 18.5 | 20 | 92.5% |
| MPI 编程实验 | 15.0 | 15 | 100.0% |
| GPU 编程实验 | 9.7 | 10 | 97.0% |
| 期末研究报告 | 18.8 | 20 | 94.0% |
| 签到 | 6.0 | 6 | 100.0% |
| **课程总评** | **96.0** | **100** | **96.0%** |

## 课程学习主线

### 1. 并行体系结构调研

[`lab0-并行体系结构调研/`](./lab0-并行体系结构调研/) 从处理器、存储层次、互连网络和编程模型四个角度梳理超级计算机体系结构，重点分析：

- 天河二号的异构节点、TH Express-2 互连与系统集成路线；
- 神威·太湖之光的 SW26010 众核架构与显式局部存储；
- 国内超算从向量机、MPP、异构加速到自主众核的发展路径；
- TOP500、HPCG、Green500 评价口径，以及 HBM、Chiplet、APU 和智能互连等发展方向。

报告：[PDF](./lab0-并行体系结构调研/report/main.pdf) | [LaTeX 源码](./lab0-并行体系结构调研/report/main.tex)

### 2. CPU 架构编程

[`lab1-CPU架构编程/`](./lab1-CPU架构编程/) 通过矩阵列内积和浮点数组求和实验，研究 cache 局部性、循环展开、指令依赖与超标量执行：

- 将矩阵访问从逐列改为行优先，降低 cache miss 和 DRAM 压力；
- 使用 2 路、4 路独立累加链提高指令级并行度；
- 结合高精度计时、汇编和 VTune Top-Down 指标定位 Memory Bound 与 Core Bound；
- 对比不同编译优化级别，并分析循环展开并非在所有工作集规模上都有效。

代表性结果：在 `n=2048` 的矩阵实验中，行优先版本相对平凡算法加速 `20.09x`，加入 4 路展开后达到 `22.41x`；求和实验的 4 路独立累加最高达到 `3.81x`。

报告：[PDF](./lab1-CPU架构编程/report/main.pdf) | [LaTeX 源码](./lab1-CPU架构编程/report/main.tex) | [实验源码](./lab1-CPU架构编程/src/)

### 3. OT：协程技术调研

[`OT-协程技术调研/`](./OT-协程技术调研/) 从“让等待变得更便宜”这一核心目标出发，对比进程、线程、事件循环和协程，讨论：

- 有栈协程与无栈协程的状态保存方式；
- Go goroutine、Java 21 virtual thread、C++20 coroutine、Python asyncio、Rust async 等实现路线；
- 编译器状态机、用户态调度器、I/O 多路复用和结构化并发之间的关系；
- 协程适合 I/O 并发但不会自动加速 CPU 密集计算的工程边界。

实验覆盖 10000 个等待任务、本地 TCP echo、CPU `fib(25)`、上下文切换和 Java virtual thread pinning。基础 I/O 微基准中，Python asyncio 相对 Python threading 约快 `7.0x`，Java virtual thread 相对固定 platform thread 池约快 `23.2x`。

报告：[PDF](./OT-协程技术调研/report.pdf) | [LaTeX 源码](./OT-协程技术调研/report.tex) | [演示文稿](./OT-协程技术调研/slides_beamer.pdf) | [基准代码](./OT-协程技术调研/bench.py)

## ANN 综合选题

### 问题定义

给定高维向量集合 `X` 和查询向量 `q`，精确最近邻搜索需要计算 `q` 与所有底库向量的距离。当底库规模和维度增大时，全量扫描的计算与访存成本迅速上升。ANNS 允许以可控的召回率损失换取更低延迟或更高吞吐。

本仓库使用课程提供的 DEEP100K 数据：

- 底库：100000 个 96 维 `float` 向量；
- 查询：正式报告主要统计前 2000 条 query；
- Ground truth：每条 query 的精确 Top-100 近邻；
- 主要指标：`Recall@K` 与平均查询延迟（`us/query`）；
- 基本接口：离线阶段构建索引，在线阶段搜索并返回 Top-k，ground truth 只参与评估，不参与候选生成。

课程选题说明：[ANN 选题介绍](./参考模板/ANN选题介绍.pdf) | [实验要求整理](./ANN要求.md)

### 算法与并行化路线

```text
DEEP100K base/query
        |
        v
Flat 精确扫描
        |
        +--> SIMD: AVX2 / NEON 距离内核
        |
        +--> SQ / PQ / FastScan: 压缩向量与查表距离
        |
        +--> IVF / IVF-PQ: 只扫描部分倒排列表
        |
        +--> HNSW: 用图遍历减少访问点
        |
        +--> Pthread / OpenMP: query 级或候选级共享内存并行
        |
        +--> MPI: 数据分片、rank-local Top-k、全局候选合并
        |
        +--> CUDA: batch GEMM、设备端 Top-k、GPU IVF
        |
        v
Recall-Latency、扩展性、Roofline 与瓶颈分析
```

ANN 优化有两条相互配合的主线：

- **让单次距离计算更便宜**：SIMD、SQ、PQ、FastScan、GEMM；
- **减少需要访问的向量数量**：IVF、IVF-PQ、HNSW、候选预算与 rerank。

### SIMD 编程实验

[`ann-SIMD/`](./ann-SIMD/) 从串行 Flat 搜索出发，实现并分析：

- x86 AVX2/FMA 和 ARM NEON 距离内核；
- Flat、Scalar Quantization（SQ）、Product Quantization（PQ）；
- PQ 的 ADC 查表、SoA/blocking、gather 与 shuffle 路线；
- 4-bit PQ FastScan、手写 SIMD 与编译器自动向量化；
- Windows i9、鲲鹏 AArch64 和 Android/Termux 的跨平台结果。

综合报告中的同口径代表点显示：Flat-AVX2 在 `Recall@10=1.00000` 时为 `1756.11 us/query`，相对串行 Flat 加速 `2.60x`；SQ-AVX2 在 `Recall@10=0.99995` 时为 `427.01 us/query`，相对串行 Flat 加速 `10.71x`。结果表明，SIMD 降低算术指令数后，Flat 扫描逐渐转为内存带宽瓶颈；SQ 的更大收益主要来自减少读取字节数。

报告：[PDF](./ann-SIMD/report/main.pdf) | [实验说明](./ann-SIMD/README.md) | [代表入口](./ann-SIMD/main.cc)

### Pthread / OpenMP 多线程实验

[`ann-pthread-omp/`](./ann-pthread-omp/) 将 ANN 搜索扩展到共享内存多核，覆盖：

- inter-query 与 intra-query 两种并行粒度；
- Pthread 静态划分、动态调度、线程池和 OpenMP schedule；
- Flat、SQ、PQ、FastScan、IVF、IVF-PQ 与 HNSW；
- 线程数与问题规模扫描、chunk size、虚假共享、P-core/E-core 亲和性；
- Windows x86 AVX2 与鲲鹏 AArch64/NEON 的跨平台对比。

实验结论是：批量查询下 inter-query 并行通常更稳定，因为 query 之间独立、同步与 Top-k 合并更少；intra-query 更适合 query 数量不足但单次候选规模足够大的场景。综合代表点中，Pthread IVF-PQ 在 `Recall@10=0.95945` 时达到 `57.61 us/query`，但这一低延迟伴随可见的召回率取舍。

报告：[PDF](./ann-pthread-omp/report/main.pdf) | [主入口](./ann-pthread-omp/main.cc) | [构建文件](./ann-pthread-omp/Makefile)

### MPI 编程实验

[`ann-mpi/`](./ann-mpi/) 研究分布式 ANN 搜索，而不是简单地把串行循环平均切开。核心设计包括：

- owner-computes 数据所有权：每个 rank 只搜索自己的底库分片；
- rank-local 搜索后仅交换定长 Top-k 候选，避免传输原始向量或完整 score；
- 根进程按全局 ID 合并候选并计算最终 recall；
- IVF-PQ、Block-HNSW、IVF+HNSW 和 HNSW-on-HNSW 等搜索模式；
- MPI+OpenMP 混合布局、阻塞/非阻塞通信、亲和性、强扩展和负载不均衡分析。

综合代表点中，MPI IVF-PQ（4 ranks x 2 threads）在 `Recall@10=0.96560` 时为 `232.45 us/query`；MPI Block-HNSW（8 ranks x 2 threads）达到 `Recall@10=1.00000`、`195.11 us/query`。在当前数据规模下，通信与 merge 占比较低，主要瓶颈往往是最慢 rank 的局部搜索与分片负载差异。

报告：[PDF](./ann-mpi/report/main.pdf) | [主入口](./ann-mpi/main.cc) | [构建文件](./ann-mpi/Makefile) | [运行脚本](./ann-mpi/scripts/)

### GPU 编程实验

[`ann-gpu/`](./ann-gpu/) 包含 HIP 平台学习实验和 CUDA ANN 搜索实现。ANN 部分将批量内积改写为矩阵乘，并实现：

- cuBLAS/batch GEMM 得分计算；
- 自定义 GEMM kernel 与 score 数据流；
- 设备端 Top-k 树形合并，减少完整结果回传；
- grouped-IVF batch 搜索；
- CUDA event 分项计时、PTX/SASS 与资源使用分析。

综合代表点中，`cublas_tree` 在 `Recall@10=0.99995` 时达到 `78.68 us/query`，相对串行 Flat 加速 `58.10x`。这一阶段的关键认识是：当 GEMM 已经足够快，Top-k、score 存储和 Host-Device 数据传输会成为新的主导成本。

报告：[PDF](./ann-gpu/report/main.pdf) | [主入口](./ann-gpu/main.cc) | [构建文件](./ann-gpu/Makefile) | [CUDA 内核](./ann-gpu/gpu/)

### 期末研究报告

[`ann-final/`](./ann-final/) 将 SIMD、多线程、MPI 和 GPU 放入统一的 ANN 查询流水线与代价模型中，并增加三组扩展实验：

1. **预算自适应 IVF-PQ**：根据 query 难度动态选择 `nprobe` 与 rerank 候选数 `p`；
2. **OPQ / IVF-OPQ**：使用正交旋转降低 PQ 子空间量化误差；
3. **GPU-CPU 异构协同**：GPU 粗排、CPU 精排，并拆分 H2D、GEMM、D2H、host top-p 和 rerank 成本。

代表性结论：

- 预算自适应 IVF-PQ 将固定 `(nprobe,p)=(4,1000)` 的 `Recall@10` 从 `0.95945` 提升到 `0.96520`，同时把延迟从 `229.06` 降至 `186.54 us/query`；
- 在 `M=8,p=1500` 下，OPQ 将 PQ 的 `Recall@100` 从 `0.95939` 提升到 `0.97316`；
- GPU-CPU 异构方案在 `query_n=2000,p=100` 时达到 `Recall@100=0.99999`，但延迟约为 `924 us/query`，明显慢于 GPU-only 路径，主要原因是完整 score D2H 和主机端候选选择。

期末报告的核心观点是**瓶颈迁移**：AVX2 将瓶颈从标量算术推向内存带宽，SQ/PQ 将全向量读取变成 code/LUT 访问，IVF/HNSW 将全库扫描变成候选选择与负载均衡，MPI 将问题变成 rank-local 慢点，GPU 则将瓶颈推向 Top-k 与数据搬运。

报告：[PDF](./ann-final/report/main.pdf) | [LaTeX 源码](./ann-final/report/main.tex) | [扩展实验](./ann-final/experiments/) | [结果汇总](./ann-final/report/results/)

## 代表性 ANN 结果

下表摘自期末报告的统一结果表。所有延迟均为 `us/query`，串行 Flat 基线为 `4571.62 us/query`。这些点用于展示不同算法族和执行后端的量级，参数与 Recall 并不完全相同，不能视为严格的同召回排行榜。

| 方法 | 平台/后端 | Recall 指标 | 延迟 | 相对串行 Flat | 主要意义 |
| --- | --- | ---: | ---: | ---: | --- |
| Flat-serial | i9 CPU | Recall@10 = 1.00000 | 4571.62 | 1.00x | 精确串行基线 |
| Flat-AVX2 | i9 AVX2 | Recall@10 = 1.00000 | 1756.11 | 2.60x | 手写 AVX2/FMA 距离内核 |
| SQ-AVX2 | i9 AVX2 | Recall@10 = 0.99995 | 427.01 | 10.71x | 压缩表示降低内存流量 |
| IVF-PQ Pthread | i9 多核 | Recall@10 = 0.95945 | 57.61 | 79.35x | 候选剪枝与 query 级多线程 |
| HNSW baseline | i9 CPU | Recall@10 = 0.96865 | 65.48 | 69.82x | 图索引减少访问点 |
| Budget-IVF-PQ | i9 CPU | Recall@10 = 0.96520 | 186.54 | 24.51x | 按 query 难度分配预算 |
| MPI IVF-PQ 4x2 | MS-MPI | Recall@10 = 0.96560 | 232.45 | 19.67x | 分片搜索与定长候选协议 |
| MPI Block-HNSW 8x2 | MS-MPI | Recall@10 = 1.00000 | 195.11 | 23.43x | 多 rank 图索引候选合并 |
| GPU cublas_tree | NVIDIA CUDA | Recall@10 = 0.99995 | 78.68 | 58.10x | batch GEMM 与设备端 Top-k |
| GPU+CPU hybrid | RTX 4060 + i9 | Recall@10 = 0.99995 | 924.10 | 4.95x | 展示跨设备传输与后处理边界 |

## 仓库结构

| 路径 | 内容 |
| --- | --- |
| [`lab0-并行体系结构调研/`](./lab0-并行体系结构调研/) | 超算体系结构调研、PPT、LaTeX 报告与参考文献 |
| [`lab1-CPU架构编程/`](./lab1-CPU架构编程/) | cache/超标量实验源码、测试驱动、VTune 数据与报告 |
| [`OT-协程技术调研/`](./OT-协程技术调研/) | 协程调研报告、演示文稿、Python/Go/Java 基准与结果 |
| [`ann_original/`](./ann_original/) | 课程 ANN 原始框架、Flat 基线与第三方 hnswlib 基础代码 |
| [`ann-SIMD/`](./ann-SIMD/) | AVX2/NEON、SQ/PQ/FastScan、跨平台结果和 SIMD 报告 |
| [`ann-pthread-omp/`](./ann-pthread-omp/) | Pthread/OpenMP 算法矩阵、调度实验、HNSW/IVF 与 profiling |
| [`ann-mpi/`](./ann-mpi/) | MPI 分片搜索、混合并行、通信实验、PBS/本地脚本与报告 |
| [`ann-gpu/`](./ann-gpu/) | HIP 学习材料、CUDA ANN 内核、性能结果与 GPU 报告 |
| [`ann-final/`](./ann-final/) | 期末综合报告、预算自适应、OPQ 和 GPU-CPU 异构实验 |
| [`files/`](./files/) | DEEP100K base/query/ground-truth 二进制数据文件 |
| [`参考模板/`](./参考模板/) | 课程实验说明、选题介绍和报告模板，不属于个人实现 |
| [`.trellis/`](./.trellis/) | 项目开发规范、任务记录和工作流上下文 |

## 环境与复现

不同实验面向不同平台，没有统一的根目录构建命令。常用工具链包括：

- C++11 编译器：GCC/G++ 或兼容工具链；
- CPU 并行：OpenMP、Pthread，x86 AVX2/FMA 或 ARM NEON；
- 分布式并行：OpenMPI、MS-MPI 或集群提供的 MPI 实现；
- GPU：CUDA Toolkit、NVCC、cuBLAS，GPU 报告使用 NVIDIA RTX 4060 Laptop GPU；
- 分析工具：Intel VTune、objdump、cuobjdump，部分图表由 Python 生成；
- 报告工具：XeLaTeX/latexmk，协程展示还使用 Beamer/Typst 相关材料。

### 数据路径

ANN 程序通常读取以下文件：

```text
files/DEEP100K.base.100k.fbin
files/DEEP100K.query.fbin
files/DEEP100K.gt.query.100k.top100.bin
```

现有 benchmark helper 优先读取环境变量 `ANN_DATA_PATH`，随后根据平台使用本地 `../files/`、仓库 `files/` 或集群共享目录 `/anndata/`。在运行脚本前应确认数据路径、query 数量、`k`、`nlist`、`nprobe`、`p`、线程数和 MPI rank 数与目标报告口径一致。

### 典型构建入口

```bash
# SIMD：目录中包含多个平台和算法入口，先阅读 ann-SIMD/README.md
cd ann-SIMD
bash run_all.sh

# Pthread / OpenMP
cd ann-pthread-omp
make

# MPI
cd ann-mpi
make
mpiexec -np 2 ./main 2 16 4 1000 200 local

# CUDA GPU
cd ann-gpu
make

# 期末扩展实验
cd ann-final/experiments
make cpu   # OPQ / adaptive IVF-PQ
make gpu   # GPU-CPU hybrid，需要 CUDA
```

具体命令会受 Windows/Linux、编译器、MPI 实现、CPU 指令集和 GPU 环境影响。课程提交入口、参数含义和完整复现矩阵请以各目录的 `README`、`Makefile`、运行脚本及报告附录为准。

## 报告索引

| 内容 | 最终报告 | 源文件 |
| --- | --- | --- |
| 并行体系结构调研 | [PDF](./lab0-并行体系结构调研/report/main.pdf) | [main.tex](./lab0-并行体系结构调研/report/main.tex) |
| CPU 架构编程 | [PDF](./lab1-CPU架构编程/report/main.pdf) | [main.tex](./lab1-CPU架构编程/report/main.tex) |
| 协程技术调研 | [PDF](./OT-协程技术调研/report.pdf) | [report.tex](./OT-协程技术调研/report.tex) |
| SIMD ANN | [PDF](./ann-SIMD/report/main.pdf) | [main.tex](./ann-SIMD/report/main.tex) |
| Pthread/OpenMP ANN | [PDF](./ann-pthread-omp/report/main.pdf) | [main.tex](./ann-pthread-omp/report/main.tex) |
| MPI ANN | [PDF](./ann-mpi/report/main.pdf) | [main.tex](./ann-mpi/report/main.tex) |
| GPU ANN | [PDF](./ann-gpu/report/main.pdf) | [main.tex](./ann-gpu/report/main.tex) |
| 期末综合研究 | [PDF](./ann-final/report/main.pdf) | [main.tex](./ann-final/report/main.tex) |

## 说明

- 本仓库主要用于课程学习、实验归档和结果复核，不应将单个平台上的性能数字直接外推到其他硬件。
- 延迟与加速比必须和 Recall、参数、query 数量、计时范围以及离线/在线边界一起理解。
- `参考模板/` 中的材料属于课程参考内容；`hnswlib` 等第三方代码沿用其原项目许可与署名要求。
- DEEP100K 数据文件的使用与再分发应遵循数据集和课程提供方的相关要求。
