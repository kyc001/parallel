# ANN Pthread/OpenMP 待审查补充实验清单

本文件只记录可能值得补充的实验项，暂不改动已有结果口径。

## 优先级较高

1. **SQ/PQ/FastScan 完整 p-sweep**
   - 现有报告已有 PQ 高召回 p-sweep 和 SIMD 报告中的 FastScan 曲线，但多线程矩阵中尚未对 SQ/PQ/FastScan 用完全一致的线程数、调度策略、p 集合重跑。
   - 建议固定 `pthread_dynamic_inter` 或每族最优 inter-query 调度，扫描 `p={40,100,300,500,1000,2000,5000}`，输出统一 recall-latency 曲线。

2. **鲲鹏侧 perf / PMU 证据**（无权限，放弃）

3. **intra-query 每线程 top-p 参数 sweep**
   - 现有实现采用每线程保留全局规模 `p_t=p`，保证 recall 不因分块丢候选。
   - 可补充 `p_t={p/T, p/2, p, 2p}` 对 recall 与 merge 成本的影响，用于更细地解释 intra-query 负优化。

## 优先级较低

4. **更大 nlist 的 IVF / IVF-PQ**
   - 当前核心矩阵使用 `nlist=16` 以控制构建与运行时间。
   - 可在 `nlist={64,256}` 上抽样验证 inverted list 更短、更不均匀时的调度差异。

5. **线程亲和与混合核影响**
   - 本地 i9-13900H 是 P/E 混合核，16 线程结果可能受 Windows 调度影响。
   - 可固定 P-core 或用 `start /affinity` 做重复测试，验证 dynamic 调度优势是否来自混合核尾部效应。

6. **HNSW 无锁 visited 标记实验**
   - 多入口和边划分主要提升 recall，但同步开销较大。
   - 可尝试 per-thread visited bitmap 或 generation tag，降低图搜索并行化中的共享状态成本。
