# Hand Back: NPC 生存決策系統

## 實作摘要

### Task 1 — TeamData.previous_task
- `team_data.gd`：`current_task` 後新增 `var previous_task: String = ""`
- 生存觸發時儲存原任務；解除後還原

### Task 2 — _evaluate_survival
- `faction_ai_system.gd`：`SURVIVAL_TASKS`、`FOOD_PER_PERSON_PER_DAY_SURVIVAL`（2.4）、`URGENCY_DAYS`（1.0）、`WARNING_DAYS`（3.0）常數
- `evaluate_all` team loop 加 `_evaluate_survival(state, team)`
- 玩家 leader 跳過；已在 SURVIVAL_TASKS 不重複觸發

### Task 3 — 四個 helper 函數
- `_find_own_outpost(state, team)` → `Vector2i(-1,-1)` if 無
- `_find_weakest_prey(state, team)` → 已探索中人口 < 自隊 70% 且 food > 20 的弱隊 id
- `_find_strong_neighbor(state, team)` → 已探索中人口 > 自隊且聲望 > 0.3 的大隊 id
- `_find_aid_target(state, team)` → 食物儲量 > 14 天的隊伍，計分後選最優

### Task 4 — _trigger_survival（決策樹 4 路徑）
- Path 1 return_home：有自有據點 → `current_task = "return_home"`
- Path 2 掠奪：殘忍>0.5 或 好戰>0.6，且有弱者 → `current_task = TeamData.TASK_LOOT`
- Path 3 投靠：義氣+信義>1.2，且有強鄰 → `current_task = "投靠"`
- Path 4 乞食：找到目標 → `current_task = "乞食"`；全失敗 → `current_task = "乞食"`（就地乞食，無具體目標）
- `_should_abandon_current_task` 防止輕易放棄近在咫尺的原任務

### Task 5 — SURVIVAL_TASKS sticky
- `_assign_tasks`：leader_team 在 SURVIVAL_TASKS 時 early return（不覆蓋）
- `_assign_member_tasks`：成員 team 在 SURVIVAL_TASKS 時 continue（不覆蓋）
- `StrategicAISystem._assign_encirclement`：跳過 SURVIVAL_TASKS 中的成員
- `StrategicAISystem._assign_breakout`：若自隊在 SURVIVAL_TASKS，清除 breakout 指派並 return

### Task 6 — InteractionSystem._resolve_aid_request
- `interaction_system.gd`：`AID_RESERVE_DAYS = 14.0`
- `_try_interact`：a 或 b 在 `乞食` 且 `combat_target` 對準對方 → `_resolve_aid_request`
- NPC 自決公式：`(honor*0.4 + (1-greed)*0.3 + rep*0.3) - annoyance * 0.3`
- 接受：轉移 food（按 `AID_RESERVE_DAYS` 計算上限）、寫記憶、更新聲望、清除乞食任務
- 拒絕：寫記憶、更新聲望、清除乞食任務

### Task 7 — 玩家 forced_event
- 若 target 是玩家 leader，設 `state.player_forced_event`（action="aid_request"）
- `sim_runner.gd`：forced_event 超時（下一 hour-tick）自動拒絕，emit aid_refused 訊息，寫記憶，還原乞食隊任務
- `player_command_system.gd`：`respond_aid_request` action；讀 `state.player_state["aid_response"]`（"accept"/"refuse"），轉移 food 或拒絕，清除 forced_event

### Task 8 — 記憶寫入（整合於 Task 6/7）
- 接受：beggar 寫 `received_aid`（from target），target 寫 `gave_aid`（to beggar）
- 拒絕：beggar 寫 `rejected_aid`（from target），target 寫 `refused_aid`（to beggar）
- 超時拒絕：beggar 寫 `rejected_aid`（from player）

### Task 9 — annoyance 機制
- `_count_recent_begs(leader, beggar_id)`：數 leader 記憶中 `begged_at_me` subject==beggar_id 的條目
- annoyance 削弱接受概率；5 次後期望只接受約 3 次

## 測試結果

```
Survival Task1 OK  — TeamData.previous_task 欄位
Survival Task2 OK  — 緊急觸發 (food < 1 day)  task=乞食
Survival Task2b OK — sticky 不重覆觸發
Survival Task3 OK  — find helpers（4 個 helper 函數）
Survival Task4 OK  — 決策樹 4 路徑
Survival Task5 OK  — strategic_ai sticky
Survival Task6a OK — NPC 接受（給 72.0 food）
Survival Task6b OK — NPC 拒絕
Survival Task7a OK — 玩家收到 aid forced event
Survival Task7b OK — 玩家給予回應
Survival Task9a OK — 反覆乞食 annoyance（5 次中接受 3 次）
Survival Task9b OK — 陌生 team 也可乞食
```

全部 pass，exit code = 0。

## 連動風險

- `create_faction` 在 200-tick sim 中有 out-of-bounds 錯誤（pre-existing，不在本 PR 範圍）
- `_find_aid_target` 評分依賴 `team_discovered` 與 `known_reputations`；若雙方互不相識，永遠找不到目標 → fallback 就地乞食（`combat_target = -1`）
- `_resolve_aid_request` 中 food 轉移量計算：`min(asked, target_surplus)`；若 target food < 14天×pop，捐出 0 food（不觸發接受）
- `combat_target` 被借用作「乞食目標」，若其他系統讀取 `combat_target` 可能誤判為戰鬥意圖
- `previous_task` 還原：若乞食期間 previous_task 被清除，清除後回 TASK_IDLE

## 待主 session 確認

- `combat_target` 語義衝突：是否應新增 `aid_target` 欄位獨立追蹤乞食對象
- Task 10（Memory intensity 細分）未在計畫內詳細規格，已用 intensity=0.5 統一處理
- 乞食觸發條件（WARNING_DAYS=3）是否與 Tick 平衡文件的設計預期一致
- `_find_weakest_prey`：掠奪對象人口 < 70% 閾值是否合適（可能過寬）
