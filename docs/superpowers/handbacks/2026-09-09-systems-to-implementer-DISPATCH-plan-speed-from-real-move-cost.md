---
from: systems
to: implementer
status: open
slice: 普查批一① MOVE_TILES_PER_DAY 接上執行端真成本
topic: ★DISPATCH（R² halt 已補完 ⇒ CLEAN）｜★★單位鐵則：不要代 _compute_team_speed,它不是 tiles/day——正確式 tiles_per_day = TICKS_PER_DAY / _move_cost()｜★★★整條鏈的 Probe.bump 都要交給呼叫端(:194/:212/:247 三處),只做 _move_cost 那層是半套
---

# 開票：`docs/superpowers/specs/2026-09-09-plan-speed-from-real-move-cost-HOW.md`

blueprint 裁批一序列 ①→②→③→④，這是 ①。R² 判過一輪 halt，已補完，**不用再送 R²**。

## 病（一句）

```
goal_resolver.gd:1023  const MOVE_TILES_PER_DAY: float = 2.0
goal_resolver.gd:1033  days += _hex_dist(...) / MOVE_TILES_PER_DAY
```
決策層拿著一個**那支隊沒有的速度**在做計畫，而執行層逐隊算真成本。
★症狀出現在執行端（走不到／延遲），沒有人會回頭懷疑決策端的一個常數。

## ★★★三個坑，都是別人（我）已經踩過的，你不要再踩

**坑一：單位。** 不要把 `_compute_team_speed` 代進去 —— 它**不是** tiles/day，
是餵給 `:214` 的中間量；`:214` 回的才是**每格 tick 成本**。
正確：`tiles_per_day = float(TICKS_PER_DAY) / float(_move_cost(state, team))`。
直接代速度會差約 1440 倍，而且**看起來像個數字**。

**坑二：Probe.bump 不只一處，而且不在 `_move_cost` 本體。**
我第一版 spec 寫「`_move_cost` 零副作用」——錯的。真實情況：
```
:194  rootdiff.TERRAIN_SPEED_MULT   （在 _move_cost 本體）
:212  rootdiff.WAGON_TERRAIN_MULT   （在 _move_cost 本體）
:247  rootdiff.NAMED_WEIGHT         （在 _compute_base_team_speed，★每個 named 成員各一次）
```
`:247` 那支對 pure/impure 是**同一條呼叫路徑**，「pure 版跳過」繞不開。
⇒ 整條鏈一起處理，不要只做 `_move_cost` 那一層。形狀你挑（抽 `*_pure` 或把 bump 提到呼叫端），
**理由寫進 handback**。★不要用「傳 probe:=false 旗標」：旗標會被忘記傳。

窮盡依據：`movement_system.gd` 全檔 `rootdiff.*` bump 只有這三處，且鏈上所有函式
（`_compute_mount_bonus`/`_compute_wagon_penalty`/`get_carry_capacity`/`get_effective_wagons`/
`get_effective_mounts`/`calc_total_weight`）**全部定義在同一檔** ⇒ 跨檔遺漏的疑慮已排除。

**坑三：驗收 §4③ 的門檻是區間不是兩個點。** 真常數代入 baseline 就已經是 6 tiles/day
（舊值 2.0 的 3 倍），clamp 全範圍是 1x–9x。
⇒ **≥100 倍＝單位接錯**（回去修接線，不是發現）；**<20 倍＝真發現**；20–100 倍貼數字上來我裁。

## 驗收四格（spec §4，缺一不可）

1. 慢隊（重載/疲勞/惡地形）的計畫天數**變長**；
2. 快隊（坐騎/輕載/平原）的計畫天數**變短**；
3. 單位健全性（上面的區間判準）；
4. ★`rootdiff.TERRAIN_SPEED_MULT`／`WAGON_TERRAIN_MULT`／`NAMED_WEIGHT` 三格計數
   before/after **都不變** —— 少一格就是決策端的呼叫混進了執行端的計數。

## 誠實限度（寫進你的 handback，不要讓下游誤用）

`_move_cost` 讀的是**當下這一格**的地形與**當下**疲勞 ⇒ 它是「現況估」ETA，
不是準確的路線預測。它比平版 2.0 好的理由是**與執行端同源**，不是它準。

`MOVE_TILES_PER_DAY` ★連常數一起刪，只留一行註解說明舊版。

完後改本信 `status: consumed`，handback 寄回 systems。
