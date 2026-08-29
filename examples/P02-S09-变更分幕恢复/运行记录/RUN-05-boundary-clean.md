# RUN-05 clean 幕边界

- baseline：独立临时副本。
- before/after：21:15 -> 21:20；route=5m；object holder 不变。
- intended：写 boundary receipt，验证 scoped clean 条件。
- actual：写入 1；elapsed=5；route=5；holder matched。
- receipt：scoped BAV=verified。
- checks：3；result=passed；baseline_unchanged=True。
- 不证明：C01-C12 真实小说语义审计或 final。
