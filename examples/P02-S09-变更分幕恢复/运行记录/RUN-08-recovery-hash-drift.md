# RUN-08 恢复 hash drift fail-closed

- baseline：独立临时副本；记录 project-state expected hash。
- intended：改变副本 active_task，检测 source drift。
- actual：写入 2；actual hash != expected；recovery-reconstructed=false。
- receipt：fail_closed_reason=hash-drift；next=rebuild-pack。
- checks：2；result=passed；baseline_unchanged=True。
- 不证明：真实恢复包已修复。
