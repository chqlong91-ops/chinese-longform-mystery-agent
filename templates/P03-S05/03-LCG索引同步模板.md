# LCG 索引同步模板

## 产物合同

- 用途：把 committed CMR 的 actual realization/consumer position 交给 S04 并记录 index-sync。
- 创建路由：CMR receipt-committed/index-pending -> S04 graph controller。
- 更新触发：CMR、current LCG、position、timing、permission、proposition 或 requiredness 改变时新建 request。
- 状态记录位置：S05-LCG-MUTATION-REQUEST、S04 event/current、LCGSR、SPEI、PEC。
- 真相源：P02 actual evidence、P01/P02 semantic owner 与 S04 current graph。
- non-claims：index-synced/coverage complete 不等于 semantic passed 或 long-range-consistent。

## Request

```yaml
request_ref:
per_cmr_ref:
expected_old_lcg_current:
node_delta: []
edge_delta: []
positions: []
dimensions: []
timing_permissions_propositions: []
coverage_expected_delta: []
idempotency_key:
```

## Owner Disposition

```yaml
disposition: required|no-op-with-owner-NAD|owner-return|blocked|stale|conflict
owner_evidence: []
nad_scope_rule:
does_not_establish: []
```

## Atomic Return

```yaml
candidate_ref:
coverage_delta:
candidate_post_read:
cas_event:
new_current_lcg_ref:
final_verify:
lcgsr_ref:
index_sync: pending|synced
stop:
checkpoint:
unique_next:
```
