# LCG Coverage、Atomic Update、Change 与 Recovery 模板

## 产物合同

- 用途：计算 expected/actual coverage，原子发布新图，并在变化后选择性失效和恢复。
- 创建路由：S04 controller；状态/verdict 仍由合法 downstream owner。
- 更新触发：source/consumer/relation/profile/query/current/schema/algorithm 或 manifest 变化。
- 状态记录位置：coverage、delta、event log、Current Registry、recovery package。
- 真相源：owner expected manifests + committed events + registry CAS；projection 可重建。
- non-claims：current/coverage/fixture/exit 0 不授 semantic verdict 或 `long-range-consistent`。

## Coverage

- LCG/basis/watermark/fingerprint：
- expected manifests / applicability decisions：
- eligible actual / observational：
- missing / extra / duplicate / unresolved / NAD：
- per-dimension result / aggregate value / evaluation：
- error/evidence index / owner routes：

## Atomic update

- operation / target / predecessor / expected current：
- idempotency / intent / algorithm：
- expected/actual/inverse write sets：
- prepare/write/coverage/post-read/CAS/final events：
- partial class / compensation：

## Change、接口与恢复

- delta / changed dimensions / seed：
- expected/actual frontier：
- invalidated / preserved / unresolved：
- preservation evidence：
- S05 mutation/query/checkpoint refs：
- S06 audit-input/non-verdict refs：
- no-progress / primary recovery / checkpoint / unique_next：

