# Hand Back: 階段2 招人成幫

branch: `feat/stage2-recruitment`
plan: `docs/superpowers/plans/2026-06-16-stage2-recruitment.md`
spec: `docs/superpowers/specs/2026-06-16-stage2-recruitment-design.md`

## 實作摘要

- `scripts/simulation/hunt_system.gd`：新增 `hunt_preview(state, team)` dry-run（不擲骰、不消耗，回 {survival, chance, yield}，共用主動狩獵公式）。
- `scripts/simulation/player_api_mapper.gd`：`map_controlled_team` 加 `capabilities` 區塊 + 新 `_team_capabilities`（狩獵=hunt_preview、戰力=武裝數+named戰鬥技能和 proxy、日耗=pop×2.4）；`map_forced_interaction` 加 `join_request` branch（收留/婉拒 responses）。
- `scripts/simulation/player_command_system.gd`：新增 `JOIN_ONBOARD_MEAL=0.8` 常數 + `_accept_join_request`（扣 onboarding 食物 + reuse `merge_teams` 整團併入）；`respond_to_forced` 加 `join_request` 分派；`get_forced_response_options` 加 `join_request → [accept, refuse]`。
- `scripts/simulation/faction_ai_system.gd`：新增 `_maybe_request_join_player`（絕境團投靠對象=玩家且同格 → 寫 join_request forced_event，非自動 merge）；SurvivalJoin 決策分支 hook：ally==玩家隊時改走 forced（NPC→NPC 維持自動 merge）。
- `scripts/simulation/recruit_tutorial.gd`（新）：`RecruitTutorial.check(state)` 一次性 onboarding（玩家食物 ≥ 60 → 旁生 1 堪用 named + 3 平民 anon 流民團 + 發 join_request + 設 `recruit_tutorial_fired` flag）。
- `scripts/simulation/sim_runner.gd`：near-cadence 末（_step9 後）加 `RecruitTutorial.new().check(state)`。
- `scripts/ui/text_ui_main.gd`：`_build_state_str` 加能力讀數行（狩獵率/產出、戰力、日耗、撐天數）。
- `scripts/debug/headless_test.gd`：加 `_test_team_capabilities_dto`、`_test_accept_join_request`、`_test_join_request_trigger_and_respond`、`_test_recruit_tutorial`、`_test_join_conservation`。
- `scripts/debug/ui_flow_test.gd`：加 `_test_capabilities_shown`、`_test_join_request_ui`。

## 與 spec 的差異

- 計劃寫 `AnonTierSystem.set_tier_pop(team, 0, 3)`，該 API 不存在 → 改用既有 `AnonTierSystem.add_anon(team, "平民", 3)`（tier0 = 平民）。語意等價。
- 能力 DTO 內 `_team_capabilities` 用 `HuntSystem.new()`（class_name 直呼）取代 plan 的 `load("res://...").new()`，效果相同、較簡潔。
- ui_flow `_test_join_request_ui` 依 U19 路徑在 `_process` 前加 `request_advance(1)`（plan 未寫；不加則 `_process` 早段 `is_advancing` 守衛擋住、forced 模式不會自動進）。

## 驗證

- headless：`=== DONE ===`，無 SCRIPT ERROR，5 新測全綠。
- ui_logic：`errors: 0`。ui_flow：`errors: 0`（含 2 新測）。
- 守恆：`_test_join_conservation` coin_eq（coin+treasury+ore_gold/silver）併入前後不變；food 確減 onboarding 量。
- sanity multi（`SIM_CONFIGS=survival_start`，21600 tick）：died=**no**、`[CoinAudit] delta=0.00`、無 SCRIPT ERROR、pop 25→31。

## 連動風險

- `faction_ai_system.gd` SurvivalJoin 分支改寫：把 `if ally_id != -1` 重構為 `if ally_id == -1: continue` + 玩家分流。NPC→NPC 投靠路徑邏輯不變（multi sim 無玩家 → `p_join==null` 走原自動 merge，sanity 已驗 pop 正常增長、coin 守恆）。
- `_maybe_request_join_player` 只在玩家與絕境團同格時觸發；玩家未同格時 NPC 仍走 `投靠` task 步行靠近。**注意**：NPC 走 `投靠` task 抵達玩家格後，interaction_system 無 `投靠` 對玩家的到場 handler，到場後不會自動再發 forced_event（需再一次 SurvivalJoin 重評，task latch 可能擋住）。實務上 tutorial 路徑（同格生成）為可靠觸發；NPC 有機投靠玩家較稀（`_find_strong_neighbor` 要求對方 pop > 自身×1.5，玩家通常較小）。如需更強 NPC→player 投靠，建議補「投靠 team 與玩家同格時的到場 forced 觸發」（plan 未涵蓋）。
- `text_ui_main.gd` status 新增一行：版面變高，真機觀感（行寬/換行）待人工 run-verify。

## 待主 session 確認

- 真視覺待人工驗：status 能力讀數版面、forced 收留選單觀感、招募 delta feedback（plan 提的 recruit delta feedback 未在本 plan task 明列實作步驟，現有招募 feedback 走既有 `_set_feedback`，未特別加投靠/招募差異化顯示）。
- 常數 `JOIN_ONBOARD_MEAL=0.8`、`RecruitTutorial.FOOD_THRESHOLD=60.0` 為 TEST VALUE，待平衡。
- NPC→player 有機投靠到場觸發（見連動風險）是否補強，由主 session 決定。
