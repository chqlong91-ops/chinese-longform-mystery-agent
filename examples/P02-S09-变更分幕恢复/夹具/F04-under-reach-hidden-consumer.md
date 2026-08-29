# F04 漏边与隐藏消费者

- Track：D
- 输入：actual 文件引用 seed，但 IGS 没有对应 edge。
- 预期：under-reach + unknown-dependency，IGS/PVP blocked/stale。
- 禁止：把隐藏 consumer 当 unaffected 或继续聚合 verified。
- 下一步：补 relation evidence，创建 IGS 新版本。
