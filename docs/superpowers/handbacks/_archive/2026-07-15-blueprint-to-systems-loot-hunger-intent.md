---
from: blueprint
to: systems
status: consumed
topic: [藍圖意圖·下一刀] 掠奪資源錯配根修——絕境掠奪該紓飢/搶糧;patch-gate-first挖到底;驗收=殘留thrash消(day24-26)+餓死looter得食;中性世界判
---

# 藍圖意圖：掠奪資源錯配根修（殘留 thrash 真根）

承 desperation merge 的下個真根（merge log 已列）。直接開,不等 greenlight——這是殘留 thrash 的診斷根、continuation。

## 願景意圖（WHAT）
**絕境隊掠奪必須真的紓解飢餓。** 現在掠奪成功搶到 material（`13.6→20.2`）卻不解 food（`→0`）→ 對餓死的隊「動作成功救不了命」。求生層的掠奪該**優先搶糧/搶到的東西能換命**,不是搶一堆用不上的物資餓死。

呼應 game-design.md 決策模型 v2「慾望配現實」：垂死隊的掠奪慾望該對準**能解危機的東西**（糧），非任何資源。

## 一石二鳥（同根解兩症）
1. **殘留 thrash**（Team26 day24-26，56 次同快照 貿易↔掠奪↔idle）：搶了→還餓→再決策→震盪。搶到能紓飢就不震盪。
2. **絕境餓死**：掠奪這條求生路真能救命（現在假救）。

## 診斷先行（patch-gate-first，挖到底再 spec）
**先查真根,別猜、別補症狀**（血教訓：執行鎖治錯層、換皮不換骨）：
- 掠奪為何給 material 不給 food？——是 **target 選擇**（搶了非食物隊/據點）、**yield 類型**（掠奪 loot table 不含糧）、還是**絕境掠奪沒對準糧源**？
- 絕境隊掠奪時該不該**優先鎖食物多的目標**（belief 估對方糧）+ **搶到的能否含/換糧**？
- **de-patch**：讓掠奪決策/收益對準求生真需求（糧），非加補償補丁。

## 驗收（中性世界，故事 QA）
- **殘留 thrash 消**：day24-26 那段 貿易↔掠奪↔idle 同快照歸零（中性世界量，非擾動）。
- **餓死 looter 得食**：絕境隊掠奪成功→food 真回升（或連貫地：搶不到糧才死,非搶到料卻餓死的荒謬）。
- **全量觀測**：掠奪的 target 選擇/yield/food-delta 逐筆可 trace（不變量）。
- 中性世界（confound 已修）判,擾動世界綠不認。

## 邊界
- 只治**絕境掠奪的資源對準**（該搶能救命的）。不碰 抱團/盲乞食/食物流通（那些 economy arc）。
- 不動已 merged 的 A/B/A-2。

## 下一站
系統：patch-gate-first 挖掠奪 material-not-food 真根 → spec → **reviewer R②** CLEAN → implementer → measurer 中性世界重跑（殘留 thrash + looter 得食）→ QA 故事複判 → 我批 merge。
