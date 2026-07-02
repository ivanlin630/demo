# cadence tick spike 收斂 — Plan（L2,函數級 root 已量測定位）

> 藍圖優先序加持（`longwindow-rulings`）:**長窗 6-12 月驗收前必收**——別讓 freeze 污染複利數據。
> per-tick 有界=硬不變量（invariants 效能域）。現行最大違反者=hourly cadence tick 1.2-1.6s vs 中位 ~184us。
> **量測鏈（已做,儀器已入 tree）**:`[PhaseSpike]`→ near.faction_ai ~97% →`[FaiPhase]`→
> **① `_assign_tasks` ≈98% of loop1（每 faction 每小時）② `_find_weakest_prey` ≈91% of indep_strategy
> （`PathSystem.estimate_catch_up` pathfinding 每 discovered candidate,且跑在便宜濾之前）**。
> 次要:loop2.solo（DecisionEngine ~70ms）、loop3.survival（~25ms）。

## 量測工具（全在 tree,直接用）

- `SimRunner.phase_timing`（static,`DIEOFF_PHASE=1` 開）→ `[PhaseSpike]` tick 相位 dump。
- `FactionAISystem._fai_ph`/`_fai_pht` → `[FaiPhase]` evaluate_all 子相位 dump（>100ms 才印）。
- 床:`dieoff_perf_bed.gd`（env DIEOFF_SEED/MONTHS/PHASE）;seeded WarringHarness pointwise diff（行為驗）。

## Task 1 — zoom `_assign_tasks` 內部（一層,同儀器 pattern）

`_fai_pht` 標記 `_assign_tasks` 內部主要迴圈/子呼叫（per-member 掃描/belief 呼叫/pathfinding/nested 全隊掃）→ 短跑 `DIEOFF_MONTHS=1` 定函數級根。**修之前先量,別猜。**

## Task 2 — `_find_weakest_prey` + `find_prosperity_prey` pathfinding fan-out 收斂

1. **便宜濾先行（純重排,行為不變）**:`_find_weakest_prey`（faction_ai:2938）現序 = has_belief → `estimate_catch_up`(貴) → pop 濾 → food 濾。改:has_belief → pop/food 濾（belief 讀,便宜）→ **最後才 estimate_catch_up**。全 AND 濾純函數,重排結果集不變。`find_prosperity_prey`（:137）同型:eta/catch_up 用於 score 除法,但可先過 richness/weakness 零分者……**只重排純濾,score 依賴 eta 的部分不動**（行為不變優先）。
2. **estimate_catch_up per-tick memoize**（若 Task1/重排後仍熱）:同 (team,target,tick) 結果 cache,tick 邊界清。純 read cache=行為不變。
3. **驗**:seeded WarringHarness pointwise diff = CLEAN（純 perf 改必須逐點相同;不 CLEAN=語意破,打回）。

## Task 3 — `_assign_tasks` 修（按 Task 1 數據）

修向候選（按量到的根選,禁猜）:便宜濾先行/迴圈內重複 belief-est memoize/嵌套全隊掃 → teams_by_tile 或 teams_within 索引（既有 pattern）/cadence 攤平（faction 錯開 tick 相位——**行為變,若走此需 handback 標明,pointwise 會 diff**）。**優先取行為不變修法**;量到只剩 cadence 攤平能救才用,並標記。

## Task 4 — 驗收

1. `dieoff_perf_bed`（seed 1337,4 月,PHASE=1）:hourly cadence tick 從 1.2-1.6s 收斂;目標 **max/median ≤ ~50×**（TEST 目標;中位 ~184us 天生小,絕對值目標 spike <100ms 更實在——`[PhaseSpike]` 門檻下不再狂印=直觀信號）。早晚期曲線平（per-tick 不變量）。
2. 行為不變部分:seeded pointwise CLEAN。行為變部分（若有,如 cadence 攤平）:單獨列 handback+quantify diff。
3. 回歸:headless（1 FAIL pre-existing 容忍）+0 SCRIPT ERROR、framework 7/7 DORMANT=0、coin_eq delta=0、InvariantAudit 0。

## Handback

`docs/superpowers/handbacks/2026-07-02-cadence-spike-fix.md`:Task1 zoom 數據、各修法歸屬（行為不變/變）、前後 spike 曲線、pointwise 結果。

## 注意

- Godot 用 `.\tools\godot.ps1`;bed 跑 `GODOT_TIMEOUT=1200~2500`+背景。
- 儀器（phase_timing/_fai_pht 標記）**保留**（長窗 tick 曲線探針要用）,勿拆。
- headless 基準 1 FAIL（弱目標未加入攻擊 goal）=pre-existing。
- scope:`faction_ai_system.gd`（_assign_tasks/_find_weakest_prey/find_prosperity_prey）+`path_system.gd`（memoize 若做）。勿碰 gate/prey score 語意（R1 剛落地）。
