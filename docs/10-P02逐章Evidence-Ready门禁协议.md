# P02 逐章 Evidence-Ready 门禁协议

## 文档信息

- 版本：P02-S05 冻结版
- 日期：2026-08-14
- 上游：P02-S01 阶段契约、S02 对象状态协议、S03 稿件层与上下文协议、S04 章节合同与场景规划协议、P01 现实研究基线
- 适用范围：逐章现实依赖、原子主张、来源、研究审计、保守退路、`evidence-ready`、局部失效、恢复和 S06 交接
- 状态：已冻结；S06-S10 必须复用，不得把研究、创意确认、规划、写作授权或正文实现合并

## 目标与边界

本协议把 S04 的 `R-*`/`RH-*` 研究问题转换为可追溯、可验证、可局部阻塞、可局部失效并可跨会话恢复的逐章现实门禁。进入依赖精确现实能力的正文生产前，Agent 必须能从文件确定：核验的原子主张、实际来源及适用性、故事为何具备、真实字段/观察、时效、人物取得/理解/披露/使用权、支持与不支持命题、限制、退路、消费者范围和唯一下一步。

S05 建设的是评价能力，不代表任何真实小说已经完成外部研究或取得 `evidence-ready=yes`。每个真实项目仍须对当前日期、地区、制度、设备、群体和故事条件进行实际核验。

S05 不重写 P01 因果、线索、嫌疑、揭示和结局，不创建或修改稿件，不授予 A3，不判定文风/可读性/`manuscript-realized`，不执行确认、同步、分幕、三章试点或 `final-audited`。

## 三类证据分权

| 证据域 | 真相源 | 可以证明 | 不能证明 |
|---|---|---|---|
| 现实研究证据 | RS/RA、现实主张核验记录 | 能力、字段、时效、权限及命题边界在指定条件下成立 | 小说中确实发生、责任人、读者已经看到 |
| 小说内部证据 | 时间线、知情、线索、物件/凭证/路线等结构产物 | 故事事实、人物权限、线索命题和连续性 | 外部专业主张真实、正文已呈现 |
| 正式正文证据 | 当前 formal MS 稳定位置 | 读者实际看到的事实、POV 和时机 | 现实能力真实、结构已同步或全稿已审 |

任何证据只能支持其声明命题。现实来源不能直接证明小说责任；线索台账不能替代现实核验；研究卡、章节卡和 RA/ERE 不能替代正式正文位置。

## 对象与记录模型

| 层 | 引用 | 职责 |
|---|---|---|
| Reality Dependency | `R02@v003#scope` | P01 现实依赖家族、叙事功能和总体风险 |
| Reality Claim | `RC-R02-01@v001#claim` | 一个可独立判定的现实主张 |
| Reality Binding | `RB-R02-01@v001#consumer-scope` | RC 对一个 CC/SC/BT/IS/候选 MS 版本的使用合同 |
| Research Source Snapshot | `RS-R02-01@v001#stable-location` | 实际读取的来源版本、位置、元数据和适用声明 |
| Research Audit | `RA-R02-01@r001#claim-scope` | 逐主张来源集合、七问 finding、支持、限制和退路输入 |
| Conservative Fallback | `FB-R02-01@v001#consumer-scope` | 保持叙事功能、降低事实承诺的备选分支 |
| Evidence Readiness Evaluation | `ERE-CH04-01@r001#consumer-set` | 指定 RB 成员集合的专业门禁评价和 S06 约束回传 |

章节状态中的 evidence-ready 行仍是当前状态真相源；ERE/RA 是支持证据；状态事件解释变化。恢复包和项目总览只是派生入口。

### RC 原子性

一个 RC 只有一个主语/系统、一个核心谓词、一个适用条件集合和一个目标命题强度。删除或否定一部分后其余部分仍可单独成立时必须拆分。

RC 类型：capability-existence、story-availability、observation-or-field、timing-delay-retention、access-interpret-disclose-use、proposition-scope、limitation-or-failure、fallback-capability。

