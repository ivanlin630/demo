# Hand Back: Anon Cohort Phase 2a（storage flip：anon_tiers → anon_cohorts）

## 實作摘要

行為位元不變的原子型別替換。所有 anon 進 `"tier|healthy"` 桶（2a 不啟用 wounded 維度）。

- **`scripts/data/team_data.gd`**：移除 `anon_tiers` 儲存欄位，改 `var anon_cohorts: Dictionary = {}` 稀疏容器；`anon_tiers` 降級為唯讀 computed getter（回 4-tier breakdown `{tier: by_tier 跨 health 總數}`，恆 size 4），`set` no-op。舊「讀」零改。
- **`scripts/simulation/anon_tier_system.gd`**：全函數體改走 `AnonCohort`（操作 `team.anon_cohorts` 的 `"healthy"` 桶），public 簽名/語意不變 = 呼叫端零改。`total_pop`/`total_wage`/`avg_speed`/`avg_combat_skill`/`tier_count`/`tier_breakdown`/`add_anon`/`remove_anon`/`kill_random`/`transfer_proportional`/`try_promote` 全遷移。常數 + `add_exp`（操作 `anon_exp`）原樣不動。
- **`scripts/simulation/game_setup.gd`**：`_setup_anon_tiers` 寫入改 `AnonCohort.add(..., "healthy", n)`，named/wounded 計算邏輯不變。
- **`scripts/simulation/beast_system.gd`**：`t.anon_tiers = {}` → `t.anon_cohorts = {}`。
- **`scripts/debug/headless_test.gd`**：加 `_seed_anon(t, {tier:count})` helper；遷移全部 anon 寫入點（22 處：14 整 dict 指派改 `_seed_anon`、8 單 tier 指派改 `AnonCohort.add`）；讀取/斷言一律不動（靠 getter 滿足）。

## 驗證

- **headless_test**：`=== DONE ===`，0 `SCRIPT ERROR`，`[OK]` 計數 49（與 baseline 完全相同）。anon 斷言全綠（AnonTier Task1–5、_test_anon_cohort_*）。
- **game_sim_multi**：4 config 跑完，0 `SCRIPT ERROR`，`coin_eq` delta=0（4455/4195/2930/1280 init==final）。`[InvariantViolation]` 全為**既有 population drift**（drift 示例顯示 `anon5`/`anon6` 等正確值，與 storage 無關），數量與 baseline 同量級（warzone ~35–47、merchant ~9、game_sim_test ~7–10）。多次計數差異源於 `world_generator` `rng.randomize()`（game_sim_multi 無固定 seed → 非決定性），非行為變更。

## 與 spec 差異

- `anon_tiers` getter 採 **set no-op**（非「唯讀報錯」路線）：殘留未遷移寫入會 silently no-op，靠全套回歸斷言抓資料不符。實測無殘留（grep 確認 `scripts/` 內 `.anon_tiers =` / `.anon_tiers[...] =` 寫法僅剩一處註解）。
- **`scripts/debug/qa_probe.gd` 未改**：該檔在 main 為 untracked，不存在於本 worktree branch，無從遷移。若主 session 之後把它納入版控，需手動把 `for t in pt.anon_tiers: pt.anon_tiers[t] = 0` 改為 `pt.anon_cohorts = {}`。

## 連動風險

- **`wounded` int 欄位**：仍完全獨立（讀寫原樣）。2b 才折入 cohort health 維度 + 修漏水 + 公式調（combat `pop-wounded-named` → `healthy_pop`）。
- **`anon_combat_skill` / `anon_wage` shim**：經 `AnonTierSystem.avg_combat_skill` / `total_wage` 自動跟著走 cohort，已驗（getter 路徑無改）。
- **存檔 / 序列化**：若有持久化 `anon_tiers` 欄位的路徑，因該欄位已無 storage（getter only），需 2c/Phase 4 處理 `anon_cohorts` 序列化。本 branch 未碰存檔。

## 待主 session 確認

- 啟動 **Phase 2b**：`wounded` → cohort health 維度（`"tier|wounded"` 桶）+ 修 wounded 漏水 + combat 公式改 `healthy_pop`。
- Phase 4：InvariantAudit cohort 自洽網 + population drift 收斂 + 存檔遷移 + docs（`invariants.md` Anon 段仍寫「儲存於 `team.anon_tiers` dict」需更新為 `anon_cohorts`）。
