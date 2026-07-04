# Hand Back: G3-targeting 攻擊/掠食目標選擇讀 belief

branch: `feat/g3-targeting-belief`（已 push origin）
plan: `docs/superpowers/plans/2026-06-20-g3-targeting-belief.md`
status: **open**（待主 session 確認 / merge）

## 實作摘要

- `scripts/simulation/faction_ai_system.gd`：
  - `find_prosperity_prey`：候選迴圈加 `has_belief` 守衛（無情報→continue，禁 god-view）；richness/weakness 改從 `BeliefSystem.best_estimate` 估。weakness 吃 `armed_est`（退 pop_est）。新增 static `_belief_richness`（tier2 sum/100 → resource_scale 粗估 → 0）。自身真值 `team.population` 照讀。
  - `_find_weakest_prey`：同模式 `has_belief` 守衛 + pop_est/food_est 從 belief；無 food_est 不以食物擋（以 pop 弱點為主）。best_pop 型別 int→float。
- `scripts/debug/headless_test.gd`：
  - 新增 `_test_prey_select_reads_belief`（偽裝低 armed_est→被選；看穿真強→不選；無 belief→不評估返 -1）、`_test_survival_prey_reads_belief`（belief 看似弱被選、無情報跳過）。**註冊置於 run 列尾**（見下連動風險）。
  - 修既有測補 belief seed：`_test_find_prosperity_prey`、`_test_prosperity_prey_personality_weight`、`_test_survival_helpers`、`_test_survival_decision_tree`(path2)、`_test_ai_catch_up_filters_unreachable`（皆原直靠 prey 真值，遷後須親見 claim）。
- `docs/invariants.md`：新增「攻擊目標選擇讀 belief（G3-targeting）」段。
- `docs/known_issues.md`：G3d-2 god-view 缺口標已補 + TEST VALUE + OUT。
- `docs/progress.md`：G3-targeting ✅ 誘殺脊椎閉環當前狀態。

與 spec 差異：無。鎖定設計決策全照辦（armed_est 偽裝載體、_belief_richness 三態、survival food 門檻、禁 god-view fallback、自身真值照讀）。

## 回歸結果

headless 全綠：`=== DONE ===`、SCRIPT ERROR 0、assertion failed 0、`[FAIL]` 0、新測 belief OK ×2、`[ProsperityAttack]`×5 + `[SurvivalLoot]`×2 + `[Scout]`×2 並見（不凍結）、InvariantAudit OK ×3、投靠守恆(coin_eq) OK。

## 連動風險

- **unseeded RNG 序（已處置，但記錄）**：新測初版註冊在 run 列前段時，`_seed_pop` 等消耗全域 RNG → 下游 `IntelSystem Tier0` 噪估（population_est 期望 10–30）由 11 漂到 31 越界 [FAIL]。**已將新測註冊移到 run 列尾**避擾前段序，pop_est 回 15 在範圍。根因是該 IntelSystem 邊界測試本身對全域 RNG 順序敏感（unseeded），非本 feature bug；若日後其他人在前段插測仍會踩。**建議主 session 評估**：是否給該 IntelSystem 噪估測試加 `seed(N)` 隔離（對齊既有 seed(7)/seed(11) 用法），根治順序脆弱。
- **`_nearest_independent`（solo/faction loot 目標選擇）仍讀 team_discovered 真值**：本 plan OUT（只遷 prosperity/survival 兩選擇器）。solo `_evaluate_solo` 掠奪/攻擊、faction goal「掠奪」走 `_nearest_independent`，未經 belief。若視為同類 god-view 缺口，需後續 plan（屬「目標決策讀殘缺情報」總則未竟之處）。
- **威脅(防禦)/team_known claim 化/情報戰 C**：同 G3d-2 OUT，延 post-measure。

## 待主 session 確認

- 上述 IntelSystem 噪估測試 seed 隔離建議（根治 unseeded 順序脆弱）。
- `_nearest_independent` 是否納入下一輪 belief 遷移（solo/faction loot targeting god-view）。
- 1000 Tick：headless 內 sim 段為 200 Ticks（既有 harness，與 G3d-1/2 同）；plan 文「1000 Tick」沿用 CLAUDE 交付標準措辭，實際以既有 headless sim 跑完不崩為準（本次達成）。如需真 1000-tick 長跑驗證，走 game_sim_multi（但 plan 明示「不用 multi drift」）。