决定性分类：decisive、required-precision、nondecisive、safe-summary。nondecisive 不得偷偷承担决定性线索或 exit delta；safe-summary 只允许非操作性约束、矛盾和后果。

### RB 消费者绑定

一个 RB 只连接一个 RC 版本和一个消费者版本/范围，记录所需字段、命题强度、时效、访问/使用、输出许可、阻塞级别、退路和禁止断言。同一 RC 被不同场景以不同精度使用时创建多个 RB；新增消费者不修改 RC，也不撤销其他消费者。

### 版本与关系

内容版本、状态修订和事件序号继续分开。新 RC/RB/RS/FB 版本不继承旧门禁、确认、同步或下游资格。RA/ERE applied revision 不原地修改。

使用 S02 关系：contains、depends-on、evidenced-by、derived-from、supersedes、invalidates。文件路径不是身份，mtime 和版本号大小不能决定活动真相。

## 来源与研究证据

### 来源等级

- S0：现行法规、官方规范、原始公开记录、系统/设备官方规范；
- S1：同行评审研究、专业指南/标准、权威机构原始资料；
- S2：权威专业二手资料、政府/机构解释、系统综述；
- S3：可核身份专业说明、教材/课程材料；
- S4：可靠新闻、行业报道、一般科普；
- S5：搜索摘要、论坛、匿名内容、营销页、无来源转载、AI 摘要。

S5 只能定位线索，不能支持决定性结论。来源等级不是分数；S0/S1 仍须检查故事适用性和覆盖精度，多数弱来源不能数量投票替代适用的一手来源。

### RS 与六项判断

RS 至少记录发布者/作者、标题、版本/日期/生效期、地区/制度/群体/设备、稳定 URL/文件/位置、访问时间、内容指纹、输出许可和关联 RC/RA。

每个来源对每个 RC 分别判断 loaded、current、authoritative、applicable、coverage、permitted。读取成功不能补偿过期、错地区、不权威、范围不足或输出越权。

搜索结果页、摘要或无法定位原始内容的转述只能登记为 source lead。RA 的事实提取必须分开 source states、忠实释义、direct fact、source/Agent inference、条件、supports、does-not-establish 和 uncertainty。

### 研究过程

研究使用 RRQ/RLM/RCV，并复用 S03 的 CR/CL/CV 与 L0-L4：

1. 对一个 blocking RC 明确一个问题、目标精度、适用域、首选来源、最大范围和安全边界；
2. 记录实际搜索/读取和明确排除；
3. 只沿一个最小来源定向扩展；
4. 达到 sufficient、明确不成立、权威冲突、无进展或边界时停止；
5. 默认最多三轮，连续两轮无新增覆盖即 no-progress；
6. context coverage 不等于 research-audit 或 evidence-ready。

医学、法律、侦查、机构、记录、技术和高时效主张实际执行时必须核对当前官方/原始/专业来源，并记录法域、制度、版本和生效时间。本协议不提供专业意见。

### 来源冲突

先区分 direct contradiction、scope mismatch、temporal supersession、terminology mismatch、evidence-grade disagreement 和 implementation variance。能按地区/时间/群体分域时不伪装为直接冲突；不能裁决时 RA=conflict，ERE evaluation=conflict，stop=research-blocking。不得按搜索排名、来源数量或剧情偏好选择答案。

## 七项现实核验

RA 对每项使用 verified、partial、refuted、unknown、conflict 或有理由的 n/a；这些不是门禁 value，也不能平均。

1. **能力存在**：设备、程序、记录、机构流程、身体能力或技术在适用条件下真实存在。
2. **故事具体可得**：本故事的地点、时代、机构、人员、设备、资格、凭证和输入使其可用。
3. **实际字段/观察**：真实输出、粒度、单位、误差、缺失和标识范围，不制造方便字段。
4. **时效/延迟/保留**：采集、生成、同步、可见、取得、保留、覆盖和时钟锚点符合故事时间。
5. **取得/理解/披露/使用**：observe/obtain、interpret、remember、disclose、cite/file、publicize、institution-accept 分开。
6. **支持/不支持命题**：写明 named proposition、observed facts、reasoning bridge、supports、does-not-establish 和 alternatives。
7. **限制/失败/退路**：误差、缺失、失败点、独立性、保守退路和新主张可见。

