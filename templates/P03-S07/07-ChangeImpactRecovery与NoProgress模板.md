# S07 Change Impact、Recovery 与 No-Progress 模板

## 产物合同

- 用途：记录 S7CI、reached frontier、PEI、失效/保留、partial 恢复和 no-progress。
- 创建路由：source/profile/current/state/change event -> S07 impact controller。
- 更新触发：actual changed targets、relation snapshot、owner evidence、checkpoint 或 attempt signature 变化。
- 状态记录位置：S7CI、PEI、invalidation events、ACP、RPM。
- 真相源：actual change event、current relation graph、post-read evidence 与 durable checkpoint。
- non-claims：相同 hash、较小改动或旧验证不能自动保留新版本结论。

## Change / Frontier

```yaml
change_ref:
old_new_refs:
changed_scope_dimensions: []
owner:
relation_snapshot:
reached_frontier: []
invalidated: []
preserved_with_pei: []
unresolved: []
```

## Recovery

```yaml
last_durable_cp:
partial_residue: []
source_watermark:
required_new_permits: []
primary_action: resume|rebuild-manifest|rebuild-candidate|repeat-verify|retry-CAS|rebuild-projection|route-owner|request-user-A4|abandon
unique_next:
```

## No-Progress

```yaml
attempt_signature:
same_root_attempts:
evidence_delta:
frontier_delta:
third_auto_run_allowed: false
escalation:
```
