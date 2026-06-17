# Hand Back: Anon Cohort Phase 1（純模組 + 單元測試）

## 實作摘要

- **新增** `scripts/simulation/anon_cohort.gd`（`class_name AnonCohort`，全 static 純函數）：
  - 常數：`TIER_ORDER`、`HEALTH_ORDER`
  - 鍵編解碼：`_key(tier, health)` / `_parse(key)`
  - 增減（維持稀疏 + 非負）：`add` / `remove` / `move`
  - 計數投影：`total` / `by_health` / `by_tier`
  - 數值投影（沿用 `AnonTierSystem.TIER_STATS` 單一來源）：`avg_combat` / `avg_speed` / `total_wage`
- **修改** `scripts/debug/headless_test.gd`：加 4 測試函數（`_test_anon_cohort_key` / `_mutate` / `_counts` / `_stats`）並於 `_initialize()` 註冊。

不變量已測：稀疏（count==0 鍵刪除）、count 非負、`remove`/`move` clamp 到現有並回實際數、空容器數值預設對齊現行（avg_combat→0.1、avg_speed→1.0、total_wage→0.0）。

## 與 spec 差異

無。本 plan 刻意只涵蓋 spec「階段 1」純模組部分（容器 + 編解碼 + 增減 + 投影 getter）。spec Phase 1 提及的 team_data 整合（加 `anon_cohorts`、`wounded` 轉 getter、AnonTierSystem 橋接）延後到 Phase 2 storage flip——已在 plan 藍圖註明，因 GDScript getter 唯讀會一次 break 所有寫入點，與「零整合零風險」的 Phase 1 目標衝突。

## 連動風險

**無已知連動風險。** 本 phase 零整合：

- 無任何系統呼叫 `AnonCohort`（全新模組，零 caller）。
- 未碰 `team_data` / `anon_tier_system` 任何既有行為。
- baseline 全測試（含 InvariantAudit population/faction/subteam）仍綠，`=== DONE ===`，0 `SCRIPT ERROR`。

## 待主 session 確認

- **Phase 2 storage flip 切換策略**：big-bang flip（一次把 `anon_tiers` 全改走 cohort、`wounded` 轉 getter、所有寫入點改入口）vs 漸進橋接（cohort 與 `anon_tiers` 雙寫過渡期、逐點遷移）。後者較安全但要維持雙寫一致性。
- Phase 4 才做的 InvariantAudit cohort 自洽網 + 存檔遷移，是否需在 Phase 2 先放 stub 防 drift。
