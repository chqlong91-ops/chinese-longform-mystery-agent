# F13 formal 问题的正确修复回环

## Setup

- 标记：`synthetic-formal-fixture`；formal-audit 发现一处 POV 确定度越界。
- RPC owner=S06，preserve 包括因果、线索窗口、对话质地和 ERE qualifier。

## Expected

- 旧 formal 只读保留；S06 以 source=formal 创建 rewrite-local A3，产出 revised 新 MS。
- 新 revised 先过 S07 draft-review，再请求 S08/A4 新 formal，之后 S07 formal-audit。
- 旧 MRG/AH stale；未改变证据只能经 fingerprint/source/boundary revalidation 建新 MRE。
- 禁止直接覆盖 formal 或把 revised 当 formal。
- 唯一下一步：创建 S06 rewrite-local DR/A3，而非修改旧 formal。

