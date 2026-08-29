# P02-S09 变更、分幕与恢复样例

本目录只包含合成夹具和隔离试验基线，不是真实小说项目。人物、事件和状态均为抽象测试数据，不证明任何真实 formal 晋升、用户确认、传播、分幕、恢复、三章闭环或 `final-audited`。

## 资产

- `夹具/F01-F18`：18 个协议夹具，覆盖传播、边界与恢复。
- `隔离试验项目/baseline`：只读语义基线。E09 每次运行复制到独立临时 workspace，禁止原地修改。
- 未来 `运行记录`：E09 保存至少 8 次 before/intended/actual/receipt/oracle 记录。

## 隔离规则

1. 每次运行先计算 baseline fingerprint。
2. workspace 必须位于独立、经验证的临时根目录。
3. 所有写入只允许发生在该次 run root。
4. 运行后重算 baseline fingerprint，任何变化均为 isolation-conflict。
5. fixture 成功不提升真实项目状态或五门禁。
