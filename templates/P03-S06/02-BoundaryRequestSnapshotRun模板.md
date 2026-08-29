# Boundary Request、Snapshot 与 Run 模板

## 产物合同

- 用途：对 BAM 中一个 required boundary 建立 BAR、四层 BSS 和 BAU。
- 创建路由：SAR boundary-incremental -> Boundary Track。
- 更新触发：boundary/window/source/permit/C item 改变时新 content version。
- 状态记录位置：BAM、BAR、BSS、BAU、SAEI、SAC。
- 真相源：current BP/BPM/BBT、actual L4-A 与 referenced L4-C。
- non-claims：一个 BAU 或旧 BAV 不表示全部边界完成。

## Boundary Identity / Window

```yaml
boundary_id:
from_act:
to_act:
last_before:
at_positions: []
first_after:
formal_versions: []
source_fingerprints: []
```

## Four-Layer BSS

```yaml
actual_story: {before: {}, at: {}, after: {}}
character_epistemic: {before: {}, at: {}, after: {}}
reader_state: {before: {}, at: {}, after: {}}
manuscript_realization: {before: {}, at: {}, after: {}}
```

## C01-C12 / Counterfactual

```yaml
items:
  C01: {actual_evidence: [], result: unresolved-input, owner: P01}
  C12: {actual_evidence: [], result: unresolved-input, owner: P02}
counterfactuals: []
actual_reads: []
not_read: [full-manuscript]
```

## Result

```yaml
bau_status:
finding_refs: []
post_read:
checkpoint:
unique_next:
```
