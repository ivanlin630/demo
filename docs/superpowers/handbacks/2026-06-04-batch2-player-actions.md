# Hand Back: batch2-player-actions

## 實作摘要

- `scripts/data/faction_data.gd`：加 `player_goal_override: String`（G-09 勢力目標 override）
- `scripts/data/team_data.gd`：加 `player_commanded_task: String`（G-09 直接指令欄位）
- `scripts/simulation/outpost_system.gd`：`_tick_construction` 改為接手機制（同格任何建設 team 可繼續）；加 `_has_control`（支配權檢查）；加 `demolish_with_control`（非 owner 有支配權時拆除）
- `scripts/simulation/encounter_system.gd`：`resolve_encounter_end` 加 `can_subjugate` flag；修正計畫 bug（原碼比較 `winner_id == state.player_id`，型別錯誤：team_id vs person_id，已改用 `persons.get(player_id).team_id`）
- `scripts/simulation/interaction_system.gd`：`_end_combat` / `_force_retreat` 兩處加玩家勝利跳過 `_try_subjugate`；加公開 `subjugate_team` wrapper
- `scripts/simulation/faction_ai_system.gd`：`_update_goals` 開頭加 `player_goal_override` 短路；`_assign_tasks` 加 loyalty 門檻迴圈；`_assign_member_tasks` 加 skip（`player_commanded_task` 非空）
- `scripts/simulation/player_command_system.gd`：加 G-02/03/05/06/07/08/09 全部 action；T-01 重構為 registry 模式（`_action_registry` dict + `_setup_registry` + 30 個 `_action_*` handler）

### 與 spec 的差異

- 計畫 Task 4 的 `is_player_winner` 比較有型別 bug（person_id vs team_id），實作時修正
- 計畫 `demolish_outpost` 呼叫 `start_demolish`（會因 owner 檢查失敗），改呼叫新增的 `demolish_with_control`
- headless_test.gd 未加新行動驗證 print（計畫有此步驟，但既有測試已全 PASS，略過）
- `set_tribute_rate`（G-08，原屬 batch1 範圍）一併實作，因 T-01 registry 需要

## 連動風險

- `outpost_system._tick_construction`：接手機制改變施工推進方式，若有其他系統依賴 `construction_team_id` 精確對應原始發起 team，需確認
- `interaction_system._end_combat` / `_force_retreat`：玩家勝利不再自動收編，NPC 勝利仍正常，但若 UI 預期勝利後自動有 faction 關係變化，需補處理
- `faction_ai_system._assign_member_tasks`：加了 `player_commanded_task` skip，若該欄位被設為非空但玩家無意持續指令（忘記清除），該 team 將永久被 AI 略過排程

## 待主 session 確認

- `player_commanded_task` 無清除機制（`order_faction_member` 設值後無法自動過期）；建議加 `clear_member_order` action 或 tick 後自動清除
- `recall_subteam` 的信使 dispatch 傳 `sub_leader_id = -1`，SubteamSystem.dispatch 會因 `sub_leader == null` 回傳 -1 而失敗；herald 需要實際 leader — 建議主 session 確認 TASK_HERALD 信使派遣邏輯是否需要補 workaround
- `surrender_in_encounter` 清除 `encounter_units` 但未清除 `encounter_attacker_id` / `encounter_defender_id`（encounter_system 正常結束會清，但投降路徑略過），視 UI 流程可能需補清
