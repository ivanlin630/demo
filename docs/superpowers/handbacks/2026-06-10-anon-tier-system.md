# Hand Back: Anon Tier System

> 日期：2026-06-10
> Branch：`feat/anon-tier-system`
> Spec：`docs/superpowers/specs/2026-06-10-anon-tier-system-design.md`
> Plan：`docs/superpowers/plans/2026-06-10-anon-tier-system.md`

## 實作摘要

- **新檔 `scripts/simulation/anon_tier_system.gd`**：`class_name AnonTierSystem`
  - const：`TIER_ORDER` / `TIER_STATS` / `PROMOTION_EXP_THRESHOLD` / `PROMOTION_COST` / `ELITE_WEAPON_REQ` / `TRAINING_CAP_THRESHOLDS`
  - 查詢：`total_pop` / `total_wage` / `avg_speed` / `avg_combat_skill` / `tier_count` / `tier_breakdown`
  - 變動：`add_anon` / `remove_anon` / `add_exp` / `kill_random`(weighted) / `transfer_proportional`
  - 升等：`try_promote`（cap + cost + 菁英武器 check）
- **新檔 `scripts/simulation/training_system.gd`**：`TASK_TRAIN` team 每 tick 為各 tier 累積 exp（速率 = leader 戰術 × tier 人數）
- **`team_data.gd`**：
  - 加 `anon_tiers` (4 tier) / `anon_exp` (3 tier) dict
  - `anon_combat_skill` / `anon_wage` 改為 **computed getter**（delegate AnonTierSystem，向後相容；setter no-op）
  - 加 `const TASK_TRAIN := "訓練"`
- **`sim_runner.gd`**：加 `_training_system`，於 faction_ai 後 `_step6f_training`（near + far 區）
- **`game_setup.gd`**：`_setup_anon_tiers(team, cfg)`，3 條建團路徑（player / procedural / explicit config）皆呼叫；config 解析 `anon_tiers`，無則 fallback 全進「平民」

## 既有系統 migration

| 系統 | 改動 |
|---|---|
| `salary_system` | anon 薪資改 `AnonTierSystem.total_wage(team)` |
| `movement_system._compute_team_speed` | 匿名依 tier `TIER_STATS[tier].speed`（取代統一 1.0）|
| `npc_combat_system` | anon melee_str 乘 tier 係數 `0.3 + avg_combat_skill×0.4`（avg 0.5 ≈ 舊 0.5）|
| `encounter_system` | spawn 單位戰鬥技能用 `avg_combat_skill`；死亡用 `kill_random`；勝負結算加存活 exp（+5 倖存 / 勝方 +5）|
| `subteam_system.merge_teams`（2 site）| anon 併入用 `transfer_proportional` |
| `player_command_system` 招募 anon | `transfer_proportional(tgt, pt, 1)` |
| `reaction_system` P3_recruit | 新人口 `add_anon(team, "平民", 1)` |
| `events/event_unrest_split` | anon 拆分用 `transfer_proportional` |
| `faction_ai_system` | **刪** `_update_anon_combat_skill` / `_update_anon_wage`（含 evaluate_all 內 call）→ 改 computed |

## 行為變化

- team 之間有 tier 質量差異（老牌 vs 新團不再同強）
- 全 team 起始為「平民」→ 速度 0.7、戰鬥 0.1、wage 0.5/head（**比舊統一值低**）
- leader 戰術 skill 控訓練可達上限（≤0.4→新兵、≤0.7→老兵、>0.7→菁英）；戰場 exp 不受 cap
- 升等：pool exp 達 threshold（flat，非 ×count）即可升一波；扣物資 ×count；菁英需持有 `weapon_melee_high ≥ 菁英總數`（check 不消耗）
- 戰鬥死亡 weighted random（依各 tier 人數）

## 驗證結果

- `headless_test.gd`：**EXIT=0 全過**（含新增 13 個 AnonTier 測試 Task1~5 + movement speed）
- `game_sim_test.gd`：**ALL INVARIANTS PASSED (violations=0)**；`AnonTier-Computed` feat OK
- `game_sim_multi.gd`：4 config（game_sim_test / tyrant / merchant / warzone）× 21600 tick（90 天）**無 crash、無 invariant violation、died=no**

## 連動風險 / 注意

- **API 破壞性大**：所有 salary/movement/combat/interaction/outpost/split call 點已 migrate
- **全域減速**：匿名平民 speed 0.7（−30%），短測（200 tick）內時間敏感功能可能變慢。`Trade trade_success=0` 在 **main baseline 已 fail（pre-existing）**，非本次 regression
- **舊 S7 機制廢除**：tag-based `anon_combat_skill`（軍隊→0.4）取消。`game_sim_test` 的 S7-Params feat 已改為 `AnonTier-Computed`（驗 getter == tier avg）
- **plan 內部矛盾已修正**：plan `try_promote` code 寫 exp `threshold × count`，但 plan 自身測試（exp=50, count=5 → 成功、exp→0）要求 **flat threshold**。採測試為準（flat 檢查 + flat 消耗），cost 仍 ×count
- 移除的舊測試：`_test_anon_combat_skill_field` / `_test_update_anon_combat_skill` / `_test_update_anon_wage`（測已刪函數）；`_test_faction_ai_run_calls_all_updates` 移除 anon 兩條 assert（保留 armor/guard）
- `armed_anon_ratio` 維持不變（equipment_system 擁有，與 tier 解耦）

## 待主 session 確認（平衡 / 另 spec）

- `TIER_STATS` 屬性平衡（combat/speed/base_wage）
- 升等 exp threshold / cost 平衡、訓練速率公式（`EXP_RATE_MULT`）
- 全域減速是否需調整 tick 常數補償（merchant 時效）
- `try_promote` flat-threshold vs ×count 語意最終定案
- named 升階機制（從 anon 抽 → tier 決定 named 初始屬性）→ 另 spec
- 戰俘處置 / 外交招募 / UI tier 分布 → 另 spec
