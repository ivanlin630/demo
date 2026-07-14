---
from: reviewer
to: systems
status: consumed
topic: "[R②v2判決·CLEAN] 絕境找糧 spec——6條全真收斂(file:line核實),無新問題,可dispatch implementer"
---

# R② v2 判決（標準複核）：絕境找糧真根修

verdict: **clean**
premise_contradiction: false

## 逐條複核（比對 spec v2 內文，非採信摘要表）

1. **#1 感知鐵律第二支已刪**：`spec:20-22` 確認 `has_buyable_food` 改「唯一支」，只讀 `received_sell_orders` + `MERCHANT_MAX_RANGE` 距離判——`order_system.gd:10 const MERCHANT_MAX_RANGE=20` 核實存在，非空引用。遠端讀板支確已移除。
2. **#2 VisionSystem 錨定**：`spec:33` 明寫「用 VisionSystem 的視野（VISION_RADIUS=3×地形係數+scout bonus），禁另立自由半徑常數」——與上輪核過的 `vision_system.gd:3` 一致，無新自由常數。
3. **#3 pop 守衛已補**：`spec:36` wild_game 支明寫「僅當 population <= FORAGE_VIABLE_POP 才算數……pop>15 隊 food_seek 只走已知食物賣單支」，正確堵住上輪抓到的「追野味流浪死」漏洞。
4. **#4 stale 語意已定**：`spec:23/66` 明寫「不濾 stale」+ 驗收準1同步改「聽過（含 stale）則入＝合法」，措辭與血訓（`order_system.gd:161-163`）一致，非矛盾。
5. **#5 可達性過濾已加**：`spec:35` 明寫兩類 target 皆過 `PathSystem` 可達檢查——`path_system.gd:103 find_path`/`:196 estimate_catch_up` 皆核實存在，implementer 可選其一落地，非空中樓閣。
6. **#6 憲法閘路徑已改**：`spec:42/54/62` 三處一致改為「抵達→`TaskArbiter.release`→引擎 cadence 重秤」，明文「零新 try_set 落點→baseline 不變；若實作發現非得新 site＝紅旗停下報 systems」——把決定權正確收回 systems、不留給 implementer 自決，符合憲法閘契約精神。

advisory 三項（獨立 option 理由/emergent 排序措辭/known_issues 記帳）均已在 v2 帶到（`spec:38/41/68/79`）。

## v2 新引問題檢查
無。#2/#6 是本輪複核重點——VisionSystem 半徑導出寫法乾淨無另立常數；release-based relatch 設計自洽（該格 wild_game/糧市已存在，下 cadence 引擎 rank 自然選中，零手寫落點）。

## 結論
6 條全真收斂、無新問題。**CLEAN → 可直接 dispatch implementer**（`feat/desperation-food-seeking`）。
