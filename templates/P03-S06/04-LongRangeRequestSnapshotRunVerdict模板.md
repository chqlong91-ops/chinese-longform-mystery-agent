# Long-Range Request、Snapshot、Run 与 Verdict 模板

## 产物合同

- 用途：对 current LCG D01-D11 expected source-consumer manifest 建立 LAR/LAS/LAU/LAV。
- 创建路由：SAR pre-assembly-long-range -> Long-Range Track。
- 更新触发：LCG/manifest/source/consumer/position/permission/proposition/change 改变。
- 状态记录位置：LAR、LAS、LAU、LAF、LAV、SAEI、SAC。
- 真相源：current LCG owner manifest、actual L4-B 与 referenced L4-C positions。
- non-claims：coverage/query/edge existence、BAV 或 progress 不等于 LAV consistent。

## Identity / Expected Set

```yaml
lar_ref:
book_lcg_manifest_scope:
watermark:
dimensions: [D01,D02,D03,D04,D05,D06,D07,D08,D09,D10,D11]
expected_sources: []
expected_consumers: []
expected_positions: []
```

## LAS / Permissions

```yaml
actual_positions: []
appearance_visibility_full_access_interpretation_disclosure_payoff: []
observe_access_understand_use_cite_disclose: []
supports_does_not_establish: []
actual_reads: []
not_read: [full-manuscript]
```

## Audit / Verdict

```yaml
dimension_results: {}
fair_six: {}
counterfactuals: {}
finding_refs: []
lav_value: consistent|findings-open|repair-pending|recheck-required|blocked|stale|conflict
decisive_unknown:
required_relation_errors:
post_read:
unique_next:
```
