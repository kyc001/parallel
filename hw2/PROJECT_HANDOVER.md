# PROJECT_HANDOVER

## 1. 项目简介

这是并行课程 `Lab1 CPU 架构编程` 的实验工程，当前已经从旧的 Linux/perf 路线切换为可直接提交的 `Windows + VTune` 工作流。代码主体仍是 C++17，实验目标不变：

- 矩阵列内积：比较 `naive`、`row_major`、`row_major_unrolled4`
- 数组求和：比较 `naive`、`superscalar2`、`superscalar4`、`pairwise`
- 产出计时结果、汇编证据、VTune 证据，并同步更新课程报告

当前可信环境基线：

- OS: `Windows 11 Home China 25H2`
- CPU: `13th Gen Intel(R) Core(TM) i9-13900H`
- Compiler: `g++ 14.2.0`
- VTune: `Intel VTune Profiler 2025.10`

## 2. 技术栈与关键决策

- `C++17 + STL`
  - 实验实现、计时框架、数据生成、环境导出都在 `src/` 下，便于统一维护。
- `g++ 14.2.0`
  - Windows 下用 `build_windows.ps1` 构建，保留 `-O3 -march=native -fno-tree-vectorize -fno-tree-slp-vectorize -g -fno-omit-frame-pointer`。
- `PowerShell`
  - 现在的标准构建与采样入口是 `build_windows.ps1` 和 `run_vtune_windows.ps1`。
- `Intel VTune CLI`
  - 现在所有 profiling 证据都来自 VTune，而不是 Linux perf。
- `LaTeX`
  - 报告仍在 `report/main.tex`，但正文已经改为 Windows + VTune 叙述，`main.pdf` 还需要重新编译确认。

关键决策：

- Windows 已经是当前项目的主实验平台，不再以 VMware / Linux perf 作为最终交付基线。
- `lab1_perf.exe` 和日志里的 `[perf-driver]` 只是历史命名，程序用途已经变成“给 VTune 驱动单个 workload 的 CLI 入口”，不是 Linux `perf`。
- Windows 下不再尝试 `perf_event_open` 读取硬件计数器，`results/profile_results.csv` 会明确写成 `external VTune collection required on Windows`，这是预期行为。
- VTune 导出的 `*_summary.csv` 和 `*_hotspots.csv` 是报告的首选证据；原始 `.vtune` 结果目录只是可再生中间产物。

## 3. 文件地图

```text
hw2/
├── build_windows.ps1                     # Windows 下标准构建脚本
├── run_vtune_windows.ps1                 # Windows 下标准 VTune 采样与导出脚本
├── PERF_REPLAY.md                        # 旧 perf 补跑说明，可保留参考，但不再是主流程
├── PROJECT_HANDOVER.md                   # 当前交接文档
├── src/
│   ├── main.cpp                          # 主 benchmark 入口
│   ├── perf_driver.cpp                   # workload CLI；VTune 实际采样的目标程序入口
│   ├── benchmark.hpp/.cpp                # 计时框架、绑核、Windows/Linux 兼容 profile 包装
│   ├── compiler_compat.hpp               # Windows/GCC/MSVC 兼容宏
│   ├── environment.hpp/.cpp              # 环境导出，Windows 下会写明 VTune 工作流
│   ├── matrix_experiment.hpp/.cpp        # 矩阵实验
│   ├── sum_experiment.hpp/.cpp           # 求和实验
│   ├── profile.hpp/.cpp                  # profile_results.csv 导出逻辑
│   ├── data_utils.hpp/.cpp               # 数据生成与校验
│   └── fs_compat.hpp                     # filesystem 兼容层
├── report/
│   ├── main.tex                          # 报告主文件，已按 Windows + VTune 改写
│   ├── main.pdf                          # 旧 PDF，需要重新编译覆盖
│   ├── reference.bib
│   └── NKU.png
└── results/
    ├── environment.txt                   # 最近一次 Windows 主实验环境快照
    ├── matrix_results.csv                # Windows 重跑后的矩阵计时结果
    ├── sum_results.csv                   # Windows 重跑后的求和计时结果
    ├── assembly_excerpt.txt              # Windows objdump 汇编摘录
    ├── profile_results.csv               # Windows 下占位提示：改用外部 VTune
    └── vtune_cli/
        ├── sampling_driver_check.txt     # amplxe-sepreg -c 检查结果
        ├── sampling_driver_status.txt    # amplxe-sepreg -s 输出
        ├── *_summary.csv                 # 报告中使用的 VTune 汇总指标
        ├── *_hotspots.csv                # 报告中使用的 VTune 热点导出
        └── <raw result dirs>             # VTune 原始数据库，可删可重跑
```

## 4. 当前进度快照

### 已完成

- Windows 兼容性已经补齐：
  - 绑核逻辑支持 WinAPI
  - `do_not_optimize` / `clobber_memory` 做了跨平台处理
  - 环境导出改为 Windows 识别
  - Windows 下内嵌 profiling 明确改成“外部 VTune 采样”
- Windows 构建脚本可直接产出：
  - `bin/lab1_benchmark.exe`
  - `bin/lab1_perf.exe`
- 主实验已经在 Windows 下重跑，当前结果文件为：
  - `results/matrix_results.csv`
  - `results/sum_results.csv`
