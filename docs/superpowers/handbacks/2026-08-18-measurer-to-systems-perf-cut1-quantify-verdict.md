---
from: measurer
to: systems
status: open
topic: perf-cut1-quantify-verdict
---

# perf-cut1 quantify 結果：gain 真在，但來自刀A不是刀B

ticket:`2026-08-18-systems-to-measurer-perf-cut1-quantify.md`
數字全落地:`docs/measurements/2026-08-18-perf-cut1-quantify.measure.json`
床:`scripts/debug/perf_cut1_quantify_bed.gd`（temp、已revert）；seed=1337 warring_states.json 3天/720tick，main(baseline) vs `.worktrees/perf-cut1`(b0d40ce1)。

## 數字

| | baseline(main) | branch run1 | branch run2 |
|---|---|---|---|
| wall | 109.17s | 94.38s | 100.65s |
| p1.ctx_total | 381.5M us | 330.8M us | 356.2M us |
| p1.selection %ctx | 97.5% | 97.5% | 97.5% |
| find_nearest_terrain_scan calls | 509 | 509 | 509 |
| find_nearest_terrain_memo_hit | (無memo) | (未印,見下) | **0** |

branch 兩跑同 seed/config/tick 數但 wall 94.38s vs 100.65s（~6% run-to-run noise，非code差異——中間我補印memo_hit重跑了一次，兩跑條件相同）。wall/ctx_total 降幅讀成範圍 **-7.8%~-13.5%**，非單點。

## 結論：memo(刀B) 這床 0 命中，gain 歸刀A

`find_nearest_terrain_scan` 呼叫數 branch 跟 baseline **完全相等 509=509**，`find_nearest_terrain_memo_hit=0`——這 3 天 warring_states 局裡，沒有一次 `frontier_candidates()` 呼叫在自己 call scope 內對同一個 `(terrain,max_range)` key 查第二次，memo 從沒機會命中。

`p1.selection`（frontier_candidates+sort）佔 ctx_total 比例 branch/baseline 都 97.5%，刀1沒動到這塊的相對權重——這符合預期，因為刀1本來就不是要動 selection 的演算法形狀，是要讓它裡面的呼叫更便宜。

觀到的 wall-clock/ctx_total 真實下降（~8~13%），歸因是 **刀A**（`_hex_dist` 轉 static，砍掉每次呼叫的 `FactionAISystem.new()` alloc）——這個優化不靠 scan 數變少就生效，它影響的呼叫點不只 `find_nearest_terrain_tile`（`_estimate_delay_days`/`_harvest_tile_known`/`faction_ai_system.gd:2409` 都吃得到）。

## 回你的決策框架

> 若gain顯著→我merge刀1;若negligible→回報（memo複雜度不值or gain在別路）→議

答：**gain 顯著且真實存在（~8~13%），但集中在刀A；刀B(memo) 在這代表性 workload 下複雜度不值**——scan 數 0 減少、命中 0 次，加的 `Dictionary` 傳遞（`memo` 6th param 貫穿 `_resolve_resource_prereq`/`_resolve_location_prereq`/`find_nearest_terrain_tile`）換不到任何實測效益。是否留著刀B：不影響正確性(byte-identical已你驗)，但目前是死重量代碼——留給你裁是否精簡掉或留作未來 workload(例如單team多goal同terrain重疊機率較高的場景)的保險。

## 刀3 spatial index 問題

`find_nearest_terrain_scan` 呼叫數 509 不管 baseline/branch 都相同，代表刀B完全沒降低 per-team O(tiles) 全圖掃描的**次數**——跨 team 不共享一樣沒解。若刀3(spatial index)要做，價值在於降這 509 次 scan 本身的單次成本(當前 O(tiles) 全圖掃)，跟刀B(call-scoped memo，降"重複呼叫次數")是正交問題；本次數據看不出刀B對刀3有沒有前置價值——509=509 已經說了刀B對這條路完全沒影響。刀3 值不值看你們要不要單獨開票。

## 收尾

main dir + `.worktrees/perf-cut1` 兩邊的 temp 量測 tap（`decision_engine.gd` phase_timing 掛勾、`goal_resolver.gd` 的 `p1.find_nearest_terrain_scan`/`_memo_hit` bump、`perf_cut1_quantify_bed.gd`）全部 revert 中，完成後兩邊 `--headless --import` 確認乾淨編譯。

ticket 已 consumed，`03b_measurer.status.md` 同步更新。
