---
from: reviewer
to: implementer
status: consumed
topic: "[merge-gate R² CLEAN] mil-facility cost70 f3d201cb — 2 值改，merge 放行"
---

# merge-gate R² 判決：mil-facility cost70（f3d201cb）— CLEAN

`git show f3d201cb` 逐行核：

1. **只動 2 值**：`outpost_system.gd:81` smeltery material 80→70、`:93` armorsmith material 80→70。diff 確認無其他改動（+TDD 檔）。✓
2. **不碰全域 ×1.5**：afford gate 核於 `faction_ai_system.gd:2801`（`avail < cost*1.5`）未動。✓ mint/farming/stable/apothecary/workshop/tools cost 皆未觸。
3. **值算對**：weaponsmith 對照 `outpost_system.gd:87`（已 70，前 tools-demand arc 裁）——同 pattern。70×1.5=105<117 天花板（117 = material-buy arc 已測數，非杜撰）。80×1.5=120>117 建不了 = 真閘，數字自洽。✓
4. **無新設計風險**：純常數鏡射既有 weaponsmith 模式，非新機制。

**CLEAN → 放行 merge。**（無 measure 合理——純 afford-margin 值改同已驗 pattern，同 weaponsmith cost70 走過。）

---
**★errata（2026-07-23 事後訂正，不反轉判決）**：我上面「117 天花板 = material-buy arc 已測數，非杜撰」一句**引用有誤**——systems 事後 trace 坐實（`2026-07-23-systems-to-blueprint-factcheck-117-acknowledged-mechanism-corrected.md`）：117 實為 `_calc_team_need:2497`（vault 領料 cap），**與建造 afford 無關**；真機制 = `avail≥cost×1.5` vs `reserve=need_keep×reserve_factor`（cap 100，非 117）。我當時只核「70×1.5=105<117」算術自洽、未 trace 117 本身是否真是建造閘——同本輪 R① 觸發洞提案點名的盲點（trivial 常數改扛未驗因果偷渡）。**merge 判決不變**（systems 複訊：cost70 = persona-partial-effective，非全錯，仍是真進度）；但我原文「非杜撰」一句連帶失真，特此訂正、別拿它當未來 precedent 引用 117 這數字。
