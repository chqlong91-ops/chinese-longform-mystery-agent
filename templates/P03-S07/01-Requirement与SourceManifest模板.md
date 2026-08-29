# S07 Requirement 与 Source Manifest 模板

## 产物合同

- 用途：实例化 S07 requirement trace、ASMF、member eligibility、exact-set 与 assembly profile。
- 创建路由：S06 ready handoff -> S07 source admission。
- 更新触发：basis、member、order、formal version、owner evidence 或 profile 改变时创建新 content version。
- 状态记录位置：ASMF、ASR、AWEI、ACP。
- 真相源：current owner manifests、current formal registry 与 actual post-read evidence。
- non-claims：manifest frozen 不表示 candidate 已构建、verified、current 或 final-audited。

## Identity / Basis

```yaml
manifest_ref:
project_book_scope:
planned_asm_ref:
current_basis_refs: []
source_watermark:
profile_ref_hash:
```

## Exact-Set

```yaml
expected_members: []
actual_eligible_members: []
missing: []
extra: []
duplicate: []
stale: []
mixed_layer: []
conflict: []
nad: []
ordered_versioned_set_hash:
```

## Member / Profile

```yaml
member: {id: '', type: chapter, order_key: '', formal_ref: '', layer: formal, source_hash: '', payload_hash: '', title_hash: '', evidence_refs: []}
profile: {encoding: '', bom: '', newline: '', title_mode: '', wrappers: {}, separators: {}, metadata_allowlist: [], hash_algorithm: SHA-256}
allowed_transforms: []
forbidden_transforms: [prose-edit, title-rewrite, reorder, gate-repair]
```

## Result

```yaml
eligibility: matched|blocked|stale|conflict|not-evaluated
actual: []
not_read: []
post_read:
checkpoint:
unique_next:
```
