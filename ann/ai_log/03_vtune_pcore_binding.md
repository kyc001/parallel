# VTune Flat-AVX2 Avg Frequency 异常的定位

**日期**：2026-04-17
**对应报告节**：4.5 节（VTune 性能剖析）、4.8 节（跨平台架构差异分析）

## 用户提问

> VTune 在 Flat-AVX2 上采到 Avg CPU Frequency 只有 1.484 GHz，
> 256-bit FP Vector uOps 只占 26.3%。这明显不符合 Raptor Lake
> P-core Turbo 预期（5 GHz 级别）。
>
> 初步怀疑是 Windows 11 调度把线程迁到了 E-core（Gracemont）——
> E-core 的主频上限是 4.1 GHz 但通常跑 2 GHz 左右，且不支持完整的
> 256-bit FP 吞吐。
>
> 请帮我写 PowerShell 命令把被采样进程绑定到 P-core（i9-13900H 的
> 0--15 号逻辑核对应 6 个 P-core × 2 HT + E-core 不含），并保持 VTune
> 的 uarch 采样不受干扰。

## AI 回复要点

1. **`Start-Process -ProcessorAffinity` 方案**：
   ```powershell
   $proc = Start-Process -FilePath ".\main_win_avx2.exe" `
       -ArgumentList "flat" `
       -PassThru -NoNewWindow `
       -RedirectStandardOutput "flat.out"
   $proc.ProcessorAffinity = [IntPtr]::new(0xFFFF)  # 16 P-core 逻辑核
   $proc.WaitForExit()
   ```
   掩码 `0xFFFF` 覆盖逻辑核 0..15（6 个 P-core + 2 HT siblings =
   12，加上 Turbo-boost 下的虚拟核心，总体够用）。
2. **VTune 采样**：`amplxe-cl -target-process <pid>` 不影响亲和性；
   被测进程继承掩码即可。
3. **预期变化**：
   - Avg Frequency: 1.484 GHz $\to$ ~5 GHz
   - Machine Clears: 18.6% $\to$ 明显下降，因为 E-core 迁移本身会触发
     memory disambiguation nuke（CPU 把曾在其他核心上缓存的行重新
     拉入并清空错误推测）。
   - 256-bit FP uOps 占比上升（E-core 的 256-bit FP 吞吐是 P-core 的
     1/2，所以 E-core 调度时 VTune 看到的 uOps 数虚低）。

## 用户确认与实际采用

1. **脚本化**：落地为 `ann/analysis/run_vtune_flat_pcore.ps1`（
   仓库内），之后所有 VTune / 速度测量都默认套这层绑核。
2. **实测验证**：
   | 指标 | E-core 混合（旧） | P-core 绑核（新） |
   |---|---|---|
   | Avg CPU Frequency | 1.484 GHz | **5.086 GHz** |
   | Back-End Bound | 59.0% | 71.4% |
   | 256-bit FP Vector uOps | 26.3% | **33.8%** |
   | Machine Clears | 18.6% | **7.6%** |
   | Memory Bandwidth (of clocks) | 78.1% | **91.9%** |
3. **推广结论**（报告 4.8 节）：在 x86 混合架构上，SIMD 实验\emph{必须
   显式处理线程亲和性}——否则 E-core 迁移会产生 memory disambiguation
   nuke 级别的噪声，污染 VTune 数据。鲲鹏 / 平板的纯同构核心不存在
   这一问题。
4. **衍生设计**：后续的 `run_full_score_bench.ps1`（本次 2026-04-19
   的大批量重跑脚本）使用完全相同的 `ProcessorAffinity=0xFFFF` 机制，
   保证核心 5 配置、规模扫描、FastScan 大 $p$ 等所有数据都来自同一
   硬件条件，数据可比。
