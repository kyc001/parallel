# ANN Pthread/OpenMP 待审查补充实验清单

本文件只记录可能值得补充的实验项，暂不改动已有结果口径。

## 优先级较高

1. ~~**SQ/PQ/FastScan 完整 p-sweep**~~ ✅ 已完成
   - PQ p-sweep 已跑完：p={40,100,300,500,1000,2000,5000}，pthread_dynamic_inter, t=16
   - 数据：`results/pq_p_sweep.txt`，已纳入报告 §6.5 表 tab:pq_p_sweep
   - IVF nlist-sweep 也已跑完：nlist={4,8,16,32,64,128,256}，nprobe=nlist/4，pthread_pool_inter, t=16
   - 数据：`results/ivf_nlist_sweep.txt`，已纳入报告 §6.5 表 tab:ivf_nlist_sweep
   - SQ 和 FastScan 的 p-sweep 可后续补充（优先级低，SQ p 主要影响粗排精度，FastScan 的 p 与 PQ 类似）

2. **鲲鹏侧 perf / PMU 证据**（无权限，放弃）

3. **intra-query 每线程 top-p 参数 sweep**
   - 现有实现采用每线程保留全局规模 `p_t=p`，保证 recall 不因分块丢候选。
   - 可补充 `p_t={p/T, p/2, p, 2p}` 对 recall 与 merge 成本的影响，用于更细地解释 intra-query 负优化。
   - 需要修改 IVF intra 接口暴露 top-p_t 参数，工作量较大。

## 优先级较低

4. ~~**更大 nlist 的 IVF / IVF-PQ**~~ ✅ 已完成（IVF 部分）
   - IVF nlist-sweep 覆盖 nlist={4,8,16,32,64,128,256}，nprobe=nlist/4
   - 结论：nlist=16 在 0.96 recall 下延迟最低；增大到 256 可把 recall 抬到 0.998，延迟仅增 23%
   - IVF-PQ 的 nlist-sweep 可后续补充

5. ~~**线程亲和与混合核影响**~~ ✅ 已完成
   - P-core only vs E-core only vs P+E 全核对比已纳入报告 §6.9
   - 结论：E-core 单核算力约为 P-core 的 1/3；OS 默认调度已接近最优

6. **HNSW 无锁 visited 标记实验**
   - 多入口和边划分主要提升 recall，但同步开销较大。
   - 可尝试 per-thread visited bitmap 或 generation tag，降低图搜索并行化中的共享状态成本。
   - 需要修改 hnswlib 核心代码，工作量大，风险高。
