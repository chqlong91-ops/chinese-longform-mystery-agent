# 控制步骤与专业交接

仅在执行对应生产、审计、晋升或传播步骤时读取相关节。这里承接根 AGENTS 的操作细节；权限、自动续跑和历史协议适用范围见 [当前运行入口](CURRENT-RUNTIME.md)。冻结协议保持原样。

## 协议入口

- 十二节点调度：[单主控协议](15-P02单主控集成与运行协议.md)。
- 正文候选：[正文生成](11-P02正文生成与文风合同协议.md)。
- 章节审计与修复：[章节审计](12-P02章节审计与最小修复协议.md)。
- formal、确认与同步：[晋升与同步](13-P02formal晋升用户确认与结构同步协议.md)。
- 传播、边界与恢复：[变更与恢复](14-P02变更传播分幕连续性与恢复验证协议.md)。
- 案件设计与门禁：先按 [当前运行入口](CURRENT-RUNTIME.md) 选择状态、规划或 Evidence-Ready 协议。

## P02 单主控状态机

沿用 S10 的职责划分，主控负责选择路由、最小装载、A0-A5 授权、Skill/owner 交接、允许写入面、独立状态写回、post-read verification、停止和恢复；不复制三个 Skill 的内部方法，也不替用户确认。

主路由按以下优先级选择第一个适用项，每个原子步骤只有一个：恢复冲突 -> 安全硬边界 -> 关键变化 -> 待确认 -> 待同步 -> 待传播 -> 分幕边界 -> 选择章节 -> 上下文 -> 规划 -> 现实核验 -> 正文 -> 审计 -> 修复 -> formal 晋升 -> 恢复测试 -> 阶段交接。

每次运行必须绑定唯一 project/task/object/version/layer/scope，并记录 L0-L4 required/actual/not-read、source fingerprint、A0-A5、allowed/prohibited writes、expected/actual evidence、各独立状态、stop、checkpoint 和 unique next。双 current、source drift、缺精确 A3/A4、门禁未过、确认歧义、partial/conflict 或非唯一下一步时 fail-closed。

十二节点严格顺序为：N00 恢复 -> N01 选择章节 -> N02 上下文 -> N03 章节合同 -> N04 evidence-ready -> N05 场景终检 -> N06 exploration/raw/revised 正文 -> N07 draft/formal 审计 -> N08 owner 最小修复 -> N09 A4 formal/用户确认 -> N10 required 结构同步 -> N11 传播/分幕/恢复/下一章。前置已有 current 证据时可以引用，但不得跳过证据或继承其他对象的门禁。

完整冻结协议见 `15-P02单主控集成与运行协议.md`；E02 候选合同保留为历史设计证据。


## 案件设计顺序

1. 项目配置和创作简报；
2. 二至三个不同因果核心及用户方向确认；
3. 实际时间线和充分原因；
4. 人物知情与使用权限；
5. 线索生命周期和证据命题；
6. 嫌疑进入、校正、退出与残留；
7. 揭示阶梯、事实结局和人的结局；
8. 结构级章节地图；
9. `design-plausible` 审计和恢复包。

局部请求只运行必要部分。前置证据已存在时引用证据，不机械重做。


## 状态和门禁

分别记录工作状态、决策状态、同步状态、风险状态、活动层和以下门禁：

`design-plausible`、`creative-confirmed`、`evidence-ready`、`manuscript-realized`、`final-audited`。

不得相互推断。P01 已实现前两项并管理第三项依赖；P02-S05 已实现逐章 `evidence-ready` 的评价、记录、局部失效和恢复语义，真实项目仍须对当前来源和消费者实际运行；P02-S06 的 DCE 只评价候选对本次写作合同的符合性，不是新门禁；P02-S07 已实现章节/切片级 Manuscript-Realized 的评价协议，但只有 current formal 的实际位置证据才能得到 yes，候选稿不得得到 yes。P02 不授予全稿 `final-audited`。报告门禁时写明对象、版本、范围、value/evaluation 和证据。


## 正文候选生产

1. project-bound 写作必须有 current DR 和内部精确 A3 scope record；在一级权限内由 Agent 自动建立和消费，A2 只用于隔离探索。
2. 目标层只允许 exploration、raw、revised；formal 由 S08/A4 晋升或替换。
3. 起草、续写、局部重写、探索分别使用 `draft-new`、`continue-current`、`rewrite-local`、`explore-isolated`。
4. 写前检查 CC/SC/BT/IS、PCE/WH、ERE、CV、STY、MS 指纹和 stop；任一就绪不能替代其他前置。
5. 默认按最小 SC/BT 串行生成，到 A3 终点结束当前生成步骤；未完成范围保存 PGR checkpoint。随后重新判定路由，按现行三级权限继续或停点，不把步骤结束等同于用户任务完成。
6. 内容变化创建新 MS version；新版本不继承确认、同步或门禁。
7. DCE 使用 reviewable/repair-required/incomplete/blocked，不使用 generic passed；PRH 只交 S07 draft-review。
8. “继续”只有在上一轮已披露唯一 DR、目标、下一切片和终点且所有来源未变时，才可形成续写授权。


