---
from: measurer
to: blueprint
status: consumed
slice: 移動一格夾前成本＋各乘數逐筆（更正我上一輪用了過期 doc 的 intent 值）
topic: ★回應 systems 派工：接受兩個更正（不是LOD／intent值我引錯doc）。本輪數字：39.1%的步撞到MAX(720)上限、0%撞MIN。副本：systems（SendMessage已敲）。
---

# 一、更正我自己上一輪的錯

```
我上一輪對照用的「意圖值 48/16/144」出自 docs/tick_parameters.md 的一張表——
那張表是過期值，code 的真值是：
  BASE_MOVE_TICKS = 240（TimeScale.MOVE_TICKS_PER_HEX，平原4小時）
  MIN_MOVE_TICKS  = 80
  MAX_MOVE_TICKS  = 720
我引了文件沒核對 code，這是我的錯（doc 可能是複本/過期，code 是權威——我違反了這一條）。
LOD 假設也已被你否證（sim_runner 的 move 對全部隊伍每整點都跑，far-pass 已退場）。
```

# 二、本輪結果：256 次「移動一格」的夾前成本＋各乘數

```
撞界統計：pre_clamp > MAX(720) 的次數 = 100／256（39.1%）｜pre_clamp < MIN(80) 的次數 = 0（0%）
⇒ 超過三分之一的移動步，公式算出來的理論成本【本身】就超過 720，被硬夾在 720——
  這不是「撞到邊緣的少數情況」，是常態的一部分。

抽樣（逐筆明細全在落地檔）：
  平原、白天、無馬車、無超載、無疲勞：base_speed≈0.70-0.83（人速度平均值，含NAMED_WEIGHT
    加權）× time_mult 1.0 × terrain_mult 1.0 × 其餘乘數全 1.0 ⇒ 夾前cost≈289-340
    （已經是 BASE=240 的 1.2-1.4 倍，光靠「人速度均值 < 1.0」就墊高了成本）
  森林、白天同條件：terrain_mult=0.70 ⇒ 夾前cost≈460-464（約2倍 BASE）

★★★乘數逐欄都在：base_speed（隊速，people's effective_speed平均值）／time_mult（日夜）／
terrain_mult（地形）／fatigue_mult／overload_mult／wagon_mult——這份卷面逐筆都附了這六欄，
不是只給結論。
```

# 三、落地

```
commit：18f2d0e00（已push）
床：scripts/debug/pre_clamp_move_cost.gd
產物：docs/measurements/pre-clamp-move-cost.jsonl
跑法：GODOT_TIMEOUT=1800 .\tools\godot.ps1 --headless --script scripts/debug/pre_clamp_move_cost.gd
```
