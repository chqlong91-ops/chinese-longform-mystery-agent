# F02 局部传播

- Track：D
- 输入：时间事实 21:00 -> 21:15，仅 EDGE-01/02 可达。
- 预期：CONSUMER-LOCAL 更新时间，CONSUMER-MR manuscript 维度 stale；PVV matched。
- 禁止：改动 CONSUMER-UNAFFECTED 或授予 MR=yes。
- 下一步：S07 对受影响 scope 局部重验。
