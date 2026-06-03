# Hand Back: Batch 1 — Core Fixes

## 實作摘要

| 檔案 | 說明 |
|---|---|
| `scripts/simulation/diplomatic_ai_system.gd` | G-01: `_send_diplomacy_message` 攔截玩家目標寫 forced_event；T-02: `_get_pop_est` helper + `_calc_diplomacy_score` 改讀 team_intel + `consider_betrayal` 改讀 faction_snapshot；G-04: `_execute_betrayal` 加 `faction_member_betrayed` alert |
| `scripts/simulation/strategic_ai_system.gd` | T-02: `_get_pop_est` helper + `_evaluate_alliance_need` 改讀 team_intel + `_assign_encirclement` 改讀 team_intel 位置；T-02: `_find_weakest_member` 改讀 faction_snapshot + `_faction_total_pop` 改讀 faction_snapshot |
| `scripts/simulation/interaction_system.gd` | T-02 快照A: `_deliver_order` 加 `snapshot_faction_member` 呼叫 |
| `scripts/simulation/sim_runner.gd` | T-02 快照B: 加 `_step4e_faction_snapshot` 函式並在近區/遠區各呼叫一次 |
| `scripts/data/world_state.gd` | G-04: 加 `player_alerts: Array` 欄位 |
| `scripts/simulation/resource_system.gd` | G-04: `resolve_consumption` 加 `food_critical` alert 觸發 |
| `scripts/simulation/player_command_system.gd` | G-08: `execute_action` 加 `set_tribute_rate` case |
| `scripts/debug/headless_test.gd` | 加 `--- player_alerts ---` 驗證輸出 |

### 與 spec 的差異

1. **G-01 forced_event 格式修正**：Plan 使用 `"type": "diplomacy"`，但現有 `respond_to_forced` 讀 `"action"` 欄位。實作改用 `"action": "diplomacy"` 與既有格式一致。

2. **G-01 player 偵測方式**：Plan 用 `state.teams.get(state.player_id)` 混用 person/team ID。實作改用 `state.persons.get(state.player_id)` 正確取得 person 再查 `team_id`。

3. **G-04 resource_system player 偵測**：同上，改用 person 查找。

4. **G-01 forced_event 覆蓋保護**：加入 `if state.player_forced_event.is_empty()` 防止覆蓋現有事件，與 interaction_system 既有邏輯一致。

5. **strategic_ai indentation**：原檔使用 4-space 縮排，加入的 `_get_pop_est` 需配合（plan 片段用 tab，已修正）。

## 連動風險

- `scripts/simulation/faction_ai_system.gd`：若有直接讀 `ally.population` 的背叛判斷邏輯，可能尚未切換到 faction_snapshot，需確認。
- `player_alerts` 清空時機：目前只加觸發，未加清空邏輯。UI 取用後需自行清空（`state.player_alerts.clear()`）或逐一移除。若 UI 層尚未實作，alerts 會持續累積。
- `resource_system.gd` 的 `food_critical` 觸發條件：`state.player_id` 對應的是 PersonData，需確認 PlayerSystem 的初始化流程都有設正確的 person_id。

## 待主 session 確認

1. **player_alerts 清空機制**：目前無 API 讓 UI 清空 alerts，建議在 `PlayerQueryApi` 加 `get_and_clear_alerts()` 或在 `SimBridge` 暴露。
2. **set_tribute_rate UI 整合**：呼叫者需先設 `state.player_state["tribute_rate_input"] = 0.2`，再呼叫 `execute_action(state, -1, "set_tribute_rate")`。UI 層尚未整合。
3. **faction_ai_system.gd 檢查**：確認是否有其他地方直接讀成員 population 而非透過 faction_snapshot。
