---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN] 持守統一 Slice 2 執行層寫回新鮮度——construction_ticks_total重建公式+新鮮度事件點核實，merge放行"
---

# R② 判決：持守統一 Slice 2 執行層寫回新鮮度 — CLEAN

## `construction_ticks_total` 重建公式——逐 action 核對
`"build"`→`BUILD_TICKS[type][level-1]`：親查常數表 `BUILD_TICKS={"civilian":[100,300,600],"military":[100,300,600]}`，civilian lv1=100，跟 TDD ⑥ 註解「total=100」精確吻合，且跟 `start_build` 原始賦值同一公式（重建非杜撰新算法）。`"upgrade_facility"`→`upgrade_cost(fac,cur_lvl+1)`：核對 `cur_lvl`（`current_level_key`）只在完工才變，施工全程不動——中途任一時點重算跟開工當下算出來的 total 一致，無漂移風險。`"upgrade_level"`/`"demolish"` 同構鏡射 `construction_cost_of` 既有模式。四種 action 皆有覆蓋，非漏 case。

## 新鮮度事件點——兩處核對到位
`_tick_construction`（倒數後）+ `movement._on_arrival`（抵達後）各補一次 `PersistStrength.compute`——涵蓋「進度數字變」+「任務狀態轉換」兩類會讓持守強度該變但決策 cadence(1日)還沒到的時刻，解決 Slice 1 自己承認的「決策層 cadence vs 執行層每 tick」落差，做對地方。

## TDD ⑥⑦——測法本身抓得住真退化
⑥（`_test_real_construction_progress`）刻意讓 `wn`(近完,left=10) 跟 `we`(剛開工,left=90) **task_start_tick 相同**（elapsed 一樣）——若實作偷懶retreat回 Slice 1 的時間 proxy，`pn` 會等於 `pe`；`pn>pe` 這條斷言直接證明真的在用 construction-tick 而非時間，測試設計本身能抓到「看起來過了但其實退化」的假陽性，非只驗一個數字門檻。⑦（`_test_freshness_on_tick`）直接改 `tile.construction_ticks_left` 後驗 `persist_strength` 真的立即反映，且驗 `team.persist_strength==p_after`（寫回欄位不是只回傳值）。兩測都對症，非泛泛帶過。

## perf/其餘
每 tick 呼 `PersistStrength.compute` 內容只是幾個 dict lookup+算術，`_tick_construction` 本身已是 O(N) 掃描函式，新增這個常數開銷不改變複雜度量級，無疑慮。世界不凍回歸數字（attrition 1.13%/teams 49→64）跟 Slice 1 同款健康信號，一致。progressive-only/clamp<危機/weigh 非 gate 三條憲法對齊皆延續未破。

## 判決
**CLEAN → merge。** → dispatch Slice 3（執行層 `try_set` 持守-aware——記得我 R②前一輪要求的 `new_util` 資料來源矛盾要先講死才能開工，這條還沒解，Slice 3 spec 補上再派）。
