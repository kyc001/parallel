# PROJECT_HANDOVER

## 1. 项目极简介绍 (Elevator Pitch)

这是并行课程 `Lab1 CPU 架构编程` 的复现实验工程：用 C++17 在 Linux 环境下实现并对比“矩阵列内积”的 cache 优化版本与“数组求和”的超标量优化版本，并尽量补齐可用于报告的计时、汇编和 profiling 证据。

## 2. 技术栈与关键决策 (Tech Stack)

- `C++17 + STL`
  - 核心实验代码用 `std::vector`、`std::chrono`、`filesystem` 组织，依赖轻、可移植、方便在课程要求的 GCC/Linux 环境复现。
- `g++ + GNU Make`
  - 课程原生工作流；`Makefile` 已拆出普通基准、`perf` 专用、`gprof` 专用三套目标，便于一次维护多种 profiling 路径。
- `-O3 -march=native -fno-tree-vectorize -fno-tree-slp-vectorize`
  - 保留高优化和本机指令选择，但显式关闭自动向量化，避免 SIMD 把实验重点从 cache/超标量机制上“盖过去”。
- `Linux perf`
  - 目标方案，用于拿 `cycles / instructions / cache-references / cache-misses / LLC` 与热点报告；现实中受环境 PMU 能力限制严重。
- `perf_event_open`
  - 内嵌在主程序里，产出 `results/profile_results.csv`，本意是直接把硬件计数器结果带进实验结果目录。
- `gprof`
  - 兜底方案；在 `perf` 被权限或虚拟化限制挡住时，至少保住用户态热点分析和调用图。
- `LaTeX`
  - 报告在 `report/main.tex`，适合课程提交 PDF，但当前内容已经和最新实验环境脱节，需要优先修正。

关键决策：

- 项目已经从“单文件作业代码”整理成多文件工程，方便复跑、扩展 profiling、同步报告。
- 优先坚持“Linux 主实验 + 诚实披露 profiling 受限”，而不是伪装成 Windows 或混淆环境来源。
- 当前不再建议继续在 Docker / WSL / 当前 VMware 上死磕真正的 L3/memory 硬件计数器；它们要么被权限挡住，要么根本没暴露需要的 PMU/uncore。

## 3. 文件地图 (File Map)

```text
hw2/
├── Makefile                      # 三套构建目标：普通 benchmark / perf driver / gprof driver
├── run_perf.sh                   # 一键 perf 脚本；当前会在 VMware 上“继续跑”但得到 <not supported>
├── run_gprof.sh                  # perf 不可用时的热点兜底脚本
├── PERF_REPLAY.md                # 补跑 perf 的操作手册，含 WSL/Hyper-V/原生 Linux 的建议路径
├── Lab0_实验环境搭建.txt        # 课程环境说明；确认 Linux/WSL/VMware 都是课程允许的开发环境
├── Lab1_CPU架构编程.txt         # 实验要求；核心是算法实现 + 高精度计时，profiling 是重要但非唯一工具链
├── src/
│   ├── main.cpp                  # 主入口：写环境、跑矩阵实验、跑求和实验、跑内嵌 profile
│   ├── benchmark.hpp/.cpp        # 计时框架、绑核、perf_event_open 封装、do_not_optimize/clobber_memory
│   ├── matrix_experiment.hpp/.cpp# 矩阵列内积三版本：naive / row_major / row_major_unrolled4
│   ├── sum_experiment.hpp/.cpp   # 求和四版本：naive / superscalar2 / superscalar4 / pairwise
│   ├── perf_driver.cpp           # perf/gprof 共用 CLI 入口，支持按 workload 单独重复执行
│   ├── profile.hpp/.cpp          # 内嵌 perf_event_open profiling，导出 profile_results.csv
│   ├── environment.hpp/.cpp      # 自动记录 OS / kernel / compiler / cache / perf_event_paranoid
│   ├── data_utils.hpp/.cpp       # 固定公式生成测试向量/矩阵，保证复现和正确性对齐
│   └── fs_compat.hpp             # 兼容 GCC 7 的 filesystem / experimental::filesystem
├── report/
│   ├── main.tex                  # 实验报告主文件；当前叙述已过时，需重写环境和结论部分
│   ├── main.pdf                  # 旧版导出的 PDF，不应再视为当前真实状态
│   ├── reference.bib             # 参考文献
│   └── NKU.png                   # 报告封面图
└── results/
    ├── matrix_results.csv        # 主实验矩阵计时结果（当前 VMware Ubuntu 上已重新生成）
    ├── sum_results.csv           # 主实验求和计时结果（当前 VMware Ubuntu 上已重新生成）
    ├── assembly_excerpt.txt      # 目标函数的 objdump 摘要，用于汇编分析
    ├── environment.txt           # 最近一次 main benchmark 运行环境快照
    ├── profile_results.csv       # 内嵌 perf_event_open 结果；当前仍是 Permission denied 失败快照
    ├── perf_cli/                 # run_perf.sh 产物；stat 会产出 <notsupported>，record/report 只可作弱热点参考
    └── gprof_cli/                # run_gprof.sh 产物；当前是最稳的热点证据来源
```

