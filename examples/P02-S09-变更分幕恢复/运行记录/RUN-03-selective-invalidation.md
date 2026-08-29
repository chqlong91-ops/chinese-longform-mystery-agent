# RUN-03 选择性维度失效

- baseline：独立临时副本。
- before：MR=yes/evaluated；evidence=yes/evaluated；confirmation=confirmed。
- intended：只将 manuscript-realized 标 stale、propagation 标 partial。
- actual：写入 1；evidence/confirmation 保留；unaffected fingerprint 不变。
- receipt：no over-invalidation。
- checks：3；result=passed；baseline_unchanged=True。
- 不证明：真实门禁已重验。
