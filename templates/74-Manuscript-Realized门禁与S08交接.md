# Manuscript-Realized 门禁与 S08 交接

## 产物契约

- 用途：保存 RRS、MRE、MRG、聚合证据和两类 S08 Audit Handoff。
- 创建触发：AUR 开始评价 required realization；formal-audit 需要写 MR evaluation/value；ready disposition 需要向 S08 请求后续动作。
- 更新触发：成员、actual location、MRE、AF、MRG、聚合、AH、来源或失效变化；新 MS version 创建独立记录。
- 活动真相源：本文件拥有 RRS/MRE/MRG/AH；MS 拥有正文，73 拥有 AF/ADP/RPC/RPD，章节状态/事件拥有 current 门禁快照。
- 非证明：candidate MRE、MR yes 或 AH 不证明 formal 已晋升、用户已确认、结构已同步、全稿正确或 final-audited。

## Required Realization Set

| Requirement | Necessity | Source/version | Expected function/form | Window/location | POV/permission | Claim/qualifier | Criteria | Status |
|---|---|---|---|---|---|---|---|---|
| `<RRS-ID>` | `blocking-required|required|conditional|informational` | `<refs>` | `<job/form>` | `<limits>` | `<limits>` | `<limits>` | `<audit items>` | `current|stale|conflict` |

## Manuscript Realization Evidence

| MRE | Requirement | Target MS/version/layer/scope | Expected | Actual location/fingerprint | Observed form | Result | POV/claim/timing fit | AF | Evidence role |
|---|---|---|---|---|---|---|---|---|---|
| `<MRE-AUR-requirement-seq>@vNNN#scope` | `<RRS-ref>` | `<refs>` | `<function/window>` | `<location|missing-search>` | `<evidence>` | `present|missing|misplaced|overstated|conflicting|indeterminate|not-applicable` | `<result>` | `<refs|none>` | `candidate-observation|formal-gate-evidence` |

### 缺失/冲突检查

- Expected search scope complete：`yes|no`
- Target full text read：`yes|no`
- Synonym/distributed realization considered：`yes|no`
- Position/context/version conflict absent：`yes|no`
- Requirement applicable：`yes|no/NAD`
- Missing allowed：只有全部 yes；否则 `indeterminate`。
- Conflict locations/propositions：`<items>`
- Residual uncertainty：`<items|none>`

## Manuscript-Realized Gate Record

- MRG：`<MRG-MS-seq>@vNNN#scope`
- Target CH/MS/version/layer/scope/fingerprint：`<refs>`
- Formal promotion/source candidate：`<refs>`
- AUR/ARQ：`<refs>`
- Value：`yes|partial|no|n/a`
- Evaluation：`not-evaluated|in-progress|evaluated|stale|conflict`
- Current member set/versions：`<refs>`
- Covered/missing/blocking/n-a：`<items>`
- MRE/AF/ADP：`<refs>`
- Aggregation basis：`<members/rule>`
- Residual uncertainty/allowed work：`<items>`
- Authority/event：`A1/<event-id>`
- Invalidation triggers：`<triggers>`
- Unique next action：`<one-action>`

## MR yes 共同条件

- [ ] Target 是唯一 current formal。
- [ ] formal promotion/source chain current 且同范围。
- [ ] ARQ=formal-audit，AUR completed。
- [ ] Review CV sufficient，目标全文/必要近场实际读取。
- [ ] RRS current 且无漏列 blocking-required/required。
- [ ] 所有必要成员有 current present formal-gate-evidence。
- [ ] 悬疑/POV/ERE/连续性/正文工艺/STY/安全标准完成。
- [ ] 无 blocking/indeterminate AF 或 conflict。
- [ ] 聚合成员/版本与 scope 完全一致。
- [ ] A1 gate event applied，下一步唯一。

任一项不满足不得 yes。candidate、formal 层标签、DCE/PRH、用户认可或总分不能补足。

## 聚合

