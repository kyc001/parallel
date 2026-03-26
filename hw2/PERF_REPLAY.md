# Lab1 Perf 补跑操作手册

这份文档用于在一台支持 `perf` 硬件计数器的 Ubuntu 机器上，重新补跑 `hw2` 的 profiling 结果。

对应代码和脚本：

- perf 专用入口：[src/perf_driver.cpp](./src/perf_driver.cpp)
- 构建规则：[Makefile](./Makefile)
- 一键执行脚本：[run_perf.sh](./run_perf.sh)

---

## 1. 目标

执行完成后，你应该拿到这些结果：

- 汇总表：`results/perf_cli/summary.csv`
- 每组 `perf stat` 原始输出：`results/perf_cli/*_stat.csv`
- L1/LLC 统计：`results/perf_cli/*_l1.csv`、`*_llc.csv`
- 热点报告：`results/perf_cli/*_report.txt`
- `perf record` 二进制数据：`results/perf_cli/*.data`

后续写报告时，优先使用：

- `summary.csv` 中的 `ipc`、`miss_rate`
- `*_report.txt` 中的热点函数信息

---

## 2. 机器要求

最好满足以下条件：

- Ubuntu 本机，或支持 PMU 透传的虚拟机
- 不是 WSL2
- 不是默认屏蔽性能计数器的容器
- 有 `sudo` 权限

如果你是在虚拟机中执行，需要确认 VM 开启了 CPU performance counters / PMU。

---

## 3. 进入项目目录

```bash
cd /home/kyc/project/parallel/hw2
```

确认脚本存在：

```bash
ls -l run_perf.sh
```

---

## 4. 安装 perf

先更新软件源：

```bash
sudo apt update
```

安装常用工具：

```bash
sudo apt install -y linux-tools-common linux-tools-generic
```

再安装和当前内核匹配的版本：

```bash
sudo apt install -y linux-tools-$(uname -r)
```

验证：

```bash
perf --version
```

如果上面最后一条能输出版本号，说明安装成功。

---

## 5. 打开 perf 权限

先看当前设置：

```bash
cat /proc/sys/kernel/perf_event_paranoid
cat /proc/sys/kernel/kptr_restrict
```

临时放宽权限：

```bash
sudo sysctl -w kernel.perf_event_paranoid=1
sudo sysctl -w kernel.kptr_restrict=0
```

如果后面脚本仍提示硬件计数器不可用，再进一步放宽：

```bash
sudo sysctl -w kernel.perf_event_paranoid=-1
```

说明：

- `perf_event_paranoid=1`：通常已经足够给普通用户读大部分硬件事件
- `perf_event_paranoid=-1`：限制更少，排障时更稳

这些修改是临时的，重启后通常会恢复。

---

## 6. 赋予脚本执行权限

```bash
chmod +x run_perf.sh
```

---

## 7. 一键补跑

直接执行：

```bash
./run_perf.sh
```

脚本会自动完成这些事情：

1. 检查 `perf` 是否安装
2. 检查当前 `perf_event_paranoid`
3. 编译 `bin/lab1_perf`
4. 探测硬件计数器是否可用
5. 跑 7 组 `perf stat`
6. 跑 4 组 `perf record`
7. 生成 `results/perf_cli/summary.csv`

---

## 8. 成功后的检查方式

先看输出目录：

```bash
find results/perf_cli -maxdepth 1 -type f | sort
```

查看汇总表：

```bash
column -s, -t < results/perf_cli/summary.csv | less -S
```

如果系统没有 `column`：

```bash
cat results/perf_cli/summary.csv
```

查看热点报告：

```bash
sed -n '1,120p' results/perf_cli/matrix_naive_n2048_r4_report.txt
sed -n '1,120p' results/perf_cli/sum_superscalar4_n1048576_r2048_report.txt
```

---

## 9. 脚本默认测试的 workload

矩阵：

```text
matrix naive               n=2048 repeat=8
matrix row_major           n=2048 repeat=200
matrix row_major_unrolled4 n=2048 repeat=256
```

求和：

```text
sum naive        n=1048576 repeat=1024
sum superscalar2 n=1048576 repeat=2048
sum superscalar4 n=1048576 repeat=4096
sum pairwise     n=1048576 repeat=1024
```

