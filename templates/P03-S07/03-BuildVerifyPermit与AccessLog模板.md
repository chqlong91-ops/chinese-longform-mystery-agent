# S07 Build / Verify Permit 与 Access Log 模板

## 产物合同

- 用途：分别签发 task-bound L4-M-build 与 L4-M-verify，记录 exact access、预算和释放。
- 创建路由：CP2 -> build permit；CP4 -> verify permit。
- 更新触发：purpose、subject、source/candidate hash、reader、budget、allowlist 或 expiry 变化时新签 permit。
- 状态记录位置：permit record、append-only access log、AWEI、ACP。
- 真相源：active permit、resolved exact locator 与 actual access events。
- non-claims：build permit 不授权语义读取；verify permit 不授权 S08 FAR，二者不可继承。

## Permit

```yaml
permit_ref:
phase: build|verify
purpose:
subject_ref_hash:
source_manifest_hash:
allowed_reads: []
allowed_writes: []
prohibited: []
reader_tool:
budget: {members: 0, bytes: 0, opens: 0, model_visible_prose_bytes: 0}
expiry:
```

## Access

```yaml
required: []
actual: []
not_read: []
unexpected_reads: []
unexpected_writes: []
access_events: []
budget_remaining:
release_receipt:
```

## Result

```yaml
status: ready|complete|blocked|stale|violation|expired
post_read:
checkpoint:
unique_next:
```
