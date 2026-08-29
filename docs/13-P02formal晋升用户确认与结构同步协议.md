# P02 formal 晋升、用户确认与结构同步协议

## 文档信息

- 所属阶段：P02 章节规划与正文生产闭环原型
- 对应任务：P02-S08
- 状态：已冻结
- 冻结日期：2026-08-14
- 上游：`docs/06` 至 `docs/12`
- 下游：P02-S09 至 P02-S10

## 目标与边界

本协议建立受 A4 控制、可追踪、可验证、可中断恢复的四段式治理闭环：

`formal 晋升 -> 返回 S07 formal-audit -> 用户明确确认 -> 结构事实同步与验证`

S08 只管理 formal 层/活动指针晋升、确认请求与决定、结构事实差异、同步计划/运行/验证、失效、冲突和恢复。它不生成或修改正文，不替代 S07 专业正文审计，不把用户确认当现实核验，不用正文静默覆盖结构真相，不执行 S09 的真实变更传播/分幕/跨会话压力验证，不执行 S10 三章集成或阶段总验收，也不授予 `final-audited`。

## 七类事实分权

| 事实 | 唯一规范证据 | 不代表 |
|---|---|---|
| A4 已授权 | 精确 A4 对象/action/version/scope/evidence | 动作已执行、正文已确认 |
| formal 已晋升 | layer registry、唯一 active pointer、formal-promoted event、post-check | formal-audit、MR、确认、同步 |
| Manuscript-Realized | S07 current formal 的 MRE/MRG | 用户确认、结构同步、全书正确 |
| 用户已确认 | current CFD + 用户证据地址 + disclosure/response fingerprints | 现实正确、所有隐含事实获准 |
| 同步已授权 | CFD 或独立 A4 的精确 target authorization | target 已写入 |
| 结构已同步 | current SYV + 所有 required target actual match + sync event/state | MR、evidence、传播/分幕、final |
| final-audited | P02 不授予 | S08 任何工作结果 |

任一事实不能从相邻事实、文件层标签、用户泛化反馈、事件存在、写入命令成功或总览声明推断。

## 运行顺序

1. S07 对 current raw/revised 完成 draft-review 并形成 `formal-promotion-request`。
2. S08 Track-P 复核 current source、A4、层/范围/指纹并执行 formal promotion。
3. S08 生成 FRH，把合法 current formal 交回 S07。
4. S07 对 current formal 新建 formal-audit，不继承 draft-review。
5. formal-audit 满足后，S07 形成 `confirmation-review-request`。
6. S08 Track-C 披露唯一 CFR，解释并记录用户 CFD。
7. 对已确认且获同步授权的事实建立 SFD 和 SYP。
8. 逐 target 执行 SYR，实际重读全部 required targets，生成 SYV。
9. 根据 SYV 写 sync/risk/stop、影响、恢复入口和 S09 handoff。

用户主动/提前反馈可以作为 interrupt 记录，但不能跳过 formal-audit、SFD 分类、目标验证或同步前置。

## 核心对象

| 对象 | 稳定引用 | 职责 | 不拥有 |
|---|---|---|---|
| Formal Promotion Review | `FPR-<AH-ID>-<seq>@vNNN#scope` | 晋升资格、A4、source/target、阻塞和决定 | 正文、层、状态 |
| Formal Promotion Run | `FPN-<FPR-ID>-<seq>@rNNN#scope` | 一次 layer/pointer 晋升 attempt 与补偿 | 资格、正文质量 |
| Formal-Audit Return Handoff | `FRH-<FPN-ID>-<seq>@vNNN#scope` | 将合法 current formal 交回 S07 | S07 audit/MR |
| Confirmation Request | `CFR-<MS-ID>-<seq>@vNNN#scope` | 用户审阅对象、变化、状态、选项和不包含事项 | 用户决定 |
| Confirmation Decision | `CFD-<CFR-ID>-<seq>@vNNN#scope` | 精确用户决定、证据、scope 与 sync authorization | 结构事实/同步结果 |
| Structural Fact Delta | `SFD-<CFD-ID>-<seq>@vNNN#scope` | formal 命题与结构 owner 的 old/new/classification | 目标实际值 |
| Sync Plan | `SYP-<CFD-ID>-<seq>@vNNN#scope` | eligible target、依赖、before/intended、验证与补偿 | 写入结果 |
| Sync Run | `SYR-<SYP-ID>-<seq>@rNNN#scope` | 一次逐目标写入 attempt、actual、checkpoint | 计划资格/synced |
| Sync Verification Receipt | `SYV-<SYR-ID>-<seq>@vNNN#scope` | 全部 required target 实际重读与 disposition | 目标内容本身 |
| Sync Impact Handoff | `SIH-<SYV-ID>-<seq>@vNNN#scope` | 向 S09 交实际变化、消费者和待验证事项 | 传播/分幕验证结果 |

