---
from: systems
to: reviewer
status: consumed
topic: "[R²·material-buy v2a·full build-need + 買料 util 校正·接 v1 ca199844·QA confirmed 半破] spec=2026-07-23-material-buy-v2a-full-need-utility.md。v1(ca199844)QA 故事判 3 層 coherent、Gate B 半破(want 接 82→72% 但 buy-to-80 未達)。本刀=①③(②coin 另 slice)。①dilution 修:_construction_facility_need `total+=cost_mat*desire`→`+=cost_mat`(desire 已當 gate `if<MIN continue`,過閘=夠想→全 cost 80 非稀釋 24;理由=想建 weaponsmith 需全 80 才建得成,買 24 白買;cap 100 仍在)。③buymaterial_drive 校正:現 shortfall band 太低(1.7% 勝率)→改繫 construction 迫切(買料=建設前置,util≈建設,shortfall×max _facility_deficit×人格)。審點:①full-need gate 語意對嗎(desire=算不算此 facility 的 gate,非買多少的 multiplier;過閘全 cost 合理?)②★util 繫建設是否過衝(買料 util≈建設→會不會只買不建/搶過求生?求生 survival_pressure 應仍壓過買料[餓優先於囤料],驗買料不搶 survival rank)③cap 交互(gate 後 full-cost 疊加 clamp 100)④無 RNG⑤②coin 另 slice 對(有-coin 隊驗機制,無 coin 卡=下刀)。CLEAN→dispatch(接 v1 branch feat/material-…續,①③完整才 merge)。"
---

# R²：material-buy v2a（full build-need + 買料 util 校正）

spec：`docs/superpowers/specs/2026-07-23-material-buy-v2a-full-need-utility.md`。v1（ca199844）QA 判 3 層 coherent、Gate B **半破**（want 82→72%、buy-to-80 未達）。本刀 = **①③**（②coin 另 slice）。

## 修
- **① dilution**：`total += cost_mat*desire` → `+= cost_mat`（desire 已當 gate；過閘=夠想建→全 cost 80，非稀釋 24=白買）。
- **③ util 校正**：buymaterial_drive 繫 construction 迫切（買料=建設前置，util≈建設；shortfall × max `_facility_deficit` × 人格）。

## ★審點
1. **full-need gate 語意**：desire=「算不算此 facility」的 gate，非「買多少」的 multiplier；過閘 carry 全 cost 合理嗎（想建就需全料）？
2. **★util 繫建設是否過衝**：買料 util≈建設 → 會不會**只買不建 / 搶過求生**？**★驗：survival（覓食/求生 survival_pressure）應仍壓過買料**（餓優先於囤料）——買料別搶 survival rank。
3. **cap 交互**：gate 後 full-cost 疊加 clamp 100。
4. **無 RNG**。
5. **②coin 另 slice 對**（有-coin 隊驗①③機制，無 coin 卡=確認下刀）。

## 回覆
`to:systems`：CLEAN / 修正（尤其 util 過衝、survival 壓制）。CLEAN → dispatch（接 v1 branch `feat/material-…` 續，①③完整才 merge）。measure 帶 §④b+specimen→QA。
