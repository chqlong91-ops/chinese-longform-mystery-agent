# S07 Controller、Preflight 与 Checkpoint 模板

## 产物合同

- 用途：建立 S7CR/AER、WIP=1、phase、event、write-ahead 与 CP0-CP9 恢复记录。
- 创建路由：frozen ASMF -> S07 controller entry。
- 更新触发：intent、scope、source watermark、commit point、stop 或恢复动作改变。
- 状态记录位置：S7CR、AWEI、ACP、event log。
- 真相源：current registry、ASMF/profile 与 durable post-read records。
- non-claims：controller committed 不表示 S08 已运行或任何语义状态通过。

## Controller

```yaml
s7cr_ref:
intent_hash:
wip_key:
lease_owner:
phase:
correlation_causation: []
idempotency_key:
```

## Preflight

```yaml
required_inputs: []
actual_inputs: []
not_read: []
allowed_writes: []
prohibited_writes: []
source_watermark:
expected_old_current:
```

## Checkpoint

```yaml
last_durable_cp: CP0|CP1|CP2|CP3|CP4|CP5|CP6|CP7|CP8|CP9
attempt:
write_ahead_refs: []
residue: []
stop_reason:
recovery_action:
unique_next:
post_read:
```
