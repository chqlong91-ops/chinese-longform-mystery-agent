# P02-S09 隔离文件级运行记录

这些记录由 `tools/run_p02_s09_isolated_trials.ps1` 对隔离 baseline 的临时副本实际写入并 post-read 后形成。脚本每次运行重算 baseline fingerprint 并安全清理已验证位于系统临时目录内的 run root。

RUN-01 至 RUN-08 均通过，baseline 均未改变。它们证明隔离文件级机制可运行，不证明真实小说、真实用户确认、真实新 Agent 会话、三章闭环或 `final-audited`。
