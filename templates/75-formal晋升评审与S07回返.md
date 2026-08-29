# formal 晋升评审与 S07 回返

## 产物契约

- 用途：保存 Formal Promotion Review、Formal Promotion Run、A4、层/活动指针变化、Post-check 和 Formal-Audit Return Handoff。
- 创建触发：current S07 `formal-promotion-request` 到达 S08。
- 更新触发：source/target/version/scope/A4、layer registry、pointer、run、补偿或回返变化；历史运行追加，不原地覆盖。
- 活动真相源：本文件拥有 FPR/FPN/FRH；MS 拥有正文，62 拥有层/指针，状态/事件拥有 current 快照，S07 拥有 audit/MR。
- 非证明：FPR eligible 或 FPN promoted 不证明 formal-audit、MR、confirmed、synced 或 final-audited。

## Formal Promotion Review

- FPR：`<FPR-AH-seq>@vNNN#scope`
- Status：`not-reviewed|in-review|eligible|rejected|blocked|stale|conflict|closed`
- Source AH/AUR/ADP：`<refs>`
- Source CH/MS/version/layer/scope/fingerprint：`<current revised ref>`
- Target formal family/layer/scope/artifact：`<refs>`
- Mode：`first-formal|replace-formal|promote-subscope`
- Existing formal/pointer：`<refs|none>`
- Open AF/risk/preserved constraints：`<items>`
- Eligibility evidence/missing/conflict：`<items>`
- Result/reason：`<value/reason>`
- Stop/unique next action：`<stop>/<one-action>`

## A4

- Authority：`A4`
- Basis/authorizer/evidence：`<project-rule|user>/<actor>/<ref>`
- Action：`formal-promote|formal-replace`
- Subject/source/target/version/layer/scope：`<refs>`
- Allowed operation：`<exact layer/pointer action>`
- Explicit non-grants：`prose-write|confirmation|sync|MR|evidence|final|scope-expansion`
- Validity/expiry/revocation：`<rules>`
- Source fingerprints：`<refs>`
- Status：`pending|valid|expired|revoked|conflict`

## Preflight

- AH/FPR current and unique：`yes|no`
- Source revised unique/current：`yes|no`
- Draft-review ready/current：`yes|no`
- No blocking finding/conflict：`yes|no`
- Scope atomic/closed：`yes|no`
- Target formal/pointer resolvable：`yes|no`
- A4 exact/current：`yes|no`
- Content fingerprint check possible：`yes|no`
- Result：`ready|rejected|blocked|stale|conflict`
- Unique next action：`<one-action>`

## Formal Promotion Run

- FPN：`<FPN-FPR-seq>@rNNN#scope`
- Status：`not-started|in-progress|promoted|failed|partial|compensating|compensated|blocked|stale|conflict`
- Before snapshot：`<source/old-formal/registry/pointer/events/fingerprints>`
- Prepared target/layer entry：`<ref/status>`
- Source/target content fingerprints：`<before>/<after>`
- Applied event bundle：`<events>`
- Old pointer action：`<none|deactivated>`
- New pointer action：`<set|not-set|conflict>`
- Last safe checkpoint：`<phase/item>`
- Partial/failed side effects：`<items|none>`
- Compensation：`<plan/run/result|none>`
- Result/stop/next：`<value>/<stop>/<one-action>`

## Post-check

- Source revised preserved/readable：`yes|no`
- Content bytes/fingerprint unchanged：`yes|no`
- Formal layer entry current：`yes|no`
- Exactly one active formal pointer：`yes|no`
- Registry/event projection matches：`yes|no`
- Old formal historical and preserved：`yes|no|n/a`
- No confirmation/sync/MR/final side event：`yes|no`
- Result：`matched|partial|failed|conflict`

## Formal-Audit Return Handoff

- FRH：`<FRH-FPN-seq>@vNNN#scope`
- Status：`not-created|active|consumed|invalidated|stale|conflict`
- FPR/FPN/A4：`<refs>`
- Current formal CH/MS/version/layer/scope/location：`<refs>`
- Source revised/derived-from：`<ref>`
- Content/layer/pointer evidence：`<refs>`
- Draft-review chain：`<AH/AUR/ADP refs>`
- STY/ERE/POV/continuity/preserved：`<refs/items>`
- Old formal invalidation impact：`<items|n/a>`
- Open risk/stop：`<items|none>`
- Explicit non-claims：`not-formal-audited|not-MR|not-confirmed|not-synced|not-final`
- Unique next action：`S07 formal-audit`

## 晋升与回返事件

| Event | Bundle | Object/version/scope | Field | Before | After | Authority | Evidence | Status |
|---|---|---|---|---|---|---|---|---|
| `<event-id>` | `<bundle>` | `<FPR/FPN/layer/pointer/FRH>` | `<one-field>` | `<old>` | `<new>` | `A4` | `<ref>` | `proposed|applied|rejected` |

## 写回检查

- [ ] source 是唯一 current revised，AH/ADP/A4/current fingerprints 匹配。
- [ ] 晋升未修改正文 bytes 或 content version。
- [ ] source revised 与 old formal 历史保留。
- [ ] formal-promoted 只改变 layer/pointer。
- [ ] partial/conflict 没有创建 FRH。
- [ ] promoted 的唯一下一步是 S07 formal-audit。
- [ ] 没有产生 confirmation、sync、MR、evidence 或 final。

## P02-S09 兼容入口

- 本对象的 stable ID、version、scope、currentness、fingerprint 与引用关系可作为 IGS 节点/边证据；路径或摘要不是身份。
- 本对象变化时，只沿显式 relation 和适用 dimension 形成 affected item；未触及范围必须有 PEI，不能全量清空。
- 若被列入幕边界或恢复白名单，必须引用 current BSS/RPM 条目及稳定位置；本模板自身不证明 propagation、act-boundary、recovery 或 final 通过。
