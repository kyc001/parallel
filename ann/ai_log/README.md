# AI 辅助开发对话记录

本目录存放本次 ANN SIMD 实验中使用生成式 AI 工具（Claude 4.7 Opus /
腾讯元宝 / Kimi 等）的关键对话片段，作为报告附录 A 的外部物证。

撰写原则与实验指导书 2.4 节``将对话记录作为报告附录提交''对应；所有
对话均按"用户主导提出具体技术方向 $\to$ AI 完善实现/细节"的学习模式组织，
体现自主设计与改进过程。

## 目录

| 文件 | 主题 | 对应报告节 |
|------|------|-----------|
| 01_fastscan_shuffle_selection.md | FastScan shuffle vs gather 路线选型 | 3.5, 4.7 |
| 02_soa_blocking_boundary.md | SoA + blocking 作用域边界讨论 | 3.4, 4.6 |
| 03_vtune_pcore_binding.md | VTune Flat-AVX2 频率异常的定位 | 4.5, 4.8 |
| 04_scale_sweep_design.md | 规模实验 per-N GT 设计 | 4.3 |
| 05_gather_vs_shuffle_verification.md | Gather vs Shuffle 实测验证方案 | 4.6 |

每份文件包含：
- 用户原始提问（含观察、判断、方向）
- AI 回复要点（已脱敏与摘录）
- 实际落地后的决策与结果

## 访问方式

这些 Markdown 文件随仓库一同通过 Git 提交。未以 PDF/截图形式内嵌进
报告正文，主要原因：(a) 保持文本可读、可搜索；(b) 避免大幅增加报告
PDF 体积；(c) 便于助教按主题抽检。
