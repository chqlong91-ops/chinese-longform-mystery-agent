# F09 Withdraw Before Sync

## Setup

CFD current confirmed，SFD 尚未执行；用户明确撤回该范围确认。

## Expected

CFD lifecycle=withdrawn；confirmation=withdrawn；SFD/SYP invalidated/stale。

## Prohibited

不得删除正文/历史或继续同步。

## Next

等待重新确认、修改、拒绝或暂停决定。
