# P04 项目初始化器与 Project Canonical State 协议

- protocol：`P04-INITIALIZER-AND-PROJECT-STATE@v001`
- scope：`P04-S02-E01—E10`
- production evidence：`P04-AC02`、`P04-AC09`

## 1. 边界

初始化器把声明的故事种子/创作简报物化为空白、隔离、可恢复的项目工作区。它不执行 P01，不生成小说结构或正文，不选择真实试点，不授予内容确认、同步、门禁或 L6-P。

## 2. 身份与路径

请求必须给出唯一 `project_id`、安全的 ASCII `slug`、显式 `output_root`、模板版本和幂等键。最终根目录严格为 `output_root/slug`。绝对 slug、路径穿越、保留名、已存在非同源项目、重解析点或越界解析全部 fail-closed。

Agent registry 与 project registry 分离。Agent registry 只知道产品任务；project registry 只管理本项目。跨项目 current pointer、对象引用或目录写入禁止出现。

## 3. 工作区 exact-set

模板创建工作区规则、恢复入口、结构层、规则层、设定层、项目 canonical registry、生成视图、raw/revised/formal 稿件层、bootstrap manifest 和 checkpoint。空目录以 README 占位，保证 exact-set 可复算。

## 4. Project canonical state

`04-state/project-registry.json` 是项目唯一机器状态源。work、confirmation、sync、risk、gate、lifecycle、governance decision 独立保存；同一 pointer key 只能有一个 current。初始化状态为 `initialized / not-required / synced / normal / not-evaluated / current / tier1-autonomous`。

唯一下一步为“建立 P01 项目简报与案件设计入口”。该动作只是路由入口，不代表 P01 已执行。

## 5. 原子与幂等语义

初始化在 output root 内创建 staging 目录，持有单 writer lock，完整渲染并校验 exact-set 后，以目录 rename 作为唯一 commit point。同幂等键和同请求指纹重放返回既有项目；同键异请求、同 slug 异项目、部分写入、模板漂移或 commit 前故障均不发布项目。

## 6. 视图与恢复

`04-state/views/CURRENT.md`、`TASK.md` 和 `RECOVERY.md` 由 registry 确定性生成，含 registry hash。视图漂移通过重建修复，不能反向写 registry。checkpoint 必须绑定 bootstrap、registry、exact-set 和 unique next。

## 7. 验收

至少两个异质 synthetic fixtures 成功初始化；必须证明幂等重放、project isolation、double-current=0、partial-write=0、deterministic view rebuild 和 baseline mutation=0。所有结果只作为 P04-AC02/AC09 的生产证据，最终裁决仍归 P04-S10。
