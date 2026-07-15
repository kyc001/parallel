# Implementation Plan

## Checklist

- [x] 确认 README 语言策略并关闭 PRD open question。
- [x] 加载 `trellis-before-dev` 和适用的项目规范。
- [x] 激活 Trellis 任务进入实现阶段。
- [x] 依据报告证据重写根目录 `README.md`。
- [x] 检查全部相对链接对应的文件或目录存在。
- [x] 核对成绩总分与 README 中所有代表性性能数字。
- [x] 运行 Markdown 静态检查、敏感信息扫描和 `git diff --check`。
- [x] 使用 `trellis-check` 完成质量门禁并审阅最终 diff。

## Verification Result

- 65 个 README 相对链接全部存在。
- 成绩复算为 96/100，关键性能数字已与 `ann-final/report/main.tex` 对照。
- 标题层级、4 个表格、3 组 fenced code block、空白和敏感信息检查通过。
- `git diff --check` 通过。
- 本机未安装 `markdownlint-cli2`，因此未引入新依赖；使用上述仓库内静态检查替代。

## Validation Commands

```powershell
git diff --check
rg -n "TBD|TODO|D:\\\\|ssh -J|password|密码" README.md
git diff -- README.md
```

另用 PowerShell 提取 README 中的相对链接，逐一以仓库根目录为基准验证目标存在。

## Risky Areas

- 不同报告使用 Recall@10 与 Recall@100，摘录时必须保留指标下标。
- 各平台延迟并非完全相同参数和召回率，不能做无条件速度排名。
- 中文目录链接需要验证 Markdown URL 处理。
- `files/` 中包含数据集文件，README 不应暗示数据可自由再分发。

## Review Gate Before Start

- PRD、design 和 implement 文档齐全。
- 用户确认 README 语言策略并批准进入实现。
- 关键数据均已有仓库内证据来源。
