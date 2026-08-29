# BPM 生产地图模板

## 产物合同

- 用途：把唯一 current BP manifest 确定性编译为只读生产图 projection。
- 创建路由：`P03-S03 / PRODUCTION-MAP-BUILD`。
- 更新触发：BP/BK/BSN、required relation、scope 或 map algorithm 发生规范变化。
- 状态记录位置：Current Registry、event log、BPM projection 和 SCP。
- 真相源：current BK/BP/BSN 与 `P03-OBJECT-RELATION@v001`；本模板不是事实源。

## Identity 与 Source

- map_ref：
- book_ref / bk_ref / bp_ref / bsn_ref：
- schema/content/projection revision：
- scope_ref：
- source manifest/relation set/event watermark：
- source fingerprint：
- algorithm version：

## Nodes 与 Edges

- expected/actual node keys：
- expected/actual edge keys：
- chapter/act/boundary/batch-candidate nodes：
- member-of / precedes / depends-on / requires-gate：
- missing / extra / duplicate / orphan / cross-version / cycle：

## Deterministic Output

- tie-break policy：
- topological order：
- graph/order hash：
- rebuild comparison：

## Control

- current event / post-read：
- checkpoint / stop / recovery / unique next：
- non-claims：不证明 ready、章节生产或任何全书状态。
