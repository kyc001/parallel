# SoA + blocking 的作用域边界讨论

**日期**：2026-04-18
**对应报告节**：3.4 节（PQ 编码与 LUT 构建的 SIMD 化设计）、4.4 节（SoA 实测加速）、4.6 节（查询热路径未恶化验证）

## 用户提问

> 当前标准 PQ 查询热路径已经较紧凑：Windows i9 P-core 绑核下
> $p=1000$ 时 761.99 $\mu$s，单次查询 $\sim 0.4$ ms。如果把 SoA + blocking
> 推到查询热路径里做 in-line reshape，每次 reshape 成本可能不会被摊销，
> 反而拉高端到端延迟。
>
> 我倾向于**只把 SoA + blocking 应用到训练 / 编码阶段的 argmin 搜索**
> （每个子段对 $K_s=256$ 个 centroid 找最近中心），查询路径保持 AoS。
> 这种"边界设计"在实际高性能库里很常见（比如 FAISS 在训练和查询用不同
> 内存布局）。
>
> 请在这个边界下，帮我给出 `build_soa_from_aos` + `argmin_l2_blocked`
> 的 AVX2 原型，并说明它如何对应指导书"跨 centroid 并行 + 数据布局
> 优化 + block+cache 优化"的高分路线。

## AI 回复要点

1. **`build_soa_from_aos`**：把 `centroids[m][c][j]` 重排为
   `centroids_soa[m][j][c]`。AoS 的迭代顺序是"先遍历 centroid，再
   对每个 centroid 扫维度"；SoA 后变成"先锁定维度 $j$，然后一次
   `loadu_ps(soa[m][j])` 取 8 个 centroid 在该维度的值"。
2. **`argmin_l2_blocked`**：双层循环结构
   ```cpp
   for (int block = 0; block < ksub; block += 32) {              // tile
     for (int c = block; c < block_end; c += 8) {                 // SIMD lane
       __m256 acc = _mm256_setzero_ps();
       for (int j = 0; j < dsub; ++j) {
         __m256 xv = _mm256_set1_ps(x[j]);                        // broadcast
         __m256 cv = _mm256_loadu_ps(soa + j*padded + c);         // SoA load
         __m256 diff = _mm256_sub_ps(cv, xv);
         acc = _mm256_fmadd_ps(diff, diff, acc);                  // 跨 cent FMA
       }
       /* horizontal reduce + compare with best_dist */
     }
   }
   ```
3. **三条高分路线的对号入座**：
   - `loadu_ps(soa[j])` 一次拉 8 个 centroid → 跨 centroid 并行
   - AoS $\to$ SoA 本身 → 数据布局优化
   - 外层 tile=32（$32 \times 12 \times 4 = 1.5$ KB，远小于 L1）→ block + cache 优化
4. **NEON 版本**用 `vdupq_n_f32` + `vmlaq_f32`，每轮处理 4 个 centroid。

## 用户确认与实际采用

1. **边界决策** 由笔者主导：查询路径保持 AoS，只在 `PQIndex::build` 的
   训练循环和 encode 阶段使用 SoA + blocking。
2. **作用域验证**：在鲲鹏上做 `main_pqsimd.cc` 的完整 $p$-sweep，确认
   查询时延与 SoA 前一致（$p=1000$: 2032.72 vs 1984.35 $\mu$s，差
   $< 2.5$%，在测量噪声内）。报告 4.6 节以此作为"查询路径未被恶化"
   的辅证。
3. **编码阶段加速实测**（附录 4）：AoS baseline 151.14 ms vs SoA+blocking
   43.06 ms，**加速 $3.51\times$**。这坐实了 3.4 节声明的高分路线确实
   带来了可测量收益，而不仅是"做了这件事"。
4. **头文件落地**：`ann/pq_blocked_avx2.h` 与 `ann/pq_blocked_neon.h`。
   两平台通过 padded_ksub 处理 $K_s$ 非 8/4 的倍数的尾部。
