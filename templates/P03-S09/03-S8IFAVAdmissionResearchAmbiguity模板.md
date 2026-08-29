# P03-S09 S8I/FAV Admission、Research 与 Ambiguity 模板

## 产物合同

- 用途：实例化 `P03-FINAL-STATE-ENTRY-VALIDATION@v001`。
- 创建路由：收到一个 current S8I candidate。
- 更新触发：ASM/FAV/current、finding closure、disposition 或 permit 变化。
- 状态记录位置：FAD、CP1—CP2。
- 真相源：S7I/ASM/FAV/closure/disposition/events/post-read。
- non-claims：admission 不授 final-audited，不默认读取全文。

S8I/ASM/FAV tuple：
Required exact-set：
Actual/missing/unexpected：
Research blocking/residual：
Ambiguity eligibility/L5：
Permit release/context disposal：
Current/watermark/expiry：
FAD value/evaluation：
Reason codes：
Owner/stop：
Unique next：
