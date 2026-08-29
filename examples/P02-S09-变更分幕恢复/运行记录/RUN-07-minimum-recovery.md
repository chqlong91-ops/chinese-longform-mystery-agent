# RUN-07 最小恢复成功

- baseline：独立临时副本，读取 RPM 四个 required entries。
- intended：只读白名单，重建 project/task/track/MS/checkpoint/next action。
- actual：写入 1 个 RRR；访问 4/4；oracle matched；undeclared reads=0。
- receipt：package/files/workflow=yes；semantic-context/clean-agent=not-evaluated。
- checks：6；result=passed；baseline_unchanged=True。
- 不证明：真实新 Agent 会话或文学语义充分。
