# F18 非唯一下一步与 pack drift

- Track：R
- 输入：checkpoint 同时声明 resume 与 repeat-audit，且 active boundary 已变化。
- 预期：pack/recovery conflict，next action 不唯一，RTV fail-closed。
- 禁止：由 Agent 偏好选择路线或把旧 checkpoint 继续执行。
- 下一步：rebuild-pack 并由 current state 明确唯一入口。
