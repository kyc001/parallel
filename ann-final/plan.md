PLEASE IMPLEMENT THIS PLAN:
# ANN 期末综合报告最终施工计划

## Summary

本次工作只在 `D:\Study\26sp\parallel\ann-final` 内施工。旧 SIMD / Pthread-OpenMP / MPI / GPU 实验结果直接复用，不重跑；新增工作集中在 **OPQ / IVF-OPQ**、**本地 i9+NVIDIA 的 Roofline/VTune/Nsight 建模**，以及一个做透的 **CPU-GPU 异构协同实验**。报告按“统一算法设计 → 分架构实现 → 统一评测与建模”组织，正文严格 ≤30 页，采用成熟客观学术笔调，不用第一人称。

## Key Changes

- 统一平台声明为本地 `i9-13900H + NVIDIA GPU + VTune/Nsight`；旧实验数据若已来自本地可直接横向比较，非本地数据只作旁证或附录。
- SIMD 主体只写 AVX2/FMA；NEON、AVX-512 不进入主线，最多放附录或一句旁证。
- 平时工作与新增工作不在正文标题中贴标签；在引言写“工作范围说明”，附录 A 放对照表满足课程硬要求。
- 代码保持课程兼容意识：核心检索实现尽量 header-only；代表性提交路径仍保持“替换 `flat_search` 调用、输出格式不变”。报告实验 runner 可放在 `ann-final/experiments`。

## Implementation Plan

### 1. 整理实验目录与旧结果

在 `ann-final` 中只拷贝必要代码：

- 从 `ann-pthread-omp` 拷贝 AVX2 SIMD、PQ、IVF、IVF-PQ 相关 header。
- 从 `ann-gpu` 拷贝 CUDA/cuBLAS/GPU top-k/IVF grouped 相关代码。
- 保留 `experiments/adaptive_ivfpq.cc` 作为补充实验材料，不作为新增主线。
- 汇总已有本地结果为统一 CSV：`method,source,platform,recall@10,recall@100,latency_us,qps,speedup,notes`。

旧结果处理原则：

- 不重跑 Lab2-Lab5 已有实验。
- 只抽取代表性数据进入正文表格和 trade-off 图。
- 不把 FastScan、IVF-PQ、HNSW 变体、GPU GEMM/IVF grouped 算作新增。

### 2. 新增 A：OPQ / IVF-OPQ

实现位置：`ann-final/experiments/opq_ivfpq.cc`，核心 OPQ 逻辑可拆为 header。

固定参数：

- 数据集：DEEP100K，`d=96`，IP 距离。
- PQ 分段数：主实验用 `m=8`；补充扫 `m={8,12,16}`。
- `ksub=256`。
- IVF：`nlist=16`。
- sweep：`nprobe={2,4,8}`，`rerank_p={500,1000,1500}`。
- OPQ 迭代：`opq_iter=5`。
- k：`10` 和 `100`，正文主图优先 `Recall@100`，表格保留 `Recall@10`。

实验组：

- `PQ`
- `OPQ`
- `IVF-PQ`
- `IVF-OPQ`

实现决策：

- OPQ 在 PQ/IVF-PQ 训练前学习正交旋转矩阵 `R`。
- base 和 query 都乘 `R` 后进入 PQ/IVF-PQ。
- rerank 使用原始 float 向量，保证最终 recall 可解释。
- 若需要 SVD，优先用 Eigen；如不希望引入依赖，则使用分块 PCA/近似正交旋转，并在报告中说明工程近似。

产物：

- `report/results/opq_ivfpq.csv`
- `report/fig/opq_tradeoff.pdf`
- `report/fig/ivfopq_tradeoff.pdf`

### 3. 新增 B：统一建模 + Roofline/Profile

CPU 侧：

- 使用 VTune 采集 Flat-AVX2、PQ、IVF-PQ、OPQ/IVF-OPQ。
- 指标：IPC、Retiring、Memory Bound、Core Bound、LLC miss、热点函数。
- 用 `objdump` 保留 AVX2 指令证据，如 `vfmadd`、`vpshufb`。

