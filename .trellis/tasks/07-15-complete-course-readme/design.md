# README Information Design

## Document Boundary

本任务只重写根目录 `README.md`。README 是仓库入口，不替代各实验报告，因此正文提供足够具体的概览、关键数字和导航，深入推导与完整实验表格通过链接交给报告。

## Proposed Structure

1. 标题与仓库简介
2. 课程成绩概览
3. 课程内容与能力主线
4. ANN 选题简介
5. 各阶段实验
   - SIMD：Flat/SQ/PQ/FastScan 与跨平台向量化
   - Pthread/OpenMP：inter-query、intra-query、调度与图/倒排索引
   - MPI：owner-computes、局部 Top-k 与全局候选合并
   - GPU：batch GEMM、设备端 Top-k、IVF 与传输瓶颈
   - 期末：预算自适应、OPQ、异构协同和统一瓶颈分析
6. 代表性结果表
7. 仓库目录
8. 环境、数据与复现提示
9. 报告索引
10. 说明与许可

## Evidence Sources

- 课程选题定义：`参考模板/ANN选题介绍.pdf`、`ANN要求.md`
- 每阶段实际工作：对应目录下 `report/main.tex`、PDF、README、Makefile 和脚本
- 综合数字：`ann-final/report/main.tex` 及 `ann-final/report/results/`
- 构建边界：各实验 Makefile、PowerShell/Bash 脚本

## Presentation Choices

- 成绩使用单一紧凑表格，避免徽章堆叠。
- ANN 流水线使用简短文本流程图或分层列表，不嵌入新的二进制图片。
- 代表性结果以“方法、平台、Recall、延迟、意义”呈现，并明确这些点并非完全同召回比较。
- 目录表把“用途”和“主要内容”放在一起，减少读者反复跳转。
- 使用仓库相对链接，确保 GitHub 和本地 Markdown 预览均可导航。

## Compatibility And Risk

- 中文路径在 Markdown 链接中直接使用，验证文件实际存在。
- 不引用 `tmp/`、本地绝对路径或未跟踪文件。
- 不把参考模板、课程要求或第三方代码描述为个人原创。
- 性能结果只摘录报告中已有结论，避免重新计算或扩大结论范围。

## Rollback

改动仅限根 README，可通过恢复该单文件回滚；任务规划文件保留为 Trellis 记录。
