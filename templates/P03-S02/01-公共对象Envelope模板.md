# P03 公共对象 Envelope 模板

## 产物合同

- 用途：记录一个 P03 全书对象版本的公共身份、版本、scope、owner、source、lifecycle 与完整性字段。
- 创建路由：P03-S02 schema；实际项目由对应对象 owner 在 A1-A4 下创建。
- 更新触发：语义内容改变建新 content version；非语义更正升 record revision；current 只由 commit event 切换。
- 状态记录位置：Current Registry、事件日志和独立状态 projection；本文件自报 current 不生效。
- 真相源：`P03-OBJECT-ENVELOPE@v001`、规范 source refs 与 committed event。

## Identity

- object_type：`${TYPE}`
- object_family：`${FAMILY}`
- object_id：`${PROJECT}-${TYPE}-${SEQ}`
- project_id：`${PROJECT}`
- book_id：`${BOOK_ID}`
- schema_version：`P03-${TYPE}-SCHEMA@s001`

## Version / Scope / Owner

- content_version：`v001`
- record_revision：`r001`
- projection_revision：`${NA_OR_P001}`
- predecessor_ref：`${NULL_OR_REF}`
- scope_ref：`${BOOK}#${SCOPE}@v001`
- scope_profile：`${PROJECT_BOOK_ACT_CHAPTER_MANUSCRIPT}`
- scope_manifest_ref：`${MANIFEST_REF}`
- state_owner / write_owner / semantic_owner：`${OWNERS}`
- authorization_ref：`${A0_A5_OR_L5_L6}`

## Source / Lifecycle / Integrity

- source_refs / source_fingerprint：`${REFS}` / `${HASH}`
- evidence_refs / requirements：`${EVIDENCE}` / `${REQ_IDS}`
- lifecycle_status：`candidate`
- current_pointer_key / expected_current_ref：`${KEY}` / `${REF_OR_NULL}`
- created_event_ref / last_event_ref：`${EVENTS}`
- payload_hash / envelope_hash：`${HASHES}`
- post_read_status：`not-run`
- checkpoint / stop / unique_next：`${CONTROL}`
- non_claims：`${EXPLICIT_NON_CLAIMS}`

