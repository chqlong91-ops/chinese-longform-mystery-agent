# S07 Candidate Build 与 Segment Map 模板

## 产物合同

- 用途：记录 deterministic ABR、candidate ASM、SGM、payload 保持、staging inventory 与 replay。
- 创建路由：active L4-M-build permit -> CP3/CP4。
- 更新触发：ASMF/profile/source/tool-output contract 改变时创建新 build intent/candidate version。
- 状态记录位置：ABR、candidate ASM envelope、SGM、staging inventory、ACP。
- 真相源：exact source bytes、frozen profile、candidate bytes 与 post-read hashes。
- non-claims：candidate built 不表示 verified/current/book-assembled/final-audited。

## Build

```yaml
build_ref:
build_key:
manifest_profile_refs: []
tool_provenance:
staging_root:
ordered_members: []
source_pre_post: []
unexpected_write_count: 0
```

## Segment Map

```yaml
sgm_ref_hash:
range_convention: zero-based-half-open
members:
  - {member_id: '', source_hash: '', decoded_hash: '', payload_hash: '', wrapper_before: '', payload_range: '', wrapper_after: '', separator: '', segment_hash: ''}
coverage: {start: 0, end: 0, gaps: 0, overlaps: 0}
structure_fingerprint:
candidate_length_hash:
```

## Result

```yaml
status: candidate-built|partial|blocked|stale|integrity-failure
replay_result:
post_read:
checkpoint: CP4
unique_next:
```
