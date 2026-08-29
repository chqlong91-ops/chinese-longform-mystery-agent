# F11 STY 与来源变化局部失效

## Setup

- `DR-CH06-01@v001` 绑定 `STY-PRJ@v002` 和 source MS 指纹 `fp-old`。
- 尚未开始第二次 PGR 时，STY v003 将对话硬约束改为“避免解释性完整句”，source MS 也被合法修订为 `fp-new`。
- 旧 DR/WA、CV、DCE/PRH 仍引用 v002/fp-old。

## Expected

- 旧 WA 因绑定旧 STY/source 而失效；CV/DCE/PRH stale，未开始 PGR 不得继续。
- 历史 MS/PGR 保留，不删除；只影响依赖对话项和来源断点的范围。
- 创建 DCI，重读 current source 近场，更新 DR/WA/CV 后再写。
- 不撤销无关 CC/ERE，也不按“改动很小”忽略指纹。
