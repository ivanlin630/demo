# Hand Back: Encounter Engagement

實作 `docs/superpowers/plans/2026-06-11-encounter-engagement.md` 全部 9 Task。

## 實作摘要（每檔一行）

- `scripts/simulation/path_system.gd`：新增 `predict_intercept` — 依 `observe_velocity` 自適應 N 步（N = 路徑成本）預測攔截點；視野外/不動/落地圖外 → fallback 回 target 當前位置。
- `scripts/simulation/threat_assessment.gd`：**新檔** static class，`score()` = 朝我移動 + (1−reputation) 敵意 + intel 估算實力比 + 距離衰減；視野外回 0。實力比用觀察者 `team_intel` snapshot（不全知）。
- `scripts/data/team_data.gd`：加 `TASK_DEFEND="迎戰"` / `TASK_PREPARE="備戰"` + `threat_eval_next_tick` / `trade_task_start_tick` 欄位。
- `scripts/simulation/faction_ai_system.gd`：
  - `_evaluate_threat`（cadence 240 tick；idle 才主動評；已在 逃跑/迎戰/備戰 則重評 threat，無則回 idle）
  - `_dispatch_threat_response`（4 反應評分：逃跑/備戰/求和(外交 tribute_offer)/迎戰；居民團排除迎戰）+ `_flee_target` + `_has_active_threat`
  - `evaluate_all` per-team 加 `_evaluate_threat` 呼叫 + 貿易 task timeout（>1440 tick → idle）
  - `_refresh_attack_pursuit` 改用 `PathSystem.predict_intercept`（視野外/不動 fallback intel 最後已知位置）
  - 三處 TASK_TRADE 派發點補記 `trade_task_start_tick`（防 start_tick=0 立即超時）
- `scripts/simulation/strategic_ai_system.gd`：`_find_trade_partner` 改 outpost-only（對方須擁有 outpost）；`_dispatch_trade_net` 記 `trade_task_start_tick`。
- `scripts/simulation/movement_system.gd`：居民鎖白名單加 `備戰`。
- `scripts/debug/headless_test.gd`：加 16 個 engagement 單測；修既有 `_test_trade_net_dispatches`（partner 補 outpost 以符合 outpost-only 新規）。

## 與 spec 差異

- `_refresh_attack_pursuit`：原碼用 `team_intel` 最後已知位置（非 spec 假設的 `prey.tile_pos`）。採 `predict_intercept`，視野外/不動時 fallback 回 intel 位置，保留原行為優點。
- cadence call 放在 `faction_ai.evaluate_all` per-team loop（非 `sim_runner`）；`_evaluate_threat` 內部自控 cadence，無需改 sim_runner。
- `trade_task_start_tick` 除 spec 指定的 strategic dispatch 外，另補在 faction_ai 兩處 TASK_TRADE 派發點（`_assign_member_tasks` / `_evaluate_solo`）— 否則這些 trader start_tick=0，tick>1440 後每 tick 立即被 timeout 誤殺。

## 驗證結果

- `headless_test.gd`：16/16 engagement 單測過，`=== DONE ===`，無新增 SCRIPT ERROR。
  - ⚠ 既有 `_test_full_config_load` 斷言 `game_sim_test 應 5 team，實際=8` **在 baseline（未改動前）已失敗** — 與本功能無關，非本 branch 引入。
- `game_sim_test.gd`：`ALL INVARIANTS PASSED (violations=0)`。
- `game_sim_multi.gd` 4 config × 90 天（各 21600 tick，全跑完，0 crash，無 game_over）：
  - **Combat > 0 ✅**：team Combat Start ×1 + game_sim_test 玩家遭遇戰 success=8；`[ThreatResponse]` ×21（逃跑/備戰/求和 各反應出現）。
  - **Trade 成交 > 0 ❌**：仍 0。

## ⚠ 核心目標未達：Trade 成交 = 0

W2 的 outpost-only 改動忠實照 spec 實作，但 **spec 自己列為已接受風險的情況發生了**（spec line 362：「trader outpost-only 找不到合適：rare（multi 有 outpost team），fallback 退回 mobile partner？暫不」）。

實測根因：
1. outpost-only filter 把 strategic trade 派發從 baseline ~433 次 砍到 ~2 次（merchant config 0 次）。
2. `_find_trade_partner` 要求對方 `team.resources` 有 goods 或 coin>50；居民團產出多沉澱到 `tile.public_storage`，team.resources 常為空 → 過濾掉。
3. merchant config 內 商隊團幾乎不進 trade_net 路徑（商隊多非 idle / faction trade_net goal 未觸發），strategic 與 faction_ai trade 派發皆 ~0。
4. 即使派發成功，merchant `move_target = partner.tile_pos`（對方當前位置），若 outpost owner 非居民（mobile 軍隊/統領擁 outpost）仍是動態目標，未必到。

## 待主 session 確認 / 建議後續 task

- **W2 是否改採 fallback**：spec 暫不 fallback mobile partner，導致 0 成交。建議：(a) outpost-only 找不到時 fallback mobile partner，或 (b) merchant 改 move_target 指向 **outpost tile 位置**（真靜止）而非 owner 當前 tile。
- **partner goods 判定**：是否納入 `tile.public_storage` 的 goods/coin（居民產出在公庫，非 team.resources）。
- **merchant config trade 路徑為何不觸發**：商隊團 idle 機率 / trade_net goal greed 門檻 0.35 是否需調，需設計面決定（屬「修改行為門檻」，非實作面）。
- threat_score 公式 magic 數 tune（求生欲/好戰/慎重 權重；THREAT_BASE_THRESHOLD 0.3）。
- 反應 task hysteresis（觸發 0.3 / 結束 0.2）避免邊緣抖動。
- 求和 tribute_offer cooldown 防 spam。
- 既有 `_test_full_config_load`（5 vs 8 team）pre-existing fail，建議另開 task 修。

## 連動風險

- `interaction_system._resolve_market`：trade 成交實際在此關閉，需 merchant 與對方同格。本 branch 未動此檔；若主 session 採上述 fallback，須確認同格觸發。
- `movement_system` 居民鎖：`備戰` 現可移動（白名單），但 `_dispatch_threat_response` 對居民 `備戰` 設 `move_target = (-1,-1)`（原地），故實際不會亂跑；若他處強設 move_target 才會動。
- `_evaluate_threat` 對所有 team（含 faction member）每日評估；與 `_assign_tasks` / `_evaluate_survival` 的 task 設定可能在同 tick 競爭（evaluate_all 內 faction loop 先於 per-team loop）。目前只在 idle 主動評、不打斷進行中 task，衝突已縮小，但 leader_team 的 外交 goal 與 迎戰 仍可能互蓋，未做完整優先級表（spec 衝突處理表 line 313）。