路径不是对象身份；content version、record revision、run attempt 和 event sequence 分开。正文由 MS 拥有，用户决定由 CFD 证明，结构事实由对应 owner 文件拥有，current 状态由项目/章节状态与事件拥有。

## 双入口与受控 interrupt

### Track-P

只接受 current S07 `formal-promotion-request`。流程：FPR -> A4 preflight -> eligible/rejected/blocked/stale/conflict -> FPN -> post-check -> FRH -> S07 formal-audit。

### Track-C

只把 current S07 `confirmation-review-request` 作为主成功入口。流程：CFR -> 用户反馈解释 -> CFD -> SFD -> SYP -> SYR -> SYV -> 状态/影响/SIH。

### User-Feedback Interrupt

用户提前确认可唯一定位的 current version/scope 时可记录 CFD，但派生视图为 `confirmed-but-pending-audit`，sync 保持 pending/not-required，不创建 ready SYP。审计修复或新版本使关系可达旧确认 stale。

## A4 合同

A4 至少记录 authorizer/evidence、action、subject/source/target/version/layer/scope、allowed operation、explicit non-grants、validity/expiry/revocation、source fingerprints、stop 和唯一下一步。

动作必须精确为 formal-promote、formal-replace、confirm、sync、withdraw、major-change 或可拆分 bundle。一个 A4 不因“相关动作”自动覆盖晋升、确认和同步。

默认不存在自动晋升。项目规则只有在自身已确认、可撤销并明确授权 exact eligible scope 时才可预授权；否则需要用户精确授权。普通“继续/可以/不错”不是 A4。

## formal 晋升

### 资格

- current S07 promotion AH 与 draft-review ADP；
- 唯一 current revised MS/version/layer/scope/fingerprint；
- 无 blocking finding/conflict；
- scope 是可独立登记的闭合稿件范围；
- target formal family/registry/pointer 可唯一；
- exact current A4；
- content、layer、pointer、event 可 post-check。

FPR 值域：eligible、rejected、blocked、stale、conflict。

### 内容与层语义

晋升不改变正文 bytes 或 content version。若 formal 使用独立路径，复制前后 content fingerprint 必须一致；路径变化不创建内容版本。source revised 保留。

首次 formal 创建 layer entry/active pointer。替换 formal 时 old formal 变 historical/superseded，但文件、内容、事件、审计、确认和同步历史保留；新 formal 不继承旧状态。

局部晋升只在 scope 是闭合、可独立审计/确认/同步的 MS slice 时允许，否则回 S03/S06 整理边界。

### 原子运行与补偿

FPN 依次 snapshot、prepare、pre-commit recheck、apply event bundle、post-check、return。业务 bundle 不冒充文件系统事务。

FPN 结果：promoted、failed、partial、compensating、compensated、blocked、stale、conflict。只有 promoted + post-check matched 创建 FRH。partial/pointer conflict 不按 mtime 或质量选择 current；按 before snapshot/事件补偿或请求 A4 解析。

FRH 明确声明 promotion 不是 formal-audit、MR、confirmation、sync 或 final；唯一下一步是 S07 formal-audit。

## 确认请求与表达解释

### CFR basis

audit-ready、user-initiated-pre-audit、re-confirmation、clarification。

CFR 保存 CH/MS/version/layer/scope/fingerprint、audit/MR、变化/保留、风险、可决定维度、不包含事项、sync targets、用户面 disclosure fingerprint、expiry 和下一步。

### 用户可见审阅面

依次展示确认对象、正文入口、变化/保留、当前审计/MR/风险、用户正在决定的维度、不代表事项、可选回复和精确同步选择。

### 四个决定维度

- prose-acceptance；
- creative-fact-acceptance；
- sync-authorization；
- downstream-use-authorization。

一个维度的 yes 不传播给其他维度。

### 表达分类

confirm-as-is、confirm-subscope、changes-requested、reject、defer、ambiguous、unrelated-feedback。

