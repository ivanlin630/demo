# Hand Back: 外交 AI

## 實作摘要

- `scripts/simulation/diplomatic_ai_system.gd`（新建）：`DiplomaticAiSystem` class，含 `_calc_diplomacy_score`（5 輸入加權）、`try_proactive_diplomacy`、`handle_diplomacy_message`（4 動作 match）、`_form_alliance`、`_update_reputation`、`consider_betrayal`、`_execute_betrayal`
- `scripts/simulation/faction_ai_system.gd`（修改）：`evaluate_all` faction 迴圈末尾加每 20 tick 主動外交評估、每 `BETRAY_CHECK_INTERVAL` tick 背叛評估
- `scripts/simulation/sim_runner.gd`（修改）：加 `_diplomatic_ai_system: DiplomaticAiSystem` 宣告與初始化（目前未在 tick 中直接呼叫，行為由 FactionAI inline 驅動）
- `scripts/debug/headless_test.gd`（修改）：加 `_calc_diplomacy_score` 範圍驗證、`known_reputations` 更新驗證

### 與 spec 的差異

- Task 1 原 spec 的 `handle_diplomacy_message` 直接呼叫在 GDScript 4.2.2 parse 時失敗（方法尚未定義）。解法：Task 1 先加 stub，Task 2 替換為完整實作。
- `_form_alliance` 加入了 `state.snapshot_faction_member()` 呼叫（spec 未提，但 interaction_system.gd 有此模式，code review 補加）。
- `faction_ai_system.gd` betrayal block 的 `leader_team_b` 加了 null-guard（code review 補加）。
- `_execute_betrayal` 的 `"tick": 0` 照 spec 硬碼，未用 `state.world.current_tick`。

## 連動風險

- `FactionAiSystem.evaluate_all`：每 20 tick 呼叫 `DiplomaticAiSystem.new().try_proactive_diplomacy`，可能觸發 `_send_diplomacy_message` → `handle_diplomacy_message` → `_form_alliance`，改動 `team.faction_id` 與 `faction.member_team_ids`。若 FactionAI 同 tick 後續邏輯依賴這些欄位的舊值，可能有時序問題。
- `_form_alliance`：兩個 team 都有 faction 時（faction_id 不同）只把 team_b 併入 team_a 的 faction，不新建 faction、不處理 team_b 舊 faction 的 member_team_ids 清理。主 session 可評估是否需補。
- `sim_runner._diplomatic_ai_system`：宣告但未在 `advance_tick` 中呼叫。目前行為完全由 FactionAI 驅動（inline `DiplomaticAiSystem.new()`）。若後續想集中管理 instance，需在 sim_runner 中補呼叫並移除 FactionAI 的 inline instantiation。
- `_execute_betrayal` 的 `"tick": 0`：memory 記錄無法反映實際發生 tick，NpcAI 若用此值做時序判斷會有誤差。

## 待主 session 確認

- `_form_alliance` 雙方都無 faction 時不成立結盟、也不新建 faction——是否符合設計意圖？
- `_execute_betrayal` 的 `"tick": 0` 是否應改為 `state.world.current_tick`？
- `sim_runner._diplomatic_ai_system` 是否應實際接入 tick loop，還是保持現狀（FactionAI inline 驅動）？
