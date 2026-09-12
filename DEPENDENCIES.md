# 依赖说明

## 必需运行环境

- Codex 桌面端、CLI 或 IDE 扩展。
- PowerShell 7.4+。
- 支持 SHA-256、严格 UTF-8、JSON 与 `Test-Json` 的 Windows 环境。

## 专业 Skill

完整创作闭环依赖：

- `craft-social-mystery`：案件因果、线索公平性、嫌疑与揭示。
- `novel-project-strategy`：长篇工作区、状态、稿件层、同步与恢复。
- `novel-writing`：章节结构、正文、人物、场景与文风。

本仓库没有再分发这些 Skill。原因是发布前尚未确认它们各自的来源与许可证。请在 Codex 中使用 `/skills` 或 `$` 检查是否可用。

Codex 支持从仓库根目录的 `.agents/skills` 装载仓库级 Skill，也支持用户级和系统级 Skill。官方说明见 [Build skills](https://learn.chatgpt.com/docs/build-skills)。

如果 Skill 缺失：

- 项目初始化、Schema、确定性状态与恢复工具仍可运行。
- Agent 必须披露缺失依赖。
- 不得把未执行的专业创作审计标记为通过。

## 0.5.0-beta 兼容要求

外部 Skill 没有统一的语义版本号。本版本以以下行为要求作为兼容下限，以 [参考快照](release-evidence/EXTERNAL-SKILLS-REFERENCE-v001.json) 记录核对过的 Markdown 文件 SHA-256。指纹相同只证明文件相同；指纹不同应复核行为要求，不能直接宣称兼容或不兼容。快照不包含 Skill 内容，也不授予再分发许可。

- `craft-social-mystery`：具备 Construct / Transform / Audit / Repair / Abstract 路由；局部请求只执行所需路由；完整案件、多章生产及改变决定性事实的修复读取 `references/production-gates.md`；正文交接读取 `references/prose-handoff.md`。
- `novel-project-strategy`：独立管理稿件层、工作、确认、同步、风险与恢复；新版本按变化范围失效和重验；项目状态以项目文件为准。
- `novel-writing`：按章节和场景组织正文，检查人物首登、文风和现实约束；将候选稿交回项目工作流处理确认与晋升。

悬疑 Skill 的五个独立状态为 `design-plausible`、`creative-confirmed`、`evidence-ready`、`manuscript-realized`、`final-audited`。其生产参考包含六道检查：设计成立、证据就绪、正文实现、幕边界连续性、修复差量和完整终审。六道检查不是六个状态；用户创意确认独立记录，幕边界及修复检查由项目工作流调度和留证。

本 Agent 对 `manuscript-realized` 的授予遵守 [控制工作流](docs/CONTROL-WORKFLOW.md)：候选可以审读，只有 current formal 的实际位置证据才可授予 yes。整书终审仍需完整 current ASM。

开始专业创作前核对所需 Skill 主文件及按其路由必读的传递资源。缺失或不满足上述要求时披露具体缺口，暂停依赖该能力的创作门禁；确定性初始化和状态工具仍可使用。

## 无需的依赖

当前公开核心不需要数据库、Node.js、Python 包、云服务或 OpenAI API key。它依赖用户已有的 Codex 运行环境。
