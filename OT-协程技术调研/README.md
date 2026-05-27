# 协程技术调研交付说明

## 交付文件

- `main.tex` / `main.pdf`：LaTeX Beamer 版本 Slides，适合课堂展示。
- `slides.typ` / `slides.pdf`：Typst 版本 Slides，与 LaTeX 版保持同一内容口径。
- `report.tex` / `report.pdf`：完整调研报告，补充 Slides 中放不下的背景、机制、实验说明和参考文献。
- `bench.py`、`bench.go`、`Bench.java`：Python / Go / Java 基准实验代码。
- `plot_results.py`、`fig/*.png`：实验图表生成脚本与图表。
- `results/coroutine_benchmark_20260525.md`：本次实测环境、命令和原始输出。
- `草稿.md`、`要求.md`：原始草稿与作业要求。

## 复现实验

```powershell
python bench.py all
go run bench.go
& 'D:\jdk\bin\javac.exe' Bench.java
& 'D:\jdk\bin\java.exe' Bench
```

图表生成使用已有的 `test` 环境：

```powershell
micromamba run -n test python plot_results.py
```

## 编译文档

```powershell
xelatex -interaction=nonstopmode -halt-on-error main.tex
typst compile slides.typ slides.pdf
xelatex -interaction=nonstopmode -halt-on-error report.tex
bibtex report
xelatex -interaction=nonstopmode -halt-on-error report.tex
xelatex -interaction=nonstopmode -halt-on-error report.tex
```

## 实验口径

- I/O 密集实验使用 `sleep(0.1s)` 模拟大量等待中的请求，主要比较调度和等待管理成本。
- CPU 密集实验使用 `fib(25)`，用于说明协程不会自动加速计算。
- 切换开销实验在不同语言中的操作并不完全同构，只用于观察数量级。
- Python 内存图是 benchmark 期间峰值工作集采样值；跨语言峰值 RSS/工作集未统一采样，因此不作为严格内存排名依据。
