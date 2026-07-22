---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·material-buy v2a·issues(②結構求生主宰 guard 要求)] ①full-need gate語意 CLEAN(過閘=需全 cost 建成,非稀釋;cap 100 在)。★②util 繫建設 direction 對但 overshoot 真風險:買料非-survival-class(SURVIVAL_OPTION_SET 不含)→rank_scored 統一 util 競 survival;買糧要求 food<DESPERATION 只餓時 fire,買料無 food-gate→餓隊買料 util 若>買糧/forage=餓死。spec「survival_pressure 壓過」是磁量希望非結構(buymaterial_drive 用 intrinsic _facility_deficit 非 survival-yielded)。要求買料 applicable 加 food-ok gate(食足才買料,鏡射買糧食危 gate=互斥)。③④agree⑤coin 另 slice 對。"
---

# R² verdict：material-buy v2a（full build-need + util 校正）

**VERDICT: issues（②結構求生主宰 guard 要求）** — ①full-need 語意對；③util 繫建設方向對，但**買料 overshoot vs 求生是真風險，需結構 guard 非磁量希望**。`premise_contradiction: false`。factcheck 對 HEAD `4d54af1c`（v1 未 merged，v2a off v1 branch；結構驗對 HEAD 之 SURVIVAL_OPTION_SET）。

## ① full build-need（desire=gate 非 multiplier）→ CLEAN
`total += cost_mat × desire` → `total += cost_mat`。desire 已在 `if < CONSTRUCTION_DESIRE_MIN: continue` 當 **gate**（算不算此 facility），過閘=夠想建→carry **全 cost**。**語意對**：想建 weaponsmith **需全 80 material 才建得成**，買 24（=80×0.3）建不了=白買。gate 決定「算不算」、非「買多少」。**cap 100** 仍在（多 facility 疊爆防護）→ gate 後 full-cost 疊加 clamp。robustness 保。

## ★② util 繫建設 → 方向對，但 overshoot 需結構 guard（要求）
**v1 半破根對**（1.7% 墊底=買料 rank 搶不到），繫 construction 迫切=合理方向（買料是建設前置，util 應與建設同級）。**但拉高 buymaterial_drive 引 overshoot vs 求生的真風險**：
- **買料是非-survival-class**：`SURVIVAL_OPTION_SET`（`options.gd:345`）含**買糧**、**不含買料** → 買料在 `rank_scored` **統一 util 排序**與 survival options 競（非 tier-ordered/非 survival 先 fire）。
- **買糧有 food-crisis gate、買料無**：買糧 applicable `food_days < DESPERATION_DAYS`（`:242`，只餓時 fire）；買料 applicable = `material_shortfall>0 and has_material_market and has_specie`（**無 food-gate**）。→ **餓隊：買糧+買料同時 applicable**，若 v2a 拉高的 buymaterial_drive util **> 買糧/forage util** → **餓隊買 material 不買糧/覓食 = 餓死買料途中**。
- **spec「survival_pressure 應壓過買料」= 磁量希望非結構保證**：`buymaterial_drive = shortfall × max _facility_deficit × 人格`——`_facility_deficit`=**intrinsic facility 慾望**（deficit-based），**非 survival-yielded util** → 買料 **不自動繼承求生讓位**（餓隊的 facility 慾望可能仍高 → 買料 util 仍高）。∴ survival-dominance 靠 term 磁量巧合，measure-fragile。
- **★要求（結構 guard，非 tune）**：**買料 applicable 加 food-ok gate**（`and ctx.food_days > DESPERATION_DAYS` 或 `and not in_crisis`）——**食足才買料，鏡射買糧的食危 gate（兩者食狀態互斥）** → 餓隊買料 not-applicable → 只 買糧/forage fire → **survival 結構主宰**（非磁量）。守手不聽腦/survival-dominance 紀律（求生須結構壓過經濟，非 tuning-luck）。

## ③④⑤
3. **buymaterial_drive 繫 construction → 方向 CLEAN（配 ② guard）**。人格穿秤（貪婪/商業）保留。校準勝率合理區間=measurer/QA（配 ② food-gate 後，餓隊已不競，勝率只在食足隊間校）。
4. **無 RNG → CLEAN**。純 utility。
5. **② coin 另 slice → agree**。structural 隔離對（本刀驗有-coin 隊 buy-to-80 達 + 建成機制；無-coin 隊卡=coin=唯一剩 blocker→v2b）。measure 預期分工清楚。

## 回覆
issues（② guard）→ ①full-need CLEAN、③方向認可，一要求：
- **買料 applicable 加 food-ok gate**（食足才買料；餓隊只求生）——**結構求生主宰**，非靠 survival_pressure > buymaterial_drive 磁量。這樣 ③ 拉高 buymaterial_drive **安全**（只在食足隊間競建設，不搶餓隊求生）。
- measure（配 guard 後）：買料勝率（食足隊間）+ buy-to-80 + 建成 + **無 starve 回歸**（food-gate 硬驗餓隊不買料）+ 送 QA 讀故事。
改好回 R² → dispatch。

——② 是本 slice R²-核心：**「拉高經濟 util 但求生仍壓過」若靠磁量=脆**（今日多次翻案的前提教訓）。結構 guard（食足互斥 gate）= 求生主宰不靠 tune。同 null-belief-flee/market-seek 的「別 trap 餓隊」家族紀律：經濟 option 拉高時，先確保**結構上餓隊走不到它**。[[feedback_symptom_vs_root_retry]]（別讓拉 util 製造新餓死路）。
