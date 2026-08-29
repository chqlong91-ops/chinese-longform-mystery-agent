# BBT 批次与门禁模板

## 产物合同

- 用途：定义一个 BPM version 内的 expected member batch、顺序、entry/exit gate、WIP 与 checkpoint policy。
- 创建路由：`P03-S03 / BATCH-PLAN`。
- 更新触发：member/order/gate/WIP/boundary/checkpoint policy 改变时创建新 content version。
- 状态记录位置：BBT object、BSR event、SCP 和 Current Registry。
- 真相源：current BPM/BP policy 与 owner gate evidence；actual 文件不能反推 expected。

## Identity 与 Membership

- batch_ref / predecessor / current key：
- book/BP/BPM/act/scope refs：
- profile：chapter-batch / boundary-checkpoint / owner-wait
- expected member refs/order/hash：
- optional/not-applicable exclusions：
- actual / missing / extra / duplicate / out-of-order：

## Entry / Exit

- entry gate manifest / actual / owner：
- exit gate manifest / actual / owner：
- WIP limit / claim：
- boundary checkpoint：
- exact-set verdict：

## Control

- source fingerprint / event watermark / post-read：
- lifecycle：
- checkpoint / stop / recovery / unique next：
- non-claims：batch complete 不反授章节或全书状态。
