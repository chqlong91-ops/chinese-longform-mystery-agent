# Evidence-Ready 评估与交接

## 产物契约

- 用途：保存指定消费者集合的 ERE 专业评价、局部聚合、门禁证据、状态事件入口和 S06 现实约束回传。
- 创建触发：当前 RC/RB 的 RA 足以评价，或旧 ERE 因来源/消费者/退路变化需要重算。
- 更新触发：成员版本、来源指纹、RA/FB、value/evaluation、冲突、失效或下游资格变化；追加 revision，不原地覆盖 applied 记录。
- 活动真相源：本文件拥有专业评价证据；章节状态拥有当前 evidence-ready 快照，状态事件解释变化。
- 非证明：ERE yes 不代表 creative-confirmed、A3、MS、正文、manuscript-realized、synced 或 final-audited。

## 评价范围

- ERE：`<ERE-ID>@rNNN#consumer-set`
- 状态：`draft|applied|superseded|stale|conflict`
- 任务/路由：`<task>/<route>`
- Target：`<CH/SC/IS/MS-ref#scope>`
- Parent CH/CC：`<refs>`
- RH：`<RH-refs>`
- RB members：`<current RB refs>`
- Excluded members/reasons：`<refs/reasons|none>`
- RC/RA/RS/FB：`<refs>`
- Consumer/source fingerprint：`<fingerprint>`
- 检查者/时间：`<route>/<ISO-8601>`

## Gate Evaluation

- Value：`yes|partial|no|n/a`
- Evaluation：`not-evaluated|pending|evaluated|stale|conflict`
- Required checks/strengths：`<requirements>`
- Covered：`<member/claim/evidence>`
- Missing：`<member/claim/minimum-source>`
- Blocking：`<member/scope/stop>`
- Allowed work：`<safe work>`
- Accepted FB/decision：`<FB-ref/state|none>`
- Conflicts：`<refs|none>`
- Evidence addresses：`<RA/RS/NAD refs>`
- Minimum next read：`<one-source|none>`
- Unique next action：`<one-action>`

## 成员评价

| RB/consumer | RC | Required strength | RA/max strength | Q1-Q7 | FB verification/decision | Value/evaluation | Covered | Missing/blocking | Allowed work |
|---|---|---|---|---|---|---|---|---|---|
| `<refs>` | `<RC-ref>` | `<strength>` | `<RA/strength>` | `<summary>` | `<FB/state>` | `<value/evaluation>` | `<covered>` | `<missing>` | `<work>` |

## N/A 证明（仅在使用 n/a 时）

- NAD：`<NAD-ID>`
- 声明范围/活动消费者：`<refs>`
- CC/SC/BT/IS 检查：`<result>`
- 无 decisive/required-precision 依赖的理由：`<reason>`
- 排除的非决定性项及不承担功能：`<items>`
- 来源指纹/检查者/时间：`<fingerprint/route/time>`
- 重检触发：`<triggers>`

没有完整 NAD 时不得写 n/a。

## 局部聚合

- Parent target：`<ref>`
- Applicable/current members：`<refs>`
- Member source revisions：`<refs>`
- Aggregation rule/result：`<rule/result>`
- Ready subscopes：`<refs|none>`
- Blocked subscopes：`<refs|none>`
- Preserved subscopes：`<refs|none>`
- 是否存在 stale/conflict：`yes|no`

## 状态事件

| Event | Bundle | Object/version/scope | Field | Before | After | Authorization | Evidence | Invalidated/preserved | Status |
|---|---|---|---|---|---|---|---|---|---|
| `<event-id>` | `<bundle>` | `<ref>` | `evidence.value|evidence.evaluation|risk|stop|eligibility` | `<old>` | `<new>` | `A0|A1|A4` | `<ERE/RA>` | `<scope>` | `proposed|applied|rejected` |

一条事件只改变一个对象版本/范围的一项字段。

## S06 Downstream Constraint Return

