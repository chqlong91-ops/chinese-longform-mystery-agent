# P02 Invocation 与 CMR 模板

## 产物合同

- 用途：记录真实 P02 N00-N11 返回的逐项验证与 chapter member receipt。
- 创建路由：committed ready preflight -> P02 controller -> S05 receipt verifier。
- 更新触发：chapter content/layer/scope、CIV intent 或任一 owner evidence 改变时新建版本。
- 状态记录位置：CIV、P02 Controller Record、CMR、SPEI、PEC。
- 真相源：P02 actual trace 与 current formal/ERE/MR/CFD/SYV 及适用 PVP/BAV/RTV。
- non-claims：terminal completed 或 CMR committed 不等于 LCG/聚合/全书状态完成。

## Invocation

```yaml
civ_ref:
dispatch_token_ref:
p02_protocol: P02-CONTROLLER-PROTOCOL@v001
trace_expected: [N00,N01,N02,N03,N04,N05,N06,N07,N08,N09,N10,N11]
trace_actual: []
terminal:
actual_reads: []
actual_writes: []
unexpected_writes: []
writer_wip_released:
```

## Evidence

```yaml
formal_ref:
ere_ref:
mr_ref:
cfd_ref:
syv_ref:
pvp_disposition:
bav_disposition:
rtv_disposition:
current_fingerprint_post_read:
evidence_profile: L4-C
synthetic: false
```

## Receipt

```yaml
cmr_ref:
expected_evidence: []
actual_evidence: []
prepare_event:
verify_event:
commit_event:
final_read:
lifecycle: receipt-committed/index-pending
stop:
checkpoint:
unique_next:
```
