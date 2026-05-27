# Design: 协程技术调研深度重构

## 交付物结构

### Slides (`slides.typ`) — 15-19 页

```
Module 1: 为什么需要协程 (2-3 页)
├── 并发演进时间线图 (新)
├── 四种并发模型对比表 (已有，精炼)
└── 核心问题：协程解决的是"等待方式"

Module 2: 协程是什么 (3-4 页)
├── 定义与心智模型
├── 有栈 vs 无栈 (合并原 #4 和 #6)
├── 无栈协程编译流程图 (新)
└── 有栈协程上下文切换 (已有汇编，保留)

Module 3: 语言怎么支持 (4-5 页)
├── 总览表 (已有，精炼为一张)
├── 有栈组：Go GMP + Java Virtual Thread (合并)
├── 无栈组：C++20 / Python / C# / Rust (合并)
├── GMP 调度器架构图 (新)
└── 三层协同图 (已有 Mermaid，保留)

Module 4: 实验验证 (4-5 页)
├── 实验设计 (精简为 1 页)
├── I/O 密集结果 (表格 + 图，带误差线)
├── CPU 密集 + 切换开销 (合并为 1 页)
├── 内存对比 (扩展到三语言)
└── 实验洞察 (精简)

Module 5: 总结与选型 (2 页)
├── 选型决策树 (已有 Mermaid)
└── 关键洞察 + AI 使用说明
```

### Report (`report.tex`) — 结构与 slides 对齐

```
1. 摘要
2. 并发执行机制为何演进到协程
3. 协程的定义、分类与底层机制
   3.1 有栈协程与无栈协程
   3.2 无栈协程：编译器生成状态机
   3.3 有栈协程：用户态上下文切换
4. 主流语言支持对比
   4.1 有栈协程语言：Go、Java 21
   4.2 无栈协程语言：C++20、Python、C#、Rust
   4.3 运行时与操作系统的协同
5. 实验设计与结果
   5.1 实验环境与方法
   5.2 I/O 密集型结果
   5.3 CPU 密集型与切换开销
   5.4 内存对比
   5.5 实验局限性 (新增)
6. 选型建议与总结
7. AI 使用说明
8. 参考文献
```

## 实验改进方案

### bench.py 改动
- 每个测试跑 `N_REPEAT=5` 次，返回 `mean ± std`
- 保持 `MemorySampler` 不变
- 输出格式：`[asyncio I/O]     0.601±0.012s  peak WS: 15.0±0.5MB`

### bench.go 改动
- 每个测试跑 5 次
- 添加内存采样：`runtime.ReadMemStats(&memStats)` 记录 `Sys` 字段

### Bench.java 改动
- 每个测试跑 5 次
- 添加内存采样：`MemoryMXBean` 记录 `HeapMemoryUsage` + `NonHeapMemoryUsage`

### plot_results.py 改动
- 柱状图添加 `yerr` 误差线
- 内存图扩展到三语言（Python peak WS、Go Sys、Java total）
- 图表样式统一美化

## 技术示意图方案

在 `slides.typ` 中使用 Typst 的 `cetz` 或 `fletcher` 库绘制：
1. 并发演进时间线 — 简洁的横向箭头 + 标注
2. 无栈协程编译流程 — 源码 → 编译器 → frame + state machine
3. Go GMP 调度器 — G/P/M 三元素关系图
4. 三层协同 — 编译器/运行时/OS 垂直堆叠

如果 Typst 绘图库不够灵活，fallback 到 Mermaid 图嵌入。

## 参考文献补充

需要补充的关键引用：
- Go scheduler: GMP paper 或官方设计文档
- Java Loom: JEP 444 已有，补充 Ron Pressler 的设计邮件
- C# async: Eric Lippert 的系列博文
- Rust async: withoutboats 的 blog
- 通用: "A Unified Theory of Cooperative Task Management" (如果存在)
