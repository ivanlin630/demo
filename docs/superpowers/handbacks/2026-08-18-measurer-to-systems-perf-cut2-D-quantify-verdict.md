---
from: measurer
to: systems
status: open
topic: perf-cut2-D-quantify-verdict
---

# perf 刀2=D quantify：negligible（噪聲範圍內，非顯著 gain、也非確認退化）

ticket:`2026-08-18-systems-to-measurer-perf-cut2-D-quantify.md`
數字全落地:`docs/measurements/2026-08-18-perf-cut2-D-quantify.measure.json`
床:`scripts/debug/perf_cut2d_quantify_bed.gd`（temp、已revert）；seed=1337 warring_states.json 3天/720tick，baseline=main HEAD（已含刀A，同你ticket描述）vs `.worktrees/perf-cut2-D`(aeee021c)。

## 數字（各跑 2 次，noise-check）

| | baseline run1 | baseline run2 | branch run1 | branch run2 |
|---|---|---|---|---|
| wall | 118.49s | 105.24s | 123.92s | 103.61s |
| ctx_total | 408.1M us | 366.0M us | 452.0M us | 357.2M us |
| find_nearest_terrain_scan | 509 | 509 | 510 | 510 |

平均：baseline wall=111.87s / ctx_total=387.1M；branch wall=113.77s(+1.7%) / ctx_total=404.6M(+4.5%)。

**同側內部兩跑波動就有 ~11-16%**（baseline run1 vs run2 差 11.2%；branch run1 vs run2 差 16.4%）——比 baseline-vs-branch 平均差(+1.7~4.5%)還大。n=2 無法把 D 的真實效果從機器噪聲中分離出來。第一輪單跑數字（branch 比 baseline 慢 ~11%）看起來像退化，補第二輪後發現純粹是噪聲，不是真效果——這也是為什麼我沒有只憑第一輪就下結論。

scan 呼叫次數 509→510 符合預期（D 跟刀B 正交，降單次成本非次數）。

## terrain 分佈（回你的「bucket≈全圖」疑慮）

```
total_tiles=631
  forest:   189 (30.0%)
  mountain: 113 (17.9%)
  plains:   329 (52.1%)
```

最大 bucket(plains) 佔全圖 **52.1%**——不到「幾乎全圖」，但也稱不上小。plains 查詢下 D 只砍約一半掃描量；forest/mountain 查詢受益較大（砍 70-82%）。若 production 呼叫大宗落在 plains（沒細查每次呼叫的實際 terrain 分布，時間所限），bucket-narrow 的平均收益會被拉低，跟噪聲同量級也就不意外。

## 一個沒進一步驗證的可能解釋

`_resolve_location_prereq`（goal_resolver.gd:420-436）在 `terrain` 未指定時傳空字串呼叫 `find_nearest_terrain_tile`，D 側 `_terrain_tile_ids` 對 `terrain==""` 走 `state.world.tiles.keys()`——這是每次呼叫都複製一份全 tile id 陣列，而 baseline 原本直接 `for tid in state.world.tiles` 免此複製。如果這條 terrain="" 路徑佔呼叫量不小比例，可能部分抵銷掉 D 在有具體 terrain 時的收益。這是我讀 diff 產生的假說，沒有另外開 Probe 拆 terrain=="" vs terrain!="" 呼叫比例驗證（時間預算所限），標記給你，若要精確答案我可以再開一輪拆。

## 結論（回你的框架）

不是「gain顯著→merge」，也不是乾脆的「退化」——是 **negligible/噪聲範圍內**。照你 ticket 自己定的分流：negligible→回報議，非直接 merge。是否要為 D 追加精確化（例如只在具體 terrain 已知時才走 index、terrain="" 保留原全掃）、或直接判定不值得複雜度而擱置，交你裁。

temp instrumentation（`decision_engine.gd`/`goal_resolver.gd` 兩側 phase-timing + scan tap、`perf_cut2d_quantify_bed.gd`）revert 中，完成後兩邊 `--headless --import` 確認乾淨編譯。
