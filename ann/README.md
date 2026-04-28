# ANN-SIMD: Parallel Computing Lab 2

并行程序设计 Lab2 的 SIMD 选题（ANN 近似最近邻搜索）。在 ARM NEON 平台上实现并对比四种检索算法，使用 DEEP100K 数据集测试。

## 最终提交入口

`main.cc` 已整理为最终提交版：PQ-FastScan（4-bit PQ + 寄存器内查表），默认 `p=1000`，可直接通过实验要求的脚本运行：

```bash
bash test.sh 1 1
```

`test.sh` 内部会编译 `main.cc` 并提交作业，因此提交时不需要切换其他入口文件。其余 `main_*.cc` 保留为实验对照版本。

## 算法与加速比（鲲鹏 920 实测）

| 版本 | Recall | Latency (μs) | 加速比 |
|---|---:|---:|---:|
| 串行 Flat (Baseline) | 0.99995 | 16120.74 | 1.00x |
| Flat-SIMD | 0.99995 | 5821.16 | 2.77x |
| SQ-SIMD (p=100) | 0.99995 | 2422.68 | 6.65x |
| PQ-SIMD (p=100) | 0.70930 | 1224.20 | 13.17x |
| PQ-FastScan (p=1000) | 0.975253 | 1339.75 | 12.03x |

详细 p 值曲线见 `bench_results/kunpeng_server/`。

- Windows i9-13900H AVX2: [RESULTS.md](bench_results/windows_i9_13900h/RESULTS.md)

## 目录结构

```text
ann/
├── main.cc                 # 最终提交入口：PQ-FastScan, p=1000, data_path="/anndata/"
├── main_baseline.cc / main_flatsimd.cc / main_sqsimd.cc / main_pqsimd.cc
│   实验对照版本，所有版本的 data_path 都是 "/anndata/"
├── main_fastscan_submit.cc # 与 main.cc 同口径的 FastScan 提交备份
├── flat_scan.h           # 原始串行 IP 距离
├── flat_scan_simd.h      # Flat-SIMD (NEON 4 路展开 + 4 累加器)
├── sq_scan_simd.h        # SQ-SIMD (uint8 量化 + 两阶段检索)
├── pq_scan_simd.h        # PQ-SIMD (乘积量化 M=8 + ADC 查表)
├── analysis/             # 汇编分析与性能剖析脚本
├── benchmarks/           # E1 对齐 / E2 prefetch / E3 规模实验
├── bench_results/
│   ├── android_termux_proot_ubuntu/   # 平板（已弃用，保留历史数据）
│   └── kunpeng_server/                # 主数据来源
├── local_results/termux_arm64/        # 平板汇编分析历史产物
├── hnswlib/              # HNSW 库
├── run_all.sh            # 依次跑 4 版本的脚本
├── qsub.sh / test.sh     # 服务器提交脚本
└── README.md
```

## 提交测试（鲲鹏 920）

```bash
bash test.sh 1 1              # 参数：选题序号=1 (ANN)，节点数=1
```

最终提交版：

```bash
bash test.sh 1 1
```

对照实验如需复跑，可手动切换入口：

```bash
cp main_baseline.cc main.cc && bash test.sh 1 1
cp main_flatsimd.cc main.cc && bash test.sh 1 1
cp main_sqsimd.cc main.cc && bash test.sh 1 1
cp main_pqsimd.cc main.cc && bash test.sh 1 1
cp main_fastscan_submit.cc main.cc && bash test.sh 1 1
```

## 核心优化要点

- Flat-SIMD：NEON `vmlaq_f32` + 4 路循环展开 + 4 独立累加器，消除流水线气泡。
- SQ-SIMD：float32 到 uint8 量化，粗排用 `vabdq_u8` + `vmull_u8` + `vpadalq_u16`，精排用 float32 IP。
- PQ-SIMD：M=8 乘积量化（48x 内存压缩），ADC 查表累加。

## 开发环境

- 日常开发：Windows（i9-13900H，AVX2，仅用于代码编辑 / git）。
- 主测试：鲲鹏 920 服务器（通过 ssh -J 跳板机提交）。
- 历史测试：Android 平板 Termux + PRoot Ubuntu（已弃用）。
- 待启用：x86 3090 服务器（AVX-512 + perf + VTune 进阶实验）。

## 数据集

DEEP100K（96 维 float32，100K 向量，IP 距离）。
服务器固定路径 `/anndata/`，本地不保存数据文件。

## 致谢

- `hnswlib/` 来自 nmslib/hnswlib。
- DEEP100K 数据集来自 Babenko & Lempitsky (CVPR 2016)。
