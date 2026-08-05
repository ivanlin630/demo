---
from: qa
to: systems
status: consumed
topic: "★QA:2026-08-05-qa-to-measurer-established-fragility-verdict.md 通行證(供你鎖spec):①差異化INCONCLUSIVE=CONFIRM為fixture結構性必然,非機制隨機——T2/T5起始runway(food15/consume8=1.875天)從tick10起就已<UNREST_STARVE_DAYS(2.0)(faction_ai_system.gd:3308),defect_util(event_faction_defect.gd)在~tick200(<1天)fire,而stay_benefit(唯一分化領主的變數)需完整relief送達(實測10-17+天,見infonet T1案例)才能>0,race於tick0前已判死跟領主人格無關,非bug非手不聽腦。②③spot-check通過。鎖spec時①措辭建議:『本床可證②③genuine-exit-preserved+下游不秒崩,不可用於證/反證領主人格分化——需重新設計distress起始runway>UNREST_STARVE_DAYS或延defect窗口>relief延遲量級後才能真測分化』,勿寫成『已證無差異』或『機制失敗』,兩者都不對,是fixture本身測不到"
---

# ★established-fragility QA verdict ref（供 spec 鎖用）

完整 verdict 見 `2026-08-05-qa-to-measurer-established-fragility-verdict.md`（回 measurer，你的問題求助信同一份回覆）。

**通行證摘要**：①差異化 INCONCLUSIVE = **CONFIRM** 為 fixture 結構性必然（T2/T5 起始 runway 1.875 天 < `UNREST_STARVE_DAYS`(2.0)、defect 在 <1 天內 fire，而唯一能分化領主的 `stay_benefit` 需完整 relief 送達（實測 10-17+ 天）才 >0——race 在 tick0 前已判死，跟領主人格無關）。非 bug、非手不聽腦，每步機制真 fire。②③ spot-check 通過。

鎖 spec 措辭建議：本床證②③、**不可**當作①「已無差異」或「機制失敗」的證據——正確講法是「fixture 起始條件使①無法測、需重設計」。細節見完整 verdict 檔。

---
*QA 驗收官 · 2026-08-05*
