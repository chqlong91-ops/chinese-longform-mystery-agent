# PER 与 Entry Preflight 模板

## 产物合同

- 用途：建立一个 S05 复合生产运行并判定是否可向 P02 dispatch。
- 创建路由：S03 chosen PN -> S05 orchestrator。
- 更新触发：source、scope、intent、授权或 expected write set 改变时创建新 content version。
- 状态记录位置：PER、PEF、PEC 与 Current Registry。
- 真相源：current BK/BP/BSN/BPM/BBT/BSR/SCP/PN/LCG 及 owner evidence。
- non-claims：ready 不等于 P02 completed、receipt committed、index-synced 或进度完成。

## Identity

```yaml
per_ref:
preflight_ref:
project_book:
batch_pn_chapter:
chapter_version_layer_scope:
correlation_causation:
idempotency_key:
```

## Current / Entry

```yaml
required_current_refs: []
actual_current_refs: []
source_fingerprints: []
ready_chosen_hash:
required_predecessors: []
entry_expected: []
entry_actual: []
existing_receipt_disposition:
owner_safety_stops: []
```

## Context / Authorization / WIP

```yaml
lcg_query_request:
load_profile: far|near|directed
permit_budget:
actual_reads: []
not_read: [full-manuscript, future-prose, old-chat, manifest-outside]
authorization_refs: []
expected_writes_by_owner: {}
prohibited_writes: []
schedule_claim_ref:
dispatch_token_ref:
```

## Result

```yaml
outcome: ready|blocked|denied|conflict
post_read:
stop:
checkpoint:
unique_next:
```
