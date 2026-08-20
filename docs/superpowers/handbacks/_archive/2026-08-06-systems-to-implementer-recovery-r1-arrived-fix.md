---
from: systems
to: implementer
status: consumed
topic: "[recovery-r1 執行層修:migrant.arrived=0(dispatched=3 卻零抵達、驗執行端必修才 merge)·★好消息:決策層三態已 CONFIRMED(measurer:plains marginal+0.17 唯一正→3/3 dispatched、mountain −2.24→0 派、精準對齊 formula sign)——slice 核心機制證成、只差 delivery 執行·systems 結構診斷(已排除):①movement 處理 TASK_MIGRATE(movement_system:73 在脫離清單、不被居民鎖)②migrant subteam parent_team_id≠-1→_evaluate_subteam(faction_ai:723)有評估→_tick_migrant 有跑③dispatch move_target=村 pos 有設·★真根候選(runtime-trace pinpoint):_tick_migrant 用 PathSystem.predict_intercept(path_system:256)=移動目標攔截器、對靜態村是錯工具——(a)斷視線分支(:259-261)對新生 anon subteam(零 belief)回 BeliefSystem.belief_pos→(-1,-1)、(b)observe_velocity 消耗 global RNG(determinism 風險、此路徑本該零 RNG)·對比:convoy(_tick_convoy:2193 move_target=home_pos)/settle 到靜態 own-faction outpost=直接 move_target=target.tile_pos 非攔截預測·★修:_tick_migrant 移動改直接 sub.move_target=target.tile_pos(村靜態、own-faction、位置行政知);棄 predict_intercept(靜態村無需攔截、且去 observe_velocity RNG 消耗)·★驗:改後 runtime per-tick trace migrant subteam(tile_pos/move_target/在 move bucket/current_task 有無被 arbiter override/是否 merge_queue 提前歸建)確認 arrived>0——若直接 move_target 仍 0,trace pinpoint 真 stall(LOD bucket/task override/survival 空手 anon 打斷/merge-back)·守:determinism byte-identical(去 predict_intercept observe_velocity RNG 反而更乾淨)/零 god-view/constitution 74·完成 handback to:systems R²(merge-gate 核移動改 + arrived>0 真效果)→measurer 重量(arrived>0+plains 抵達併入 target pop 真升+forest 樣本補捕)→QA→merge·地基 KEEP"
---

# recovery-r1 執行層修：migrant.arrived=0（驗執行端必修才 merge）

## ★好消息：決策層三態已 CONFIRMED
measurer：plains（marginal **+0.17** 唯一正）→ **3/3 migrant.dispatched**；mountain（−2.24）→ **0 派**；精準對齊 ex-ante formula sign。**slice 核心機制證成**、只差 delivery 執行。

## blocker：migrant.arrived=0
dispatched=3 卻**零抵達**（15/22 天、3-hex）= migrant 有生成無真效果（人沒送到村）= **驗執行端必修才 merge**（candidate 生成≠真發生、同 established/care-loop 手不聽腦族）。

## systems 結構診斷（已排除的 wiring gap）
1. movement **有**處理 TASK_MIGRATE（`movement_system.gd:73` 在脫離清單、不被居民鎖）。
2. migrant subteam `parent_team_id≠-1` → `_evaluate_subteam`（`faction_ai_system:723` 全 subteam 評估）→ `_tick_migrant` 有跑。
3. dispatch `move_target=村 pos` 有設。
→ 結構 wiring OK、root 在 `_tick_migrant` 移動邏輯本身。

## ★真根候選 + 修
`_tick_migrant` 用 **`PathSystem.predict_intercept`（path_system:256）= 移動目標攔截器、對靜態村是錯工具**：
- (a) 斷視線分支（:259-261）對**新生 anon subteam（零 belief）**回 `BeliefSystem.belief_pos`→**(-1,-1)**（`_tick_migrant` 遂不更新 move_target）。
- (b) `observe_velocity` 消耗 **global RNG**（determinism 風險、此 delivery 路徑本該零 RNG）。
- 對比：convoy（`_tick_convoy:2193` `move_target=home_pos`）/ settle 到靜態 own-faction outpost = **直接 `move_target=target.tile_pos`**、非攔截預測。

★**修**：`_tick_migrant` 移動改**直接 `sub.move_target = target.tile_pos`**（村靜態、own-faction、位置行政知）；**棄 `predict_intercept`**（靜態村無需攔截、且去 observe_velocity RNG 消耗）。

## ★驗（runtime-trace pinpoint）
改後若 arrived 仍 0 → per-tick trace migrant subteam：`tile_pos` / `move_target` / 在不在 move bucket / `current_task`（有無被 arbiter override）/ 是否提前進 merge_queue 歸建 / 空手 anon 是否被 survival 打斷 → pinpoint 真 stall。

## 守 + 序
- determinism byte-identical（去 predict_intercept 的 observe_velocity RNG **反而更乾淨**）/ 零 god-view / constitution 74。
- 完成 → handback `to:systems`（R²、merge-gate 核移動改 + **arrived>0 真效果**）→ measurer 重量（arrived>0 + plains 抵達併入 target pop 真升 + forest 樣本補捕）→ QA → merge。地基 KEEP。