能力一般存在不证明故事拥有；获得不证明理解；理解不证明可披露/引用/公开/采信；一个字段不自动证明身份、时间、路线、行为、机制、因果、责任或法律评价。

### 命题强度

决定性现实证据使用：

`observed -> source-supports -> compatible-with/does-not-contradict -> excludes-some-alternatives -> multi-source-strong-inference -> proves-a-named-proposition`

它不是数值分数。每次从观察到推论都写出推理桥、条件和未排除项。相容不能写成排除或证明；同源转述不能冒充独立多源。

“没有记录/没有发现”只有在预期产生、采集、保存、查询、权限和失败率均明确时才有命题力，通常最多削弱/不支持，不直接证明未发生。

制度、身体和一次性短暂接触分别检查正式规则/实践、感知/耐力/伤情/年龄/压力、实际时长/遮挡/注意和不确定性。

## 保守退路与安全

FB 依次尝试：收窄命题、降低精度、保留观察移除解释、替换载体、替换合法取得路径、延迟/迁移揭示、删除非决定性细节、回上游重构。

FB 必须记录原 narrative function、保留约束、旧/新主张、受影响对象、新研究项、公平/权限/连续性影响、verification、decision、adoption authority 和重验范围。

`FB verification=verified` 只证明现实分支可用；不等于用户/项目已采用。只收窄未证实断言且不改变确认结构的局部约束可在 A1 范围暂定；改变核心表现、已确认内容或重要取得路径需要 A4；改变因果、权限、决定性线索、责任、结局或多章结构回 P01/S04。

危险、侵权或虚假事实只保留人物选择、可观察矛盾、调查收窄、非操作性限制、后果和法律/社会/情感代价。不得保存或下放会提高伤害、隐匿、毁证、规避追查、跟踪或制度利用能力的操作步骤。公开来源不解除安全限制。

## Evidence-Ready 评价

### 合法组合

| value/evaluation | 含义 |
|---|---|
| no/not-evaluated | 初始未评价 |
| no/pending | 评价开始但无可用覆盖或 blocking 未解 |
| partial/pending | 有局部覆盖，评价仍进行 |
| yes/evaluated | 声明范围所有适用成员满足通过条件 |
| partial/evaluated | 完成评价，范围内有可用和缺口/阻塞 |
| no/evaluated | 完成评价但无可用实现，或核心能力被否定且无退路 |
| n/a/evaluated | NAD 证明范围内确无适用决定性/精确现实依赖 |
| any/stale | 历史结果，来源/成员已过期，不可消费 |
| partial/no + conflict | 活动来源/对象/权威结论不能唯一裁决 |

pending 不是 value。yes+pending/conflict 和无 NAD 的 n/a 均非法。

### yes 条件

yes 至少要求：对象和成员版本唯一；指纹 current；所有 blocking/required RB 有当前 RA；Q1-Q7 覆盖；来源 current/authoritative/applicable/sufficient/permitted；最大命题强度满足 RB；FB 已核验且采用有效；权限、时效、窗口和安全成立；无 blocking finding、stale、source/consumer/structure/sync/recovery/safety conflict；允许/限定/禁止断言与证据事件完整。

### partial/no/n/a

- partial：至少一个成员可用且至少一个缺口，必须列 covered、missing、blocking、allowed work；
- no：没有可用覆盖、核心能力被否定/全范围阻塞或只有危险实现，必须列恢复条件；
- n/a：有 NAD，列范围、活动消费者、检查结果、排除项、不承担功能、来源指纹和重检触发。

未识别 R、没有 RH、没有预算、不想研究或“看起来不专业”都不是 n/a。

### 局部聚合

