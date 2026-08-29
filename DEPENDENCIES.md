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

## 无需的依赖

当前公开核心不需要数据库、Node.js、Python 包、云服务或 OpenAI API key。它依赖用户已有的 Codex 运行环境。

