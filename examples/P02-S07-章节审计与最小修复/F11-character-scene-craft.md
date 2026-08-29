# F11 人物与场景工艺失败

## Setup

- 核心人物首次出现只有名字和一句台词，读者不知道角色/关系/为何在场。
- 随后两个访谈段重复“停电很突然”，没有新信息、压力或决定；章尾只是访谈结束。

## Expected

- AF 包含 `character-entry-underanchored`、`flat-repetition`、`ending-is-only-stop`，各自位置和规则独立。
- 若 CC/SC/BT 有角色锚点/delta/ending state，owner=S06；否则回 S04。
- 不用“文笔一般”或总分替代 finding。
- 禁止用传记倾倒修人物、用无因 cliffhanger 修章尾。
- 唯一下一步：选择最早结构/实现 failure 建 RPC。

