# Hand Back: NPC Wakeup Fixes

實作日期：2026-06-10
分支：`feat/npc-wakeup-fixes`
Spec：`docs/superpowers/specs/2026-06-10-npc-wakeup-fixes-design.md`
Plan：`docs/superpowers/plans/2026-06-10-npc-wakeup-fixes.md`

## 實作摘要（每檔一行）

- `scripts/simulation/strategic_ai_system.gd`：加 `_is_valid_tile` / `_nearest_valid_tile` in-map helper；新增 `ENCIRCLE_DIST=1`/`BREAKOUT_DIST=2`/`BREAKOUT_NEAREST_THRESHOLD=3` 常數；encirclement / breakout 派 target 套 in-map 修正；breakout 加「鄰敵 > 3 hex 不觸發」距離 guard；加 `trade_net` match handler + `_dispatch_trade_net` / `_find_trade_partner`。
- `scripts/simulation/faction_ai_system.gd`：`SURVIVAL_TASKS` 移除 `TASK_LOOT`；加 `STUCK_TASKS` + `_is_stuck()`；`_evaluate_prosperity_attack` 與 `_evaluate_solo` 的 gate 改「stuck 視為 idle 允許重評」。
- `scripts/simulation/movement_system.gd`：stuck log 加 source（target / task / strategic_assignments）。
- `scripts/debug/headless_test.gd`：加 5 個測試（in-map check、breakout 距離 guard、stuck 重評、survival 在 loot 重評、trade_net dispatch）。

## 與 spec 差異

- trade_net handler 用 `faction.member_team_ids`（spec 草稿誤寫 `faction.team_ids`，實際欄位名為 `member_team_ids`）。
- `_dispatch_trade_net` 不設 `combat_target`（避免誤觸發攻擊路徑），只設 `current_task=貿易` + `move_target`。
- Fix 2 套用範圍：聚焦 `_evaluate_prosperity_attack`（faction 領隊 / 獨立團 prosperity 候選）與 `_evaluate_solo`（獨立團）兩個全 gate（`!= IDLE` 型）。`_assign_tasks` 內攻擊/掠奪 branch 用 `not in [清單]` 型 gate，且 faction 領隊已由 prosperity 路徑覆蓋，故未動，維持 surgical。`STUCK_TASKS` 僅含 ATTACK/LOOT，刻意排除「逃跑」（逃跑本就 move_target=-1,-1，不可誤判 stuck）。

## 驗證結果

- `headless_test.gd`：`=== DONE ===`，無 SCRIPT ERROR，5 個 Wakeup 測試全過（Task1~5 OK）。既有 `Survival Task2`（urgent → 乞食 fallback）不受 SURVIVAL_TASKS 改動影響。
- `game_sim_test.gd`：**ALL INVARIANTS PASSED (violations=0)**。
- `game_sim_multi.gd`（4 config × 90 天 = 21600 tick）：無 SCRIPT ERROR。
  - **stuck = 0**（baseline：大量 stuck / zombie）→ off-map 派發鏈已斷。
  - **抵達 = 373**（baseline：1）→ NPC 已「醒來」會移動並抵達。
  - **trade_net 派發 = 433**（`[StrategicAI] 商隊 → trade`）→ 貿易任務 channel 已活。
  - ProsperityAttack = 4。

## ⚠️ 核心目標未完全達成（重要）

使用者目標「multi 跑出 Combat > 0 + Trade > 0」**未達成於「成交/開戰」層級**：

- `[Encounter]` / `[Hit]` = **0** → 0 場戰鬥
- `[Market]` / 成交 = **0** → 0 筆貿易成交

### 根因（已定位，超出本 spec 範圍）

戰鬥與貿易只在 **同格**（`interaction_system.process_on_move` → `_try_interact` → `start_combat` / `_resolve_market`）觸發。本批 fix 讓 team 會移動並抵達（1→373），但：

- 攻擊者 task=攻擊 追 **會動的** prey（`_refresh_attack_pursuit` 每 tick 對齊 prey 最後位置），雙方持續移動 → 永遠差一格，never 同格 → 0 開戰。
- 商隊 task=貿易 移向 **會動的** partner，同理 never 同格 → 0 成交。

即「醒來會走」已解，但「會合/攔截」未解。Spec 明列**不在範圍**：「改互動規則（仍嚴禁非同格互動）、改戰鬥規則」，故本批未碰。Plan Step1 的最低期望「或至少有 trade 派發」已滿足（433 派發）。

## 連動風險

- `faction_ai_system`：`SURVIVAL_TASKS` 移除 `TASK_LOOT` 後，多處 sticky/skip gate（line 392 領隊、456 成員、1220 survival、1406）對掠奪中的 team 不再 early-return → 掠奪 team 可被重評換任務。multi 已驗證無崩潰、無 invariant 違反，但「掠奪中被 survival 改 task」的頻率值得主 session 觀察是否過度抖動。
- `_is_stuck` 僅判 ATTACK/LOOT；若未來有其他會被 movement 清 target 的任務型別，需擴充清單。
- `_dispatch_trade_net`：派發後不成交（見上），目前每 STRATEGIC_INTERVAL 重評，idle 商隊才派；若 trade 永不成交，商隊會停在「貿易」task 不回 idle，可能不再被重派（已非 stuck，但等同新形態 zombie）。需配合下方會合修正一起看。

## 待主 session 確認 / 建議後續 spec

1. **會合/攔截邏輯**（解 Combat>0 / Trade>0 的真正關鍵）：
   - 攻擊：prey 在 N hex 內時改「預測攔截點」或同格容差（±1 hex 即可開戰），或 prey 看到 attacker 應停/迎戰而非無限逃。
   - 貿易：partner 為移動 team 時難會合 → 優先派往「定點」對象（有 outpost 的 resident / 商隊駐點），或 partner 收到 trade 意圖後停留。
2. `BREAKOUT_DIST=2` / `ENCIRCLE_DIST=1` 是否適配正式地圖半徑（目前測試地圖偏小）。
3. trade_net 是否需 cadence cap / 商隊貿易 task 逾時自動回 idle（避免新形態卡死）。
4. 防守方 active 行為（prey 迎戰 / 逃跑決策）—— 與第 1 點關聯。