“继续/可以/不错/很好/收到”默认只是 acknowledgement/feedback。“确认”只有在直接回应唯一 current、完整披露且未变化的 CFR 时可确认现有文本；sync authorization 仍需明确。混合反馈按不重叠 scope 拆分；未来条件性修改不能确认尚未产生的文本。

最多询问三个会 materially 改变对象、scope、决定类型或同步授权的问题，默认一次只问最阻塞的一项。

## CFD 生命周期

decision：confirmed、confirmed-subscope、changes-requested、rejected、deferred、ambiguous、no-decision。

lifecycle：current、superseded、withdrawn、stale、conflict、historical。

decision、lifecycle、confirmation_state、sync authorization 和 risk 独立。局部确认只更新精确范围；只有全部 current 子范围无 gap/overlap/conflict 时才能产生父范围聚合事件。

changes-requested 按 root owner 路由 S06/S07/S03/S04/S05/P01/S08/safety。拒绝不删除正文、不自动恢复旧 formal。撤回使用新事件保留历史。

已同步确认被撤回时，confirmation=withdrawn、sync=stale，建立 reversal/repair SFD 和新 A4；不得静默回滚结构。

新 MS version 不继承旧 confirmation。未触及范围也需 change-impact、稳定指纹和 current-version `confirmation-revalidated` 新事件，才能用于 current 版本。

## Structural Fact Delta

SFD item 保存 formal stable location、命题/qualifier、epistemic layer、old/new、classification、owner/target、CFD/A4、ERE/权限/安全、依赖、风险和下一步。

epistemic layer：actual-story-fact、character-observation、character-belief、character-memory、character-claim、reader-working-inference、narrative-framing、authorial-assertion、open-ambiguity。

七类 classification：

- existing-consistent：no-write verification；
- chapter-local：不晋升结构；
- eligible-for-promotion：可进入 SYP；
- structure-conflict：停止并回结构 owner；
- ambiguous：缺少唯一命题/owner/范围；
- unverified：超出 ERE/权限，回 S05；
- prohibited：违反项目硬规则、原创、安全或危险信息边界。

角色误解、读者工作答案、修辞和瞬时质地不能写进真实时间线。用户确认不能把 unverified/prohibited 变 eligible。

## 结构 owner

- 真实时间线/核心因果：P01 真实时间线；
- 人物知情/披露/使用：P01 权限矩阵；
- 线索：P01 线索台账；
- 嫌疑：P01 嫌疑路径；
- 揭示/结局：P01 揭示阶梯；
- 章节地图、CC/SC/BT/IS：P01/S04；
- 稳定设定/角色关系：项目对应 owner；
- 物件/凭证/路线/数量：对应 ledger；
- 现实能力/研究：S05 RS/RA/FB/ERE；
- 文风/正文工艺：S06/S07，通常 chapter-local；
- 工作/确认/sync/risk/gate：状态文件与事件，不作为 SFD 结构事实。

核心因果、责任、结局、世界规则、决定性线索/权限、主要嫌疑校正、章节边界、多章结构或新现实能力即使被用户确认，也先回 P01/S04/S05/A4，不由 S08 直接覆盖。

多 owner 命题拆成原子 items 并建立依赖。若所有 items 仅 existing-consistent/chapter-local/not-applicable，记录 no-sync-required，不创建空 SYR。

## Sync Plan/Run/Verification

### SYP

只有 eligible SFD、current CFD/sync authorization、current formal/audit/MR/ERE、唯一 target/before/after、无 conflict、安全可验证时 ready。

拓扑顺序：时间/身份/实际事件 -> 物件/凭证/路线/数量 -> 知情/权限 -> 线索/嫌疑/揭示 -> 章节地图/消费者 -> 设定/摘要。

SYP ready 不等于目标已写。

### SYR

运行前保存 source/target/event snapshot。每个 target 写前重验 fingerprint，写后立即重读 actual，记录 applied/remaining/blocked 和 checkpoint。跨文件 bundle 表示业务关联，不承诺原子事务。

SYR 结果：completed、partial、failed、compensating、compensated、stale、conflict。completed 仍需 SYV。

### SYV

每项结果：matched、missing、mismatched、over-applied、source-stale、target-stale、unverifiable、conflict。

汇总：synced、partial、pending、stale、conflict、not-required。

只有所有 required target actual matched、无 missing/mismatch/over-applied/stale/conflict，才能 `sync_state=synced`。

