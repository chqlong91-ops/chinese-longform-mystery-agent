# F01 无实际变化

- Track：D
- 输入：current SIH 表明 old=actual=new，且无 invalidation event。
- 预期：CIR=`not-required`，生成证据完备的 propagation-not-required；不创建空 PVR。
- 禁止：把“无 run”写成 generic verified，或触及任何 consumer 状态。
- 下一步：按需进入 Track-B/R，五类事实保持独立。
