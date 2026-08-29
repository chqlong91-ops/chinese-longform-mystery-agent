# F05 partial 后续跑

- Track：D
- 输入：两个 required consumers，第一项 matched 后第二项目标暂时 conflict。
- 预期：PVR partial，checkpoint 保存 applied/remaining；冲突解决且指纹未变后 resume-forward。
- 禁止：重跑已匹配项、丢失 partial 历史或提前 verified。
- 下一步：新 attempt 完成第二项并生成 PVV。
