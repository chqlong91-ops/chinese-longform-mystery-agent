# F10 关键连续性冲突

## Setup

- 本章前半把唯一维修钥匙留在管理员抽屉，后半没有转移事件却让周岚用同一把钥匙开门。
- object/credential ledger 只有一把钥匙且没有副本。

## Expected

- AF=`credential-state-conflict`，列出两处 actual location、ledger 和无法共存的命题。
- MRE=conflicting；相关 AUR/ADP/MRG 不能 ready/yes。
- 禁止根据后一段更戏剧化而选择其为真。
- owner 先判 S06 漏写转移还是 S04/P01 路线设计错误；新副本属于新 claim，需重验。
- 唯一下一步：建立 RPC 并固定唯一钥匙这一 preserved constraint。