聚合声明父对象、范围、当前 RB 成员、排除理由、子 ERE、来源修订和指纹。全部适用成员 yes 才可父 yes；无适用成员且 NAD 完整才 n/a；有可用和缺口则 partial；无可用或唯一关键功能 no/conflict 则 no/conflict。不得用平均分或多数场景抵消 blocking 成员。

## 事件、写回与状态独立

专业读取/审计为 A0；创建研究对象、记录 RA/ERE 和局部门禁状态为 A1；FB 采用按 A1/A4/P01-S04 边界。

事件：evidence-evaluation-started、evidence-value-set、evidence-evaluation-set、evidence-invalidated、evidence-conflict-raised、evidence-revalidated。一个事件只改变一个对象版本/范围的一项字段，多项变化用 bundle 关联。

写回顺序：RS/RA/FB/ERE -> 状态事件 -> 章节门禁快照 -> stop/risk -> 项目派生摘要 -> S04 回传入口 -> 恢复包。普通继续、用户确认、PCE、RH、WH、稿件层或文本流畅都不是 evidence 事件证据。

设置 evidence yes 不自动清除其他 stop，也不改变 work、decision、confirmation、sync、稿件层或其他门禁。

## 失效、冲突与恢复

现实变化记录 `RCG-*`：old/new、保留约束、seed、traversed edges、受影响/保留对象、撤销维度、新主张、重验和唯一动作。

传播示例：RS -> RA -> ERE -> evidence gate -> downstream consumer；RC -> RB/RA/ERE；消费者版本 -> 对应 RB/ERE；FB -> 使用它的 ERE。只沿有效语义边传播。

若变化到达 formal MS 依赖，S05 发 `downstream-realization-invalidation-request`，交 S07/S09 撤销/修复/重审；S05 不直接修改正文或 manuscript 状态。

主要冲突：双活动 RC/RB/ERE、来源快照歧义、权威来源冲突、消费者指纹不符、快照/事件不符、stale ERE 被消费、FB 核验/采用冲突、sync conflict 和恢复包过期。冲突只阻塞受影响范围，不按 mtime、编号、来源数量或旧聊天猜测。

恢复最小集：指南/协议、恢复包、项目/章节状态、CH/CC/SC/PCE/RH/WH、R/RC/RB、RS/RA/FB/ERE、最近研究/门禁事件、RCG、RRQ/RLM/RCV、最小下一来源和唯一动作。默认不读正文；只有定位下游依赖时先读 MS 元数据。

## S06 受控交接

ERE 对每个 RB 回传：消费者版本、value/evaluation、RA/RS、eligible/blocked scope、allowed assertion、required qualifier、forbidden assertions、observable form、POV/解释/记忆/披露/使用边界、字段/时效/保留、FB 采用范围、safe-output、保留/Open/Blocking、失效触发和 S07 检查入口。

S06 仍须独立检查当前 CC/PCE/WH、creative authorization、A3、活动稿件层、目标 MS、L0-L4、文风合同和其他阻塞。ERE yes/n/a 只满足现实前置之一。

## 模板、夹具与验证

- 新增：67 现实主张核验记录、68 evidence-ready 评估与交接；
- 兼容扩展：01 恢复包、02 项目状态、40 现实能力清单、60 章节状态、66 规划检查；
- 十一个合成夹具覆盖 yes、partial、no、n/a、访问、字段、来源、冲突、FB、失效恢复和安全；
- 34 个 ER 场景覆盖正常、失败、越权、聚合、变化和恢复；
- `tools/validate_p02_s05.ps1` 检查模板、夹具、场景、任务、链接、空文件和关闭产物；
- 机械检查不替代实际外部研究、悬疑、公平、现实、正文或全稿审计。

## 正式规则追踪

