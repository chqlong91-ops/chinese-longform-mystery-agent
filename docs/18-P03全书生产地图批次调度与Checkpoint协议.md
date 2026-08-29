# P03 全书生产地图、批次调度与 Checkpoint 协议

## 协议身份

- protocol：`P03-BOOK-SCHEDULING-PROTOCOL@v001`
- requirement baseline：`P03-S03-REQ@v001`
- production map：`P03-PRODUCTION-MAP@v001`
- batch/gate：`P03-BATCH-GATE@v001`
- P02 invocation：`P03-P02-INVOCATION@v001`
- single controller：`P03-SINGLE-CONTROLLER-SCHEDULER@v001`
- checkpoint：`P03-SCHEDULE-CHECKPOINT@v001`
- exception：`P03-SCHEDULE-EXCEPTION@v001`
- change/recovery：`P03-SCHEDULE-CHANGE-RECOVERY@v001`
- upstream：`P03-BOOK-OBJECT-STATE-PROTOCOL@v001` + `S2H-P03-S03@v001`
- downstream：`S3H-P03-S04@v001`
- frozen date：2026-08-20

本协议汇总 S03 frozen 调度模型。底层规范分别是 [E01 需求与术语](../work/P03-S03/01-S03契约需求追踪与调度术语基线.md)、[E02 生产图](../work/P03-S03/02-BP生产地图节点与依赖DAG.md)、[E03 批次门禁](../work/P03-S03/03-批次成员EntryExit门禁与ExactSet.md)、[E04 P02 调用](../work/P03-S03/04-P02十二节点调用授权证据与交接.md)、[E05 单主控](../work/P03-S03/05-单主控调度状态机WIP与UniqueNext.md)、[E06 Checkpoint](../work/P03-S03/06-调度RunCheckpoint暂停与文件恢复.md)、[E07 异常分流](../work/P03-S03/07-阻塞跳过重排回退Owner与NoProgress.md) 和 [E08 变更恢复](../work/P03-S03/08-计划改版漂移选择性失效与恢复接口.md)。汇总不得覆盖底层证据。

## 目标与边界

S03 把 current BK/BP/BSN 转换为确定、可验证、可暂停、可恢复的全书生产调度合同，使 S04 能建立长程一致性索引、S05 能安全逐批调用 P02。它不运行 P02、不读取 manuscript、不构建真实 LCG、不创建小说实例，也不评价章节或八类全书状态。

## 调度对象与真相源

- `BPM`：BP 的确定性只读 production-map projection；不拥有案件真相或执行结果。
- `PN/PE`：chapter/act/boundary/batch-candidate 节点与显式 member/precedes/depends/gate 边；只引用 owner source/version/scope。
- `BBT`：一个 BPM version 内的 expected member exact-set、顺序、entry/exit gate、WIP 和 checkpoint policy。
- `CIV`：对 P02 N00-N11 的版本化调用 request/result envelope；不拥有 P02 verdict。
- `BSR`：一个 BK/scope 下唯一 current 的 controller run。
- `SCP`：BSR 在 committed watermark 上的不可变恢复锚点。

这些记录全部服从 S02 Envelope、content/revision/current、关系和原子事件语义。计划意图、执行 actual、章节 evidence、状态 projection 与 summary 严格分离。

## 确定性生产图

编译只消费 Current Registry 解析的唯一 BK/BP/BSN 和 BP frozen expected manifest。required node/edge 绑定 source/target version、scope、dimension、owner 和 evidence；observational edge 不参与 gate。

编译顺序为 current resolution -> expected/actual exact-set -> node/source/membership 验证 -> relation/version/scope 验证 -> cycle 检测 -> 稳定 Kahn topological sort -> output hash/post-read/committed event。tie-break 固定 `act_rank, planned_unit_rank, node_type_rank, stable_node_key`；mtime、目录顺序、随机数和模型偏好禁止参与。

missing/extra/duplicate/orphan/cross-version/cycle/order/current/projection drift 均 fail-closed。相同 source/algorithm 必须生成相同 graph/order hash。

## 批次与门禁

BBT 只能从合法 topo slice 或显式合法 antichain 构造。required predecessor 必须在 batch 前完成或在同 batch 中严格更早；未验证 boundary 不能跨幕。batch size/context/review policy 由未来项目合同决定，本协议不预设真实数值。

entry gate 要求 source/current/fingerprint、required predecessors、owner gate evidence、P02 对象/授权、无 stop 和 WIP 全部满足。exit gate 要求 CIV terminal、N00-N11 actual、current formal/ERE/MR/CFD/SYV 与适用 PVP/BAV/RTV、expected/actual、event 和 post-read 完整。

