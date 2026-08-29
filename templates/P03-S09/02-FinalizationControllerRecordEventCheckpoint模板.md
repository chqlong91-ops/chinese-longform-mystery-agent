# P03-S09 Finalization Controller、Record、Event 与 Checkpoint 模板

## 产物合同

- 用途：实例化 FSI/FSP、BCR/BCD、BRM/BRV、BRPM/BRTV 和 controller。
- 创建路由：current S8I 候选进入 S09。
- 更新触发：phase、event、current pointer、partial 或 recovery 变化。
- 状态记录位置：controller、event registry 和 CP0—CP12。
- 真相源：current records、append-only events、CAS 与 post-read。
- non-claims：controller 不拥有 S08 verdict、L5 或 L6。

Controller/key/WIP：
Record identity/version/scope：
Input fingerprint：
Expected current：
Event/CAS：
Checkpoint/predecessor：
Allowed/prohibited writes：
Actual/not-read：
Stop/recovery action：
Post-read：
Unique next：