| Target scope | Current members/versions | yes | partial/no | n-a/NAD | Blocking/conflict | Result | Evidence |
|---|---|---|---|---|---|---|---|
| `<BT/IS/SC/CH>` | `<refs>` | `<refs>` | `<refs>` | `<refs>` | `<refs>` | `yes|partial|no|n/a` | `<refs>` |

不平均、不按比例、不跨版本/相邻章节继承；chapter yes 不提升 act/book/final。

## Audit Handoff

- AH：`<AH-AUR-type-seq>@vNNN#scope`
- Type：`formal-promotion-request|confirmation-review-request`
- Status：`draft|active|consumed|invalidated|expired|conflict`
- Target CH/MS/version/layer/scope/fingerprint：`<refs>`
- AUR/ADP/MRE/AF/MRG：`<refs>`
- Baseline fingerprints：`<refs>`
- Preserved constraints/open risks：`<items>`
- Requested S08 action：`<promotion-validation|confirmation-review>`
- Required authority：`A4|user/S08-rule`
- S08 must independently validate：`<items>`
- Prohibited inference：`<formal-not-yet|not-confirmed|not-synced|not-final>`
- Expiry/invalidation：`<triggers>`
- Unique next action：`<one-action>`

### 两类条件

- formal-promotion-request：只来自 current raw/revised 的 `candidate-ready-for-formal-request`；不携带 MR value。
- confirmation-review-request：只来自 current formal 的 `formal-ready-for-confirmation-review` 与 MRG evaluated+yes；不构成用户确认。

repair/incomplete/blocked 不创建 S08 AH。

## 门禁/交接事件

| Event | Bundle | Object/version/scope | Field | Before | After | Authority | Evidence | Status |
|---|---|---|---|---|---|---|---|---|
| `<event-id>` | `<bundle>` | `<MRE/MRG/AH-ref>` | `<one-field>` | `<old>` | `<new>` | `A1|A4` | `<ref>` | `proposed|applied|rejected` |

## Explicit non-claims

- [ ] candidate MRE 不是 MR gate evidence。
- [ ] formal layer 不等于 formal-audit completed。
- [ ] MR yes 不等于 confirmed/synced/final-audited。
- [ ] formal-promotion-request 不证明 S08 已晋升。
- [ ] confirmation-review-request 不证明用户已确认。
- [ ] 新 MS version 没有继承旧 MRG/AH。

## 写回检查

- [ ] RRS/MRE/MRG/AH 对象、版本、范围和来源一致。
- [ ] missing 有完整缺失检查，否则为 indeterminate。
- [ ] value/evaluation 分开，pending 未被当 value。
- [ ] partial/no/n-a 有 covered/missing/blocking/NAD 和下一步。
- [ ] AH 只在对应 ready disposition 下创建。
- [ ] 聚合没有越过 chapter 或提升 final-audited。

## P02-S08 消费回执

- AH type/ref/status：`<ref>`
- S08 consumer：`<FPR|CFR-ref>`
- Consumed source version/scope/fingerprint：`<refs>`
- S08 result：`<FPN/FRH|CFD/SFD/SYP/SYR/SYV|none>`
- Invalidated/expired reason：`<reason|none>`
- Unique next action：`<one-action>`

formal-promotion-request 只能进入 FPR；confirmation-review-request 只能进入 CFR。S08 消费回执不反向修改 MRG，S08 状态变化时按关系可达范围使 AH/MRG consumer 资格 stale。

## P02-S09 兼容入口

- 本对象的 stable ID、version、scope、currentness、fingerprint 与引用关系可作为 IGS 节点/边证据；路径或摘要不是身份。
- 本对象变化时，只沿显式 relation 和适用 dimension 形成 affected item；未触及范围必须有 PEI，不能全量清空。
- 若被列入幕边界或恢复白名单，必须引用 current BSS/RPM 条目及稳定位置；本模板自身不证明 propagation、act-boundary、recovery 或 final 通过。
