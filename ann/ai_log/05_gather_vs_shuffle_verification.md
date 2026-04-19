# Gather vs Shuffle 实测验证方案

**日期**：2026-04-19
**对应报告节**：4.6 节（Gather vs Shuffle 实测）、3.5 节（FastScan 设计说明）

## 用户提问

> 报告 3.5 节我之前写了一句"在 x86 上 gather 会受随机访问延迟限制，
> 所以没选"。但助教的评语是：**这只是口头说明，没给数字**——
> 严格审稿会认为"偷懒"。
>
> 我想补一个 30 行的 gather-based ADC 版本，跑一遍拿一个数（即使
> 它就是慢），做成一行表格 `gather: X ns/row / shuffle: Y ns/row`，
> 让"选 shuffle 不选 gather"变成**有证据的决策**。
>
> 请按这个方向设计微基准：
> 1. 公平设置：scalar / gather / shuffle 都跑 100K rows；
> 2. gather 用 `_mm256_i32gather_ps`（而不是 `_epi32`，因为 LUT 是
>    float），一次 gather 8 个 centroid；
> 3. shuffle 按 FastScan 风格：$K_s=16$ 的 4-bit LUT + `_mm256_shuffle_epi8`；
> 4. 输出 CSV 以便 Python 画图。

## AI 回复要点

1. **三份实现**（新文件 `analysis/bench_gather_vs_shuffle.cc`）：
   - `adc_scalar`：纯 8 次 `lut[m*Ks + code[m]]` 查表相加
   - `adc_gather`：构造 `int32[8]` 索引 $m \cdot K_s + \text{code}[m]$，
     `_mm256_i32gather_ps(lut, vidx, 4)` 一次 gather，再 reduce
   - `adc_shuffle_batch`：FastScan 风格，每行做 `broadcastsi128_si256`
     加载两个小 LUT，`and / srli+and` 拆 nibble，`shuffle_epi8` 查表，
     `adds_epu8` 累加
2. **公平性**：
   - 所有实现都跑 100K rows，5 次取平均，第一次丢弃（warmup）
   - scalar 用 `volatile float sink` 防止死码消除
   - gather 的索引不缓存（每行都新构造，模拟随机 LUT）
3. **Intel 优化手册的预期**：gather 随索引散度线性恶化。$M=8$ 时每条
   gather 要对 8 个完全不同的 LUT 行做独立 load，cache line split 几乎
   不可避免。

## 用户确认与实际采用

1. **编译落地**：`g++ analysis/bench_gather_vs_shuffle.cc -O2 -mavx2 -mfma`，
   P-core 绑核 5 次重复。
2. **实测结果**（报告表 \ref{tab:gather_vs_shuffle}）：

   | 路线 | ns / row | 相对 scalar |
   |---|---|---|
   | scalar（基线） | $13.55 \pm 0.89$ | 1.00$\times$ |
   | gather (`_mm256_i32gather_ps`) | $52.73 \pm 3.65$ | **0.26$\times$（慢 3.9$\times$）** |
   | shuffle（FastScan 风格） | $13.40 \pm 3.08$ | 1.01$\times$ |

3. **决策坐实**：gather 慢 3.9$\times$ 这个数字是 Intel 手册的定量
   验证——随机索引 gather 的吞吐远低于固定步长 load。shuffle 路线
   本身与 scalar 持平，但叠加了 4-bit LUT / 编码打包 / batch 三项
   结构化红利，在真实 FastScan 里最终比 scalar ADC 快 $\sim 1.4\times$（
   表 \ref{tab:fastscan}）。
4. **选择 shuffle 而非 gather 是有实测依据的设计决策** 这一条
   写进了报告 4.6 节末尾。
5. **副产物**：bench 同时验证了 shuffle 的实现正确性——输出 `sums[r]`
   与独立参考实现在 100K 样本上逐行一致。
