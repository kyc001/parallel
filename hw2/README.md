# Lab1: CPU 架构编程实验

## 实验内容

本实验研究 CPU 架构特性（Cache 局部性、超标量执行）对程序性能的影响，包含两个问题：

### 1. 矩阵列内积（Cache 局部性）

- **平凡算法**：逐列访问，跨步 $n$ 跳转，Cache 命中率低
- **优化算法**：行优先访问 + 4路循环展开

### 2. 浮点数组求和（超标量/ILP）

- **链式累加**：单条依赖链，CPU 并行能力无法发挥
- **超标量优化**：2路/4路独立累加，拆分为多条独立依赖链
- **两两归约**：递归两两相加

## 项目结构

```
hw2/
├── src/               # 源代码
│   ├── matrix_experiment.cpp   # 矩阵实验实现
│   ├── sum_experiment.cpp      # 求和实验实现
│   └── ...
├── bin/               # 编译产物
├── results/           # 实验结果
│   ├── matrix_results.csv      # 矩阵计时数据
│   ├── sum_results.csv        # 求和计时数据
│   ├── vtune_cli/             # VTune Profiling 数据
│   └── assembly_excerpt.txt   # 汇编片段
├── report/            # 实验报告
├── Makefile          # 编译脚本
└── run_vtune_windows.ps1  # VTune 采样脚本
```

## 编译与运行

### 编译

```bash
cd hw2
make
```

### 运行计时实验

```bash
make run
# 或直接运行
./bin/lab1_benchmark
```

结果输出到 `results/matrix_results.csv` 和 `results/sum_results.csv`。

### 生成汇编

```bash
make asm
```

### VTune Profiling（Windows）

```powershell
.\run_vtune_windows.ps1
```

结果保存在 `results/vtune_cli/`。

## 编译选项

- `-O3`：最高优化级别
- `-march=native`：利用目标平台特性
- `-fno-tree-vectorize`：关闭自动向量化，隔离 Cache/ILP 效应

## 实验结果

| 问题 | 优化方法 | 最高加速比 |
|-----|---------|-----------|
| 矩阵 (n=2048) | 行优先+4路展开 | 22.41x |
| 求和 (n=4096) | 四路独立累加 | 3.81x |

详见 `report/main.pdf`。

## 依赖

- g++ 9+
- Intel VTune Profiler（可选，用于性能分析）
- Windows 10/11 或 Linux