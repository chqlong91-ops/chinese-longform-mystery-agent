# Contributing

感谢关注本项目。

## 贡献许可

本仓库采用 Apache License 2.0。除非贡献者明确另行说明，主动提交并由维护者接收的贡献按 Apache License 2.0 第 5 节处理。

## 贡献原则

- 不提交任何真实小说正文、未公开稿件、私人数据或外部来源缓存。
- 不把试点项目专用事实写进通用协议。
- 不增加用户逐门授权；遵守三级权限机制。
- 状态、确认、同步、风险和门禁保持分维。
- 修改运行时必须提供 fail-closed 和选择性恢复测试。
- 修改创作协议必须保持原创、公平线索、POV、现实命题与安全边界。

## 本地检查

```powershell
pwsh -NoProfile -File .\tools\validate-release.ps1
pwsh -NoProfile -File .\tests\smoke.ps1
```

Pull request 请说明：目标、影响范围、非目标、测试结果、状态迁移影响和是否触发三级例外。
