# Hand Back: 階段1 Plan 2c — subsistence 改狩獵唯一

Branch: `feat/hunting-subsistence`
Plan: `docs/superpowers/plans/2026-06-14-stage1-2c-hunting-subsistence.md`

## 實作摘要

- `scripts/simulation/resource_system.gd`：`collect_resources` 的 `outpost_level==0` 分支移除 `_forage_from_tile` 呼叫，保留被動小獵（有 `wild_game` 才獵）；刪 `_forage_from_tile` 函數 + `const FORAGE_RATE`（已無引用）。`forage_today`/`flush_forage_episodes` 管道保留（狩獵得肉照走日彙整）。
- `scripts/simulation/faction_ai_system.gd`：`_find_forage_tile` 改找本格+鄰格 `wild_game` 最多的無 outpost 格；皆無 game → 回 `(-1,-1)`（Path 3.5 守衛放行掉到乞食/idle）。
- `scripts/debug/headless_test.gd`：
  - `_test_forage_no_outpost` → `_test_no_passive_forage_food`（反轉預期：無 wild_game 格零食物產出、food pool 不被動）
  - 新 `_test_find_game_tile`（forage path 選 wild_game 鄰格；周圍無 game 回 -1,-1）
  - `_test_passive_hunt_on_forage` 補「有 wild_game 應靠被動小獵得食物」斷言
  - 刪 `_test_forage_scale_cap`（驗被動覓食 scale，已無意義）

## 與 spec 的差異

無。spec §1/§2「狩獵唯一」如實落地。

## 計畫外但必要的改動（請主 session 確認）

舊測試假設「覓食永遠有得採」（`_find_forage_tile` 舊版空世界回 `team.tile_pos`）。狩獵唯一後，無 `wild_game` 的格 → survival 掉到乞食/idle，3 個 survival 單元測試因此轉紅。已補 `wild_game` tile 保其原意（測 survival 觸發/覆蓋機制，非 forage 結果）：

- `_test_survival_trigger_urgent` / `_test_survival_reeval_in_loot` / `_test_arbiter_survival_beats_dispatch`：各加 `_mk_game_tile(state, (0,0))`（新 helper）。
- `_mk_state_with`（`_test_npc_forage_viability` / `_test_forage_release` 共用）：tile 補 `wild_game:5`。

純測試 fixture 補強，未改世界模型/規則。

## 量測結果（Task 4，2 年 ×3 config）

`SIM_CONFIGS=survival_start,tyrant,warzone`，`game_sim_multi.gd`：

| config | died | coin_eq delta | pop_init→final |
|---|---|---|---|
| survival_start | no | 0.00 | 23→~4（4 persons 存活） |
| tyrant | no | 0.00 | 88→94 |
| warzone | no | 0.00 | 134→73 |

- **0 SCRIPT ERROR**（sim 全程）。守恆 delta=0 三 config。
- **噴泉解除（核心交付）**：無據點隊（FoodLedger `op=0`）`days` 由舊 300+ 降到 **0~26 天**，income/day ≈ burn 或 NA → 遊牧獵人精準度區間，符合 spec「減緩餓死不餵飽」。
- 高 `food`/`days` 的 ledger 行均為 `op=1`（據點隊），屬正常据点經濟，非被動覓食噴泉。

判斷：落在「剛好遊牧獵人 precarity」→ 收手不 tune，記錄為現行定值（`HuntSystem.PASSIVE_BASE_CHANCE`/`FOOD_PER_GAME`/`world_generator.WILD_GAME_*` 維持）。

## 連動風險

- `world_generator`（WILD_GAME 密度/再生）：狩獵唯一後，無據點隊存亡完全綁 `wild_game` 分佈。survival_start 兩年 pop 23→~4（Famine 事件 87 次/3config）— 死率偏高但 died=no、非全滅。**建議主 session 觀察**：若認定 survival_start 過嚴，下一輪單調一變因（升 `WILD_GAME` 密度或再生率），勿同時多調。
- `faction_ai`：`TASK_FORAGE` 名稱沿用，語意已改為「赴獵物格狩獵」；無 game 時 survival 落到乞食/idle release（既有 latch-fix 邏輯，未新增）。

## 既存問題（非本 plan，主 session 知會）

- `_test_on_team_extinct_to_storage`（headless_test.gd:4948「food 應進公庫」）在 **main baseline 即紅**，與本 plan 無關。Godot assert 不中止執行，`=== DONE ===` 仍達。本 plan 未動該路徑。
