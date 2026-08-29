# LCG Query、Read Permit 与 Budget 模板

## 产物合同

- 用途：以最小上下文回答一个明确问题，远场结构优先，正文只读精确许可位置。
- 创建路由：S04 query controller；S05/S06 以 task-bound request 调用。
- 更新触发：purpose/basis/seed/profile/permit/budget/source fingerprint 改变时新 query/run。
- 状态记录位置：query record、permit、actual/not-read manifest、checkpoint。
- 真相源：versioned owner source 与 actual permitted read event；query summary 不是真相源。
- non-claims：query sufficient 不证明答案为真、coverage complete 或 audit passed。

## Query

- query_id/ref / run_ref：
- requester / task / purpose / expected answer：
- basis refs / fingerprint / as-of：
- dimensions / seed nodes-edges / target positions：
- load_profile / traversal / stop boundary：

## Read permit

- permit_ref / issuer / authorization：
- allowed objects/versions/layers/scopes/positions：
- allowed operations/outputs：
- prohibited reads/writes：
- valid event window / expiry / reuse：

## Budget、actual 与恢复

- max files/objects/positions/tokens/hops/dimensions：
- adjacent/future limits / attempts：
- expected_reads / actual_reads / not_read_manifest：
- denied / over_budget / unresolved / conflict：
- post_read / checkpoint / remaining budget：
- stop / unique_next：

