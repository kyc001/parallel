# 协程技术调研交付说明

## 交付文件

- `slides.typ` / `slides.pdf`：Typst 版本 Slides（主交付物，16 页，5 模块结构）。
- `report.tex` / `report.pdf`：完整调研报告（12 页），补充 Slides 中放不下的背景、机制、实验说明和参考文献。
- `bench.py`、`bench.go`、`Bench.java`：Python / Go / Java 基准实验代码（每项 5 次重复）。
- `plot_results.py`、`fig/*.png`：实验图表生成脚本与图表（带误差线）。
- `results/coroutine_benchmark_20260525.md`：实测环境、命令和原始输出。
- `草稿.md`、`要求.md`：原始草稿与作业要求。

## 复现实验

```powershell
python bench.py all
go run bench.go
javac Bench.java
java -cp . Bench
```

图表生成：

```powershell
python plot_results.py
```

## 编译文档

```powershell
typst compile slides.typ slides.pdf
xelatex -interaction=nonstopmode -halt-on-error report.tex
bibtex report
xelatex -interaction=nonstopmode -halt-on-error report.tex
xelatex -interaction=nonstopmode -halt-on-error report.tex
```

## 实验口径

- I/O 密集实验使用 `sleep(0.1s)` 模拟大量等待中的请求，每项测试重复 5 次，报告均值和标准差。
- CPU 密集实验使用 `fib(25)`，用于说明协程不会自动加速计算。
- 切换开销实验在不同语言中的操作并不完全同构，只用于观察数量级。
- Python 内存为峰值工作集，Go 为 MemStats.Sys，Java 为 heap+nonHeap，跨语言对比仅作参考。