GPU 侧：

- 复用 Lab5 CUDA event/cuobjdump 结果。
- 必要时补 Nsight 指标：occupancy、带宽利用、访存合并、top-k kernel 时间。

Roofline：

- STREAM 或已有本地带宽数据作为 i9 带宽上界。
- 标出 Flat、PQ/ADC、FastScan、IVF-PQ、OPQ rotation、GPU GEMM。
- 结论围绕瓶颈迁移：Flat memory-bound，量化降低访存但引入 LUT/cache 压力，GPU GEMM 提高吞吐后 top-k/transfer 变得显性。

产物：

- `report/results/profile_summary.csv`
- `report/fig/roofline.pdf`
- `report/results/objdump_key_snippets.txt`

### 4. 新增 C：CPU-GPU 异构协同

实现目标：GPU 做 GEMM 粗排，CPU 用 AVX2 对 top-p 候选精排。

固定实验：

- `candidate_p={100,300,500,1000}`
- `query_n={1,128,512,2000}`
- 对比组：CPU-only Flat/IVF-PQ、GPU-only cublas_tree、GPU coarse + CPU rerank。
- 可选优化：CUDA stream 重叠 H2D 与 compute；若时间不够，只做时间分解和可行性分析。

输出指标：

- recall@10 / recall@100
- online latency
- wall latency
- H2D、kernel、D2H、CPU rerank 分项时间
- QPS

产物：

- `report/results/gpu_hybrid.csv`
- `report/fig/gpu_hybrid_timeline.pdf`
- `report/fig/gpu_hybrid_tradeoff.pdf`

### 5. 报告重构

正文结构固定为：

1. 引言：ANNS 问题、指标、统一平台、工作范围说明，约 2 页。
2. ANNS 系统全流程：离线建索引、在线查询、候选生成、精排、评估，约 2.5 页。
3. 统一视角下的并行算法设计：两条主线与四架构并行粒度映射，约 4 页。
4. 距离计算与量化加速：AVX2、SQ、PQ、FastScan、OPQ，约 4.5 页。
5. 减少访问点：IVF、HNSW、多核与本地 MPI，约 5 页。
6. GPU 并行与异构协同，约 3 页。
7. Profile、Roofline 与性能建模，约 3 页。
8. 统一实验评测：Latency-Recall 主图、加速比/QPS，约 3 页。
9. 工程取舍与局限，约 1.5 页。
10. 结论，约 1 页。

附录不计正文页数：

- 附录 A：平时工作与本次工作范围对照表。
- 附录 B：关键代码片段。
- 参考文献。
- AI 使用报告。

## Test Plan

- 编译：
  - CPU OPQ/IVF-OPQ 在本地 AVX2 模式编译通过。
  - GPU 异构实验使用 `nvcc + cuBLAS` 编译通过。
- 正确性：
  - PQ 与 OPQ 使用相同 `m/ksub/rerank_p`。
  - IVF-PQ 与 IVF-OPQ 使用相同 `nlist/nprobe/rerank_p`。
  - rerank 统一用原始 float 向量。
- 性能：
  - 新实验 warmup 后运行 3 次，取中位数。
  - 输出 CSV 保留分项时间，避免只报总时间。
- 报告：
  - 正文 ≤30 页。
  - 图表不少于：pipeline 图、架构×算法矩阵、Latency-Recall 总图、OPQ 对比图、异构时间分解图、Roofline 图、工作范围表。
  - 全文删除“综上所述”“值得注意的是”“本节将介绍”等汇报腔表达。
  - 不使用第一人称。

## Assumptions

- 本地 NVIDIA CUDA/cuBLAS 可用。
- DEEP100K 可从 `files/` 或 `ANN_DATA_PATH` 读取。
- 旧实验结果可信，除 OPQ、异构协同、少量 profile/Roofline 所需补测外不重跑。
- D/E 方向，即 SDC 流水线和 HNSWPQ，不进入主施工范围；只在时间充裕时二选一，否则写入未来工作。