# F15 恢复 hash drift

- Track：R
- 输入：listed file 内容改变但 RPM hash 未更新。
- 预期：pack/source stale，RTR 停止并保留 actual hash。
- 禁止：按 mtime 接受新文件或原地修改旧 oracle。
- 下一步：从 current normative evidence rebuild RPM。
