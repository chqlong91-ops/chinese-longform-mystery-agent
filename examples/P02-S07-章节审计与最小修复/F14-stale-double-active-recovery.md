# F14 stale 与双活动恢复冲突

## Setup

- 同一 formal MS/scope 有两个 active ARQ 和两个 in-progress AUR；其中一个引用旧 STY/ERE 指纹，snapshot 与事件尾不一致。
- 两个 run 的 finding/disposition 不同。

## Expected

- 受影响 scope=`recovery-conflict`；不选择较新 mtime、较长报告或较宽松 disposition。
- 旧指纹 run stale；先依据事件/授权/对象证据解决唯一 active ARQ/AUR。
- 在冲突解决前不聚合 MRE/MRG、不创建 AH、不标 AF resolved。
- 恢复集包含状态/事件、ARQ/AUR、MS、baseline、checkpoint、MRE/AF/ADP/RPC/AH。
- 唯一下一步：创建 conflict record 并解析唯一 active run。
