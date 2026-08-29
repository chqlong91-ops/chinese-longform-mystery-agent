# RUN-04 partial、冲突与续跑

- baseline：独立临时副本。
- before：两个 required consumers 未处理。
- intended：第一项 applied，第二项 conflict 后从 checkpoint resume。
- actual：写入 4；partial checkpoint 保留 applied/remaining；完成后 applied=2、remaining=0。
- receipt：first actual result 未丢失或重复。
- checks：2；result=passed；baseline_unchanged=True。
- 不证明：真实 owner conflict 已解决或真实补偿完成。
