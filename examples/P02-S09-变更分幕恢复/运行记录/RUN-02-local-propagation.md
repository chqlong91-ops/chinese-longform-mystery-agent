# RUN-02 局部传播

- baseline：独立临时副本。
- before：local time=21:00；MR lifecycle=current。
- intended：local=21:15/source v002；MR lifecycle=stale。
- actual：写入 2；post-read 两项均 matched。
- receipt：required consumers matched intended local/stale states。
- checks：2；result=passed；baseline_unchanged=True。
- 不证明：S07 已完成局部重审或 MR 恢复 yes。
