# F03 formal 来源局部修订

## Setup

- Source：`MS-CH04-01@v004#P12-P16`，formal，只读。
- DR：`DR-CH04-03@v001#P13-P14`；mode=`rewrite-local`。
- WA：A3，只允许修复一段对话中的称谓跳变并保留停顿和反复。
- Target：revised 新版本；formal 不得覆盖。

## 来源片段

“周老师，”方屿说，“我不是那个意思。老师，你先听我说完。”

## 合成修订候选

“周老师，”方屿说，“我不是那个意思。你先——你先听我说完。”

## Expected

- 创建 `formal-revision-started` 和 revised MS；formal v004 保留。
- 保留自我修正、破折停顿和关系温度，只修不一致称谓。
- DCE 只覆盖 P13-P14 及必要连接范围。
- 新 revised 不继承 formal 的 confirmation/sync/manuscript 状态。
