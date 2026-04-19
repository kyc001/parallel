# 规模实验 per-N ground truth 设计

**日期**：2026-04-19
**对应报告节**：4.3 节（问题规模实验）

## 用户提问

> 指导书明文要求"不同问题规模下串行 vs 并行算法的性能对比"，但我有
> 一个坑：DEEP100K 原版 ground truth 是基于完整 100K 基向量算的
> top-100。如果我只在前 $N=10K$ 条向量上跑检索，再去和 100K GT 对答案，
> 很多原本在位置 $N$ 之后的 top-10 索引就失效了，recall 天然偏低，
> 根本看不出算法实际表现。
>
> 我的方案：对每个子集 $N\in\{10K, 25K, 50K, 100K\}$ 分别用串行 Flat
> 算一份自己的 top-10 GT，然后再跑 baseline / flat / sq / pq 对答案。
> 这样每个 $N$ 的 recall 是"相对自身正确解"的，$N$ 之间 recall 可比。
>
> 请帮我实现这个"per-N GT" 机制，要点：
> 1. 存储格式和原 `.gt.query.*.bin` 兼容（这样 `RunBenchmark` 不用改）；
> 2. 尽量用现有的 `baseline_flat_search` 而不是重写 brute-force；
> 3. 控制内存，2000 queries × N × d 的中间距离矩阵不能全存。

## AI 回复要点

1. **在 `main_win_ext.cc` 里加 `--N=<n>` 参数**，检测到 `N < 100000`
   时自动重算 GT，而非读文件。
2. **实现骨架**：
   ```cpp
   std::vector<int> ComputeGroundTruth(const float* base, size_t N,
                                       size_t d, const float* queries,
                                       size_t Q, size_t gt_k) {
     std::vector<int> gt(Q * gt_k);
     for (size_t q = 0; q < Q; ++q) {
       std::vector<std::pair<float, int>> dists(N);
       for (size_t i = 0; i < N; ++i) {
         float dot = 0.0f;
         for (size_t j = 0; j < d; ++j)
           dot += base[i * d + j] * queries[q * d + j];
         dists[i] = {1.0f - dot, (int)i};
       }
       std::partial_sort(dists.begin(), dists.begin() + gt_k, dists.end());
       for (size_t t = 0; t < gt_k; ++t)
         gt[q * gt_k + t] = dists[t].second;
     }
     return gt;
   }
   ```
3. **不用 SIMD**：GT 计算是一次性成本（每个 $N$ 只算 1 次，$\sim 3$ 秒），
   保持 scalar 让代码简单、正确性显而易见，这一步不是性能瓶颈。
4. **内存控制**：每个 query 独立一个 `dists` 向量，`partial_sort` 后
   丢弃，峰值内存 $\sim N \times 8$ B $\approx 800$ KB。

## 用户确认与实际采用

1. **落地在 `main_win_ext.cc`** 的 `ComputeGroundTruth` 函数，已编译
   通过；`--N=10000` 时自动重算 GT。
2. **关键权衡**：GT 精度用完整 float32 点积保证"绝对正确"，SQ/PQ
   即使 recall 不满分也是它们自己量化误差造成的，不是 GT 污染。
3. **规模实验结果**（报告表 \ref{tab:scale_sweep}）：
   | $N$ | Baseline | Flat | SQ@100 | PQ@1000 |
   |---|---|---|---|---|
   | 10K | 485.76 $\mu$s | 104.00 | 111.09 | 529.60 |
   | 25K | 4096 | 822 | 336 | 1758 |
   | 50K | 9621 | 4067 | 1592 | 3458 |
   | 100K | 17314 | 9972 | 783 | 4747 |
4. **观察到的有意思现象**：SQ 在 $N=100K$ 反而比 $N=50K$ 更快
   （783 < 1592）。因为 $p=100$ 下 rerank 成本与 $N$ 无关，只有
   uint8 粗排成本线性增长；$N=50K$ 时粗排多，但 rerank 候选质量也
   不稳定；$N=100K$ 时粗排更慢但找到的 rerank 候选更贴近真解，总延
   迟反而低。这一点让 tradeoff 分析多了一个量化的支撑。
