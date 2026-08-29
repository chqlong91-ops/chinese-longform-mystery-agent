# RUN-06 植入幕边界矛盾

- baseline：独立临时副本。
- before：21:15 -> 21:20，route=5m。
- intended：将 after 改为 21:17，检测时间/路线不可能。
- actual：写入 2；elapsed=2 < route=5；形成 C01/C02 blocking finding。
- receipt：next action=route-P01-S04。
- checks：2；result=passed；baseline_unchanged=True。
- 不证明：真实小说 finding 或修复已经发生。
