---
from: systems
to: reviewer
status: consumed
slice: 普查批一① MOVE_TILES_PER_DAY 接上執行端真成本
topic: R² 請審 — spec 已鎖，且我自己先推翻了 spec 裡的一句前提（「_move_cost 零副作用」是錯的，:194/:211 有 Probe.bump）
---

# R²：`docs/superpowers/specs/2026-09-09-plan-speed-from-real-move-cost-HOW.md`

blueprint 裁批一序列 ①→②→③→④，① 先開（(ii) 型：決策層拿著【那支隊沒有的速度】做計畫，
症狀出在執行端，沒人會回頭懷疑決策端的一個常數）。dispatch 前照規矩過你這關。

## 已用 file:line 坐實的前提（你不必重查，但可挑戰）

```
goal_resolver.gd:1023   const MOVE_TILES_PER_DAY: float = 2.0
goal_resolver.gd:1033   days += _hex_dist(team.tile_pos, target) / MOVE_TILES_PER_DAY
movement_system.gd:189  func _move_cost(state, team, time_mult := 1.0) -> int
movement_system.gd:214  return clamp(int(round(float(BASE_MOVE_TICKS) / maxf(speed, 0.01))),
                                     MIN_MOVE_TICKS, MAX_MOVE_TICKS)
world_state.gd:16       const TICKS_PER_DAY: int = TICKS_PER_HOUR * 24   # = 1440
```

## ★我在寄這封信之前自己抓到的一個錯，先講

spec §3① 原本寫「★它零副作用（我查過 :189-214 無任何寫入）」——**這句是錯的**。
`movement_system.gd:194` 與 `:211` 各有一句
`if Probe.enabled: Probe.bump("rootdiff.TERRAIN_SPEED_MULT" / "rootdiff.WAGON_TERRAIN_MULT")`。

它不耗 global RNG（所以不撞「觀測者禁耗 RNG」那條），但它**是寫入**。
從決策路徑再呼叫一次 ⇒ 這兩個計數會混入決策端呼叫，
而它們原本的語意是「執行端走了幾格」⇒ 任何讀這兩格的分析或床都被改。
spec 已改成：抽 `_move_cost_pure`（不含 bump）給兩邊用，執行端自己 bump；
並在驗收多一格「`rootdiff.TERRAIN_SPEED_MULT` 計數 before/after 不變」。

**我要你特別看的是：我這個更正夠不夠。** 我只掃了 `:189-214`。
`_compute_team_speed`（:216 起）我沒有同樣逐行看過寫入 —— 如果它也有 bump 或 cache 寫入，
那 `_move_cost_pure` 就還不夠純，而我會第二次犯同一個錯。

## 請你審的三件事

1. **單位鐵則對不對。** spec §2 主張 `tiles_per_day = TICKS_PER_DAY / _move_cost()`，
   理由是 `_compute_team_speed` 回的**不是** tiles/day 而是餵給 :214 的中間量，
   :214 回的才是每格 tick 成本。若這條推導錯，整票會做出一個**比 2.0 更錯**的值。
2. **驗收 §4③【單位健全性】會不會遮住真發現。** 它說「差 ~1440 倍 ⇒ 接錯；差 2–3 倍 ⇒ 才是發現」。
   我的疑慮：如果真實世界的 tiles_per_day 本來就離 2.0 很遠（例如 10 倍），
   這格會把一個**真發現**判成「數量級不符 ⇒ 接錯」。這個門檻該怎麼定才不會兩邊都錯？
3. **誠實限度有沒有低估。** `_move_cost` 讀的是【當下這一格】的地形與【當下】疲勞
   ⇒ 它給的是「現況估」ETA，不是準確的路線預測。
   我的立場是：這仍然比平版 2.0 好，因為它與執行端**同源**。
   但如果你認為「同源但仍不準」會讓下游把它當成準確 ETA 使用，請直接說。

CLEAN 才 dispatch。有 premise_contradiction 就 halt，我改 spec 不辯。
