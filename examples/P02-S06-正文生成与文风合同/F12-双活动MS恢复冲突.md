# F12 双活动 MS 恢复冲突

## Setup

- 章节状态指向 `MS-CH07-A@v003#SC01` revised。
- 层清单另有 `MS-CH07-B@v002#SC01` revised 标为 active。
- 两者都有未关闭 DR/PGR，事件序列无法证明哪一个应活动。

## Expected

- `recovery-conflict`，停止该 write scope。
- 不按版本号、mtime、字数或文字质量选择。
- 最小读取：两条 active 指针的创建/转换/状态事件和 WA；不扫描全稿。
- 允许无关 read-only 检查；不得继续写 SC01。
- 解析后追加纠错/冲突解决事件，退休或 supersede 非活动分支，再重建恢复包。
