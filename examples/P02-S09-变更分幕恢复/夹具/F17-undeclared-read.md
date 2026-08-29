# F17 manifest 外读取

- Track：R
- 输入：loader 尝试读取未列入 RPM 的未来章节文件。
- 预期：denied log + RTR invalid，即使重建值碰巧正确也不得通过。
- 禁止：先读全稿再宣称最小恢复。
- 下一步：若确有唯一缺口，创建 RPM 新版本；否则保持拒绝。
