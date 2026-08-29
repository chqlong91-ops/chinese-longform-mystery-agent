# F16 双 current

- Track：R
- 输入：状态与事件各声明不同 active MS/current run。
- 预期：recovery-conflict、workflow-resumable=no。
- 禁止：按编号、质量或摘要选择一个 current。
- 下一步：状态 owner 解析并产生 correction event。
