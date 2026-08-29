# F06 图冲突与无进展

- Track：D
- 输入：同一 edge 同时 required/excluded，连续两轮重扫没有新证据。
- 预期：graph-conflict；第二轮 no-progress，停止自动循环。
- 禁止：按摘要/mtime 选择关系或无限 retry。
- 下一步：relation owner/A4 resolution 或 abandon-run。
