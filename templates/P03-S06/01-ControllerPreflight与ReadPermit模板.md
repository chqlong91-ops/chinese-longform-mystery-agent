# Controller、Preflight 与 Read Permit 模板

## 产物合同

- 用途：建立 SAR、current resolution、SAEI/SAC 与 task-bound read permit。
- 创建路由：S05/S04 audit input -> P03-S06 controller。
- 更新触发：intent、mode、scope、source watermark、permit 或 WIP 改变时新建 content version。
- 状态记录位置：SAR、SAEI、SAC、event log。
- 真相源：current registry、owner manifests 与 actual post-read evidence。
- non-claims：preflight ready 不表示 BAU/LAU 已运行或 BAV/LAV/state 已通过。

## Identity

```yaml
sar_ref:
mode: boundary-incremental|pre-assembly-long-range|revalidation
track: boundary|long-range
project_book_scope:
source_watermark:
wip_key:
idempotency_key:
```

## Current / Input Exact-Set

```yaml
required_current_refs: []
actual_current_refs: []
expected: []
reference: []
actual: []
fixture: []
not_read: [full-manuscript, future-or-unlisted-prose, old-chat]
missing_extra_duplicate_stale_conflict: {}
```

## Permit / Budget

```yaml
permit_ref:
far_field: []
near_field_exact_positions: []
directed_expansion: []
budget: {positions: 0, hops: 0}
authorization: [A0, A1-audit-records-only]
prohibited_writes: [truth, formal, schedule, LCG-current, progress, ASM, state]
actual_reads: []
dispatch_token:
```

## Result

```yaml
outcome: ready|blocked|stale|conflict|read-violation
post_read:
checkpoint:
stop:
unique_next:
```