写入命令、target applied event、局部验证或总览均不能替代 SYV。

## Partial、补偿与 no-progress

- resume-forward：sources/plan/targets current，已写 matched，从 checkpoint 继续；
- compensate：完整 before、无未处理消费者、exact A4、新 SYP/SYR/SYV；
- replan：target/source/confirmation 变化，使旧 SYP stale；
- A4 resolution：核心事实或实际写入面无法安全恢复。

补偿不删除 partial 历史。相同根因连续两轮没有新增 matched、减少 blocker 或提高可判定性时标记 sync-no-progress，停止自动循环并回 root owner/用户。

## 失效、冲突与恢复

MS/formal/CFD/audit/MR/ERE/permission/target/SYP/SYR/SYV 变化只沿关系可达边失效；历史和无关范围保留。

冲突包括 source、target、write、event、scope、dependency、authority、recovery、safety。双 current、target 与 event 不符、恢复包漂移时，不按 mtime、编号、质量或摘要猜测。

恢复最小集：AGENTS/本协议、状态/事件、current FPR/FPN/FRH 或 CFR/CFD/SFD/SYP/SYR/SYV、MS/formal、A4、audit/MR/ERE、target before/actual/intended/fingerprint、applied/remaining/checkpoint、compensation/conflict/no-progress、SIH 和唯一下一步。

先解析对象/指针/授权，再读取最小 changed/remaining targets；默认不读全稿、未来正文、所有旧稿或旧聊天。

## S09 交接

SIH 保存实际 changed targets old/new/version/fingerprint、applied/partial/compensated、direct consumers/relations、preserved/new claims、失效维度、未决 risk，以及传播/分幕/恢复待验证项。

SIH 不证明传播、分幕连续性、跨会话压力或 final 已通过。S08 只记录 direct/reached impact，真实验证留给 S09。

## 原子事件

- promotion：formal-promotion-review/run、formal-layer-entry、formal-promoted、formal-active-pointer、promotion-compensation、formal-audit-return；
- confirmation：confirmation-request/decision/subscope/changes/rejected/withdrawn/superseded/invalidated/revalidated；
- sync authorization：granted/limited/withheld/revoked；
- sync：sync-plan、sync-run、sync-target、sync-verification、sync-state；
- recovery：sync-compensation、sync-conflict、sync-source-revalidated、sync-impact-handoff。

一条事件只改变一个对象/version/scope 的一个字段；bundle 不合并跨维事实。applied 历史不原地改写。

## 模板、夹具与验证

- 新模板：75 formal 晋升评审与 S07 回返、76 用户确认请求与决定、77 结构事实差异与同步计划、78 同步运行验证与恢复；
- 兼容入口：00、01、02、10、11、20、21、22、30、40、41、42、50、60、61、62、63、64、67、68、69、71、72、73、74；
- 空白原型：formal 晋升、用户确认、结构同步三个治理目录；
- 16 个夹具覆盖晋升、A4、替换、partial、确认、撤回、新版本、分类、owner、同步和恢复；
- 46 个 CS 场景覆盖正常、提前、模糊、错序、越权、失效、冲突、安全和恢复；
- `tools/validate_p02_s08.ps1` 检查模板、兼容、夹具、原型、场景、任务、链接、空文件和关闭产物；
- 机械/合成测试不替代真实 A4、用户确认、target writes、正文审计、传播/分幕/恢复压力或全书审计。

## 正式规则追踪

