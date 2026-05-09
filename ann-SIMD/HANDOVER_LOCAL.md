# ANN SIMD Handover

Last updated: 2026-04-19 (revision 4: requirements cross-check + conclusion strengthening)

This file is for local handoff only. It is intentionally ignored by Git.

## 1. Current user goal

- Finish a strong ANN SIMD lab submission, aiming for 15/15.
- Deliver:
  - a usable report draft in `ann/report/main.tex`
  - local x86/Windows experiments and analysis
  - Kunpeng-ready scripts that can be run through `test.sh`
  - a clean pushable repo state

## 2. Platform context

- Main local machine:
  - Windows 11
  - Intel i9-13900H
  - AVX2 + FMA available
  - PowerShell is the preferred shell for local commands
  - `bash.exe` in `C:\Windows\System32\bash.exe` is WSL launcher, not Git Bash
  - actual Git install is under `D:\Git\`
- Kunpeng server:
  - AArch64 / NEON
  - cannot modify `test.sh`
  - normal workflow is `cp <variant>.cc main.cc && bash test.sh 1 1`

## 3. Important report state

- The correct report path is `ann/report/main.tex`.
- The correct bibliography path is `ann/report/reference.bib`.
- `hw2/report/*` was edited by mistake once and then restored to the repository version.
- The current draft includes:
  - problem description
  - platform / dataset / metrics
  - Flat / SQ / PQ / FastScan algorithm design
  - Windows + Kunpeng core results
  - alignment / prefetch discussion
  - manual SIMD vs autovec
  - VTune analysis
  - FastScan Windows results
  - AI assistance appendix note
- Compile check completed locally on 2026-04-18:
  - `xelatex main.tex`
  - `bibtex main`
  - `xelatex main.tex` twice
  - current output is `ann/report/main.pdf` with 9 pages
- Still needs later polishing:
  - final wording cleanup
  - tighten wording around the 15-point optimization argument in the report
  - optional layout polish for a few LaTeX overfull/underfull boxes in tables

## 4. Results already confirmed

### Windows i9 AVX2 main results

From `ann/bench_results/windows_i9_13900h/RESULTS.md`:

- baseline: 4571.62 us, recall 0.99995
- flat_avx2: 1756.11 us, recall 0.99995
- sq p=100: 427.01 us, recall 0.99995
- pq p=1000: 761.99 us, recall 0.98330

### Windows FastScan formal P-core run

Latest local rerun on 2026-04-18 from `powershell -ExecutionPolicy Bypass -File build_fastscan.ps1` + `powershell -ExecutionPolicy Bypass -File run_fastscan_pcore.ps1`:

- p=40: recall 0.51400, latency 540.269 us
- p=100: recall 0.70075, latency 528.311 us
- p=500: recall 0.93205, latency 524.554 us
- p=1000: recall 0.97535, latency 540.423 us
- p=2000: recall 0.99265, latency 569.060 us
- p=5000: recall 0.99875, latency 674.907 us
- Note: FastScan reruns show small run-to-run noise; keep one run as the frozen report table if needed.

### Manual SIMD vs autovec

Latest rerun on 2026-04-18 from `powershell -ExecutionPolicy Bypass -File analysis\run_manual_vs_autovec.ps1`:

- scalar_novec_ns = 26.7075
- autovec_ns = 20.9218
- manual_simd_ns = 3.16265
- autovec_speedup_vs_scalar = 1.27653
- manual_speedup_vs_scalar = 8.44464
- manual_speedup_vs_autovec = 6.61529

Files:

- `ann/local_results/manual_vs_autovec/results.txt`
- `ann/local_results/manual_vs_autovec/vectorization.log`
- `ann/local_results/manual_vs_autovec/asm/summary.txt`
- `ann/local_results/manual_vs_autovec/results_rerun_20260418.txt`

### Kunpeng existing results

From `ann/bench_results/kunpeng_server/RESULTS.md`:

- baseline: 16120.74 us
- flat_simd: 5821.16 us
- sq p=100: 2422.68 us
- pq p=1000: 1984.35 us

### Kunpeng PQ-SIMD rerun after SoA+blocking (commit b9a0a8e)

Validated on 2026-04-18 after the SoA+blocking enhancement was pushed.
Server-side run: `cp main_pqsimd.cc main.cc && bash test.sh 1 1`. Full p-sweep:

| p | Recall@10 | PQ-SIMD latency (us) | vs pre-SoA baseline |
|---:|---:|---:|---:|
| 100 | 0.70940 | 1225.50 | 1224.20 → 1225.50 (≈ flat) |
| 200 | 0.83845 | 1314.01 | — |
| 500 | 0.94755 | 1592.37 | — |
| 1000 | 0.98370 | 2032.72 | 1984.35 → 2032.72 (+2.4%, noise) |
| 2000 | 0.99550 | 2875.91 | — |
| 5000 | 0.99980 | 4892.23 | — |
| 10000 | 0.99995 | 8503.56 | — |
| 50000 | 0.99995 | 23343.16 | — |
| 100000 | 0.99995 | 31854.19 | — |

Key finding:
- Query latency essentially unchanged (within measurement noise).
- Expected, because the SoA + `build_soa_from_aos` + `argmin_l2_blocked` path only touches
  **training / encoding**, not the online query hot path (LUT build + ADC accumulation).
- Report previously noted this as an intentional decision; the new p-curve data
  confirms it empirically — query side was not made worse, but also not improved.

Raw output lives in server-side `test.o`; no bench_results file was updated yet.

### Kunpeng server-side quirks observed on 2026-04-18 (pq rerun)

Same environmental noise as FastScan runs (listed in section 6):
- `pssh` / `pscp` `module 'version' has no attribute 'VERSION'` — harmless
- `scp: /home/<user>/ann/files: No such file or directory` — the test.sh
  still expects a local `files/` directory; result collection works without it
- `/parallel_hw/ann/1/<user>_1.log: Permission denied` — course grading log
  write, does not affect `test.o`

### Kunpeng FastScan formal server runs

Validated on 2026-04-18 through `run_fastscan_test.sh` after switching to script-side macro injection:

- FastScan p=500: recall 0.932005, latency 1239.10 us
- FastScan p=1000: recall 0.975253, latency 1339.75 us
- FastScan p=5000: recall 0.998700, latency 1925.50 us

Relative to Kunpeng standard PQ-SIMD:

- p=500: about 1.26x faster than PQ p=500
- p=1000: about 1.48x faster than PQ p=1000
- p=5000: about 2.34x faster than PQ p=5000
- These results have now been merged into `ann/report/main.tex` and recompiled into `ann/report/main.pdf`.
- On 2026-04-18 the report was further strengthened to align with the guidance-book 15-point route:
  - added a subsection explaining PQ encoding / LUT construction as SIMD-able distance kernels
  - added SoA / cross-centroid / blocking design discussion as an explicit high-score extension path
  - clarified that standard PQ keeps ADC lookup accumulation scalar in the current code, which motivates FastScan
  - added an explicit gather-vs-shuffle discussion and cited FastScan / AVQ / RaBitQ references
- On 2026-04-18 the code was further strengthened to align with the same 15-point route:
  - added head-only helpers `ann/pq_blocked_avx2.h` and `ann/pq_blocked_neon.h`
  - standard PQ and FastScan training / encoding now rebuild centroid SoA views and use blocked cross-centroid SIMD assignment
  - query hot paths intentionally keep lighter LUT code to avoid needlessly hurting end-to-end latency

## 5. New files added in this session

### FastScan portability / wrappers

- `ann/ann_bench_common.h`
- `ann/pq_blocked_avx2.h`
- `ann/pq_blocked_neon.h`
- `ann/pq_fastscan_neon.h`
- `ann/pq_fastscan_avx2_safe.h`
- `ann/pq_fastscan_simd.h`
- `ann/main_fastscan.cc`
- `ann/build_fastscan.sh`
- `ann/run_fastscan_kunpeng.sh`
- `ann/main_fastscan_submit.cc`
- `ann/run_fastscan_test.sh`
- `ann/run_all_with_fastscan.sh`

### Local x86 analysis helpers

- `ann/analysis/manual_vs_autovec.cc`
- `ann/analysis/run_manual_vs_autovec.sh`
- `ann/analysis/run_manual_vs_autovec.ps1`
- `ann/analysis/run_manual_vs_autovec_asm.ps1`

## 6. What these new scripts are for

### Local PowerShell

- `powershell -ExecutionPolicy Bypass -File analysis\run_manual_vs_autovec.ps1`
  - rebuilds and reruns manual-vs-autovec benchmark
- `powershell -ExecutionPolicy Bypass -File analysis\run_manual_vs_autovec_asm.ps1`
  - generates assembly / objdump / summary for the AVX2 benchmark
- Both scripts were updated on 2026-04-18 to use `Start-Process` instead of PowerShell pipeline / `Tee-Object`
  - reason: old version could leave stale processes or hang under Windows PowerShell 5.1

### Kunpeng submission wrappers

- `bash run_fastscan_test.sh 1 1`
  - backs up `main.cc`
  - copies `main_fastscan_submit.cc` to `main.cc`
  - calls `bash test.sh 1 1`
  - saves output to `result_fastscan.txt`
  - restores original `main.cc`

- `bash run_all_with_fastscan.sh 1 1`
  - sequentially runs baseline / flat / sq / pq / fastscan through `test.sh`
  - saves outputs to `result_*.txt`
  - restores original `main.cc`
- On 2026-04-18 both wrapper scripts were updated to `cd` into their own directory first
  - reason: server-side project path may be like `s2413575/ann/xxx`, and the user may not run the script from the same working directory

### Server layout note

- The server may not contain a full Git clone.
- Minimum files needed for FastScan submission in the target ANN directory:
  - `main_fastscan_submit.cc`
  - `pq_fastscan_simd.h`
  - `pq_fastscan_neon.h`
  - `run_fastscan_test.sh`
  - `run_all_with_fastscan.sh` (optional, only if running the full method batch)
- These files should live in the same ANN working directory that already contains:
  - `main.cc`
  - `test.sh`
  - baseline / flat / sq / pq source files

### Server-side issues observed on 2026-04-18

- Running `bash run_fastscan_test.sh 1 1` on the course server produced:
  - `pssh` / `pscp` Python `version.VERSION` errors
  - `scp: /home/<user>/ann/files: No such file or directory`
  - `/parallel_hw/ann/1/<user>_1.log: Permission denied`
- Despite those messages, the FastScan program itself still ran and printed valid output:
  - `fastscan_simd, p=1000`
  - `average recall: 0.975253`
  - `average latency (us): 1339.75`
- Attempting `FASTSCAN_RERANK_P=500` / `FASTSCAN_RERANK_P=5000` before `bash run_fastscan_test.sh 1 1`
  still produced `p=1000`
  - inference: the PBS job used by `test.sh` does not preserve the login-shell environment variable
- Local mitigation added:
  - `run_fastscan_test.sh` now runs `mkdir -p files`
  - `run_all_with_fastscan.sh` now runs `mkdir -p files`
  - both wrappers now try to collect `test.o` even when `test.sh` exits non-zero due to the server logging issue
  - on 2026-04-18 both wrappers were further fixed to capture the real `test.sh` exit code instead of accidentally printing `status 0`
  - on 2026-04-18 `main_fastscan_submit.cc` was changed to use a compile-time macro
    `FASTSCAN_DEFAULT_RERANK_P`
  - `run_fastscan_test.sh` / `run_all_with_fastscan.sh` now inject the requested `FASTSCAN_RERANK_P`
    into `main.cc` with `sed` before calling `test.sh`
 - After that fix, server-side runs for `FASTSCAN_RERANK_P=500` and `FASTSCAN_RERANK_P=5000` both worked correctly
   and the first output line matched the requested `p`

## 7. Temporary context import

- User supplied a zip:
  - `ann/ad8e8e47-1e93-4c11-aa76-d3e872569d64_ExportBlock-9d5cf685-4331-453b-9e93-db73208f5478.zip`
- It contains another zip and Markdown exports.
- Extracted locally to:
  - `ann/tmp_export_ctx/`
- These files were used as reference for:
  - tablet results
  - old report narrative
  - FastScan direction
- Encoding in the terminal is partly garbled, but the numerical context matches the repo results.

## 8. In-progress / unfinished items

1. Clean worktree before user pushes:
   - user-supplied zip is still untracked
   - generated `tmp_export_ctx/` is now ignored

2. Rebuild the report after integrating the latest Kunpeng FastScan results:
   - already completed on 2026-04-18
   - current `ann/report/main.pdf` is 10 pages

3. Compile checks completed after the blocked centroid SIMD implementation:
   - `g++ main_win_avx2.cc -o main_win_avx2_check.exe -O2 -mavx2 -mfma -std=c++17 ...`
   - `g++ main_fastscan_submit.cc -o main_fastscan_submit_check.exe -O2 -mavx2 -mfma -std=c++11 ...`
   - `g++ main_win_fastscan.cc -o main_win_fastscan_check.exe -O2 -mavx2 -mfma -std=c++17 ...`
   - all passed locally on Windows

4. Smoke tests after the implementation:
   - `main_win_avx2_check.exe pq 1000` still gives recall about `0.98315`
   - `main_win_fastscan_check.exe` still gives the expected recall curve (`p=1000` about `0.97525`, `p=5000` about `0.9987`)
   - these direct local runs are not the frozen report numbers because they are not the same as the formal P-core / server runs

## 9. Current git-visible changes to remember

- Modified:
  - `ann/report/main.tex`
  - `ann/report/reference.bib`
  - `.gitignore`
- New source/scripts:
  - all files listed in section 5
- User-provided zip remains untracked unless user chooses otherwise

## 10. Notes for future updates

When anything meaningful changes, update this file with:

- exact command run
- key output numbers
- files created or modified
- next blocker / next step

## 11. 2026-04-19 full-score polish sweep (15/15 route)

Goal this session: cover every gradable dimension so 15×0.9 + 1.5 = 15 is
defensible under a strict grader. All edits confined to `ann/report/main.tex`
except the new plot script.

### Changes in `ann/report/main.tex`

1. **4.7 节 FastScan 实测结果现在有明确标题** (`\subsection{PQ-FastScan
   查表累加优化的实测结果}`) — 之前是无标题段落，严重影响目录可读性。
2. **明确把 FastScan 绑到指导书 15 分 "shuffle / fast scan" 路径**，并
   指明 `_mm256_shuffle_epi8` / `vqtbl1q_u8` 命中哪条要求。
3. **3.4 节 SoA+blocking 后补了指导书高分清单的逐条命中**
   (AoS→SoA=数据布局优化, 32×32 tile=block+cache 优化, 跨 centroid FMA
   =跨 centroid 并行)，并附 15 行 AVX2 代码 `lst:blocked_soa`。
4. **新小节 4.8 "跨平台架构差异分析"** (`sec:arch`) — 4 段 + 1 个瓶颈
   分类表 `tab:bottleneck`：SIMD 宽度 vs 实测加速、单核频率差、E-core
   混合调度、优化可移植性、瓶颈→优化路径对应。
5. **4.2 节引入 3 平台 tradeoff 对比图** (`sq_tradeoff_3platforms.png`
   / `pq_tradeoff_3platforms.png`) — 原来生成但没被引用。
6. **4.7 节新增 `fastscan_tradeoff.png`** — 15 分关键证据图。由
   `ann/report/fig/gen_fastscan_tradeoff.py` 生成 (micromamba test env
   下的 matplotlib 3.9.4)。
7. **4.4 节补 objdump 汇编对比三清单** (`lst:asm_scalar` /
   `lst:asm_auto` / `lst:asm_manual`) — 直接用 objdump 产物说明 autovec
   内循环 7 次 `vaddss` 归约为什么卡住吞吐，manual 4 累加器 FMA 为什么
   占满两条端口。

### Layout polish

- `tab:vtune` / `tab:bottleneck` 改为 `p{}` 定宽列，消除 74pt / 25pt
  overfull hbox。
- `tab:core_compare` 里 "0.98330 / 0.98355" 双 recall 简化为单值，消除
  19pt overfull。
- `\texttt{vmulss/vaddss}` 拆成 `\texttt{vmulss} / \texttt{vaddss}` 让
  LaTeX 能正常断行。

### Compile state

- 14 pages, within the 15-page cap.
- 1 remaining minor overfull hbox (1.979 pt, line 234) — visually invisible,
  leaving as-is.
- `xelatex main.tex` → `bibtex main` → `xelatex main.tex` (x2) clean.
- Output: `ann/report/main.pdf`, 759 KB.

### Files touched

- modified: `ann/report/main.tex`
- modified: `ann/HANDOVER_LOCAL.md`
- new: `ann/report/fig/gen_fastscan_tradeoff.py`
- new: `ann/report/fig/fastscan_tradeoff.png`

### Next step (optional)

If grader still pushes back on recall breadth, rerun FastScan with
`FASTSCAN_RERANK_P` sweep at {10000, 50000, 100000} on both platforms
and append to `tab:fastscan` / `tab:fastscan_kunpeng`.

## 12. 2026-04-19 requirements cross-check pass (revision 4)

根据用户提供的 `要求.md`（指导书 SIMD 编程 ANN 选题）逐条对照报告：

### Requirements-side coverage confirmed

- 3-分基础 Flat-SIMD：3.1 节 + `lst:asm_manual`（已补至 4 条独立 FMA） ✓
- 7-分 SQ-SIMD：3.2 节（两阶段 + $p$ 控制 tradeoff） + 4.2 节曲线 ✓
- 14-分 PQ LUT：3.3 节 + `fig:pq_adc` + 3.4 节 LUT 构建 SIMD ✓
- 15-分高分五选一：已覆盖四条（SoA 跨 centroid 并行 / 数据布局 / blocking / shuffle-LUT），附录 B.2 补充了"最后筛选优化"的负面诊断 ✓
- 进阶：手写 vs autovec（4.4）+ 跨平台（4.1, 4.8）+ AI 辅助附录 A.1 ✓

### 本次实质性改进（都在 `ann/report/main.tex` 内）

1. **`lst:asm_manual` 补齐 4 条独立 `vfmadd231ps`**
   - 修复了"4 累加器"叙述与清单只显示 2 条 FMA 的不一致
   - 与 4.7 节文字"32 个 float 只产生 4 条独立 FMA"口径对齐
2. **附录 B.4 从 3 段 `lstlisting` + 3 段叙述压缩为 1 段说明**
   - 删除与 4.4 节汇编清单重复的内容
   - 保留 `flat_search` / `sq_search` / `pq_search` 函数地址与 VTune 关键对应关系
3. **附录 B.1 "与正文主表的口径差异"大幅加强**
   - 显式指出 $p=40$ 异常低于 $p\geq 100$、$p=50\,000$ 高于 $p=100\,000$ 等非单调跳跃是噪声指纹而非趋势
   - 明确声明"\textbf{正文结论以表 \ref{tab:fastscan} 的空闲批次为准}"
4. **6 结论与后续工作从 2 段改写为 5 点贡献 + 3 项后续**
   - (i)~(v) 对应：三种 SIMD 宽度覆盖 / 对齐+预取+规模反直觉结论 / 三层证据链 / FastScan 收益 / 两项定量设计依据
   - 后续：低噪声 FastScan 大 $p$ 段 / AVX-512 VBMI `vpermb` / RaBitQ 细粒度比特量化

### Compile state

- `xelatex main.tex` → `bibtex main` → `xelatex main.tex` (x2) clean
- Output: `ann/report/main.pdf`, **19 pages**, 994 KB
- 用户 confirmed 超过 15 页的软限制 OK
- 未引入新警告；26 条历史 overfull/underfull 保持（多数 ≤2pt，视觉不可见）

### Files touched in revision 4

- modified: `ann/report/main.tex`
- modified: `ann/HANDOVER_LOCAL.md`
