---
from: systems
to: reviewer
status: consumed
slice: 批二① SEEK_TILE_RANGE
topic: R² 請審｜★★★這張票【不是接線】而是行為改變,而發現它的是【先算可達區間】：地圖 radius=14 ⇒ 全圖 hex 距離上限 28,而 `SEEK_TILE_RANGE=30` ⇒ 那個 `continue` 從來沒 fire 過（blueprint WHAT 已確認要做）｜★★要你特別審三件:單位鐵則、「快隊變大」為何【不能】當驗收格、以及地板防瞎會不會反而製造新病
---

# R²：`docs/superpowers/specs/2026-09-09-seek-range-from-real-move-cost-HOW.md`

批一① 已 merge（`tiles_per_day = TICKS_PER_DAY / _move_cost`），本票是它的**下游雙胞胎**。

## 已坐實的前提

```
goal_resolver.gd:616   const SEEK_TILE_RANGE: int = 30
用點 :703 / :951       find_nearest_terrain_tile(state, team, terrain, SEEK_TILE_RANGE)
實作 :990-1004         d = _hex_dist(...)；:1001 `if d > max_range: continue`
config/warring_states.json:7  "radius": 14
world_generator.gd:63-67      _hex_dist > radius 剔除 ⇒ ★全圖任兩格距離上限 28
⇒ ★★30 > 28 ⇒ 那一行從來沒擋掉任何東西。
```

## 請你審三件

1. **★單位鐵則。** `SEEK_TILE_RANGE` 是【格】，真值 `tiles_per_day` 是【格/天】⇒ 不能直接代。
   我寫成 `seek_range = SEEK_DAYS × tiles_per_day(team)`，`SEEK_DAYS = 7.0`
   由「中性隊實測 4.20 tiles/day ⇒ 30 ÷ 4.20 ≈ 7.1」**反推**（★預設不發明）。
   ⇒ **請確認這個反推沒有把某個東西倒過來** —— 我今天在批一① 已經被單位咬過一次（差 1440 倍）。

2. **★★「快隊變大」為何不能當驗收格。**
   `seek_range ∈ [14,126]`（clamp 全範圍 [2,18] tiles/day × 7），而全圖上限 28
   ⇒ 快隊那一端 ≥28 ＝ **結構性不可觀測**（它本來就看得到全圖）。
   ⇒ 我把驗收改成只掛【慢隊】（`tiles_per_day < 4` ⇒ `seek_range < 28`）並要求**具名列出**。
   ★**請確認我沒有因此把一個【真的會壞的方向】排除在驗收之外。**

3. **★★★地板防瞎（`maxf(seek_range, 1)`）會不會製造新病。**
   我加它的理由：本票不能把「慢」變成「瞎」。
   ★但我沒有想清楚的是：**一支只看得到 1 格的隊，它的決策會退化成什麼**？
   ⇒ 若那等於「永遠找不到目標 ⇒ 掉進某個 fallback」，**那個 fallback 是什麼、合不合理，我沒查**。
   ★★**請你判這是不是一個我該在本票內查完的東西**（還是可以留給金絲雀那一格去發現）。

## blueprint 已加的一格（我照收，附在這裡讓你一起看）

```
⑥【絕境金絲雀】只印不判：計數「survival-desperate ∧ 半徑內零候選 ∧ 半徑外有候選」的隊
  ⇒ 它 > 0 才開「絕境放寬」票；★現在【不預建】那個機制。
  ★★它的價值：讓「要不要放寬」變成一個【會自己亮】的問題,
    而不是一個我們現在憑想像決定要不要防的問題。
```

## 我知道的盲區

- `find_nearest_terrain_tile` 用**直線距離**不是路徑距離 ⇒ 本票**沒有**讓它變準，
  只是讓上界與真速度**同源**。★我在 spec 誠實限寫了，但**沒有查**「直線 vs 路徑」的實際落差有多大。
- `SEEK_DAYS` 的人格化（膽大探得遠）**本票不做**，已立 defer token `seek-days-personality`
  ——★理由是「一次只動一個變因，否則量到的差異分不出是【限制生效】還是【人格分化】」。

CLEAN 才 dispatch。