- 当前矩阵实验最重要的结论：
  - `n=2048` 时，`row_major` 相比 `naive` 约 `20.09x`
  - `n=2048` 时，`row_major_unrolled4` 相比 `naive` 约 `22.41x`
- 当前求和实验最重要的结论：
  - `superscalar4` 全程优于 `naive`
  - `n=1048576` 时，`superscalar4` 相比 `naive` 约 `1.93x`
  - `pairwise` 在大规模输入下明显更慢
- VTune 采样已完成并导出可用 CSV：
  - `matrix_naive_memory_access_*`
  - `matrix_row_major_unrolled4_memory_access_*`
  - `sum_naive_uarch_*`
  - `sum_superscalar4_uarch_*`

### 当前最可信的 VTune 结论

- 矩阵 `naive`:
  - P-core `Memory Bound = 76.3%`
  - `DRAM Bound = 77.7%`
  - `LLC Miss Count = 29712474`
- 矩阵 `row_major_unrolled4`:
  - P-core `Memory Bound = 36.4%`
  - `DRAM Bound = 21.6%`
  - `LLC Miss Count = 13755775`
  - 说明访存顺序优化后，主瓶颈显著减轻
- 求和 `naive`:
  - `CPI = 0.830803`
  - `IPC ≈ 1.204`
  - `Retiring = 14.5%`
  - `Back-End Bound = 81.8%`
- 求和 `superscalar4`:
  - `CPI = 0.540861`
  - `IPC ≈ 1.849`
  - `Retiring = 27.9%`
  - `Back-End Bound = 75.6%`
  - 说明四路累加确实提升了指令级并行性

### 当前仍待收尾

- `report/main.tex` 已经改成 Windows + VTune 版本，但 `report/main.pdf` 还没有重新编译和视觉检查。
- 报告最后一页的“实验过程与踩坑记录”已经整理思路，后面可以直接往正文吸收。

## 5. 已知坑与解释

- `[perf-driver] affinity_pinned=yes cpu=0` 不是 Linux perf 在工作。
  - 这是 `src/perf_driver.cpp` 的历史日志前缀，当前只是 VTune 调起的 workload 驱动程序名没改。
- `lab1_perf.exe` 这个文件名也只是历史遗留。
  - 现在它真正的角色是“让 VTune 按算法/规模单独采样”的命令行入口。
- `vtune: Warning: Cannot locate debugging information for ... ntoskrnl.exe / ntdll.dll / *.sys`
  - 这通常只是 Windows 内核模块缺少 PDB。
  - 对我们分析自家用户态函数、比较 Memory Bound / CPI / IPC 这类报告结论影响不大。
- 目前没有证据表明必须重启电脑。
  - `sampling_driver_check.txt` 已确认 `sepdrv5`、`sepdal`、`vtss` 服务都在运行。
  - 只有在 VTune 后续无法启动采样、驱动状态变成 stopped，或者系统更新后驱动失效时，才值得优先尝试重启。
- `sum_naive_uarch` 和 `sum_superscalar4_uarch` 的 repeat 不同。
  - 报告里比较这两组时，应优先使用 `CPI / IPC / Top-down 百分比`，不要直接比较绝对 `Instructions Retired`。
- `sum_superscalar4_uarch_samework*` 是一次无效尝试。
  - 当时为了强行做 same-work 采样把 workload 缩得太短，结果指标不稳定，不能用于正文结论。
- `results/profile_results.csv` 中的 0 值不是实验失败。
  - 这是 Windows 工作流下的占位文件，已经明确写了 `external VTune collection required on Windows`。

## 6. 接下来建议怎么做

1. 先重新编译报告。
   - 进入 `hw2/report/`
   - 用 `xelatex main.tex`，如有参考文献再补 `bibtex main` 和后续两次 `xelatex`
2. 报告正文优先引用这些文件：
   - `results/matrix_results.csv`
   - `results/sum_results.csv`
   - `results/assembly_excerpt.txt`
   - `results/vtune_cli/*_summary.csv`
   - `results/vtune_cli/*_hotspots.csv`
3. 如果需要重跑 VTune：
   - 用管理员 PowerShell 运行 `run_vtune_windows.ps1`
   - 先删旧的目标结果目录，再重新采样，避免把旧结果和新结果混在一起
4. 如果后面只想保留可提交证据：
   - 保留导出的 CSV 和 `sampling_driver_*.txt`
   - VTune 原始结果目录可以删除，因为脚本能重建

## 7. 最可信的结果基线

- 环境基线：`results/environment.txt`
- 计时基线：`results/matrix_results.csv`、`results/sum_results.csv`
- 汇编基线：`results/assembly_excerpt.txt`
- Profiling 基线：
  - `results/vtune_cli/matrix_naive_memory_access_summary.csv`
  - `results/vtune_cli/matrix_row_major_unrolled4_memory_access_summary.csv`
  - `results/vtune_cli/sum_naive_uarch_summary.csv`
  - `results/vtune_cli/sum_superscalar4_uarch_summary.csv`
- 需要忽略或直接删除的失败产物：
  - `results/vtune_cli/sum_superscalar4_uarch_samework/`
  - `results/vtune_cli/sum_superscalar4_uarch_samework_summary.csv`
  - `results/vtune_cli/sum_superscalar4_uarch_samework_hotspots.csv`