| 规则 | 冻结内容 | 来源 | 主要测试 |
|---|---|---|---|
| CTL-01 | Track-P 只消费 promotion AH | E02 | CS-01 至 CS-05 |
| CTL-02 | Track-C 主成功入口只消费 confirmation AH | E02 | CS-11、CS-18 |
| CTL-03 | user feedback interrupt 不绕过主路径 | E02、E04 | CS-12、CS-18 |
| CTL-04 | 九类控制对象职责与真相源分权 | E02 | CS-01、CS-11、CS-37 |
| AUTH-06 | A4 精确绑定 action/object/version/scope/non-grants | E02、E03 | CS-01、CS-02 |
| PRO-01 | promotion 只接受 current eligible revised | E03 | CS-01 至 CS-05 |
| PRO-02 | promotion 不修改 content bytes/version | E03 | CS-08 |
| PRO-03 | replace 保留 old formal，新 formal 不继承状态 | E03 | CS-07 |
| PRO-04 | partial/pointer conflict 不创建 FRH | E03 | CS-09 |
| PRO-05 | promoted 唯一返回 S07 formal-audit | E03 | CS-06、CS-10 |
| CFR-01 | CFR 披露唯一对象/version/scope/状态/非主张 | E04 | CS-11、CS-19 |
| CFR-02 | 四类决定维度独立 | E04 | CS-11、CS-13 |
| CFR-03 | 泛化继续/审美反馈不确认 | E04 | CS-12、CS-14 |
| CFR-04 | 局部/混合/未来反馈按 scope 解释 | E04 | CS-15 至 CS-17 |
| CFR-05 | 提前确认 pending-audit/no-sync | E04 | CS-18、CS-20 |
| CFD-01 | decision/lifecycle/confirmation/sync auth 独立 | E05 | CS-11、CS-23 |
| CFD-02 | changes/reject 保留历史并路由 owner | E05 | CS-21、CS-22 |
| CFD-03 | withdrawal 不删除正文或静默回滚结构 | E05 | CS-23、CS-24 |
| CFD-04 | 新版本不继承旧 confirmation | E05 | CS-25 |
| CFD-05 | 未触及范围需 current-version revalidation event | E05 | CS-26 |
| SFD-01 | 先判 epistemic layer 再同步 | E06 | CS-28、CS-29 |
| SFD-02 | 七类 classification 互斥且有唯一动作 | E06 | CS-27 至 CS-34 |
| SFD-03 | eligible 同时要求 formal/MR/CFD/A4/owner/ERE | E06 | CS-30 |
| SFD-04 | 多 owner 命题拆原子 item 和依赖 | E06 | CS-31 |
| SFD-05 | 核心变化回 P01/S04/S05/A4 | E06 | CS-32、CS-33、CS-35 |
| SFD-06 | no-sync-required 不创建空运行 | E06 | CS-36 |
| SYP-01 | SYP ready 不等于 synced | E07 | CS-37 |
| SYR-01 | 逐 target 写前指纹、写后 actual/checkpoint | E07 | CS-38、CS-40 |
| SYV-01 | 写命令/event 不替代 actual verification | E07 | CS-39、CS-43 |
| SYV-02 | 全 required matched 才 synced | E07 | CS-44 |
| SYV-03 | sync 与 MR/evidence/final 独立 | E07 | CS-44、CS-46 |
| PAR-01 | partial 按 resume/compensate/replan/A4 分流 | E07 | CS-40 至 CS-42 |
| PAR-02 | compensation 需新 A4/计划/运行/验证 | E07 | CS-41 |
| REC-06 | 冲突不按 mtime/摘要猜测 | E07 | CS-09、CS-43 |
| REC-07 | 两轮无进展停止自动循环 | E07 | CS-45 |
| HND-03 | SIH 不证明 S09 验证完成 | E07 | CS-45 |
| SAFE-05 | 用户授权不能覆盖现实/原创/安全 | E04、E06 | CS-20、CS-34、CS-46 |
| FIN-07 | S08 不执行 S09/S10 或授予 final | 全部 | CS-45、CS-46 |

## 下游接口

| 任务 | 必须复用 | 仍由后续定义 |
|---|---|---|
| S09 | CFD/SFD/SYP/SYR/SYV/SIH、changed targets、relations、checkpoint、conflict | 真实变更传播、分幕连续性、跨会话压力与恢复验证 |
| S10 | 四模板、十六夹具、46 场景和校验器 | 主控集成、相邻三章黄金路径和 P02 总验收 |

## 决策状态与下一入口

### Confirmed

- S08 的 formal promotion、S07 回环、CFR/CFD、SFD/SYP、SYR/SYV、partial/conflict/recovery 和 SIH 协议已冻结。
- formal、MR、confirmation、sync、evidence 和 final 保持独立。
- 46 个协议场景、S08 专项校验和 P01/S02-S07 回归均为零错误。

### Open

- 真实小说项目的 A4、current candidate/formal、用户表达、SFD targets 和结构文件实际写入。
- S09 对真实变化传播、分幕连续性和跨会话恢复压力的正式协议与运行证据。
- S10 三个相邻章节黄金路径和 P02 总验收。

### Blocking

- 当前无协议建设阻塞。

唯一下一入口：审查并拆分 `P02-S09`。不得直接执行 S09，不得宣称任何真实小说已完成 formal 晋升、用户确认、结构同步、传播/分幕验证或 `final-audited`。
