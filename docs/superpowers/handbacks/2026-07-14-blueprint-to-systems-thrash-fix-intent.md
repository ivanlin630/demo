---
from: blueprint
to: systems
status: consumed
topic: 用戶greenlight thrash-fix當第一刀;意圖=survival執行鎖(承諾reach into execution);patch-gate-first診斷控制層打架;故事性驗收
---

# 藍圖意圖：thrash-fix（決策模型第一刀）

用戶 greenlight。這是決策模型 v2「承諾」那塊的落地（`game-design.md §★決策模型 v2` 第 3、4 點）。

## 願景意圖（WHAT）
**求生決策一旦 fire，鎖住執行到完成，別每 tick 被底層任務打回 idle。** 餓死可以，但**沒有隊伍能「想求生卻掙扎落空」地抖死**。死前若真求生（買糧/覓食/乞食…），要嘛成功、要嘛在**真掙扎中**死（跨線持續行動），非 `貿易↔idle` 鬼打牆。

呼應願景錨（已入 `04_qa.md` 故事性判官）：**零被動/thrash 餓死**。

## 診斷先行（patch-gate-first，用戶通則）
**先查控制層打架，非猜 tuning。** Team14 血證：求生控制器每 tick 喊 `idle→貿易`，下 tick 某處打回 `貿易→idle`，買糧單永遠下不成，days_left 2.7→0 餓死（抖 122 次）。
- **查**：誰在跟求生控制器搶？哪個底層任務/gate/優先序每 tick reset 掉求生 action？（TaskArbiter priority？SoloAI/SubAI 重派？survival task 沒 latch？）
- **de-patch，非補償補丁**：讓求生決策 fire 後**持有 execution**（承諾 reach into execution），不是加一個新閘去壓另一個閘。

## 驗收（故事性 + 量測）
- **故事性判官**（QA 第五職）：抽 thrash-死 specimen，判 motive→action→outcome 鏈——求生想做且**真的持續在做**，非落空抖動。
- **量測**：`貿易↔idle` 同 tick 反覆翻轉次數 → 應歸零/趨零；`extinct.starve_no_forage` 類「沒行動就餓死」→ 降。fullprobe attrition 順帶觀察（不強求回 baseline，本刀治抖非治死亡率）。
- **全量暫態可觀測性**（新不變量）：修 SpecimenTracer tap-gap（decision_count=0 假象＝tap 沒接 order 系統）順帶收，讓 thrash 死因可溯。

## 溯源（血證檔）
- thrash 實錄：`docs/measurements/2026-07-14-sliceA-reeval-attribution-branch-67d4a47.log` line 4242-4425（Team14 subteam `貿易↔idle` 122 次，days_left 2.7→0；line 4348 urgent 還 buy weapon×6）
- 同型 Team10：`docs/measurements/2026-07-13-roach-scan-team10-thrash-1337.log`（早於 slice A→舊病非本 slice regression）
- tap-gap 假象：`docs/measurements/2026-07-14-samewrld-team14-deathcause-67d4a47-dirty.log`（decision_count=0 但死時 coin=47/weapons=3/food=0）

## 邊界
- 這刀只治 **survival thrash（執行鎖）**，不碰慾望生成泛化/③內部政治/②④⑤（後續刀）。
- spec 你出（HOW），出完走 **reviewer R②** CLEAN 才 dispatch。範圍小、前提已 file:line 坐實 → R① factcheck 免。
