# LCG Node 模板

## 产物合同

- 用途：登记一个可定位的 owner source 引用，不复制 owner truth。
- 创建路由：S04 graph controller；S05 只能提交 candidate mutation。
- 更新触发：source/version/scope/position/role/dimension/owner 任一语义变化时新 content version。
- 状态记录位置：LCG node record、event log、Current Registry projection。
- 真相源：`source_ref + owner event + source fingerprint`；LCG 不是语义真相源。
- non-claims：node 存在/current 不证明命题真实、正文实现、coverage 或一致性。

## Identity 与 basis

- node_id：
- node_ref：
- schema_ref：`P03-LCG-NODE-SCHEMA@s001`
- graph_basis_ref：
- dimension_family：
- artifact_subtype：
- node_role：

## Owner source

- source_ref：
- source_type：
- source_scope_ref / manifest_ref：
- source_current_event_ref：
- semantic_owner / write_owner / state_owner：
- source_fingerprint：
- provenance_refs：
- certainty_ref / epistemic_ref：

## Position

- carrier_object_ref / layer：
- chapter_ref / act_ref：
- section_key / scene_key / beat_key：
- position_kind / range_anchor：
- anchor_basis_ref / stability / fallback_chain：
- last_verified_event_ref / post_read_status：

## Lifecycle 与恢复

- predecessor_ref / lifecycle_status：
- authorization_ref / requirements：
- payload_hash / events：
- stop / owner route：
- checkpoint / unique_next：

