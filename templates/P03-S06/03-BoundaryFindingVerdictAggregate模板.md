# Boundary Finding、Verdict 与 Aggregate 模板

## 产物合同

- 用途：记录 BAF、评价 scoped BAV 并重建 BAM all-BAV exact-set。
- 创建路由：BAU -> findings evaluation -> BAV -> aggregate candidate。
- 更新触发：finding、owner closure、source version 或 expected boundary manifest 改变。
- 状态记录位置：BAF、BAV、BAM、state input candidate、SAC。
- 真相源：current BAU/BAF closure/L4-A/L4-C 与 owner manifest。
- non-claims：BAV verified 只证明一个边界；aggregate candidate 不授真实 state。

## Finding

```yaml
finding_ref:
location_kind: stable|missing
location:
observed_evidence: []
rule:
type:
severity:
gate_effect:
owner:
minimum_repair:
new_changed_claims: []
revalidation_scope: []
closure_evidence: []
```

## Verdict

```yaml
bav_ref:
boundary_scope:
value: verified|findings-open|repair-pending|recheck-required|blocked|stale|conflict
evaluation:
c01_c12_exact: false
counterfactual_exact: false
decisive_unknown:
post_read:
```

## Aggregate

```yaml
expected: []
eligible_current_bav: []
missing: []
extra: []
duplicate: []
pending: []
stale: []
conflict: []
state_input_candidate:
unique_next:
```
