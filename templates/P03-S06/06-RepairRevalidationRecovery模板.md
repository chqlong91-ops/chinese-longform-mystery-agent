# Repair Return、Revalidation 与 Recovery 模板

## 产物合同

- 用途：接收 owner 新版本，计算 reached frontier、preservation/失效并恢复重验。
- 创建路由：finding owner return -> change impact -> revalidation SAR。
- 更新触发：owner return、source version、frontier、permit、checkpoint 或 root cause 改变。
- 状态记录位置：owner return、change event、frontier、SAC、new BAU/LAU、closure event。
- 真相源：owner actual return/current pointer/post-read 与显式 current relations。
- non-claims：source 已编辑或新版本存在不等于 finding closed、BAV/LAV 恢复或 state 通过。

## Owner Return

```yaml
finding_handoff_ref:
before_source:
after_new_current_source:
actual_changed_positions_claims: []
preserved_constraints_evidence: []
authorization_decision_refs: []
post_read:
```

## Impact / Revalidation

```yaml
delta_kinds: []
reached_frontier: []
preserve: []
invalidate: []
revalidate: []
owner_backed_nad: []
new_permit:
new_run_refs: []
closure_event:
```

## Recovery

```yaml
last_commit_point:
partial_write_set: []
root_cause_signature:
attempt:
evidence_delta:
no_progress:
allowed_reads: []
not_read: [full-manuscript, old-chat]
stop:
unique_next:
```
