# F15 Sync Partial Resume

## Setup

三项计划中前两项 actual matched，第三项写入失败；source/CFD/targets 未变化。

## Expected

SYV=partial；sync_state=partial；保存 applied/remaining/checkpoint；允许 resume-forward 新 attempt。

## Prohibited

不得标 synced、重写已 matched 项或让消费者假设第三项完成。

## Next

从第三项恢复，完成后重读全部 required targets。