## 4. 当前进度快照 (State Snapshot)

### ✅ 已完成功能

- 矩阵实验 3 个版本已经稳定实现并通过数值一致性校验：
  - `naive`
  - `row_major`
  - `row_major_unrolled4`
- 求和实验 4 个版本已经稳定实现并通过数值一致性校验：
  - `naive`
  - `superscalar2`
  - `superscalar4`
  - `pairwise`
- 主实验流程 `make clean all run asm` 可成功运行，并会自动生成：
  - `results/matrix_results.csv`
  - `results/sum_results.csv`
  - `results/assembly_excerpt.txt`
  - `results/environment.txt`
  - `results/profile_results.csv`
- 当前 VMware Ubuntu 上的主实验结果已经重跑完成。
  - 矩阵：`row_major`/`row_major_unrolled4` 明显优于 `naive`，`n=2048` 时约 `5.97x / 5.87x`
  - 求和：`superscalar4` 在小规模上优势明显，`n=1048576` 时约 `2.21x`；`pairwise` 在大规模下明显变慢
- `gprof` fallback 已落地且可用。
  - `matrix_row_major_unrolled4` 热点约 `97.89%`
  - `sum_superscalar4` 热点约 `99.64%`
- `run_perf.sh` / `run_gprof.sh` / `PERF_REPLAY.md` 已经补齐，能支持“补跑 profiling”这条工作流。
- 课程要求已重新核对：
  - Linux 环境是推荐主环境
  - WSL/VMware Ubuntu 都在课程环境文档中出现
  - Lab1 硬要求核心仍是“算法实现 + 高精度计时”
  - profiling 重要，但文档写法是 `VTune / perf / 其他 profiling 工具`，不是只认 perf

### 🚧 进行中任务 (WIP)

1. **profiling 章节还没真正闭环**
   - 目标是补完 Lab1 的 L3 / memory 相关分析。
   - 当前 VMware Ubuntu 中，`perf` 已不再被纯权限直接拒绝，但硬件事件本身仍不可用。

2. **当前 perf 的真实状态**
   - 主程序内嵌 `perf_event_open` 的结果在 `results/profile_results.csv` 中仍然是：
     - `perf_event_open failed: Permission denied`
   - 这是在 `perf_event_paranoid=4` 时跑出来的旧快照。
   - 后续手动将系统改成：
     - `kernel.perf_event_paranoid=1`
     - `kernel.kptr_restrict=0`
   - 再跑 `run_perf.sh` 后，脚本可以继续执行，但 `results/perf_cli/summary.csv` 里是：
     - `cycles = <notsupported>`
     - `instructions = <notsupported>`
     - `cache-references = <notsupported>`
     - `cache-misses = <notsupported>`
     - `ipc = -nan`
     - `miss_rate = -nan`
   - 样例原始输出见 `results/perf_cli/matrix_naive_n2048_r8_stat.csv`：
     - `<not supported>,,cycles`
     - `<not supported>,,instructions`
     - `<not supported>,,cache-references`
     - `<not supported>,,cache-misses`

3. **当前 VMware 虚拟 PMU 能力不足**
   - 内核看到的 PMU 名称是：
     - `pmu_name=generic_arch_v1`
   - 暴露出来的事件几乎只有：
     - `ref-cycles`
   - 没有看到真正想要的：
     - `LLC-loads`
     - `uncore_imc_*`
     - `uncore_cha_*`
   - 结论：当前 VMware Ubuntu 不是“命令写错”，而是 vPMU/uncore 根本不够。

