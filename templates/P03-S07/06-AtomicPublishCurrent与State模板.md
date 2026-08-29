# S07 Atomic Publish、Current 与 State 模板

## 产物合同

- 用途：记录 APV PREPARE/CAS/final-read、唯一 current ASM 与 book-assembled ASI。
- 创建路由：CP6 eligible AVV -> CP7 current -> CP8 state projection。
- 更新触发：candidate/AVV/source/current registry/state event 变化时新建 event/input。
- 状态记录位置：APV、current registry/event、ASI、S02 state event、ACP。
- 真相源：CAS registry、immutable current artifact、current AVV 与 final post-read。
- non-claims：book-assembled 不蕴含 final-audited、book-confirmed、release、recovery 或任何上游状态。

## Publish

```yaml
apv_ref:
candidate_avv_refs: []
expected_old_current:
target_post_read:
cas_receipt:
current_event:
final_post_read:
```

## Current

```yaml
registry_key:
current_asm_ref_hash:
manifest_profile_map_avv_refs: []
source_watermark:
supersedes:
registry_revision:
```

## State

```yaml
dimension: book-assembled
value: yes|partial|no|not-evaluated
evaluation: evaluated|not-evaluated
evidence_exact_set: []
independent_states_not_inferred: [chapter-production, act-boundaries-verified, long-range-consistent, final-audited, book-confirmed, release, recovery]
post_read:
unique_next:
```
