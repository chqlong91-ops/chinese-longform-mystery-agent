# F05 决定性线索晚到导致 formal no

## Setup

- 标记：`synthetic-formal-fixture`；current formal 合法。
- 解答段首次说明门禁系统还记录“手动放行原因”，此前人物已完整读取该来源却未见此字段；供述依赖该字段锁定行为人。

## Expected

- AF=`source-timing/necessary-fact-late`，severity=blocking，gate effect=blocks-requested-scope。
- 公平结果=`impossible-without-late-information`；MRE=misplaced/missing-before-payoff。
- MRG=`no + evaluated`，ADP=`repair-required`。
- 禁止用供述或“事后能解释”放行。
- 唯一下一步：判定根因在 S04/P01 还是 S06 actual realization 后路由 RPC。