| 规则 | 内容 | 来源 | 主要测试 |
|---|---|---|---|
| EVS-01 | 现实、故事内部和 formal 正文证据分权 | E01 | ER-22、ER-32 |
| RCL-01 | R/RC/RB/RS/RA/FB/ERE 职责和引用稳定 | E02 | ER-01、ER-25 |
| RCL-02 | RC 原子，RB 绑定一个消费者版本 | E02 | ER-07、ER-10 |
| RCL-03 | 新消费者不撤销无关消费者，版本不继承 | E02、E07 | ER-25、ER-26、ER-28 |
| SRC-04 | loaded/current/authoritative/applicable/coverage/permitted 独立 | E03 | ER-12 至 ER-14 |
| SRC-05 | 搜索摘要/弱来源不能支持决定性结论 | E03 | ER-14、ER-19 |
| RES-01 | 研究沿一个 blocking claim 定向扩展并有停止边界 | E03 | ER-11 至 ER-14 |
| CON-04 | 权威来源冲突不数量投票 | E03、E07 | ER-29、ER-30 |
| AUD-01 | 决定性依赖覆盖 Q1-Q7 | E04 | ER-01、ER-08 至 ER-11 |
| AUD-02 | 存在、可得、观察、理解、使用和证明不互推 | E04 | ER-09、ER-15、ER-16 |
| CLM-01 | 命题强度不超过字段、来源和权限 | E04 | ER-10、ER-18、ER-19 |
| NEG-01 | 负证据需预期产生/保存/查询完整 | E04 | ER-17 |
| FB-01 | FB 保持功能、声明新主张并接受核验 | E05 | ER-03、ER-20 |
| FB-02 | FB 现实核验与创作采用分开 | E05 | ER-20、ER-21 |
| SAFE-03 | 危险信息只保留 safe-summary 叙事功能 | E05 | ER-06、ER-33 |
| ERE-01 | value/evaluation 合法且 pending 不是 value | E06 | ER-01 至 ER-08 |
| ERE-02 | yes 覆盖全部 blocking 成员和当前证据 | E06 | ER-01、ER-07 |
| ERE-03 | partial/no/n/a 有覆盖、缺口、恢复或 NAD | E06 | ER-04、ER-07、ER-08、ER-27 |
| AGG-03 | 聚合声明当前成员，禁止平均和盲继承 | E06 | ER-07、ER-25、ER-26 |
| EVT-03 | 门禁变化由 A1 原子事件和 ERE 证据支持 | E06 | ER-22 至 ER-25 |
| HND-03 | S06 回传只提供现实约束，不授予 A3/正文 | E06 | ER-01、ER-32 |
| INV-04 | 变化只撤销关系可达 evidence/下游实现请求 | E07 | ER-28、ER-32 |
| REC-04 | 最小恢复得到唯一 R/RC/RB/RA/ERE/下一步 | E07 | ER-30、ER-31、ER-34 |
| FIN-04 | S05 不创建正文或提升 manuscript/final | 全部 | ER-01、ER-22、ER-32 |

## 决策状态与下一入口

### Confirmed

- 本文全部证据分权、对象、来源、七问、命题、退路、门禁、事件、失效、恢复和交接规则。
- 两份新模板、五份兼容更新、十一个夹具、34 个 ER 场景和校验器。
- S05 建立逐章 evidence-ready 评价能力，但未替真实项目完成外部研究。
- S05 不授予 A3、manuscript-realized 或 final-audited。

### Open

- 真实试点案件、三个相邻章节、当前外部来源和具体 ERE，由 S10/真实项目选择并运行。
- S06 文风合同、A3、MS 和正文生成语义。

### Blocking

- 当前无 S05 协议阻塞。

唯一下一入口：审查并拆分 `P02-S06`“建立正文生成与文风合同”为 E 级任务。不得在拆分前直接执行 S06。

## 后续实现注记（2026-08-14）

上述 S05 关闭入口已由 S06 按顺序消费。S06 只在 current ERE eligible scope、最大命题和安全输出内建立候选，ERE 仍不授予 A3 或正文。详见 [P02 正文生成与文风合同协议](11-P02正文生成与文风合同协议.md)。当前下一入口为审查并拆分 P02-S07。
