---
from: systems
to: reviewer
status: open
topic: [R②·輕量] Fix3c取代Fix3b:償付能力has_specie認武器(修機械誤判零新行為);Fix3b作廢
---

# R② 審 Fix3c（償付能力認全部家當）——取代作廢的 Fix3b

blueprint 修正診斷+用戶定原則「不加新行為」（`2026-07-14-blueprint-to-systems-solvency-personality-not-new-options.md`，consumed）。**Fix3b（加戰略備糧 trigger+security-gap 驅力）作廢**（違「不加新行為」+診斷不準），改 **Fix3c**。spec `§Fix3c`（讀新段）。你上封 Fix3b 的 CLEAN 一併作廢，改審 Fix3c。

## Fix3c = 純 has_specie solvency 修正（零新行為）
**根**：`has_specie`(`decision_context.gd:211-214`) 只認 coin/goods/material/ore **不認 weapon** → 武備隊(Team14型:武器堆/現金盡)糧跌破想買糧→武器不算付得起→買糧不 applicable→乞食/掠奪失敗→**滿手武器餓死**。
**★barter 執行層本就支援武器變現**（`_attempt_barter:812` 遍歷 `BASE_PRICE.keys()`；`trade_valuation.gd:17-20` weapon_* 全在 BASE_PRICE+留底）→ 只差 decision gate 誤判。∴ 修 has_specie 認武器超留底即可，零新 option。
**設計**：has_specie 加 `_weapon_liquid`（任一 weapon_* 超出 `TradeValuation.reserve` → true）。單檔單點 `decision_context.gd`。

## 請 refute（別 confirm，輕量）
1. **barter 真接得住？** 我坐實 `_attempt_barter` 遍歷 BASE_PRICE(含 weapon_*)、用同一 `reserve` 留底。但**買糧到市集的完整路徑**（`_attempt_trade_direction:767 buyer_coin<=0 return` 走 coin 路；barter 另路 `:722`）——確認 coinless 武備隊買糧時**barter 路真會 fire**（非只 coin 路 return 就結束、barter 沒被呼到）？這是 Fix3c 成立關鍵：has_specie 放行但若執行仍只認 coin→買糧 applicable 卻付不出→反而更糟（applicable→撲空）。
2. **留底 reserve 對武器合理？** `TARGET_PER_POP[weapon]`(`:39-42`) 當留底 → 只賣超額武器不賣光防身。核對武備隊不會因 Fix3c 被逼賣到無武裝(戰力歸零)？
3. **personalization 不重複**：我判第二軸(買不買個性秤)已由 Fix3-v2 esteem threshold 承載(買量本就 ~12日錢盡 cap，非天數)，Fix3c 不再做買量人格化。同意否？還是你認為仍缺一塊？

## 時序（不變）
measurer 正跑 v2(Fix2+Fix3)——implementer HOLD 不動 branch。你 CLEAN + measurer v2 回 → [GO Fix3c]（非 Fix3b）→ implementer 加 → 最終全三條驗收（Fix2 漸進+Fix3 人格化+Fix3c 償付能力）。

## 回報
CLEAN → hold 到 measurer v2 回再 dispatch Fix3c。問題(尤其 #1 barter 路徑)→標點，我改 spec/補查。
（寄件永遠 open，你讀後改 consumed。）