这些重复次数是为了让 `perf` 统计时每组 workload 都有足够长的执行时间，减少波动。

---

## 10. 手动单独跑某一个算法

如果你只想补跑单项，不想执行整套脚本，可以这样做。

先编译：

```bash
make perf
```

列出可用算法：

```bash
./bin/lab1_perf list
```

### 10.1 只跑矩阵 naive

```bash
perf stat -r 5 \
  -e task-clock,cycles,instructions,cache-references,cache-misses,branch-misses \
  -- ./bin/lab1_perf matrix naive 2048 8
```

### 10.2 只跑矩阵 row_major_unrolled4

```bash
perf stat -r 5 \
  -e task-clock,cycles,instructions,cache-references,cache-misses,branch-misses \
  -- ./bin/lab1_perf matrix row_major_unrolled4 2048 256
```

### 10.3 只跑 sum naive

```bash
perf stat -r 5 \
  -e task-clock,cycles,instructions,cache-references,cache-misses,branch-misses \
  -- ./bin/lab1_perf sum naive 1048576 1024
```

### 10.4 只跑 sum superscalar4

```bash
perf stat -r 5 \
  -e task-clock,cycles,instructions,cache-references,cache-misses,branch-misses \
  -- ./bin/lab1_perf sum superscalar4 1048576 4096
```

### 10.5 看调用图 / 热点

```bash
perf record --call-graph fp -g \
  -- ./bin/lab1_perf sum superscalar4 1048576 2048

perf report --stdio
```

如果你想把结果存文件：

```bash
perf record --call-graph fp -g -o results/perf_cli/manual_sum_sp4.data \
  -- ./bin/lab1_perf sum superscalar4 1048576 2048

perf report --stdio -i results/perf_cli/manual_sum_sp4.data \
  > results/perf_cli/manual_sum_sp4_report.txt
```

---

## 11. 常见失败与处理

### 11.1 `perf: command not found`

说明没安装，回到第 4 节执行安装命令。

### 11.2 `No permission to enable cycles event`

说明权限不够，执行：

```bash
sudo sysctl -w kernel.perf_event_paranoid=1
sudo sysctl -w kernel.kptr_restrict=0
```

如果还不行：

```bash
sudo sysctl -w kernel.perf_event_paranoid=-1
```

### 11.3 `hardware counter probe failed`

说明脚本里的探测阶段失败了。常见原因：

- `perf_event_paranoid` 太高
- 虚拟机没开 PMU
- 容器环境屏蔽了硬件计数器
- 当前内核和 `perf` 工具版本不匹配

先试：

```bash
sudo apt install -y linux-tools-$(uname -r)
sudo sysctl -w kernel.perf_event_paranoid=-1
```

再重跑：

```bash
./run_perf.sh
```

### 11.4 `perf list` 有事件，但 `perf stat` 还是失败

这一般不是代码问题，而是运行环境没有真正开放 PMU。

优先检查：

- 是不是在 WSL2
- 是不是 Docker / LXC 容器
- 是不是云主机限制了 PMU
- 是不是虚拟机没有开启 CPU performance counters

---

## 12. 跑完后建议保存什么

最少保留这些文件：

```text
results/perf_cli/summary.csv
results/perf_cli/matrix_naive_n2048_r8_stat.csv
results/perf_cli/matrix_row_major_unrolled4_n2048_r256_stat.csv
results/perf_cli/sum_naive_n1048576_r1024_stat.csv
results/perf_cli/sum_superscalar4_n1048576_r4096_stat.csv
results/perf_cli/matrix_naive_n2048_r4_report.txt
results/perf_cli/sum_superscalar4_n1048576_r2048_report.txt
```

这样后面即使不重新跑，也足够写报告。

---

## 13. 如果你要把结果发回当前项目

在 Ubuntu 机器上执行完后，把整个目录带回来即可：

```bash
results/perf_cli/
```

如果你之后让我继续写报告，最好同时带回：

```text
results/perf_cli/summary.csv
results/perf_cli/*_report.txt
```

这样我可以直接帮你把 profiling 表格和分析段落补进报告。
