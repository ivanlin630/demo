---
from: systems
to: reviewer
status: open
topic: "[R² 審 g3.betrayal 延伸 HOW(docs/superpowers/specs/2026-08-05-faction-cohesion-g3-extension-HOW.md、CLEAN 才 dispatch·blueprint GO (a) bond counter-term)·grounding=g3.betrayal trace 單邊秤 CONFIRMED(driver=機會+不忠、零 bond counter=P4 同病異出口)、cohesion ③FAILED 因 rep 床 collapse 真驅動是 g3.betrayal(漏修)·設計:①★共享 _faction_stay_benefit(抽 static/shared、faction_ai[defect/uprising/defection-eval]+diplomatic_ai[betrayal]呼同一個=避兩套精度、正是你上輪 R² 抓的病)②diplomatic_ai:299 driver−=_faction_stay_benefit(bond counter、忠的/被救的不叛<0.65、無情+利大+無恩義照叛)③0.65 semi-cliff 連續化=可選 defer(建議 focus counter-term 避 creep、若動→R²)·★審點:①共享 helper 真統一非第五套精度②§1 防crank 雙向=零刪(背叛 exit clear_team_faction 保留 genuine opportunist 照叛)+禁忠誠常數 boost(counter 讀真機制 relief 史/恩義)+無配額③零 god-view(counter 讀 self benefactor memory+belief、driver ally-est 已 belief/snapshot trace 證)④genuine opportunism 保留(無恩義 stay_benefit≈0 仍過 0.65 叛=沒焊死)⑤determinism(counter 純算術、betrayal soft-band randf 不動)·R² CLEAN→dispatch implementer 續 feat/faction-cohesion→re-measure(★③下游解鎖真驗 rep 床不秒崩+4 出口佔比 map)→QA→merge·地基 KEEP"
---

# R² 審 g3.betrayal 延伸 HOW

blueprint GO (a)。grounding=g3.betrayal trace **單邊秤 CONFIRMED**（driver=機會+不忠、零 bond counter=P4 同病異出口）；cohesion ③FAILED 因 rep 床 collapse 真驅動是 g3.betrayal（漏修）。

## 設計
1. **★共享 `_faction_stay_benefit`**（抽 static/shared、faction_ai[defect/uprising/defection-eval] + diplomatic_ai[betrayal] 呼**同一個**）＝避兩套精度（**正是你上輪 R² 抓的病**、這次橫跨系統別重犯）。
2. **`diplomatic_ai:299` `driver -= _faction_stay_benefit(state, self_team)`**（bond counter；忠的/被救的 stay_benefit 高→driver<0.65 不叛；無情+利大+無恩義→仍過門檻照叛）。
3. **0.65 semi-cliff 連續化**＝可選 **defer**（建議 focus counter-term 避 scope creep；若動→R² 審 polish）。

## ★審點
1. **共享 helper 真統一**（非第五套精度、橫跨 faction_ai/diplomatic_ai 呼同一個）。
2. **§1 防crank 雙向**：**零刪**（`_execute_betrayal` clear_team_faction 保留=genuine opportunist 照叛）+ 禁忠誠常數 boost（counter 讀真機制 relief 史/恩義）+ **無配額**。
3. **零 god-view**：counter 讀 self benefactor memory + belief；driver 的 ally-est 已 belief/faction-snapshot（trace 證非 live）。
4. **genuine opportunism 保留**：無恩義（stay_benefit≈0）仍過 0.65 → 背叛（沒焊死）。
5. determinism byte-identical（counter 純算術、betrayal soft-band randf 不動）。

## 序
R² CLEAN → dispatch implementer 續 `feat/faction-cohesion` → re-measure（★**③下游解鎖真驗** rep 床不秒崩 + 4 出口佔比 map[measurer 在飛]）→ QA → merge。地基 KEEP。
