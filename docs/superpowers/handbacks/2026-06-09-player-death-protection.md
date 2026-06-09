# Hand Back: Player Death Protection (H / known_issues D2)

> 日期：2026-06-09
> Branch：`feat/player-death-protection`
> Spec：`docs/superpowers/specs/2026-06-09-player-death-protection-design.md`
> Plan：`docs/superpowers/plans/2026-06-09-player-death-protection.md`

## 實作摘要

- `scripts/data/world_state.gd`：加 `game_over: bool` + `game_over_reason: String`
- `scripts/simulation/faction_ai_system.gd`：
  - `_get_player_team_id(state)` helper（含玩家已死的 fallback 反查）
  - `_handle_player_leader_death(state, team)`（寫 choose_heir forced event；無 named → game_over）
  - `_promote_successor` 開頭分流：玩家 team → `_handle_player_leader_death`，NPC team 走原 S11 auto-promote
- `scripts/simulation/player_command_system.gd`：
  - registry 加 `choose_heir`
  - `_action_choose_heir`：選 named member 繼任、`player_id` 跟隨、清 forced event
  - `execute_action`：choose_heir 在 `pt == null` 守衛**之前**處理（玩家 person 已死，`_get_player_team` 必為 null，否則永遠回「找不到玩家 team」）
- `scripts/simulation/sim_runner.gd`：
  - `advance_tick` 開頭：`game_over` → 回 `"game_over"`；`choose_heir` forced event → 回 `"awaiting_heir"`，皆不推進 tick
  - forced_event 超時邏輯加 `choose_heir` 跳過（防禦；開頭早退已涵蓋）
- `scripts/debug/headless_test.gd`：加 8 個 Death 測試（Task1~5），全通過

## 驗證

- `headless_test.gd`：8 Death 測試全 OK，全檔 0 SCRIPT ERROR
- `game_sim_test.gd`：跑到 `=== game_sim_test DONE ===`，0 SCRIPT ERROR（無 crash regression）

## 與 spec / plan 的差異（需主 session 留意）

1. **Task5 測試修正（重要）**：plan 的 Task5 測試含 `state.persons.erase(100)`，但**實際 encounter 不會從 `state.persons` 移除死者**。
   - 實際行為（`encounter_system.gd:1042-1043`）：死者只從 `team.named_members` 移除、`team.leader_id = -1`；death record 仍留在 `state.persons`（body_parts 標記死亡）。
   - 因此 `_get_player_team_id` 在真實流程中可由 `persons[player_id].team_id` 正常反查到玩家 team；**fallback loop 在真實流程中其實不會被觸發**。
   - 已將 Task5 測試的 `state.persons.erase(100)` 移除，使其反映真實 encounter 行為。修正後測試通過。

2. **`execute_action` 提前處理 choose_heir**：plan 未明寫，但必要——否則 `pt == null` 守衛會在玩家死亡時先攔截。已加註解說明。

## 連動風險

- **`_get_player_team_id` fallback 為死碼風險**：spec 的 fallback（`t.leader_id == player_id or player_id in named_members`）在真實流程中不可達——`_promote_successor` 只在 `leader_id == -1` 時被 `evaluate_all` 呼叫，且玩家是 leader 不會在 named_members。目前**靠死者 person 留在 `state.persons` 才找得到 team**。
  - **若未來新增「死者 GC」清除 `state.persons` 中的死者**，則玩家死亡且 `leader_id` 已 -1 後將無法反查玩家 team → 路由失效、走 NPC auto-promote。
  - **建議**：主 session 評估是否在 `WorldState` 持久化 `player_team_id`（開局設定），讓 `_get_player_team_id` 不依賴 person record 存活。
- `sim_runner.advance_tick` 兩個早退在 `game_over` / `choose_heir` 期間**完全跳過** encounter 推進、消息修剪、population overflow 等所有步驟（符合「凍結」語意，但 UI / 上層需確保不在此狀態呼叫其他 tick 副作用）。
- UI 尚未實作繼承人選擇面板：後端寫入 `player_forced_event = {action: choose_heir, team_id, candidates}`，UI 需設 `state.player_state["heir_id"]` 後呼叫 `execute_action(state, -1, "choose_heir")`。

## 待主 session 確認

- 是否持久化 `player_team_id`（見連動風險，消除 fallback 死碼）
- UI 繼承人面板規格（spec G/I）
- Game Over 後重玩 / 主選單流程（本 spec 不含）
- 其他死亡來源（老化 / 飢餓 / 病死 / 被俘虜）→ 獨立 spec；目前僅 encounter / event_unrest_replace / N3_defect 走 S11 路徑
- `game_sim_test` 既有 `[FEATURE FAIL] Trade trade_success=0` 為**既有問題**，與本次改動無關
