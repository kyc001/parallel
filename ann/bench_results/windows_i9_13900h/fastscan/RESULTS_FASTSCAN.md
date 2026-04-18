# PQ-FastScan 实验结果 (i9-13900H AVX2)

## 环境
- CPU: Intel i9-13900H, 8P+4E, Turbo 5.0 GHz
- ISA: AVX2 + FMA (no AVX-512)
- OS: Windows 11, MSYS2 MinGW-w64 g++ 14.2.0
- 编译: `-O2 -mavx2 -mfma -std=c++17`
- 绑核: PowerShell `$proc.ProcessorAffinity = [IntPtr]0xFFFF`
- 数据: DEEP100K (N=100000, d=96, IP), 2000 queries, k=10

## 配置
- M=16 (子段数), Ks=16 (每段码本 4-bit), dsub=6
- Codes 打包: SoA [M/2][N/32][32] = 800000 bytes (vs 标准 PQ 800000 bytes, 字节数相同但粒度 4-bit)
- LUT: M × 16 uint8 = 256 bytes (vs 标准 PQ 的 M × 256 × float32 = 8192 bytes)

## 测量
| p | Recall@10 | Latency (μs) |
|---|---|---|
| 40 | 0.514 | 536.489 |
| 100 | 0.70075 | 535.689 |
| 500 | 0.93205 | 535.701 |
| 1000 | 0.97535 | 537.298 |
| 2000 | 0.99265 | 574.602 |
| 5000 | 0.99875 | 684.497 |

## vs 标准 PQ (i9 AVX2, 同环境)
| p | PQ-FastScan | 标准 PQ | 加速 |
|---|---|---|---|
| 500 | 535.7 / 0.932 | 838.2 / 0.946 | 1.56× |
| 1000 | 537.3 / 0.975 | 762.0 / 0.983 | 1.42× |
| 2000 | 574.6 / 0.993 | 1640.2 / 0.996 | **2.85×** |
| 5000 | 684.5 / 0.999 | 3042.1 / 0.99965 | **4.44×** |

## 关键结论
1. 粗排 latency 几乎恒定 ~535 μs (p=40→p=1000 变化 <0.5%), O(p) 增长全部来自精排 rerank
2. 曲线从标准 PQ 的线性 latency-vs-p 变为 L 型, 算法复杂度质变
3. FastScan p=5000 (684 μs, recall=0.999) 比 flat-SIMD (1756 μs) 快 2.57×
4. 小 p 区间 (p≤100) 标准 PQ 仍更快, 因 FastScan 基础成本固定 535 μs

## 复现
- 新增文件: pq_fastscan_avx2.h, main_win_fastscan.cc
- 未修改任何已有 main/header, 原 20 组基准完全保留
- 构建: `.\build_fastscan.ps1`
- 运行: `.\run_fastscan_pcore.ps1`