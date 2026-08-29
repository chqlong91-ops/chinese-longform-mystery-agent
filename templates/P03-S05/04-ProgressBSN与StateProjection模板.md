# Progress、BSN 与 State Projection 模板

## 产物合同

- 用途：从 expected manifest 聚合 chapter/batch/act/book 进度并构建 BSN/state input。
- 创建路由：CMR committed + required index-synced -> S05 aggregate projector。
- 更新触发：manifest、member、evidence、LCG current、watermark、schema 或 algorithm 变化。
- 状态记录位置：AMR、PAM、BSN event/current、chapter-production state projection。
- 真相源：BP/BPM/BBT expected manifest、CMR/index-sync owner evidence 与 S02 state event。
- non-claims：PAM/BSN/current 不补授 member，也不蕴含其他七类全书状态。

## Exact-Set

```yaml
scope_type: chapter|batch|act|book
scope_key:
expected_members: []
eligible_actual_members: []
missing: []
extra: []
duplicate: []
pending: []
partial: []
stale: []
conflict: []
owner_nad: []
as_of_watermark:
```

## Aggregate / BSN

```yaml
pam_ref:
amr_refs: []
set_hashes: {}
aggregate_evaluation:
bsn_candidate_ref:
bsn_member_evidence_exact_set:
bsn_post_read:
bsn_cas_event:
bsn_final_read:
```

## State Projection

```yaml
state: chapter-production-complete
value: yes|partial|no|not-evaluated
evaluation: evaluated|evaluated-incomplete|not-evaluated
required_evidence: [L4-C,L4-B]
actual_evidence: []
invalidations: []
non_implications: [act-boundaries-verified,long-range-consistent,book-assembled,final-audited,book-confirmed,release-verified,recovery-verified]
unique_next:
```
