# Plan — 指標 specimen 決策 tracer

> spec = `specs/2026-07-01-specimen-tracer-design.md`。觀測 only、零行為變。
> 交付含「用它 measure 錨→行為」回報。

## 前置
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd   # 基準 PASS
```

## Task 1 — specimen 指定 + SpecimenTracer 骨架
- `world_state.gd`：加 `var specimen_team_ids: Array[int] = []`。
- 新 `scripts/debug/specimen_tracer.gd`（`class_name SpecimenTracer`，static）：`enabled=false`、`entries: Array`（或 per-team dict）、`is_specimen(team_id)`、`reset()`、`capture_options/capture_intent/capture_decision`（先 stub）、`flush()/dump()`。
- **DoD**：模組載入無錯、`is_specimen` 對 specimen_team_ids 回真。

## Task 2 — capture_options（decision_engine scored[] tap，TDD）
- **測先**：造 specimen team、跑 `DecisionEngine.rank` → 斷言 tracer 捕到**全候選 {opt,util}**（非只 winner）;非 specimen team → 零捕。
- `decision_engine.gd:19`（`rank`）+ `:43`（`rank_survival`）：`scored.append(...)` 後（或 return 前）`if SpecimenTracer.is_specimen(team.team_id): SpecimenTracer.capture_options(team, scored)`。no-op-unless-specimen（零非-specimen 成本）。
- **DoD**：specimen 決策全候選+util 捕到、測綠、非 specimen 零影響。

## Task 3 — capture_intent（commander + solo）
- `faction_ai_system.gd:875 _emit_goal`：specimen faction（leader team ∈ specimen）→ `capture_intent(f, intent_type, why, mode)`。
- `_evaluate_independent_strategy:950/954`：specimen solo team → capture `solo_intent` + task_reason。
- **DoD**：specimen 的 intent+why 捕到（commander goal_drivers / solo_intent 兩路徑各測一）。

## Task 4 — capture_decision（winner + 狀態 + belief）
- winner commit `faction_ai_system.gd:1124`（unified）/`:2653`（survival）：specimen → `capture_decision(team, winner_opt, task, target, ctx)`。
- entry 組：想什麼(intent+candidates+action-target belief best_estimate)/做什麼(winner_opt,task,target)/狀態(pop/food_private/food_granary/effective_food/consume_per_day/rung/faction/coin/material)。
- **DoD**：一條完整 timeline entry 成形（測斷言欄位齊）。

## Task 5 — LOD-exempt + flush 週期印
- `sim_runner.gd:340 _get_near_teams`：specimen team 一律納 near（mirror player_id 豁免）。
- flush 呼叫點（週期，如每日/每月，mirror warring per-month）→ 印 `[Specimen T<id>]` 可讀 timeline。
- **DoD**：specimen 遠離玩家仍每 tick 捕;跑 seed 印得出 timeline;無 print spam。

## Task 6 — ★用它 measure 錨→行為（交付核心）
- `warring_states_seed.gd`（或新 `specimen_bed.gd`）：指定 1 merchant/produce specimen（有致富潛力）+ 開 tracer → 跑 → 讀 timeline。
- **回報**：致富/擴張 intent fire 沒?fire 了 winner 有沒 = 貿易/賣貨/擴張 action?斷在哪(intent 沒 fire / fire 了 action 沒接 / action 接了無效)?
- 加指定 1 potential-conqueror specimen → 征服 intent→攻擊鏈卡哪 tick。
- **DoD**：timeline 讀出錨→行為斷點、handback 明確回報（這是藍圖要的答案）。

## Task 7 — 守恆 + 回歸閘
```
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd   # PASS ≥ 基準
```
- **DoD**：framework S1-S6 PASS、coin_eq 0、pop 守恆、無 GDScript 錯、模擬結果不變（tracer 零行為變）。

## 不碰（scope guard）
- 決策邏輯/util 公式/世界模型/經濟。純觀測。R1 食物不碰（藍圖緩）。

## 完成
- handback：tracer 就位 + **錨→行為 measure 結論**（致富驅不驅動交易，斷點在哪）。這是經濟真根答案。
- ⚠ 與軌 B（scaling-hardening）並行同觸 sim_runner/world_state/faction_ai/headless_test 不同函數 → 系統 merge 順序解。