- Target CC/SC/BT/IS/candidate MS：`<refs>`
- ERE/RA：`<refs>`
- Eligible consumer scope：`<scope|none>`
- Blocked consumer scope：`<scope|none>`
- Allowed assertion：`<maximum assertion>`
- Required qualifier：`<qualifiers>`
- Forbidden assertions：`<claims>`
- Observable form/POV access：`<form/access>`
- Interpretation/remember/disclose/use limits：`<limits>`
- Fields/precision/timing/retention：`<limits>`
- Accepted FB/adoption scope：`<refs|none>`
- Safe-output mode：`<permission>`
- Preserved/Open/Blocking：`<items>`
- Invalidation triggers：`<triggers>`
- S07 expected-realization entry：`<constraints-to-check>`
- Bound DR/WA proposal：`<DR-ref>/<WA-ref|none>`
- Bound target MS/layer/scope：`<ref/layer/scope|none>`
- Consumer/source fingerprint for PGR：`<fingerprint>`
- DCE required reality checks：`<items>`

本交接只满足现实前置；S06 仍需独立检查 CC/PCE/WH、creative authorization、A3、活动稿件层、MS、上下文和文风合同。

## 失效与恢复

- 最近 RCG：`<change-ref|none>`
- ERE/member/source 指纹一致：`yes|no`
- Stale/invalidated refs：`<refs|none>`
- Open conflicts：`<refs|none>`
- Downstream invalidation requests：`<MS/manuscript refs|none>`
- Active R/RC/RB/RA/FB/ERE：`<refs>`
- Recovery allowed work：`<safe work>`
- Minimum next source：`<one-source|none>`
- Unique next action：`<one-action>`

## 写回检查

- [ ] value/evaluation 组合合法。
- [ ] yes 覆盖所有 blocking/required-before-prose 成员。
- [ ] partial 列 covered、missing、blocking、allowed work。
- [ ] n/a 有 NAD，no 有恢复条件。
- [ ] 聚合声明成员版本和来源修订，没有平均分。
- [ ] stale/conflict ERE 没有交给 S06。
- [ ] FB verification 与 adoption decision 分开。
- [ ] 事件原子且状态快照引用 applied bundle。
- [ ] 下游交接未授予 A3、MS 或正文门禁。
- [ ] DR/WA proposal 没有把 ERE 解释为授权；绑定只覆盖 current eligible consumer scope。
- [ ] PGR/DCE/PRH 若引用本 ERE，使用相同消费者和来源指纹。

## P02-S07 消费与失效入口

- Consuming ARQ/AUR/MS/version/scope：`<refs>`
- MRE/AF actual claim result：`<refs>`
- ERE mismatch/new claim：`<items|none>`
- Affected MRG/RPC：`<refs|none>`
- Required S05 action：`<revalidate|fallback|conflict-resolution|none>`

ERE yes 只说明现实前置；S07 仍须检查 actual wording、POV、使用权和 qualifier，且不得反向扩大 ERE。

## P02-S08 结构同步消费边界

- SFD/SYP consumer：`<refs>`
- Eligible RC/RB scope/max proposition：`<refs>`
- Confirmed adoption vs verification：`<CFD>/<ERE>`
- Stale/blocked consumers：`<items>`
- SYV/actual target：`<refs>`

confirmation/sync 不改变 ERE value/evaluation。新结构版本若改变现实 consumer，关系可达 ERE 与正文资格需重新评价。

## P02-S09 兼容入口

- 本对象的 stable ID、version、scope、currentness、fingerprint 与引用关系可作为 IGS 节点/边证据；路径或摘要不是身份。
- 本对象变化时，只沿显式 relation 和适用 dimension 形成 affected item；未触及范围必须有 PEI，不能全量清空。
- 若被列入幕边界或恢复白名单，必须引用 current BSS/RPM 条目及稳定位置；本模板自身不证明 propagation、act-boundary、recovery 或 final 通过。
