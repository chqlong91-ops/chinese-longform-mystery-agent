# Finding、Owner 与 Research 模板

## 产物合同

- 用途：统一 BAF/LAF 分类、位置、severity/gate effect、唯一 owner 与 research 分流。
- 创建路由：BAU/LAU finding evaluation -> owner routing。
- 更新触发：evidence、type、owner、research readiness 或 source currentness 改变。
- 状态记录位置：BAF/LAF、owner handoff、research card、event log。
- 真相源：actual observed evidence、专业规则与 owner current source。
- non-claims：acknowledged、plan ready 或 research complete 均不自动关闭 finding。

## Finding

```yaml
finding_ref:
track_scope_dimension:
stable_or_missing_location:
observed_evidence: []
rule:
why_it_fails:
type:
severity: blocking|major|minor|advisory
gate_effect:
primary_owner:
dependent_owners: []
```

## Repair / Research

```yaml
preserved_constraints: []
minimum_repair:
stronger_option:
new_changed_claims: []
research_dependency:
supports:
does_not_establish:
conservative_fallback:
required_revalidation: []
```

## Lifecycle

```yaml
status: opened|routed|repair-returned|recheck-required|closed-current|stale|conflict
closure_evidence: []
checkpoint:
unique_next:
```
