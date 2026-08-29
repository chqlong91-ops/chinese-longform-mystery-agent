# S07 Verification、Finding 与 Receipt 模板

## 产物合同

- 用途：执行 V01-V32、记录 AVR/findings/AVV 与 source/candidate post-read。
- 创建路由：CP4 candidate + fresh L4-M-verify permit -> CP5/CP6。
- 更新触发：candidate、ASMF/profile/SGM/source watermark、permit 或 finding closure 变化时新建 AVR/AVV version。
- 状态记录位置：AVR、finding register、AVV、AWEI、ACP。
- 真相源：独立 candidate/source stream、ASMF/profile/SGM 与 current post-read。
- non-claims：AVV matched 只证明来源/结构一致，不证明 S08 语义终审通过。

## Verification

```yaml
avr_ref:
candidate_manifest_map_refs: []
permit_ref:
check_results: {V01: '', V32: ''}
expected_actual_not_read: {}
source_candidate_post_read:
```

## Finding

```yaml
finding: {id: '', type: '', check_id: '', member_or_global: '', source_locator: '', candidate_range: '', expected: '', actual: '', severity: blocking, owner: '', minimal_repair: '', reverify_scope: '', status: open}
finding_exact_set: []
```

## Receipt

```yaml
avv_ref:
value: matched|blocked|stale|conflict|not-evaluated
open_blocking_major: 0
unexpected_read_write: 0
release_receipt:
expires_on_change: []
unique_next:
```
