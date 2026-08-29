# F16 Recovery Event Target Conflict

## Setup

恢复包声称 synced，事件声称 applied，但一个 target 实际值与 SYP 不符且有外部新版本。

## Expected

sync_state=conflict；恢复包 stale；停止受影响消费者并重建 current SFD/SYP 或人工解析。

## Prohibited

不得让摘要/事件覆盖目标实际值，也不得按 mtime 选择版本。

## Next

读取最小 target/change record，选择 replan 或 A4 conflict resolution。
