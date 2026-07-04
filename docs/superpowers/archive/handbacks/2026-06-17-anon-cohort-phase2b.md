# Hand Back: Anon Cohort Phase 2b（wounded 折入 cohort health 維度 + 修膨脹漏水）

## 實作摘要

`wounded` int 累加器 → cohort `health="wounded"` 桶投影。受傷/治療/轉移全走 cohort `move`，結構性消除單調膨脹漏水。

- **`scripts/data/team_data.gd`**：`var wounded: int = 0` → 唯讀 computed getter（`AnonCohort.by_health(anon_cohorts, "wounded")`），`set` no-op。舊「讀」零改，舊「寫」失效轉走 AnonTierSystem。
- **`scripts/simulation/anon_tier_system.gd`**：加 `_weighted_tier(team, health)`（依桶內各 tier count 加權選 tier，對齊 `kill_random` 分布）+ `wound_random`/`heal_random`/`kill_wounded(team, n)->int`（回實際操作數）；`transfer_proportional` 改 health-aware（迭代 `HEALTH_ORDER × TIER_ORDER`，兩桶都按比例搬，保 tier+health）。`kill_random` 維持只殺 healthy。
- **`scripts/simulation/health_system.gd`**：`resolve_anon_units` 尾段 3 處 `team.wounded += 1` → 本地 `wounded_count` 累加（每 anon 至多計一次，修原 bleed+fracture +2 bug），迴圈後一次 `wound_random`。死亡分支（`_is_unit_dead_bp` → `population -= 1`）原樣保留。
- **`scripts/simulation/npc_combat_system.gd`**：`_apply_casualties` anon 傷 `team.wounded += 1` → `anon_wounded` 累加，迴圈後 `wound_random`。
- **`scripts/simulation/interaction_system.gd`**：`_treat_wounded` `team.wounded -= to_treat` → `heal_random(saved)` + `kill_wounded(died)`，保 `population -= died`。`wounded` 讀取點全走 getter。
- **`scripts/simulation/subteam_system.gd`**：`_transfer_proportional_assets` 刪除 3 行手動 wounded 轉移（getter 後無效）；wounded 桶改由 caller 的 health-aware `transfer_proportional` 帶走。已核對 4 處 caller（164/165、224/226）皆先呼叫 `transfer_proportional` 且 count 涵蓋 wounded（`population`/`total_pop` 含 wounded 桶）。
- **`scripts/simulation/invariant_audit.gd`**：population 公式去 `+ t.wounded`（wounded 已含於 `total_pop`），更新訊息與註解。
- **`scripts/debug/headless_test.gd`**：加 `_test_anon_wound_heal_kill`（wound/heal/kill_wounded + 上限不膨脹 + getter）、`_test_anon_transfer_carries_wounded`（轉移帶走 wounded 桶），註冊於 `_initialize`。

## 驗證

- **headless_test**：`=== DONE ===`，0 `SCRIPT ERROR`，`[OK] _test_anon_wound_heal_kill`、`[OK] _test_anon_transfer_carries_wounded`，既有斷言全綠。
- **game_sim_multi**：4 config 跑完，0 `SCRIPT ERROR`，`coin_eq` delta=0（4455/4195/2930/1280 init==final）。`[InvariantViolation]` 全為既有 population drift，每 config 跨 tick **數量穩定不增**（merchant 9、game_sim_test 7–9、tyrant 24–25、warzone 26–29），drift 示例為 off-by-1（欄位=7 期望=8 anon7）—— **無 wounded 單調膨脹特徵**（wounded 受 anon 上限 move 約束）。

## 與 spec 差異

- **`kill_random` 保持只殺 healthy**：anon 無 per-unit 傷況，wounded 在營不上戰場，只因治療失敗死（走 `kill_wounded`）。對 spec「wounded 來源」的合理具體化。
- **combat `population - wounded` 公式未改**：2a handback 曾預告 2b 改 `healthy_pop`。實際不需要 —— `wounded` getter 回 cohort wounded 桶、`population` 仍含 wounded anon，故 `pop - wounded` 自動續正確（getter 透明）。改寫無行為差異且增風險，故不動（plan architecture 已說明）。

## 連動風險

- **`population` 仍手動寫入**：未轉 getter（2c 範圍）。drift off-by-1 來自此，非本 phase 引入。
- **anon 死亡雙路徑並存**：`resolve_anon_units` 死亡分支直接 `population -= 1`（encounter 暫時 unit，未進 cohort 統計）與 `kill_random`（cohort）並存，2c 統一。
- **存檔 / 序列化**：`wounded` 已無 storage（getter only）。若持久化路徑曾存 `wounded` 欄位，需 Phase 4 處理（隨 `anon_cohorts` 序列化）。本 branch 未碰存檔。

## 待主 session 確認

- 啟動 **Phase 2c**：`population` → getter（`leader + named + total_pop`）+ 刪所有手動 `population` 寫入點（消 off-by-1 drift + 統一 anon 死亡路徑）。
- Phase 4：InvariantAudit cohort 自洽網 + 存檔遷移 + docs（`invariants.md` Anon 段）。
