# Implement: 协程技术调研深度重构

## 执行计划

### Phase 1: 实验改进 (先做实验，因为数据是报告的基础)

- [x] 1.1 修改 `bench.py`：每个测试跑 5 次，输出 mean ± std
- [x] 1.2 修改 `bench.go`：每个测试跑 5 次 + `runtime.ReadMemStats` 内存采样
- [x] 1.3 修改 `Bench.java`：每个测试跑 5 次 + `MemoryMXBean` 内存采样
- [x] 1.4 本机运行三语言 benchmark，收集新数据到 `results/`
- [x] 1.5 更新 `results/coroutine_benchmark_20260525.md`

### Phase 2: 图表生成

- [x] 2.1 重写 `plot_results.py`：误差线 + 三语言内存 + 样式美化
- [x] 2.2 运行 `plot_results.py` 生成新图表到 `fig/`
- [ ] 2.3 绘制技术示意图（并发演进、状态机编译、GMP 调度、三层协同）— 未做，slides 中用文字和表格替代

### Phase 3: Slides 重构

- [x] 3.1 重写 `slides.typ`：按 5 模块结构重组
- [x] 3.2 嵌入新图表
- [x] 3.3 精炼文字，16 页
- [x] 3.4 编译 `slides.pdf` 验证

### Phase 4: Report 重构

- [x] 4.1 重写 `report.tex`：按新结构重组
- [x] 4.2 补充技术深度（底层机制分析）
- [x] 4.3 添加"实验局限性"章节
- [x] 4.4 补充参考文献至 24 条
- [x] 4.5 编译 `report.pdf` 验证

### Phase 5: 清理

- [x] 5.1 删除 `main.tex` 及其编译产物
- [x] 5.2 更新 `README.md`
- [x] 5.3 Git commit 存档（3 次 commit）
