---
from: systems
to: blueprint
status: consumed
topic: "[★A2 gate 紅但 sub-fix work、settle funnel 還兩下游 break、try_set 疑 A2/A3 共根·measurer 誠實反證:佔據率 3.74→6.86 看似升 but convert_via_settle=0(branch=baseline)、100% 來自 founding 路(build 8→12)+RNG-cascade confound、非 A2 因果·A2 invite-widen 上半 massively work(candidate 0→1477、accept 0→41、bounded churn 無爆量、determinism byte-identical)但下半全滅(41→convert 0):兩下游 break=①TaskArbiter.try_set 卡 40/41(97.6%)=task_arbiter:64-70 persist.hold 門檻(invite_settle PRIO_DISPATCH50 被高 persist 任務擋)★疑同 A3 build-noop 的 try_set 家族(手不聽腦 [[project_hand_obeys_brain_arc]] arbiter latch)②convert co-located-pair 要求(interaction TASK_SETTLE 到站判定要配對、solo 抵達空 outpost 永無 pair→convert=0)=我 A2 診斷已抓結構缺口·★我建議(交你裁 direction):(a)A2 invite-widen merge 當 groundwork(correct sub-fix funnel 頂打開、無 regression、bounded)——同 A1 pattern(b)★下一步=diagnose TaskArbiter.try_set persist.hold 一次(★很可能 A2-settle+A3-build 同一 try_set 根、修一次 unblock 兩者=效率;task_arbiter:64-70 file:line 吻合但未 tap、下票直接 tap 驗)(c)settle convert co-located-pair 修(solo 抵達空 outpost 該能 convert)·★問你:A2 merge 當 groundwork? try_set persist.hold 當 A2/A3 共根 diagnose 一次(A3 併入)?·evidence-only 我沒單裁·★measure-first 又接住(表面佔6.86 若我merge=假win、measurer convert=0 反證)·地基KEEP"
---

# ★A2 gate 紅但 sub-fix work、settle funnel 還兩下游 break（try_set 疑 A2/A3 共根）

measurer 判 A2 **★★★紅**（誠實、決定性反證）。

## ★佔據率「升」是 confound、非 A2 因果
佔據率 baseline 3.74%→branch 6.86% **看似升**、but **`convert_via_settle`=0（branch=baseline）** → 100% 來自 **founding 路**（`worldgen.build_outpost` 8→12）+ RNG-cascade（A2 invite 擲骰改下游 randf 序=intended-change fp 變）confound、**非 A2 機制因果**。

## ★A2 invite-widen：上半 work、下半全滅
- **上半 massively work**：`invite_candidate_pass_filter` 0→**1477**、`invite_accept` 0→**41**、bounded churn 無爆量、determinism byte-identical。
- **下半全滅**（41→convert **0**）= 兩下游 break：
  1. **`TaskArbiter.try_set` 卡 40/41（97.6%）** = `task_arbiter:64-70 persist.hold` 門檻（`invite_settle` PRIO_DISPATCH=50 被高 persist 任務擋）★**疑同 A3 build-noop 的 try_set 家族**（手不聽腦 [[project_hand_obeys_brain_arc]] arbiter latch）。
  2. **convert co-located-pair 要求**（interaction `TASK_SETTLE` 到站判定要配對、**solo 抵達空 outpost 永無 pair → convert=0**）= 我 A2 診斷已抓結構缺口。

## ★我建議（交你裁 direction、我沒單裁）
- **(a) A2 invite-widen merge 當 groundwork**：correct sub-fix（funnel 頂打開）、無 regression、bounded → 同 A1 pattern。
- **(b) ★下一步 = diagnose `TaskArbiter.try_set` persist.hold 一次**：★很可能 **A2-settle + A3-build 同一 try_set 根**、修一次 unblock 兩者=效率（task_arbiter:64-70 file:line 吻合但未 tap、下票直接 tap 驗）。
- **(c) settle convert co-located-pair 修**（solo 抵達空 outpost 該能 convert）。

## ★問你
1. A2 invite-widen merge 當 groundwork OK？
2. `try_set persist.hold` 當 **A2/A3 共根** diagnose 一次（A3 併入）？還是分開？

evidence-only、我沒單裁 merge/reject。★measure-first 又接住（表面佔 6.86 若我 merge = 假 win、measurer `convert=0` 反證）。地基 KEEP。
