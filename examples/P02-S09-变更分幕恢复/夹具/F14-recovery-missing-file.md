# F14 恢复包缺文件

- Track：R
- 输入：manifest required `relations.json` 缺失。
- 预期：package-valid=no、recovery-reconstructed=no，fail-closed。
- 禁止：搜索 sibling 目录或旧聊天补文件。
- 下一步：rebuild-pack/owner resolve。
