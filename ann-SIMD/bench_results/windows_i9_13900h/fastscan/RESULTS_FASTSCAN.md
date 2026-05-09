# PQ-FastScan 实验结果 (i9-13900H AVX2)

## 环境
- CPU: Intel i9-13900H, 8P+4E, Turbo 5.0 GHz
- ISA: AVX2 + FMA (no AVX-512)
- OS: Windows 11, MSYS2 MinGW-w64 g++ 14.2.0
- 编译: `-O2 -mavx2 -mfma -std=c++17`
- 绑核: PowerShell `$proc.ProcessorAffinity = [IntPtr]0xFFFF`
- 数据: DEEP100K (`N=100000`, `d=96`, IP), 2000 queries, `k=10`

## 配置
- `M=16`
- `Ks=16`，每子段 4-bit
- `dsub=6`
- codes 打包布局: `SoA [M/2][N/32][32] = 800000 bytes`
- LUT: `M x 16 uint8 = 256 bytes`

## 测量结果
| p | Recall@10 | Latency (us) |
|---|---:|---:|
| 40 | 0.51400 | 536.447 |
| 100 | 0.70075 | 529.995 |
| 500 | 0.93205 | 526.872 |
| 1000 | 0.97535 | 541.689 |
| 2000 | 0.99265 | 571.850 |
| 5000 | 0.99875 | 674.161 |

## 对比标准 PQ (同平台同环境)
| p | PQ-FastScan | 标准 PQ | 加速比 |
|---|---|---|---:|
| 500 | 526.9 us / 0.93205 | 838.2 us / 0.94595 | 1.59x |
| 1000 | 541.7 us / 0.97535 | 762.0 us / 0.98330 | 1.41x |
| 2000 | 571.9 us / 0.99265 | 1640.2 us / 0.99550 | 2.87x |
| 5000 | 674.2 us / 0.99875 | 3042.1 us / 0.99965 | 4.51x |

## 结论
1. `p=40` 到 `p=1000` 区间延迟基本稳定在 530-542 us，说明粗排成本近似常数。
2. `p` 增大后主要增加的是 rerank 成本，而不是 FastScan 粗排本身。
3. `p=5000` 时，FastScan 以 `0.99875` 的 Recall@10 将标准 PQ 的 `3042.1 us` 降到 `674.2 us`。
4. 相比 Flat-SIMD (`1756.11 us`)，FastScan 在近满召回下仍可达到约 `2.60x` 加速。
5. 小 `p` 区间标准 PQ 仍可能更快，因为 FastScan 的固定粗排开销更高。

## 复现
- 构建: `.\build_fastscan.ps1`
- 运行: `.\run_fastscan_pcore.ps1`
- 主程序: `main_win_fastscan.cc`
