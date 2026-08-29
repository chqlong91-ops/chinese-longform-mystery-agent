# P03-R1 控制面迁移与 Legacy 兼容协议

## 1. 目的与边界

本协议把 Agent 当前控制语义迁移到 canonical registry，并用生成视图提供人类可读入口；P01—P03 历史控制文档只通过只读 adapter 进入兼容层。协议不读取小说正文，不重写 frozen evidence，不授予历史对象 current，不创建 R1/P03 baseline，也不授予 `L6-P`。

## 2. 唯一真相源

`state/p03-r1/canonical-registry.json` 是 current 状态唯一机器真相源。README、AGENTS、任务页、恢复入口、current-facing view 和 historical compatibility projection 都是派生信息，不得反向写回 registry，也不得自行授予状态。

## 3. Legacy inventory 与分类

迁移输入必须先由 allowlist inventory 冻结路径、bytes、SHA-256、阶段、角色和允许的解析模式。实际 inventory 固定为 9 个 Agent 控制文档，覆盖 P01、P02、P03；其生命周期一律为 historical-only，状态上限为 non-current/non-granting。路径逃逸、未登记文件、hash/bytes 漂移、重复身份或 forbidden path 均 fail-closed。

## 4. 只读 adapter

Adapter 只产生 canonical locator、source identity、provenance、字段映射、lineage、冲突与 nonclaims。它不得修改源文件，不得解析小说 payload，不得把自然语言中的“完成”映射成 current gate，也不得用缺失字段的推断补足状态。冲突必须显式登记，不得以最后写入者覆盖。

## 5. 迁移事务

迁移须先生成 migration plan 和 dry-run，再经 S04 原子事务提交。事务必须验证 expected registry hash/current refs，使用单 writer lease、staging、CAS 和单一 registry commit point；任何失败不得留下半写、双 current 或 stale operational entry。历史对象保留证据身份，但不得出现在 current pointers。

## 6. 生成视图与兼容投影

Current-facing view 只显示 registry current pointers、生命周期、adapter 和 unique next。Historical compatibility projection 只显示 P01—P03 的 historical 状态、state ceiling 与 nonclaims。两类视图都绑定 registry/projection fingerprint，write-back forbidden；漂移必须被检测并重新生成，不能手工修补为真相。

## 7. 恢复与证据上限

迁移后恢复包只装载 canonical registry、current control view、historical compatibility view 与 legacy projection。必须核验 package identity、exact-set、hash/bytes、actual/not-read/over-read/writes、语义断言、unique next 与 context disposal。S07 实际运行只达到 `L3-local-runtime`；未执行独立 clean session，因此不得授予 `L6-S`，`L6-P` 继续为 `not-evaluated`。

## 8. 验证门槛

S07 的最低实际门槛为：44 个迁移/兼容场景、24 个隔离强制失败、21 个 historical regressions 全部通过；deterministic replay=true；legacy mutation=0；view drift=0；novel/C10 reads=0、writes=0；baseline pollution=false。失败场景的 state grants 必须为空。

## 9. 状态与 nonclaims

S07 通过只证明 Agent 控制面迁移、只读兼容、生成视图与本地恢复成立。它不证明 P03 已通过，不证明 R1 已验收，不追认 P03 AC08/AC10，不授予真实项目恢复，不创建 frozen baseline。R1-AC03、AC04、AC07、AC08 的最终裁决属于 S08。

## 10. 恢复入口

恢复时先读 canonical registry，再读生成的 current-facing view；只有确需理解历史兼容时才读 compatibility projection。不得回读旧聊天推断 current，也不得直接从 P01—P03 历史文档恢复 current。S07 完成后的唯一下一步是审查并拆分 `P03-R1-S08`。
