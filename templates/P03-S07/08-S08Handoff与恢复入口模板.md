# S07 -> S08 Handoff 与恢复入口模板

## 产物合同

- 用途：形成 S7I current verified ASM 受限移交，并生成聊天无关的最小恢复入口。
- 创建路由：CP8 current ASM/state post-read -> CP9 handoff；会话恢复 -> RPM loader。
- 更新触发：current ASM/ASMF/profile/SGM/AVV/state/source watermark 或 unique next 改变。
- 状态记录位置：S7I、handoff event、ACP、RPM。
- 真相源：唯一 current registry、current AVV/ASI、source map 与 post-read evidence。
- non-claims：handoff ready 不表示 S08 已接收、读取、审计、修复或授 final-audited。

## S08 Input

```yaml
handoff_ref:
current_asm_ref_hash:
manifest_profile_segment_refs: []
verification_receipt:
upstream_state_refs: []
book_assembled_state_ref:
s07_permit_history_and_release: []
unresolved: []
not_read: []
ready: false
expires_on_change: []
```

## Excluded

```yaml
excluded: [candidate, partial, staging, fixture, summary, old-current, stale-avv, raw, revised, legacy, old-chat]
s08_must_issue_own_semantic_read_permit: true
```

## Recovery

```yaml
rpm_ref:
required_read_order: []
explicit_not_read: []
allowed_writes: []
prohibited_writes_and_non_grants: []
checkpoint:
active_stop:
unique_next:
```
