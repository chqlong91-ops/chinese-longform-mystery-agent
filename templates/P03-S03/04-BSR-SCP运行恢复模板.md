# BSR 与 SCP 运行恢复模板

## 产物合同

- 用途：记录单 current 调度 run、确定性 ready/selection、WIP 和可重放 checkpoint。
- 创建路由：`P03-S03 / SCHEDULE-RUN` 与 `CHECKPOINT-SAVE`。
- 更新触发：committed 调度动作、pause/stop、source drift 或 recovery action。
- 状态记录位置：BSR/SCP、Current Registry、event log 和 recovery entry。
- 真相源：committed events + registry CAS + current source refs；mtime/summary 不是真相。

## BSR

- run/current key/owner/authorization：
- BK/BP/BPM/BBT refs/scope/fingerprint：
- controller state：
- ready set/hash/tie-break/chosen PN：
- WIP claim/lease：
- expected/actual action：

## SCP

- checkpoint/predecessor/current key：
- event watermark/last committed/pending action：
- source/map/batch/ready/WIP hashes：
- expected/actual read-write/side effects：
- completed/pending/blocked members：
- pause/root cause/attempt/delta：
- required reads / explicit not-read：

## Control

- post-read / checkpoint hash：
- stop / recovery action / unique next：
- non-claims：run/checkpoint 不证明章节质量或 recovery-verified。
