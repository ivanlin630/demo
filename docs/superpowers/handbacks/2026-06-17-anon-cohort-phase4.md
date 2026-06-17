# Hand-back — Anon Cohort Phase 4（cohort 自洽審計網 + 文件收尾）

分支：`feat/anon-cohort-phase4`
Plan：`docs/superpowers/plans/2026-06-17-anon-cohort-phase4.md`

## 實作摘要

| Task | 動作 |
|---|---|
| 1 | `invariant_audit.gd` 加 `_check_anon_cohort`（每桶 count>0、鍵合法 tier∈TIER_ORDER/health∈HEALTH_ORDER），註冊進 `check()` |
| 2 | `headless_test.gd` 加 `_test_invariant_anon_cohort` + `_contains_substr`（正常 cohort 過、非法鍵 + 負桶被抓），註冊於 `_initialize()` 不變量區 |
| 3 | `invariants.md` anon 段改 cohort 模型；新增「資料模型不變量規則」節 |

零行為變更（純加檢查 + 文件）。

## 驗證

- `headless_test.gd` → `=== DONE ===`、`[OK] _test_invariant_anon_cohort`、`InvariantAudit population OK`、無 `SCRIPT ERROR`。
- `game_sim_multi.gd` → 全 4 config `coin_eq delta=0.00`；無 `population drift`；cohort 自洽網 **0 違反**；無 `SCRIPT ERROR`。

## 連動風險

- **存檔遷移 N/A**：專案無 save/load 系統（`FileAccess` 僅讀 config JSON）。
- **旁註 pre-existing**：multi 殘留 `faction 反向破` / `faction 雙向破` 違反（game_sim_test/tyrant/merchant/warzone 皆有）。與本 plan 無關，為獨立 known issue，建議後續另開 branch 修（faction member_team_ids 雙向同步在滅團/脫離時未清）。

## 收尾聲明

anon 統一 cohort 模型重構**全竣**（Phase 1 → 2a → 2b → 2c-1 → 2c-2 → coin fix → Phase 4）。
population/wounded/anon_combat_skill/anon_wage 全為投影 getter（物理不可 drift），cohort 結構由 InvariantAudit 守。
