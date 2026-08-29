# P03-R1 事务 Replace 修复与冻结基线 Successor

## 问题

E10 首次 close transaction 已提交 registry v013，但事务引擎对已存在的 `mode=replace` 目标只检查、不替换，导致 current generated views 仍绑定 v012。由于 closing validation 检出 drift，E10 不得以 v013 作为最终完成状态。

## 修复

- `replace` 先备份既有目标，再通过同目录临时文件原子替换。
- registry commit point 之前失败时，按逆序恢复备份并移除本事务新建目标。
- `create` 对已存在且同 hash 的目标保持幂等；不同 hash 继续 fail-closed。
- registry 仍是唯一 commit point，CAS 与 writer lease 不变。

## Successor 规则

修复通过 `TX-P03R1-S08-CLOSE-REPAIR@v001` 生成 registry v014、S08 v003、lifecycle v004、compatibility view v005 与 frozen baseline v002。v013、S08 v002、lifecycle v003 和 baseline v001 保留为历史证据，不得删除或伪装为从未发生。

## 非声明

此修复不改变 R1 的 AC 结论，不授予小说状态、`L6-P` 或 P04 启动状态。
