# Hand Back: G2d 私人脫軌（血仇）

branch: `feat/g2d-vendetta`（未 merge，等主 session 確認）

## 實作摘要

- `scripts/simulation/npc_ai_system.gd`：加 `vendetta_target(state, leader) -> int`（讀 leader 最強 feud 邊 + 衝動 gate：好戰≥0.6、慎重<0.4、intensity≥0.6 → 回仇人 team_id 否則 -1）+ 3 const（全 TEST VALUE）。**刪** dormant `get_goal_task_override`（grep 確認無 caller）。
- `scripts/simulation/task_arbiter.gd`：加 `PRIO_VENDETTA = 55`（PLAYER 60 與 DISPATCH 50 之間）。
- `scripts/simulation/faction_ai_system.gd`：`evaluate_all` per-team loop **`_evaluate_threat` 之後**加脫軌 caller（try_set TASK_ATTACK@PRIO_VENDETTA + 設 prosperity_target_id 供追擊復用 + `[Vendetta]` print）。
- `scripts/debug/headless_test.gd`：加 `_test_vendetta_target` + `_test_vendetta_derail_task`，註冊於 `_initialize()` G2d 區塊。
- docs：`invariants.md`（新增「私人脫軌（血仇）」段 + G2d ✅ 標記）、`known_issues.md`（G2d ✅ + OUT 清單）、`progress.md`（npc_ai 表更新 + 刪 `get_goal_task_override 接入` 待辦列）。

## 與 plan 的差異（重要）

- **插入點**：plan 文字寫「威脅評估後、prosperity 前」，但實 `evaluate_all` 順序為 survival→prosperity(50)→refresh_pursuit→`_evaluate_threat`(522)，**prosperity 在 threat 前**。且 `_evaluate_threat` 只在 `current_task == IDLE` 動作（line 208 early-return）。
  - 若把 vendetta 放 threat **之前**，vendetta@55 會先佔 task，threat 看到 non-idle 直接 return → 威脅再也壓不過脫軌，違反「威脅擋得住」不變量。
  - 故 vendetta caller 放在 `_evaluate_threat` **之後**。此時 threat 已在 idle 設 DEFEND/FLEE@70，vendetta@55 try_set 搶不動 → 威脅優先正確；無威脅時 team idle，vendetta 設 ATTACK@55，且 55>50 可覆蓋 prosperity 早先設的 ATTACK。優先序語義 = plan 意圖一致，僅實體位置依真實 code 順序調整。
- plan 把 Task1/Task2 測試分兩 step 跑紅燈；我兩測試一次加入（先確認 parse fail 紅燈，再實作綠燈），結果等價。

## 驗證

- `--import` + `headless_test.gd`：`=== DONE ===`、SCRIPT ERROR/Parse/assert fail = **0**、`vendetta_target OK` + `vendetta derail OK`、既有 coin 守恆/InvariantAudit 測試全綠。
- `game_sim_multi.gd`：1000 tick 多配置跑完無崩潰（0 SCRIPT ERROR）。
- **未觀測到 sim 中 `[Vendetta]` emergent**：gate 嚴（衝動 leader 好戰≥0.6+慎重<0.4 且持 intensity≥0.6 feud 邊，需戰敗且 leader 存活產生強 feud），本 seed 1000 tick 未自然觸發。邏輯經 unit test 完整覆蓋；emergent 觀測為「desirable」非硬閘。

## 連動風險（待主 session 判斷）

- `faction_ai.evaluate_all`：每 tick 對每 team `NpcAiSystem.new()` 並呼 `vendetta_target`（無 cadence gate，異於 prosperity 的 3 天 cadence）。功能正確但每 tick 多一次 feud 邊掃描（`relation_edges` size 小，成本低）。若日後 perf 敏感，可加 cadence 或快取 `NpcAiSystem` 實例。
- `prosperity_target_id` 復用：脫軌與 prosperity 共用此欄位做追擊刷新（`_refresh_attack_pursuit`）。語義相容（都是「追某 team」），但若同 tick prosperity 與 vendetta 都想設，vendetta(55) 勝出覆蓋，符合預期。
- `get_goal_task_override` 已刪：原 dormant 無 caller，但若有外部/未來分支假設其存在需注意（progress.md「待接入」列已移除）。

## 待主 session 確認 / 建議後續

- **OUT 未做（plan 明列）**：弱仇「偏置」（擴張優先挑仇人邊）= refinement；kin/家族樹 feud 傳播 = G2a 骨架後續；`killed` 型別深用。
- 建議：藍圖平衡 pass 時調 `VENDETTA_*` 3 個 TEST VALUE，並可在 world_generator 注入帶 feud 的對立 leader 以實機驗 emergent 脫軌戲劇性。
- G2c（rung→task 全表 + prosperity 接階梯）未動，待藍圖 feel。
