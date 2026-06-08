# Hand Back: NPC Infrastructure (C)

分支：`feat/npc-infrastructure`（worktree `.worktrees/feat/npc-infrastructure`）
Plan：`docs/superpowers/plans/2026-06-09-npc-infrastructure.md`（12 Task 全完成）

## 實作摘要

| 檔案 | 變更 |
|---|---|
| `scripts/data/team_data.gd` | 加 `task_extra_data: Dictionary`（子隊任務附加數據） |
| `scripts/simulation/outpost_system.gd` | 加 `FACILITY_DEF` 註冊表；`begin_subteam_construction` + `_subteam_upgrade_level` / `_subteam_upgrade_facility`（faction 擁有權施工）；完工 `_auto_settle_builder`（建造子隊就地安頓） |
| `scripts/simulation/faction_ai_system.gd` | `_check_food_shortage` / `_check_goods_shortage`；`_pick_advisor`、`_dispatch_builder` / `_dispatch_upgrader` / `_dispatch_facility_builder`；`_evaluate_new_outpost_location` + `_min_dist_to_enemy_outpost`；`_pick_outpost_type`、`_evaluate_infrastructure` 主決策（升級→擴建→蓋新）；整合進 `evaluate_all`（每 `INFRA_INTERVAL`=500 tick）；`_evaluate_subteam` 加 `建設` 守衛（施工不打斷）；`_evaluate_uprising` 起義取消施工 |
| `scripts/simulation/movement_system.gd` | `_on_arrival`：基建子隊（建造/升級/擴建）抵達 → `begin_subteam_construction` |
| `scripts/simulation/player_command_system.gd` | 加 `build_facility` action（依 `player_state["facility_type"]` 分派 farming/manufacturing） |
| `scripts/debug/headless_test.gd` | Infra Task1–11 共 10 個測試 |

## 與 Plan 的差異（API 校正）

Plan 內 code snippet 是依「假設 API」寫的，與實際 codebase 不符，已逐一校正並保留 Plan 的測試契約意圖：

- `OutpostSystem.start_build` 實際簽名為 `(state, team, type, level)`，非 `(team, type, level)`。
- 不存在 `OutpostSystem.upgrade(team, facility)`；實際為 `start_upgrade_farming(state, team)` / `start_upgrade_manufacturing(state, team)`。`build_facility` action 改為分派至這兩者。
- 任務常數 `TeamData.TASK_BUILD = "建設"`，且 `tick_construction` 只處理 `建設`。子隊「旅途」task 用 `建造/升級/擴建`，**抵達後**經 `begin_subteam_construction` 切成 `建設` 才被施工 tick 推進。
- Tile 用 `construction_ticks_left` / `construction_team_id` / `construction_target`，無 `construction_progress`（Plan Task9 用詞已校正）。
- `upgrade_outpost` player action **本來就存在**（呼叫 `start_upgrade_level`），Task10 僅補測試。
- 升級/擴建子隊非 outpost owner（owner=母團），故新增 `_faction_owns()` 以「faction 擁有權」放行就地施工，而非 `start_upgrade_*` 的嚴格 `owner==team_id` 檢查。
- Plan Task8「母團派安頓子隊」改為 **建造子隊完工後自身就地安頓**（`_auto_settle_builder`：脫離母團、加 PRODUCE/MILITARY tag）。較穩健、避免二次派遣與 outpost 孤兒化。

## 驗證

- `headless_test.gd`：0 SCRIPT ERROR、`=== DONE ===`，Infra Task1–11 全 OK，既有測試全綠。
- `game_sim_test.gd`（7200 tick）：0 SCRIPT ERROR、`ALL INVARIANTS PASSED (violations=0)`。
- 既有 `[FEATURE FAIL] Trade trade_success=0` 在 `main` baseline 即存在，與本次無關。

## 連動風險

- `game_sim_test` 目前情境（玩家中心、persons_total=14）**不形成 NPC faction**（立國=0），故 NPC 基建路徑在該 sim 未被觸發、無 `[Infra]` log。功能正確性由 unit test 保證。需要更大型 NPC 世界情境才能在 integration sim 觀察到 NPC 主動蓋/升級。
- 軍用 outpost 建造子隊安頓後加 `MILITARY` tag（非 PRODUCE），不受居民移動鎖約束，可能離開該格。民用（PRODUCE）正常駐留。
- `_dispatch_*` 以母團 1.5x 資源餘量檢查，但子隊只分到 `pop/parent_pop` 比例資源；抵達後 `start_build` 若分到不足會 false（優雅跳過，不崩潰）。
- 安頓後的 owner team 有 `faction_id` 但未加入 `faction.member_team_ids`（與現有子隊行為一致）。

## 待主 session 確認

- 副官建言路徑：玩家 leader 的 faction 目前在 `_evaluate_infrastructure` 直接 return（TODO `AdvisorSystem.push_outpost_advice`）。
- 獨立（faction_id=-1）team 主動蓋 outpost 邏輯（Plan 提及未展開）。
- 新設施類型擴充（城牆、市集等）—— `FACILITY_DEF` 已 data-driven，可直接擴。
- `INFRA_INTERVAL`=500 tick 為測試值，待 tick 平衡時調整。
</content>
</invoke>
