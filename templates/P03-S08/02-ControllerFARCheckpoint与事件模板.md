# P03-S08 Controller、FAR、Checkpoint 与事件模板

## 产物合同

- 用途：实例化 S8CR、FAR、S8EI、CP0-CP10 和幂等事件。
- 创建路由：P03-FULL-BOOK-AUDIT-CONTROLLER@v001。
- 更新触发：phase commit、pause、stop、owner return、new ASM 或 recovery。
- 状态记录位置：S8CR current registry、FAR、S8CP。
- 真相源：committed event、current registry 与 final post-read。
- non-claims：controller committed 不证明专业轨、FAV 或任何全书状态。

S8CR/FAR ref：
ASM/audit scope：
Intent/idempotency：
Phase/predecessor：
audit_wip/manuscript_writer_wip：
Expected/actual read-write：
Source fingerprint：
Event/watermark：
CP0-CP10：
Post-read：
Stop/root cause/action：
Unique next：
