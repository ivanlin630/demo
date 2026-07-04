# Hand Back: 玩家動作 Parity + 主隊 Task 收口

branch: `feat/player-action-parity`
plan: `docs/superpowers/plans/2026-06-16-player-action-parity.md`
spec: `docs/superpowers/specs/2026-06-16-player-action-parity-design.md`

## 實作摘要

- `scripts/simulation/reaction_system.gd`：恐慌橋 `if flee_count...` 加 `and team.leader_id != state.player_id` 守衛 → 玩家主隊不被設「逃跑」task/move_target。其餘恐慌效果（work_morale、per-person 忠誠/壓力/叛逃、戰場潰逃）不動。
- `scripts/ui/text_ui_main.gd:654`：玩家主隊狀態列「任務:」→「狀態:」（只此一行；子隊/成員「任務」下令字樣保留）。
- `scripts/simulation/player_command_system.gd`：新 `TRAIN_COST_COIN=30`/`TRAIN_EXP_GAIN=20`/`CAMP_BUILD_TICKS=240`/`CAMP_FOOD_CAP=40` 常數 + registry 加 `train`/`camp` + `_action_train`（coin sink → `AnonTierSystem.add_exp`+`try_promote`）+ `_action_camp`（免材料 + `_check_distance` spacing + 設 construction + `TaskArbiter.try_set` TASK_BUILD/PRIO_PLAYER）。
- `scripts/simulation/outpost_system.gd`：`_complete_construction` 加 `"crude_camp"` 分支（lvl1/owner/type + **只抬 `resource_cap["food"]`,絕不動 `resources["food"]`** + 軍/生產 tag + erase 流亡 + `TaskArbiter.release` 完工釋放）。
- `scripts/simulation/player_query_api.gd`：available_actions 加 `train`/`camp` self-action（`allowed_kinds:["none"]`，走 `PlayerApiMapper.map_available_action`，gate:有 anon / 腳下可紮營）。
- `scripts/debug/headless_test.gd`：`_test_panic_skips_player_team`（NPC 對照組）、`_test_player_train`、`_test_player_camp`（含完工釋放斷言）+ `_test_action_ui_coverage` map 加 train/camp。
- `scripts/debug/ui_flow_test.gd`：`_test_player_status_label`、`_test_train_action_reachable`、`_test_camp_action_reachable`。

## 與 plan 的差異

- plan 的 available_actions 是簡化 dict literal；現碼自 P4-2 起 self-action 走 `PlayerApiMapper.map_available_action` → 照現碼實作（plan 已註「以現碼為準」）。
- `_test_action_ui_coverage` 覆蓋審計 dict 需加 train/camp（plan 未列，但不加 assert fail）→ 已加，in-scope。
- **修正**：Task 4 實作初版誤把 plan 的 `TaskArbiter.release(team)` 從 crude_camp 分支移除（誤認尾段統一 release，實際尾段無 release）→ 玩家隊紮營後永卡 task=建設。controller review 抓到並補回 + 加測試斷言。

## 驗證

- headless：`=== DONE ===` 無 SCRIPT ERROR；`動作 UI 覆蓋審計 OK（50 actions 全有路徑）`；新測 `恐慌橋跳過玩家主隊 OK`/`玩家訓練/晉升 anon OK`/`玩家紮營 OK` 全綠。
- ui_logic：`errors: 0`。ui_flow：`errors: 0`（含 3 新測）。
- sanity multi（`SIM_CONFIGS=survival_start`）：`coin_eq delta=-0.00`（訓練 coin sink 多 sim 無玩家不觸發；panic 守衛 + 紮營不破 NPC 路徑）。
- 最終全 branch review（cavecrew-reviewer）：無 issue，去剝削/coin sink/無 scope creep 確認。

## 連動風險

- **訓練 coin sink + coin_eq 審計**：玩家訓練扣 coin = 合法消耗。multi sanity 無玩家 → 不觸發 → coin_eq 維持 0。若日後寫「玩家訓練」進守恆審計 run，需把訓練 sink 標為合法消耗（同 onboarding 食物模式），否則誤判破口。
- **紮營 vs NPC establish_crude_camp**：兩條獨立路徑。NPC 版（即時 + 送種子糧）未動；玩家版（限時 + 只抬 cap）為新 construction 分支。log 都印 `[CrudeCamp]`，字樣相近但可由「玩家紮營完工」區分。
- **紮營 task=建設**：玩家發起的限時令（PRIO_PLAYER），完工 release 回 idle。panic 守衛確保不被 AI 覆蓋。

## 待主 session 確認 / 後續

- 真視覺待人工 run-verify：訓練/紮營 self-action 選單觀感、紮營施工中 status 顯「狀態: 建設」、label「狀態:」版面。
- 常數 `TRAIN_COST_COIN`/`TRAIN_EXP_GAIN`/`CAMP_BUILD_TICKS`/`CAMP_FOOD_CAP` 為 TEST VALUE，待平衡。
- **roadmap 後續**（本批不做）：覓食/pacify/settle/主動投靠（YAGNI/邊緣）；**NPC crude_camp 即時糧軟化絕境 → 獨立量測 task**（先量測 NPC 是否靠紮營免死再決定是否去即時糧）。
- known_issues P5 的 C-1~C-6 框架已由本批 + spec 重frame，可標處理狀態。
