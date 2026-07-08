# Hand Back: cadence tick spike 收斂（cadence-spike-fix）

> Status: consumed（2026-07-02 merged,系統收編;殘餘 far.total/orders_ambition 入 known_issues queue）

## 實作摘要

### Task 1 — zoom 定罪（函數級 → 呼叫級）

`_fai_pht` 儀器下鑽三層（`_assign_tasks` 內部 → `DecisionContext.gather` 各 finder → `_find_weakest_prey` 內部），`dieoff_perf_bed`（seed 1337, 1 月, PHASE=1）量到：

| 相位 | baseline (spike tick) | 佔比 | 根 |
|---|---|---|---|
| `unified.rank`（rank_scored ⊂ `_assign_tasks`→`_decide_unified` + `_evaluate_solo`） | ~900k-1000k us | ~65% | `DecisionContext.gather` 呼 `_find_weakest_prey`/`_find_strong_neighbor`/`_find_aid_target` → 每 discovered 候選一次 `estimate_catch_up`（A\* fan-out） |
| `indep.weakest_prey`（`_evaluate_independent_strategy`） | ~400-450k us | ~30% | 同根（`_find_weakest_prey` A\* fan-out） |
| `loop1.infra` → `infra.new_loc`（每 500 tick） | ~250-500k us | 500-tick spike ~95% | `_evaluate_new_outpost_location` 每 candidate 呼 `_min_dist_to_enemy_outpost`＝全圖掃 → O(tiles²) |
| `estimate_catch_up` 殘餘（SSSP 後） | wp.catch 高 | — | 每候選 2 次 O(n) `Array.has`（discovered 檢查 estimate+observe 各一）→ O(n²) |

A\* 本體 = naive（每 iteration 全 open sort_custom + 無界全圖探索），unbounded per-pair。

### 修法（全部行為不變 by construction）

1. **`path_system.gd` — per-source SSSP（Dijkstra binary heap）永續 cache**（`catch_cost`/`_dijkstra`/`_sssp_cache`）
   - terrain 只在 world gen / game_setup 寫，runtime 永不變 → cost 圖靜態 → 單源最短路算一次永續有效（cache 以 world instance id 分層，headless 多世界測試不互污；未來 runtime 改地形須呼 `clear_sssp()`）。
   - `estimate_catch_up` 改查 SSSP cost O(1)，不再 per-pair A\*。
   - **行為不變論證**：最優 cost = 同一 float path-sum 集合的 min（Dijkstra 與 A\* 沿 path 同序累加）→ bit-exact 等值；`observe_velocity` 的 `randf()` 呼叫條件不動（SSSP 可達 ⟺ A\* path 非空 = 同 component，全圖連通）→ RNG 流逐點相同。`.path` 欄無 consumer（全消費端只讀 `.reachable`/`.eta`，grep 驗證）→ 移除。
   - movement 等其他 `find_path` 呼叫者不走此路（A\* tie-order 影響實際走位，勿混）。
2. **`estimate_catch_up`/`observe_velocity` 加 `trusted` param** — 5 個 finder 呼叫端（`find_prosperity_prey`/`_find_trade_target`/`_find_weakest_prey`/`_find_strong_neighbor`/`_find_aid_target`）本來就迭代同一 discovered array → 檢查恆真 → 跳 2 次 O(n) `Array.has`。回傳值恆等、randf 不動。
3. **`_evaluate_new_outpost_location` hoist** — 敵 outpost 位置一次收集（`_enemy_outpost_positions`），候選迴圈對小集取 min-dist，取代 per-candidate 全圖掃（同集合同 min 值）。`infra.new_loc` 250-500ms → ~70ms。
4. **儀器保留**（plan 要求，長窗 tick 曲線探針用）：`loop1.infra/diplo/betray`、`assign.*`、`member.*`、`unified.*`、`gather.*`、`infra.*` 相位 marker + `_fai_pht_s`（static callee 用）。

### Plan 差異

- **Task 2.1「便宜濾先行重排」未做，理由**：`estimate_catch_up` → `observe_velocity` 每呼叫消耗一次 `randf()`（global RNG 流）。重排讓被 pop/food 濾掉的候選跳過 estimate → randf 消耗次數改變 → 全下游 RNG 流位移 → pointwise 必 DIRTY。plan 假設「全 AND 濾純函數」不成立（濾鏈含 RNG 副作用）。SSSP 讓 estimate 變 O(1) 後重排已無收益。
- **Task 2.2「estimate_catch_up per-(team,target,tick) memoize」未做，同理**：同 tick 重複呼叫在 baseline 各消耗一次 randf，memoize 會砍掉第 2+ 次 draw → RNG 位移 → dirty。RNG-safe 的等效物 = find_path 既有 per-tick cache（已在 tree）+ SSSP 永續 cache（本次）。
- **Task 3 cadence 攤平未動用**：行為不變修法已足，無 faction 錯開相位需求。
- **scope 延伸**：`_evaluate_new_outpost_location`（同檔 `faction_ai_system.gd`，量測定罪 500-tick spike 根）。plan 明文「修向候選按量到的根選」。

