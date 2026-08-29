# State、S07 Handoff 与 Recovery 模板

## 产物合同

- 用途：重建 all-BAV/LAV state input，投影两类独立状态，并向 S07 提交受限引用。
- 创建路由：current BAV/LAV verdicts -> S02 state projector -> S06/S07 handoff。
- 更新触发：BAM/LAV/source/state/watermark、S07 readiness 或 checkpoint 改变。
- 状态记录位置：state input candidate、state events、S06-S07 handoff、RPM。
- 真相源：current exact-set verdict evidence 与 S02 state projection event。
- non-claims：handoff ready 不表示 ASM、final audit、确认、release 或 recovery 已完成。

## Independent State Inputs

```yaml
all_bav_expected: []
all_bav_eligible: []
boundary_errors: {}
boundary_state_candidate: {value: not-evaluated, evaluation: not-evaluated}
current_lav_ref:
d01_d11_actual: []
long_range_errors: {}
long_range_state_candidate: {value: not-evaluated, evaluation: not-evaluated}
```

## S07 Handoff

```yaml
handoff_ref: S06-S07-ASSEMBLY-INPUT@v001
current_book_basis: []
chapter_production_refs: []
formal_manifest_source_refs: []
boundary_refs: []
long_range_refs: []
unresolved_research_open: []
actual_refs_only: true
not_read: [full-manuscript]
s07_ready: false
```

## Recovery

```yaml
checkpoint:
source_watermark:
required_read_order: []
allowed_writes: []
prohibited_writes: [manuscript, ASM, state-grant]
non_grants: []
unique_next:
```
