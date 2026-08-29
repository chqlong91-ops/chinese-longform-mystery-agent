# F13 最小恢复成功

- Track：R
- 输入：RPM required entries/hash/currentness 全部有效，oracle 唯一。
- 预期：package-valid/files-reconstructed/workflow-resumable=yes，undeclared reads=0，recovery-reconstructed=yes。
- 禁止：把 semantic-context-sufficient 或 clean-agent-session 自动设 yes。
- 下一步：恢复到 `run-propagation-preflight`。
