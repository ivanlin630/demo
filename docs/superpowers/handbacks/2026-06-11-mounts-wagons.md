# Hand Back: Mounts / Wagons 速度系統

> 分支：`feat/mounts-wagons` ｜ Spec：`docs/superpowers/specs/2026-06-11-mounts-wagons-design.md` ｜ Plan：`docs/superpowers/plans/2026-06-11-mounts-wagons.md`

## 實作摘要

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/movement_system.gd` | `get_effective_wagons` 改 1人1獸（pop − effective_mounts 上限）；新增 `_compute_mount_bonus`/`_compute_wagon_penalty`，`_compute_team_speed` = base × mount × wagon（原邏輯抽成 `_compute_base_team_speed`）；**刪 `_tick_stray_mounts`** + caller + `STRAY_RATE` const；`_on_arrival` 加野馬採集 |
| `scripts/simulation/resource_system.gd` | `resolve_consumption` 加 mount 草料消耗 `FOOD_PER_MOUNT_PER_DAY=0.5`/day |
| `scripts/simulation/outpost_system.gd` | **`FACILITY_DEF` 加 `stable` entry**；`UPGRADE_COST["stable"]`；`STABLE_PRODUCE_PER_DAY`/`STABLE_FOOD_PER_DAY`/`STABLE_CAP`；`tick_all` 加 stable 產出；新 `produce_stable_day`；`_complete_construction`/`_subteam_upgrade_facility` 加 `stable` case（限平原）；demolish 重置 stable |
| `scripts/data/tile_data.gd` | 加 `stable_level`、`stable_progress` |
| `scripts/simulation/faction_ai_system.gd` | facility 擴建迴圈加 `required_terrain` gate；新 `_check_mount_demand` |
| `scripts/simulation/world_generator.gd` | tile 生成加 `wild_horses`（平原 1% 1–2、森林 0.5% 1） |
| `scripts/simulation/harvest_system.gd` | `tick_all` 加月邊界 `_regen_wild_horses`（5% +1，cap 3） |
| `scripts/simulation/encounter_system.gd` | `init_encounter` 記 `encounter_initial_pop` 快照；新 `apply_mount_loot`（loser_mounts × kill_ratio），`resolve_encounter_end` 呼叫 |
| `scripts/data/team_data.gd` | 加 `encounter_initial_pop` |
| `scripts/debug/headless_test.gd` | 加 9 個 mount/wagon 測試 |

## 與 Spec 的差異（重要，待確認）

1. **野馬採集 = 抵達自動收編，非「task=採集」**：Spec/Plan 寫「team 站 wild_horse tile + task=採集」，但 `TeamData` 無「採集」task、`harvest_system` 也無 per-team 採集流程。為避免發明新 task + 新 AI，改為 **`movement_system._on_arrival` 抵達該格即自動收編野馬**。任何路過的 team 都會撿走。
2. **stable 只在 civilian outpost 蓋得起來**：既有 facility 擴建機制（`_evaluate_infrastructure` 步驟2 + `_subteam_upgrade_facility`）只處理 civilian outpost。stable category 雖標「軍事」，`cap_by_outpost` 設 `civilian:[1,2,3] / military:[0,0,0]`，NPC 實際只會在 **平原 civilian 據點**蓋。軍事據點養馬未支援（需改世界模型，不在範圍）。
3. **`trigger_check` 目前是死碼**：擴建決策（步驟2）只看 `cap vs current_level`，不呼叫 `trigger_check`（farming/manufacturing/mint 皆然）。新增的 `_check_mount_demand` 同樣未被呼叫，僅為與既有 FACILITY_DEF 結構一致而補。
4. **stable 產出 LOD 限制**：`outpost_system.tick_all` 只在近區（玩家半徑內）每小時跑，與 `mint` 相同 → 遠離玩家的馬廄不產馬。沿用既有限制。
5. **mount loot 與既有 `loot_pool` 並存**：`resolve_encounter_end` 既有 `loot_pool` 已含 30% mounts（記錄於 `last_encounter_result`，玩家 subjugate 用，未實際轉移）。新 `apply_mount_loot` 是**實際轉移** mounts 給勝方，兩者語意不同、不衝突。

## 連動風險

- `get_effective_wagons` 改動：`get_carry_capacity` 與 `_move_cost` 車輛地形懲罰都用它 → 有 mount 的隊，effective_wagons 會被壓低，carry cap 與 wagon penalty 隨之下降（符合 1人1獸，但屬行為變化）。
- mount 食物消耗：大騎兵團 food 經濟負擔加重，可能更早觸發飢餓徵用 / survival。multi 90 天未見異常。
- `resolve_consumption` 每次 new 一個 `MovementSystem`（取 `get_effective_mounts`）；頻率低（cadence tick），開銷可忽略，但可考慮改 static。

## 驗證結果

- `headless_test`：所有新增 9 個 mount 測試 **OK**，`=== DONE ===`。唯一 SCRIPT ERROR 為**既有** `game_sim_test 應 5 team 實際 8`（main 同樣存在，config 漂移，非本次引入）。
- `game_sim_test`：**ALL INVARIANTS PASSED (violations=0)**，0 SCRIPT ERROR。
- `game_sim_multi`：4 config × 21600 tick（90 天）全跑完，0 SCRIPT ERROR，無崩潰。
  - 未觀察到 stable 建造 / 野馬採集 / mount loot（mount 活動 = 0）：野馬 1% 稀有、NPC 蓋馬廄路徑慢（需平原 civilian 據點 + 7200-tick 建造），90 天內難自然發生。Spec 風險清單已預期。

## 待主 session 確認

- **參數 tune**：mount bonus / size_penalty（50 騎僅 2.4X，spec 疑追不上慢 prey）、stable food cost（30 material+50 coin + 5 food/day）、野馬 1% 是否過稀。
- **差異 1（野馬採集機制）**是否接受「抵達自動收編」取代「採集 task」，或要求補一個正式採集 task + AI。
- **差異 2（軍事據點養馬）**是否需要支援（要改 facility 擴建機制）。
- Combat 是否因 mount 速度差有改善（multi 仍只 2 場，樣本太小，需專門場景驗證 W1）。
