# FastScan shuffle vs gather 路线选型

**日期**：2026-04-18
**对应报告节**：3.5 节（FastScan 设计）、4.6 节（Gather vs Shuffle 实测）

## 用户提问

> 我在看 PQ 的 ADC 查表累加时发现它是 memory-bound：$O(NM)$ 次随机索引访问 LUT。
> x86 AVX2 有 `_mm256_i32gather_ps` / `_mm256_i32gather_epi32` 指令，
> 但 Intel 优化手册里说它的吞吐量随索引散度线性恶化；ARM NEON 又没有
> 等价的通用 gather 指令。
>
> 我打算走 shuffle / table-lookup 路线：把 LUT 从
> $M \times 256 \times 4\,\mathrm{B}$ 压到 $M \times 16\,\mathrm{B}$
> （也就是 $K_s$ 从 256 → 16），然后用 `_mm256_shuffle_epi8`（x86）
> / `vqtbl1q_u8`（ARM）做寄存器内查表。
>
> 请按这个方向完善：
> 1. $M$、$K_s$ 的选择；
> 2. double-nibble 打包格式（因为 16 项 LUT 只用 4 bit 编码）；
> 3. 跨平台头文件 dispatch 的骨架。

## AI 回复要点

1. **$M=16$、$K_s=16$ 是最佳匹配**：`_mm256_shuffle_epi8` 每通道
   按 4 bit 索引从 16 字节的表里取值，正好对应 $K_s=16$。$M$ 从标准
   PQ 的 8 提到 16 是为了补偿 $K_s$ 减小带来的量化精度损失。
2. **LUT 量化到 $[0, 15]$ 小整数**（每段独立 min/max 重标度），扫描
   用 `_mm256_adds_epu8` 饱和累加即可，避免 uint16 溢出。
3. **Double-nibble 打包**：每 2 段 code 合并为 1 字节（低 4 bit +
   高 4 bit），扫描时 `_mm256_and_si256(..., 0x0f)` 取低半、`srli_epi16
   + and` 取高半，两次 shuffle 后 `adds_epu8` 累加。
4. **跨平台头文件 dispatch 骨架**：
   ```cpp
   // pq_fastscan_simd.h
   #if defined(__AVX2__)
   #include "pq_fastscan_avx2_safe.h"
   #elif defined(__aarch64__) || defined(__ARM_NEON)
   #include "pq_fastscan_neon.h"
   #else
   #error "FastScan requires AVX2 or NEON"
   #endif
   ```
   主算法分两个版本实现，共用 `train_fastscan` / `encode_fastscan` /
   `fastscan_search` 的 C API 签名。

## 用户确认与实际采用

1. **LUT 量化比例系数** 由笔者自行决定：每个子段 $m$ 的 $\mathrm{LUT}_m$
   独立取 min/max 做 8-bit 重标度（而非 4-bit，因为累加后需要 epu8 空间）。
2. **rerank_p 环境变量** 改为编译期宏 `FASTSCAN_DEFAULT_RERANK_P`，
   原因：鲲鹏 PBS 作业不保留 shell 变量，登录后 `export FASTSCAN_RERANK_P=1000`
   并不会传给 `test.sh` 的子进程。实际脚本用 `sed` 注入宏值到 `main.cc`。
3. **落地结果**：i9 P-core $p=1000$ 上 FastScan 541.69 $\mu$s vs 标准 PQ
   761.99 $\mu$s（$1.41\times$ 快），鲲鹏 $p=1000$ 上 1339.75 $\mu$s vs
   1984.35 $\mu$s（$1.48\times$ 快），证实了 shuffle 路线在两平台的可移植收益。
4. **gather 路线事后实测**（见附录 5）：在 100K rows 上 `_mm256_i32gather_ps`
   达 $52.73$ ns/row，\emph{比 scalar 慢 3.9$\times$}。选择 shuffle 是
   正确的。
