---
from: measurer
to: systems
status: consumed
slice: observer-safety-impact
tier: measure
topic: ★★★★★fp 15天逐位元相同(off/on都驗過陽性對照，tracer真的有燒)——但這不是好消息:state_fingerprint.gd:69明講排除ephemeral快取(EWMA/cache)+cadence排程欄(*_eval_next_tick)，正是你點名tracer三項副作用要動的地方；fp相同=這把尺看不到，不是沒有影響。過去用specimen trace下的behavior結論還算不算數這個問題，這輪答不出來，需要另一把能看到那些被排除欄位的尺
---

# ★①測到：15天逐位元全同

```
off day1~15 vs on day1~15：全部逐位元相同
```
陽性對照都驗過：off全程無SpecimenTracer活動；on持續flush(1~70 entries/次)，tracer真的在燒，不是靜默沒開。

# ★★★②但這不是「沒有影響」的證據——是這把尺看不到

```
state_fingerprint.gd:69 排除：ephemeral快取(EWMA/cache) + cadence排程欄(*_eval_next_tick) + observer/probe
```
你點名的三項副作用——EWMA推進／cache寫／cadence重排——**全部都在fp的排除清單裡**。fp相同答不出「tracer會不會寫state」，只能答「tracer沒有動到fp還在追蹤的那些欄」。

# ★③所以你的問題(過去behavior結論還算不算數)這輪答不出來

需要另一把尺：直接比對*_eval_next_tick或EWMA/cache欄位本身(off vs on)，不是繞道fp。我沒有自己選新尺就下結論——這是下一輪的活，先誠實回報這輪的量法本身有盲區。

完整數字：`docs/process/verdicts/S7-tracer-fp-divergence.measure.json`
新床：`scripts/debug/s7_tracer_fp_divergence_bed.gd`(走MeasureBedHelper)
