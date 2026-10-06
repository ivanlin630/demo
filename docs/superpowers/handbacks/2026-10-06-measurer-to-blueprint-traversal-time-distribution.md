---
from: measurer
to: blueprint
status: open
slice: 相鄰一格實際通過時長分佈（對照 tick_parameters.md 意圖值）
topic: ★回應 systems 派工：實測中位數 600-780 tick，是純常數意圖值的 5-15 倍，且幾乎不隨地形/日夜變化——這個「幾乎常數」的形狀指向真正瓶頸可能是 LOD 處理節律，不是地形移動成本本身。副本：systems（SendMessage 已敲）。
---

# 一、意圖值對照表（純常數，零 team 修飾）

```
terrain｜period｜意圖cost(tick)｜小時
plains ｜day   ｜48 ｜0.80
plains ｜dawn/dusk｜60｜1.00
plains ｜night ｜96 ｜1.60
forest ｜day   ｜69 ｜1.15
forest ｜dawn/dusk｜86｜1.43
forest ｜night ｜137｜2.28
mountain｜day  ｜120｜2.00
mountain｜dawn/dusk/night｜144(撞MAX_MOVE_TICKS上限)｜2.40
```

# 二、實際觀測（全世界 30 天，共 256 次移動一格）

```
terrain｜period｜n｜中位(tick)｜p90(tick)｜意圖值｜中位/意圖
forest  ｜dawn ｜11 ｜720.0｜14100.0｜86 ｜8.37x
forest  ｜day  ｜58 ｜600.0｜6846.0 ｜69 ｜8.70x
forest  ｜dusk ｜17 ｜720.0｜7788.0 ｜86 ｜8.37x
forest  ｜night｜10 ｜720.0｜1392.0 ｜137｜5.26x
mountain｜dawn ｜1  ｜720.0｜720.0  ｜144｜5.00x
mountain｜day  ｜3  ｜779.0｜779.0  ｜120｜6.49x
plains  ｜dawn ｜25 ｜720.0｜7932.0 ｜60 ｜12.00x
plains  ｜day  ｜103｜720.0｜5988.0 ｜48 ｜15.00x
plains  ｜dusk ｜23 ｜684.0｜6732.0 ｜60 ｜11.40x
plains  ｜night｜5  ｜720.0｜6264.0 ｜96 ｜7.50x
```

# 三、★★★決定性觀察：中位數幾乎是常數（600-780），不隨地形/日夜變

```
意圖值表地形差距到 3 倍（plains 48 vs mountain 120）、日夜差 2 倍，但實測中位數
全部卡在 600-780 這個窄帶（最大784、最小600，差不到1.3倍）——
★★★地形乘數在理論上該造成的差異，在實測裡幾乎看不出來。

這個「幾乎常數」的形狀通常代表【有一個更強勢的週期性因素蓋過了地形因素】。
我查了 sim_runner.gd：移動步驟掛在 `grp:"hour"` 但帶 `tl:"near.move"` 標籤，
且 `CadenceStagger.next_tick(cur,cur,int(tid),NEAR_CADENCE)` 給每隊各自錯開的
`pass_next_tick`——★這暗示 FAR（遠區）隊的 move 步驟不是每小時都真的執行，
而是跟 LOD／cadence 錯開頻率掛鉤。

★推論但未完整追蹤（交你/systems判要不要深入）：197/218「insufficient_time_budget」
卡住段裡，量級主要可能不是來自「這一步地形成本多高」，是來自「這支隊多久才被排到真正
跑一次move」——即使地形成本只要48 tick，若這支隊的 move 步驟本身要間隔12小時(720tick)
才被呼叫一次，move_tick_acc 多久累積到足夠扣款就看那個間隔，不是看地形乘數。
那樣的話，docs/tick_parameters.md 的意圖值表本身沒有錨到「這支隊多久被排到跑一次」
這個維度，對不上不是地形數字錯，是這張表漏了一個維度。
```

# 四、落地

```
commit：09c517b9a（已 push）
床：scripts/debug/traversal_time_distribution.gd
產物：docs/measurements/traversal-time-distribution.jsonl
跑法：GODOT_TIMEOUT=1800 .\tools\godot.ps1 --headless --script scripts/debug/traversal_time_distribution.gd
```
