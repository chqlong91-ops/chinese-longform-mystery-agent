# 中长篇悬疑小说创作 Agent

一个面向中文中篇与长篇悬疑小说的 Codex 工作区 Agent。它把故事种子推进为可验证、可恢复、状态一致的完整小说，并将案件设计、章节生产、长程连续性、整书审计与用户确认分成清晰的闭环。

- 当前版本：`0.5.0-beta`
- 成熟度：`product-grade-beta-candidate / bounded`
- 作者：`qianlong.chen`
- GitHub：[`chqlong91-ops/chinese-longform-mystery-agent`](https://github.com/chqlong91-ops/chinese-longform-mystery-agent)
- 运行环境：Codex + PowerShell 7+
- 许可证：`Apache-2.0`

## 已完成能力

- 真相优先的案件设计、线索公平性与嫌疑路径控制。
- 章节合同、场景规划、正文候选、审计、最小修复与确认。
- 全书生产地图、分批推进、跨幕与长程连续性审计。
- 唯一全稿装配、整书审计、选择性重审、终稿确认与恢复。
- 三级权限：常规可逆工作自主执行，内容确认才停，真正例外才授权。
- 唯一机器状态、原子事务、生成视图、Skill-aware 恢复与 fail-closed。
- 新项目初始化、状态驱动编排、跨项目隔离与低交互运行。

P04 的冻结验收为 `12/12 yes/evaluated`。验证范围包括一部 18 章完整深度试点，以及一个 12 章全书计划加 4 章正式切片的异质广度试点。详见 [阶段验收报告](docs/60-P04阶段验收报告与产品交接.md)。

## 这是什么

`0.5.0-beta` 同步按需装载、单主路由、连续执行与验证复用规则，补齐控制工作流，并声明外部 Skill 的兼容要求。已有用户见 [升级说明](docs/UPGRADING-0.5.0-beta.md)。本次增量检查独立于上述 P04 历史冻结验收。

这是一个 Codex 工作区 Agent 套件，不是脱离 Codex 独立运行的自动写小说程序。根目录 `AGENTS.md` 提供持续生效的项目规则；PowerShell 工具负责确定性的初始化、状态、事务和恢复；专业 Skill 负责悬疑设计、长篇治理与正文创作。

Codex 会在进入仓库时读取项目根目录的 `AGENTS.md`。相关机制见 [OpenAI 官方 AGENTS.md 文档](https://learn.chatgpt.com/docs/agent-configuration/agents-md)。

## 前置条件

1. Windows PowerShell 7.4 或更新版本。
2. Codex 桌面端、CLI 或 IDE 扩展。
3. 以下专业 Skill：
   - `craft-social-mystery`
   - `novel-project-strategy`
   - `novel-writing`

Skill 没有随仓库再分发，因为其来源与许可证需要单独确认。安装位置和检查方法见 [依赖说明](DEPENDENCIES.md)。本仓库自身采用 [Apache License 2.0](LICENSE)。

## 快速开始

克隆仓库后，在仓库根目录打开 Codex。先运行冒烟测试：

```powershell
pwsh -NoProfile -File .\tests\smoke.ps1
```

初始化一个新小说工作区：

```powershell
pwsh -NoProfile -File .\scripts\new-project.ps1 `
  -OutputRoot "D:\novel-workspaces" `
  -ProjectId "NOVEL-DEMO-001" `
  -DisplayName "示例悬疑小说" `
  -Slug "demo-mystery" `
  -Seed "一份不存在的社区维修记录改变了三个人的证词"
```

随后在生成的项目目录中打开 Codex，并输入：

```text
基于当前项目恢复入口，从故事种子开始建立案件设计方向。遵守三级权限机制：普通可逆步骤自主推进，只在创意方向或正文候选需要确认时停下。
```

只读查看编排器认为的唯一下一步：

```powershell
pwsh -NoProfile -File .\scripts\show-next-step.ps1 `
  -ProjectRoot "D:\novel-workspaces\demo-mystery"
```

## 三级权限

- 一级：已圈定项目内的最小读取、规划、研究、可逆候选修复、审计、状态维护及确认后的常规闭环，由 Agent 自主完成。
- 二级：创意方向、章节/正文候选、全书终稿需要用户确认。
- 三级：核心因果、责任人、决定性线索、幕结构、结局、protected source 覆盖、跨项目私人数据、外部发布与破坏性动作需要明确授权。

内部 permit、lease、hash 和 checkpoint 是审计机制，不得变成用户逐门审批。

## 仓库结构

- `AGENTS.md`：Codex 项目级运行规则。
- `docs/`：P01—P04 的协议、状态模型与验收报告。
- `templates/`：项目、案件、章节、审计、恢复和全书对象模板。
- `schemas/`：机器可读状态、事务、交互与项目注册表 Schema。
- `tools/`：确定性状态、恢复、初始化和编排核心。
- `scripts/`：面向使用者的入口脚本。
- `examples/`：不含正式小说载荷的结构示例。
- `tests/`：公开包冒烟与发布边界测试。
- `release-evidence/`：P04 冻结基线和发布范围说明。
- 当前发行范围：[v002 发布清单](release-evidence/PUBLIC-RELEASE-MANIFEST-v002.json)。

## 验证

```powershell
pwsh -NoProfile -File .\tools\validate-release.ps1
pwsh -NoProfile -File .\tests\smoke.ps1
```

GitHub Actions 会在 Windows runner 上运行同一组检查。

发布验证器的缺失文件、断链和版本不一致回归检查：`pwsh -NoProfile -File ./tests/release-validator.ps1`。

## 明确限制

- 不证明所有悬疑类型都已覆盖。
- 广度试点不是第二部完整小说。
- 不证明无人值守长期运行、商业出版质量或市场成功。
- 不包含任何试点小说正文、候选稿、formal 稿或私有项目状态。
- 不执行外部发布，也不替用户做三级创意或法律决定。

## 公开范围

本仓库公开 Agent 框架、协议、模板、确定性工具、非正文示例与验收摘要，不包含试点小说正文、候选稿、formal 稿或私有项目状态。验收文档会公开试点作品名称及少量机制级摘要，用于说明验证范围。

Apache-2.0 适用于本仓库发行内容。以后使用本 Agent 创建的独立小说项目及其正文不因使用本工具而自动纳入本仓库许可证；其发布与授权由对应项目权利人另行决定。

## 贡献、安全与支持

- 贡献方式见 [CONTRIBUTING.md](CONTRIBUTING.md)。
- 安全问题见 [SECURITY.md](SECURITY.md)。
- 使用问题见 [SUPPORT.md](SUPPORT.md)。
- 版本变化见 [CHANGELOG.md](CHANGELOG.md)。

## 许可证

Copyright (c) 2026 qianlong.chen。本仓库采用 [Apache License 2.0](LICENSE)，归属信息见 [NOTICE.md](NOTICE.md)。第三方 Skill 不包含在本许可证覆盖的发行内容中。