只有 expected required members 与 actual completed members exact-set 相等且全部 exit current，BBT 才能 `batch-completed/evaluated`。批次聚合不能补授章节门禁或任何全书状态。

## P02 调用合同

CIV 绑定唯一 book/map/batch/run/node/chapter/MS version/layer/scope、L0-L4、A0-A5/L5/L6、允许/禁止读写和 idempotency。S03 只编排 P02 frozen N00-N11，不生成章节合同、ERE、正文、审计、修复、formal、CFD、SYV、传播或 BAV verdict。

CIV terminal 分 completed、pending-confirmation、repair/research/owner-blocked、paused、partial、stale、conflict、no-progress、abandoned。只有 completed + 全量 current evidence + post-read matched 可形成 node completion candidate；exit 0、summary、用户鼓励和文件存在均不能替代。

## 单主控、Ready 与 WIP

Current Registry key `project/book/scheduler-run/scope` 只有一个 current BSR。状态从 prepared、ready-evaluating、ready、dispatching、waiting/paused/blocked、verifying、committed 到 batch/plan complete candidate；stale/conflict/no-progress/abandoned fail-closed。

ready-set 逐 PN 验证 current/fingerprint、predecessors、entry gate、owner/safety stop 和 WIP。相同输入产生相同 ready hash 与 chosen node。一个 manuscript family 的 project-bound `write_wip=1`；lease timeout 不自动转授权，双 writer 必须停止并 route owner。

ready 空需区分 exact-complete candidate、gate/owner blocked、cycle/drift/current conflict、WIP wait 和 no-progress；不能任意跳章或提前聚合。

## Checkpoint 与恢复

SCP 保存 plan/map/batch/run/node/CIV refs、watermark、source/map/batch/ready/WIP hash、last committed/pending action、expected/actual read-write、member sets、pause/stop/root cause/attempt、required reads/not-read、post-read 和 unique next。

保存固定 CHECKPOINT-PREPARE -> candidate write -> full post-read -> CHECKPOINT-VERIFY -> CAS CURRENT-COMMIT -> final post-read/CHECKPOINT-SAVE。none-written、proper-subset、all-unverified、verified-uncommitted、committed-final-read-missing、unexpected-write 分别恢复；跨版本结果不能拼接。

恢复最小装载为 workspace/protocol/recovery/current registry/BSR/SCP/相关 BPM-BBT-CIV-event slice，默认不读旧聊天、全稿、未来章节或 manifest 外文件。机械恢复不授 semantic/clean-session。

## 阻塞、重排与 No-Progress

source/gate/authorization/research/repair/dependency/environment/safety blocked 分开记录并回唯一 owner。required node、决定性依赖、boundary、用户确认和 owner finding 不可 skip；optional/not-applicable 需要 owner/rule/evidence 与新 manifest。

reorder 仅限同一 current ready antichain，且无 required path、boundary、source-timing 或 WIP hazard；不能改变 truth/reveal 语义。replan 创建新 BP/BPM/BBT/BSR content version；旧 run 状态不继承。

同 root cause 连续两轮无规范 delta 时提交 NO-PROGRESS，禁止自动第三轮；unique next 仅 replan、route-owner、request-user/A4、abandon 之一。

## 计划变化与选择性失效

delta 分 scope/member/order/dependency/gate/batch/checkpoint/source-timing/owner/protocol 十维。影响只沿显式 current required relation 的匹配 scope/dimension 传播。旧 chapter evidence 只有在 owner impact verdict、current refs、untouched dimensions、membership revalidation 和 post-read 完整时可作为 preservation candidate；旧 ready/running/batch-complete 不继承。

source/current drift、partial batch、interrupted run、double controller、checkpoint gap、unexpected write、projection drift 分别停止并只选择一个主恢复动作。

## S04 与 S05 接口

S04 只消费 current BPM/PN/PE 的稳定 source/scope/dependency/source-timing/consumer refs，必须由 P01/P02/专业 owner 建立真实 LCG 语义，不能把 planned edge 当 truth edge。

S05 消费 current BPM/BBT/BSR/SCP、CIV、WIP、entry/exit、delta/invalidation/recovery，必须实际调用 P02 和保存 L4-C evidence；S03 fixture 与 plan-complete-candidate 不能冒充实际聚合。

## 验证与 Non-grants

[P03-S03 模板](../templates/P03-S03/) 覆盖五类资产。`S3M-01`—`S3M-40`、`S3F-01`—`S3F-14` 验证正向、结构失败、门禁、WIP、幂等、partial、重排、失效和 no-progress；S03 专项与全部 frozen regression 零错误。

S03 没有创建真实 BPM/BBT/CIV/BSR/SCP、运行 P02、读取 manuscript、选择试点或授予 chapter-production-complete、final-audited 等状态。唯一下一入口是审查并拆分 `P03-S04`。
