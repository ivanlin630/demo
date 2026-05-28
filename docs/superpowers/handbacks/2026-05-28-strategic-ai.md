# Hand Back: 戰略 AI (StrategicAiSystem)

## 實作摘要

- `scripts/data/faction_data.gd` — 新增 `strategic_goals: Array = []` 欄位（dict 格式，與既有 string 格式 `goals` 分離）
- `scripts/simulation/strategic_ai_system.gd` — 新建 StrategicAiSystem：目標更新（expand/defend/trade_net）、包圍指派、突圍指派、聯盟威脅評估
- `scripts/simulation/movement_system.gd` — 主移動迴圈加入 strategic_assignments 優先邏輯（`逃跑` 任務豁免）
- `scripts/simulation/sim_runner.gd` — StrategicAiSystem 整合，near/far 兩區均觸發
- `scripts/debug/headless_test.gd` — 加入 StrategicAI 驗證區塊

### 與 spec 的差異

- Plan 原定用 `goals` 欄位，但 FactionAISystem 已佔用該欄位（string 格式）。改用 `strategic_goals`，全系統一致。
- `_evaluate_alliance_need` 目前僅 print 警告，不觸發實際外交行動（spec Task 4 範圍即此）。
- `_step6e_strategic_ai` 函式簽名改為只接受 `state`（無 `team_ids`），因邏輯遍歷全 faction 與 team_ids 無關。

## 連動風險

- `scripts/simulation/movement_system.gd`：strategic_assignments 優先邏輯插入主移動迴圈。若其他系統也在同一 tick 寫入 `move_target`，執行順序影響最終目的地。目前 `逃跑` 任務已豁免，但 `攻擊`/`外交` 等主動任務若 `move_target` 被清為 `(-1,-1)` 後尚未重設，可能被 strategic_assignments 短暫蓋過一 tick。
- `scripts/simulation/faction_data.gd`：`strategic_goals` 欄位每 STRATEGIC_INTERVAL tick 由 StrategicAiSystem 清空重建。若未來有其他系統讀取此欄位，需注意時序。
- `scripts/simulation/sim_runner.gd`：`_step6e_strategic_ai` 在 near/far 兩區各呼叫一次。由於 StrategicAiSystem.tick() 內部以 `% STRATEGIC_INTERVAL` 控制，同一 tick 若 near + far 均觸發（far 區每 FAR_ZONE_INTERVAL tick 才跑），策略邏輯會執行兩次。實際影響：strategic_goals 重算兩遍，assignments 也寫兩遍，功能正確但略有冗餘。

## 待主 session 確認

### 設計決策

1. **`strategic_goals` vs `goals` 命名**：plan 原用 `goals`，因衝突改為 `strategic_goals`。確認此命名符合後續設計？
2. **聯盟威脅評估僅 print**：`_evaluate_alliance_need` 偵測到威脅後目前只印訊息。後續 task 是否要接 `_form_alliance` (DiplomaticAiSystem)？
3. **`_assign_encirclement` 清除所有 assignments**：包圍指派前會清除 member teams 的所有正整數 strategic_assignments key。若未來有多目標並行指派需求，此設計需調整。

### 建議後續 task

1. **`_evaluate_alliance_need` → 實際觸發外交**：威脅閾值超標時呼叫 `DiplomaticAiSystem._form_alliance()`，而非僅 print。
2. **MovementSystem strategic_assignments 豁免範圍**：目前只豁免 `逃跑`。是否需擴展到 `外交`/`貿易` 等有明確目的地的任務？
3. **`threat_map` 改用 team_discovered**：`_evaluate_alliance_need` 目前遍歷 `state.teams`（全知），與 vision system 設計不符。可改為只計算已偵測到的敵方勢力。
4. **pre-existing SCRIPT ERROR**：`NpcAiSystem.write_memory` (npc_ai_system.gd:8) 有 2 個 Nil 存取錯誤，存在於 main 分支，與本 PR 無關，建議另開 task 處理。