## 量測結果

### pointwise（seeded_warring_bed，seeds 1337/42/7 × 3 月，main baseline vs branch）

**3 seeds 全部 POINTWISE IDENTICAL**（JSON 全 metric 逐點相同：teams/factions/established/pop 月曲線、意圖分布、attrition、probe 計數）= 零行為變實證。

### perf（dieoff_perf_bed，seed 1337, 1 月, PHASE=1）

| 指標 | baseline (main) | 修後 |
|---|---|---|
| hourly cadence faction_ai 相位（`[FaiPhase]` total） | 1.3-1.5s | 常態 ~50-70ms、偶發 100-160ms |
| `unified.rank` | ~900k-1000k us | ~60-80k us |
| `indep.weakest_prey` | ~420k us | ~25-60k us |
| `infra.new_loc`（500-tick） | ~250-500k us | ~70-80k us |
| tick median | 364 us | ~360 us（不變） |
| tick max | 2.26s | ~1.0s（殘餘=far.total，見未修項） |

注意：1 月量測各輪間有背景 CPU 競爭（baseline dump 同時跑），相對量級可信、絕對值偏高。乾淨單獨 4 月驗收數字見下。

### 4 月驗收（seed 1337, PHASE=1, 單獨跑, 28800 ticks）

- median 307us / p90 51.5ms / p99 272ms / max 1.08s（max/median 3520×）
- **早晚期曲線平** ✔：月 median 356→370→327→307us；max 全程持平 ~1.08s；die-off tick 數 10→29→48→61 遞增而 spike 不隨之長（per-tick 有界不變量成立，K 分桶無相關惡化）
- **in-scope 根全收斂** ✔：
  - hourly cadence faction_ai 相位常態 ~50-70ms（baseline 1.2-1.6s，~20×↓）；最差 hourly tick 中 `_assign_tasks` 鏈（assign/member/unified.rank）~70-155k us
  - top-15 全域 spike **全部 = `far.total`**（LOD far batch，plan 外 pre-existing）
- **plan 數字目標未全達，卡的全是 plan 外根**：max/median 3520×（目標 ~50×）由 far.total（0.8s/500tick）+ `loop3.orders_ambition`（300-330ms/order-cadence tick）貢獻；faction_ai in-scope 部分已達標。`[FaiPhase]`（evaluate_all>100ms）仍印 1917 次/28800 tick，主成分 = orders_ambition + far 相鄰 tick，非本次修的三函數。

### 回歸閘

- headless：0 SCRIPT ERROR、`=== DONE ===`、唯一 `[FAIL] 弱目標未加入攻擊 goal` = plan 明列 pre-existing 容忍 ✔
- coin_eq：`[CoinAudit] delta=0.00` ✔
- InvariantAudit：population/faction 雙向/subteam 雙向/roster 雙向/roster 反向 全 OK ✔
- framework_validation：7/7 PASS、DORMANT=0 ✔

## 未修項（量測發現、plan 外根，主 session 裁）

1. **`far.total` LOD far batch ~0.45-0.83s / 每 500 tick**：pre-existing（baseline 同 tick 同量級 ~0.8s），非 faction_ai。4 月驗收 top-15 spike 全是它 = 現在的效能域最大違反者。die-off/far scaling 傘下另案。
2. **`loop3.orders_ambition` ~300-330ms**（OrderSystem `tick_team_orders`，order cadence 對齊 tick 集中爆）：plan 列次要，未動。修後 faction_ai 最差 tick 主成分。
3. `unified.rank` 殘餘（最差 ~150k us，內含 `gather.market`/`gather.home_food` 各 ~20-37k = O(tiles) 掃）、`loop3.outpost`、`loop2.solo` 等 <100ms 級。

## 連動風險

- `PathSystem._sssp_cache` 永續 by world-iid：**若未來加 runtime 地形改變**（如燒林/築路改 terrain cost），SSSP + `_path_cache` 都會 stale — 屆時須在改地形 chokepoint 呼 `PathSystem.clear_sssp()`（已留 API）+ 清 `_path_cache`。現行 runtime 無地形寫點（grep 驗證：只有 world_generator/game_setup/測試 harness 寫 terrain）。
- `estimate_catch_up` 不再回傳 `path` 欄：現無 consumer；未來需要攔截路徑者應走 `find_path`（真 A\* path）。
- headless 測試多世界共用 static cache：以 world instance id 分層解決；若測試重用同一 WorldData 且改 terrain，須自行 `clear_sssp()`。

## 待主 session 確認

- far.total 500-tick spike 是否開新 measure/fix case（效能域 per-tick 有界不變量仍被它違反）。
- orders_ambition cadence spike 同上。