4. **Hyper-V 备选方案目前也走不通**
   - 宿主机是 `Windows 10 Home China`。
   - 管理员 PowerShell 中：
     - `Get-VM` 不存在
     - `Get-VMHostSupportedVersion` 不存在
   - 说明不能按微软官方 `Hyper-V + Set-VMProcessor -Perfmon` 路线操作。
   - 换言之：当前宿主机无法低成本切 Hyper-V 来救 perf。

5. **报告正文和当前事实严重不一致**
   - `report/main.tex` 仍写着“真实 Ubuntu + AMD EPYC 7453 + g++ 7.5.0”的旧环境。
   - 当前实际可复现环境已经变成：
     - VMware Ubuntu 20.04.6
     - Kernel `5.15.0-139-generic`
     - CPU `13th Gen Intel(R) Core(TM) i9-13900H`
     - L3 `24576K`
   - 报告中的部分速度结论和 profiling 叙述也还是旧版本，不可直接提交。

### 🐛 已知 Bug / Hack / 坑

- `run_perf.sh` 的 probe 只检查 `perf stat` 的退出码，不检查输出值是否为 `<not supported>`。
  - 结果：在当前 VMware 上，脚本会“看起来成功跑完”，但 `summary.csv` 全是无效硬件计数。
- `results/environment.txt` / `results/profile_results.csv` 与 `results/perf_cli/*` 不是同一次系统状态下生成的。
  - 前者来自 `perf_event_paranoid=4` 时的主实验。
  - 后者来自后续手动把 paranoid 调成 `1` 后的单独 perf 补跑。
  - 写报告时必须明确区分，不然会自相矛盾。
- `perf_cli/*.data` 与 `*_report.txt` 已经生成，但它们只能当“弱热点证据”看待，不能当成拿到了真实 L3/memory 计数器。
- `report/main.tex` 目前是项目里最大的“假上下文源”，很容易误导新接手的人以为实验已经在 AMD 真机上完成。
- 宿主机是 `Windows 10 Home China`，所以不要再浪费时间尝试当前机器的 Hyper-V PowerShell 路线，除非先升级系统版本。
- Git 工作区当前是脏的，主要集中在 `results/` 目录下；接手时不要误把结果文件变化当成功能代码变化。

## 5. 下一步指令 (Next Actions)

### 接下来 1 小时内必须做的 3 件事

1. **先修 `run_perf.sh` 的假成功问题**
   - 在 probe 后增加“内容级失败检测”，只要发现 `<not supported>` / `<notsupported>` 就立刻报错退出。
   - 同时在错误提示里明确写出：当前 VMware vPMU 只暴露 `generic_arch_v1`，不应继续把 `summary.csv` 当有效硬件计数。

2. **重写 `report/main.tex` 的环境与 profiling 章节**
   - 把平台信息改成当前真实可复现状态。
   - 删掉旧的 AMD EPYC / 真机 / 旧结论。
   - 采用“Linux 主实验 + gprof/汇编 + 诚实说明 perf 受限”的叙述，不要伪装成已拿到 L3/memory 计数器。

3. **做最终策略收敛，不再继续无效折腾**
   - 如果目标是“本次作业合规提交”，立即转为：
     - 使用 `matrix_results.csv` / `sum_results.csv`
     - 使用 `gprof_cli/*_report.txt`
     - 使用 `assembly_excerpt.txt`
     - 在报告中诚实解释 VMware perf 受限
   - 如果目标是“无论如何补到真实 L3/memory 指标”，则必须换到：
     - 原生 Linux 宿主机
     - 或一台支持 Hyper-V 且非 Home 版的 Windows 主机
   - 当前这台机器不值得再投入更多排障时间。

---

## 附：当前最可信的事实基线

- 项目根目录：`/home/kyc/Desktop/parallel/hw2`
- 当前课程相关结论：
  - Linux 环境是推荐主环境
  - Lab1 核心硬要求是实现 + 高精度计时
  - profiling 很重要，但不强制只能用 perf
- 当前最可信结果来源：
  - `results/matrix_results.csv`
  - `results/sum_results.csv`
  - `results/assembly_excerpt.txt`
  - `results/gprof_cli/*`
- 当前不可信或需谨慎解释的来源：
  - `results/profile_results.csv`：旧权限失败快照
  - `results/perf_cli/summary.csv`：流程完成但硬件计数器无效
  - `report/main.tex` / `report/main.pdf`：环境叙述已过时
