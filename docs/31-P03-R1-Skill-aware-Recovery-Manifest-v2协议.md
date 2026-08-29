# P03-R1 Skill-aware Recovery Manifest v2 协议

- 协议：`P03-R1-SKILL-AWARE-RECOVERY-MANIFEST-V2@v001`
- Schema：`P03-R1-RECOVERY-MANIFEST@s002`
- Validator：`P03-R1-RECOVERY-MANIFEST-VALIDATOR@v001`
- 适用范围：P03-R1 合成恢复与未来明确授权的 project-bound 恢复

## 目的

Manifest v2 让恢复任务在读取之前说清三件事：项目内容是什么，运行时依赖是什么，哪些资源绝对不能读。实际运行再用独立账本记录读了什么、没读什么、写了什么和是否越界。

旧恢复包把项目白名单和宿主 Skill 依赖混在一个 exact-set 中，容易把必需的 Skill 读取误判为项目越界，也可能给 Skill 一个没有边界的默认豁免。本协议拒绝这两种做法。

## Identity 与 Profile

Manifest identity 绑定 id、version、epoch、profile class、project/task、predecessor、canonical registry 和 checkpoint fingerprint。Current 只来自 canonical registry。

`L6-S` 只用于无真实项目载荷的 synthetic profile，evidence ceiling 为 L6-S。`L6-P` 只用于 project-bound profile，必须绑定明确项目；它不能继承 L6-S 结果。S05 的 profiles 只定义 L6-S 输入，不授予 L6-S receipt。

## Bootstrap Core

解析 manifest 前仅允许存在 manifest locator、strict UTF-8 JSON 规则、schema identity/fingerprint、validator identity 和 fail-closed 默认值。Bootstrap 不携带项目 payload、Skill 内容、旧聊天或断言答案。

## Dependency 与读取分类

`runtime_required_dependencies` 是逻辑依赖图。Skill main、按 Skill 规则必读的传递资源、协议、schema、工具和环境契约都必须显式声明 identity、kind、locator、用途、版本、fingerprint、requiredness、parent/child 和 resolved resource。

Locator 支持 filesystem、environment-owned、orchestrator-resource 和 custom-resource。任何 locator 都必须解析到唯一 canonical identity 并可验证 fingerprint。

解析后的读取分类为：

- `project_payload_reads`
- `environment_reads`
- `forbidden_reads`

执行账本为：

- `actual_reads`
- `not_read`
- `over_reads`
- `writes`
- `not_applicable_dependencies`

`allowed_reads = (project_payload_reads union environment_reads) minus forbidden_reads`。

`over_reads = (actual_reads minus allowed_reads) union (actual_reads intersect forbidden_reads)`。

Forbidden 优先。Over-read 只能复算，不能预授权。Project exact-set 和 environment exact-set 必须分开输出。

## Load graph 与预算

装载顺序固定为 bootstrap、runtime-dependencies、project-payload、state-evidence、assertions。条件依赖只能得到 true、false 或 unresolved；unresolved fail-closed。

每个 manifest 同时限定 files、bytes 和 estimated tokens。预算不足不能静默省略 mandatory source。默认只读近场项目内容和远场结构资源，不把全稿、未来章节或旧聊天当作启动上下文。

## Ledger 与 canonicalization

每次实际 read attempt 必须记录 sequence、stage、requested identity、canonical identity、category、dependency、result、bytes 和 observed fingerprint。Filesystem 资源在路径绝对化、大小写规则、`.`/`..` 消解和最终 target 解析后分类；非文件资源使用 authority、package 和 resource identity。

Redirect、symlink、junction 和别名不能保留入口分类。最终 canonical resource 未声明或落入 forbidden 时，本次恢复失败。

## Assertions、writes 与 next

Semantic assertion 只能使用 load graph 已读取的资源。每条 assertion 有 owner、required resources、expected result 和 nonclaims；assertion 不能自证或扩张读取集合。

合成恢复 write policy 为 forbidden。Unique next 必须只有一个 action、owner 和 scope。

## Fail-closed

Missing dependency、hash drift、ambiguous locator、dependency cycle、condition unresolved、budget overflow、classification conflict/laundering、forbidden intersection、undeclared read、over-read、write attempt、L6 class conflict、assertion conflict 和 non-unique next 都阻止状态授予。

同一 blocker 连续两次没有 evidence delta 时进入 no-progress。用户授权不能绕过安全、证据、依赖或读取边界。

## 实现与验证

- Schema：`schemas/p03-r1-recovery-manifest-v2.schema.json`
- Validator：`tools/p03_r1_recovery_manifest_v2.ps1`
- Trials：`tools/run_p03_r1_s05_manifest_trials.ps1`
- Profiles：`evals/夹具/P03-R1-S05/profiles/`

验证结果为 48/48 契约场景、28/28 强制失败、21/21 历史兼容映射、deterministic replay=true、小说读写 0/0、baseline pollution=0。

## Nonclaims

本协议不实现 builder、ordered loader、实际 read ledger、semantic verifier 或 context disposal，不执行 clean-session，不授予 L6-S/L6-P，不迁移 legacy，不终裁 R1-AC05/R1-AC07，不创建 R1/P03 frozen baseline。
