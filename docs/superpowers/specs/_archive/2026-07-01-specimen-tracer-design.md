# 指標 specimen 決策 tracer — 設計 spec

> 系統 HOW spec。承藍圖 `anchor-probe-and-hardening` ①②（指標 specimen 追蹤 → 診斷錨→行為經濟真根）。
> 目標：指定 1 指標團 + 幾指標 named → LOD-exempt trace 決策全程（想什麼/做什麼/狀態）= 可讀決策 timeline（非 end-state tally）。**先鋪、即用來 measure「致富/擴張錨驅不驅動經濟/擴張行為」**。
> **觀測 only、零行為變**（tracer 讀+印，不改決策）。唯一 cadence 變 = 指標團 LOD-exempt（遠離玩家也每 tick 全跑）——刻意（要完整 trace）。

## 用途（藍圖指定）
診斷經濟真根（錨→行為）：指標團 leader 的**致富/擴張 intent 到底 fire 沒？fire 了有沒有產生它命名的動作（賣貨賺錢/擴張）？** 致富沒接日常交易 = **錨有名日常無實 = 經濟真根**（比食物根，R1 食物緩）。跟一個 climber/trader/potential-conqueror 走完一生 → 看卡在哪 tick 哪決策。

## 資料模型：每 specimen 每決策一條 timeline entry
```
{ tick, team_id/person_id,
  想什麼: {
    intent: <commander goal_drivers{intent,why,mode} | solo_intent | (隊層無 intent→"日常")>,
    candidates: [ {opt, util} × 全候選 ],     # ← decision_engine scored[]，現丟棄
    beliefs: [ {tgt, est} ]                    # 該決策 action target 的 best_estimate（re-query/capture）
  },
  做什麼: { winner_opt, task, target },
  狀態: { pop, food_private, food_granary, effective_food, consume_per_day, rung, faction_id, coin, material }
}
```

## HOW（tap 點，複用既有結構）

### A. specimen 指定 + LOD-exempt gate
- `WorldState` 加 `specimen_team_ids: Array[int]`（+ optional `specimen_person_ids`）。seed/config 設。
- **LOD-exempt**：`sim_runner.gd:340 _get_near_teams` → specimen team 一律納 near（無論距玩家）→ 每 tick 全 pipeline。mirror `state.player_id` 既有豁免 pattern。
- **capture gate**：dispatch fan-out（`faction_ai_system.gd:543-554`）+ 各決策入口是天然單點——`if team.team_id in specimen_ids` → tracer 詳捕（否則 no-op）。

### B. SpecimenTracer 模組（mirror Probe 全域 static）
新 `scripts/debug/specimen_tracer.gd`（`class_name SpecimenTracer`，static，default off，seed 開）：
- `capture_options(team, scored)` — DecisionEngine `rank`/`rank_survival`（`decision_engine.gd:19/:43`）內，team 是 specimen 時呼叫，存本決策全候選 `{opt,util}`（現 `scored[]` 丟棄，這是唯一拿全 util 的點）。
- `capture_intent(team_or_faction, intent, why, mode)` — commander `_emit_goal`（`:875`）/ solo `_evaluate_independent_strategy`（`:950/954`）specimen 時呼叫。
- `capture_decision(team, winner_opt, task, target, ctx)` — winner commit（`faction_ai_system.gd:1124`/`:2653`）specimen 時，組完整 entry（含狀態 snapshot from ctx/team + effective_food/consume）+ 該 action target 的 `BeliefSystem.best_estimate`（beliefs 不存→這裡 re-query action target 一條）。
- `flush()` / 週期 dump — 印可讀 timeline（mirror `warring_states_seed` per-month summary pattern），tag `[Specimen T<id>]`。
- `reset()` / `enabled`。

### C. 狀態 snapshot（食物收支 = 錨→行為的關鍵）
- entry 狀態含 `food_private`(team.resources food) / `food_granary`(own granary) / `effective_food` / `consume_per_day`(pop×2.4) → 看**收支 flow**（連 granary cadence 討論：specimen 能顯示食物是流入還是釘 cap）。
- rung（`ambition_ladder.target_rung`）/ faction_id / coin / material → 攀爬+經濟脈絡。

## 驗證用途（本 spec 交付含「用它 measure」）
- **econ/warring seed 指定 1 merchant/produce specimen**（有致富潛力）→ 跑 → 讀 timeline：
  - 致富 intent fire 沒（commander 有 RICH goal？或隊層 rank 有 貿易 高 util？）
  - fire 了有沒有 winner=貿易/賣貨 action（還是被覓食/survival 碾）
  - → **回報藍圖：錨→行為 斷在哪**（intent 沒 fire / fire 了 action 沒接 / action 接了但無效果）。
- **指定 1 potential-conqueror specimen** → 看征服 intent→攻擊 action 鏈卡哪 tick。

## believability / 守恆 guard
- tracer **零改決策/世界**（純讀+印）→ 模擬結果不變、守恆不動。
- specimen LOD-exempt = 該 1 團 cadence 變（遠也每 tick）→ 世界層級影響可忽略（1 團），且正是要的完整 trace。
- 硬閘：headless 全綠（PASS 不降）、coin_eq 0、pop 守恆、無 print spam（specimen 少 + 週期 dump）。

## 檔案
- `scripts/data/world_state.gd`：`specimen_team_ids`（+ optional person）。
- `scripts/debug/specimen_tracer.gd`：新模組（static capture/flush）。
- `scripts/simulation/decision/decision_engine.gd`：`rank`/`rank_survival` 加 specimen `capture_options`（`scored[]` tap）。
- `scripts/simulation/faction_ai_system.gd`：`_emit_goal`/solo intent capture + winner commit `capture_decision` + dispatch gate。
- `scripts/simulation/sim_runner.gd`：`_get_near_teams` specimen 豁免 + tracer flush 呼叫點。
- `scripts/debug/warring_states_seed.gd`（或新 `specimen_bed.gd`）：指定 specimen + 開 tracer + 跑讀 timeline。
- `scripts/debug/headless_test.gd`：tracer 單元測（specimen 團決策捕到全候選+intent+狀態、非 specimen 零捕）。

## 風險 + 緩解
- **beliefs 不存需 re-query**：只 re-query specimen 少數（action target），成本可忽略;够診斷錨→行為（是否 act on belief）。若要全候選的 belief 依賴 → 後續增（先夠用）。
- **print spam**：specimen 限少（1 團+幾 named）+ 週期 dump（非每 tick 每候選狂印）。plan 定 dump 粒度。
- **capture_options 侵入 decision_engine**（純函數加 side-effect）：static no-op-unless-specimen（mirror Probe.bump 模式），零非-specimen 成本。
- **scope**：純觀測，**零碰決策邏輯/util 公式/世界模型**。

## 開放細節（plan 定）
- specimen 選定法（config 欄 vs seed 硬指定 vs 自動挑「首個 merchant leader」）。
- dump 粒度（每決策印 vs 週期批 vs 只 flush end）。傾向週期批 + end full dump。
- person specimen（named）範圍（先隊層夠診斷錨→行為；named individual trace 可 phase 2）。
- 與 scaling-hardening（軌 B）並行：同觸 sim_runner/world_state/faction_ai/headless_test 但不同函數/行 → merge 順序解（系統收）。
