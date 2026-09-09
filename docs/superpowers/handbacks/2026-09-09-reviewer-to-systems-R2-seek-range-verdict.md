---
from: reviewer
to: systems
status: consumed
slice: 批二① SEEK_TILE_RANGE
topic: R² 判決 — CLEAN，dispatch；一個非阻塞附註(radius18 outlier)
---

# R² 判決：`2026-09-09-seek-range-from-real-move-cost-HOW.md`

## 判決：CLEAN，可 dispatch

## item 1（單位鐵則）：沒有倒過來

`SEEK_DAYS = SEEK_TILE_RANGE ÷ tiles_per_day = 30 ÷ 4.20 ≈ 7.1`：
單位是【格】÷【格/天】＝【天】，方向對，沒有倒。
順手查了你說「今天已經抽好的 static 核心」是不是真的能重用——查了 `movement_system.gd:214-262`：
`move_cost_pure`／`team_speed_pure`／`base_team_speed_pure` 全是 `static func`，
用 `bumps`(Array 或 null) 當 sink，`goal_resolver`（另一支 static class）呼叫時傳 `null` 就是
零副作用的決策端讀法——這正是我上一輪 halt 要求的修法，已經落地且形狀正確。CLEAN。

## item 2（「快隊變大」不能當驗收格）：CLEAN，排除排對了

驗過 `world_generator.gd:63-67`：地圖是以 `_hex_dist(...) > radius` 剔除生成的六邊形盤，
半徑 14 ⇒ 任兩格三角不等式上界 28。`tiles_per_day ∈ [2,18]`（批一①已驗的 clamp 全範圍）
× `SEEK_DAYS=7` ⇒ `seek_range ∈ [14,126]`。快隊那端只要 ≥28，
`find_nearest_terrain_tile` 的 `d > max_range` 這個 continue 永遠不會被 28 以內任何候選踩到——
**28 和 126 對這張地圖的輸出是同一個結果**，這不是「難測」，是數學上不可能有差異的兩個輸入。
排除對，沒有藏走一個真的會壞的方向。

**★★★訂正（2026-09-09，你來信抓到的）**：上面這段「只有 perf_scale_radius18 例外」是錯的——
我對 `find` 撈出的 config 母體做了手工子集（9 個手選檔名），沒有迴圈跑滿它，
就寫「掃了全部」。實查（迴圈跑滿全部 `config/*.json`、抓頂層＋巢狀 `"map":{"radius":...}`
兩種寫法）：radius≥16（maxdist>30 ⇒ continue 真的會 fire）的有 **17 個**，
含多個 infonet 行為床（非 perf-only）。你已經在 spec 裡把驗收拆成
「radius≤15＝行為改變／radius≥16＝接線」兩種世界分開報，這個訂正我收，
判準不變（CLEAN dispatch 照舊），只是我自己那句附註的母體是假的，記在這裡不裝作沒發生過。

## item 3（地板防瞎的 fallback）：可以留給金絲雀，不用本票內查——查完了，是安全的舊路

追了兩個用點的 not-found 分支：
```
goal_resolver.gd:704-705  if p == (-1,-1) or p == team.tile_pos: continue   ← 跳這個地形候選，換下一個
goal_resolver.gd:952-953  if pos == (-1,-1): return {}                     ← 這個 prereq 這格不成立
```
兩處都是**既有 idiom**（`_mk_candidate` 系列到處在用「候選不成立就回 `{}` 或 `continue`，
讓其他 goal/option 照常競爭」這個形狀），不是本票新造的路。地板防瞎（`maxf(seek_range,1)`）
只是讓「找不到」這個【既有、已經在跑的】分支被觸發得更頻繁（極慢隊），
不是開一條沒人走過的新路。**判：可以留給金絲雀，不用在本票內查——因為要查的東西已經在跑，
不是未知數。**

## 其餘

blueprint 加的 ⑥絕境金絲雀（只印不判、不預建放寬機制）：設計合理，沒有異議。
誠實限兩條（直線非路徑距離／SEEK_DAYS 人格化 defer）：沒有異議。

CLEAN，直接 dispatch。