## 章节审计与最小修复

1. current raw/revised 候选只进入 draft-review；只有未来由 S08/A4 合法晋升的 current formal 才进入 formal-audit。
2. draft-review 不授予 Manuscript-Realized；formal 层标签、DCE、流畅度或用户认可也不能替代逐位置证据。
3. 每次审计绑定唯一 ARQ/AUR、MS 层/版本/scope、来源指纹、RRS、输出许可、stop 和 checkpoint。
4. finding 必须指向稳定位置或明确缺失位置，并记录观察、规则、后果、严重度、gate effect、owner、最小修复和重验范围。
5. 公平线索按 presence、visibility、interpretability、independence、uniqueness、source timing 六项检查；POV、现实、连续性、人物、场景、节奏、文风和安全独立检查。
6. S07 不改正文；修复回 S06 以 rewrite-local 和新 A3 产生 revised 新版本，formal 来源也不得原地覆盖。
7. 新 MS version 不继承旧审计、确认、同步或门禁；只使关系可达结论 stale，保留历史和无关结论。
8. S07 只向 S08 提交 formal-promotion-request 或 confirmation-review-request，不执行晋升、确认或同步。


## formal 晋升、确认与结构同步

1. formal-promotion-request 只进入 FPR/FPN；source 必须是 current eligible revised，且有内部精确 A4 evaluation scope。用户确认候选稿后，若未触发三级例外，由 Agent 自动执行。
2. promotion 不修改正文 bytes/content version，只登记 layer/active pointer；source 与 old formal 历史保留。
3. promoted 后唯一下一步是 S07 formal-audit，不能直达 confirmation/sync。
4. CFR/CFD 绑定唯一 MS version/layer/scope、用户证据、披露指纹、不包含事项和 sync authorization。
5. “继续/可以/不错/很好”默认不是正式确认；提前确认保持 pending-audit/no-sync。
6. 新版本不继承旧 confirmation；未触及范围也需 change-impact 和 current-version revalidation event。
7. SFD 先区分实际事实、人物观察/误解、读者推断和叙述修辞；只有 eligible-for-promotion 进入 SYP。
8. 核心因果/责任/结局/世界规则、决定性线索/权限或新现实能力回 P01/S04/S05/A4，不由正文覆盖。
9. SYR 逐 target 保存 before/intended/actual/checkpoint；只有 SYV 重读全部 required targets matched 才能 synced。
10. partial/conflict 使用 resume/compensate/replan/A4 分流；SIH 不证明 S09 传播/分幕/恢复验证已完成。


## 变更规则

S09 的运行边界：

1. 只消费 current SIH/SYV 与 actual changed targets；sync-verified 不等于 propagation-verified。
2. IGS 关系必须显式绑定 source/target version、scope、dimension 和证据；关键词、mtime、摘要不能创建 required edge。
3. 影响精确到 object/version/scope/dimension；变化只失效可达维度，未触及结论由 PEI 保留。
4. PVP/PVR/PVV 分别管理 plan/run/post-run verification；只有全部 required current actual matched 才 propagation-verified。
5. 分幕边界以 BAR/BSS/BAU/BAF/BAV 检查 C01-C12；missing input 先标 unresolved，不伪造矛盾。
6. RPM 只列白名单最小集；loader 不读旧聊天、全稿、未来正文或 manifest 外文件。
7. RTV 分开 package、files、workflow、semantic-context 和 clean-agent-session；机械前三维不能提升后两维。
8. partial/stale/conflict/no-progress 按 resume/replan/rebuild/repeat/owner/A4/abandon 分流，不拼接跨版本结果。
9. 隔离 A2 运行只写临时 run root；baseline 污染即失败，合成结果不授真实项目状态。
10. S9H 只把协议和受限证据交 S10，不证明真实三章、P02 完成或 final。

决定性事实变化时：

1. 记录保留约束和新旧事实；
2. 列出受影响的时间线、知情、线索、嫌疑、揭示、结局和章节；
3. 撤销变化可达的状态，保留无关状态；
4. 重跑被触及的因果、权限、公平、现实、原创和安全审计；
5. 防止修复引入未验证的新能力。
