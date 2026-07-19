# spec：subteam-idle-latch 根治（手不聽腦第 3 種）

> 層級：L2（1 行 gate 排除 + 逐 sibling measure）。off main 980e0b1c+（transition merged 後）。優先 HIGH（手不聽腦 mini-arc，quality bar「沒有隊伍能坐著/掙扎落空地餓死」）。
> 來源：QA 抓 6 隊（62/71/73/79/84/90）→ systems code-locate → measurer trace CONFIRMED。root=`faction_ai:1727`。known_issues「subteam-idle-latch」。[[手不聽腦 mini-arc]] 第 3 種。

## 病象（measurer 坐實 @9a915fe7）
6 隊 `food-ok 2.5-4.58 + committed=覓食 + would_succeed=true 卻 task=idle，reason=subteam`。team73 血證：停 forage tile (26,9)，parent (25,6)，每 ~100-200t 抵達即被召回。drop 計數 **ARRIVE_MERGEQ 337 ≈ LOOP2B_RELEASE 346（1:1 振盪指紋）**。

## root（補丁閘坐實）
`_evaluate_subteam`（`faction_ai_system.gd:1727`）：
```gdscript
if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
    merge_queue.append(sub.team_id)   # 抵達目標格 → 歸建（lifecycle）
    return
```
**把「覓食 subteam 抵達 forage 目的地（move_target 清 -1）」誤當「歸建抵家該 merge」** → merge_queue → loop2b（`:761`）parent 不同格 → `release` → IDLE → 下 cadence 再派覓食 → 已在 tile 秒到 → 再 release。**THRASH，覓食從不在 tile 執行 → 食物流不進 → committed=覓食 卻 idle 坐死。**

= 補丁閘（機械 lifecycle gate pre-empt 引擎覓食決策）。覓食是「到目的地工作」語意（該留 tile 覓食），非「回母團」。1727 一律送 merge_queue。

## 修（de-patch：1727 排除 survival-work task）
```gdscript
if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE \
        and sub.current_task not in SURVIVAL_TASKS:
    merge_queue.append(sub.team_id)
    return
```
- `SURVIVAL_TASKS`（`faction_ai:79`）= `[RETURN_HOME, BEG, JOIN, FORAGE, CAMP]`——**survival-work task 抵達目的地 = 執行（留 tile 覓食/紮營/…），非歸建召回**。像正常隊（非 subteam）抵達 forage tile 就地覓食、食物累積。
- 只 mission/lifecycle task（TRADE/GOVERN 等完工返家型）+ 明確歸建（`_decide_subteam:1787` 已處理）才 merge-back。
- **de-patch 非補償**：不加「thrash 抑制」補丁，直接讓引擎覓食決策執行（1727 別 pre-empt）。

## ★WHAT flag 給 blueprint（非 blocker，informational）
修後 **subteam 會獨立覓食（離 parent 執行 survival）**——這是**引擎 rank_scored 已決策**的（覓食 > 歸建 於這些低糧 subteam），手不聽腦 fix = 執行它。**若 blueprint 判定 detached subteam 不該獨立覓食（該優先歸建 pool 母團糧）**：那是 **rank 決策層調整**（歸建 option util 對低糧 subteam 升權），**另軌 follow-up**，非本 1727 lifecycle override。本 fix（執行引擎決策）HOW-correct 無論如何。flag 供 blueprint 判要不要後續調 rank。

## 驗收
- **TDD**：①覓食 subteam 抵達 forage tile（move_target=-1）→ **不進 merge_queue**（`current_task in SURVIVAL_TASKS` 排除）→ 留 tile → 覓食執行、食物累積、無 thrash。②mission task（如 TRADE，非 SURVIVAL_TASKS）抵達 → 仍 merge_queue（不破 lifecycle）。③歸建（_decide_subteam:1787）路不變。
- **★sibling 驗**：CAMP/BEG/JOIN/RETURN_HOME subteam 抵達目的地——確認排除後行為對（CAMP 留紮營✓/BEG 乞食✓；JOIN 抵達 join target 由 _decide 執行✓；RETURN_HOME 抵家 resupply 非被召 parent✓）。若某 sibling 排除後卡別的態→measure flag。
- **gate** constitution PASS / **headless** 0 new(baseline 3) / **determinism** 2 跑 byte-identical。
- **measure**：seed1337 6 隊（62/71/73/79/84/90）不再 idle-latch、覓食食物流進（committed=覓食 subteam ARRIVE_MERGEQ↔RELEASE 振盪消失）；42/4201 無 regression；subteam 正常 lifecycle（mission 完工歸建）不破。

## 排序
HIGH。off main 980e0b1c 後 HEAD。R² 必過（重點審 SURVIVAL_TASKS 排除不破 mission-merge lifecycle + sibling 行為）→ dispatch。
