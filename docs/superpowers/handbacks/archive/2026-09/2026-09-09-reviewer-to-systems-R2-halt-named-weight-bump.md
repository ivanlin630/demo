---
from: reviewer
to: systems
status: consumed
slice: 普查批一① MOVE_TILES_PER_DAY 接上執行端真成本
topic: R² 判決 — premise_contradiction 確認，halt
---

# R² 判決：`2026-09-09-plan-speed-from-real-move-cost-HOW.md`

## 判決：halt（premise_contradiction 確認為真）

你自己在信裡點的疑慮成立：**`_compute_team_speed` 沒有同樣逐行查完，而它裡面真的還有一處寫入。**

```
movement_system.gd:189-190  _move_cost() → _compute_team_speed(state, team)  # 兩版都會呼叫，無法繞過
movement_system.gd:216-218  _compute_team_speed() → _compute_base_team_speed(state, team)
movement_system.gd:247      if Probe.enabled: Probe.bump("rootdiff.NAMED_WEIGHT")
                             # 每個 named/leader 成員各 bump 一次
```

`_move_cost_pure`（spec §3①(a)）目前的設計只抽掉 :194／:211 兩處 bump，但 `_compute_team_speed` 這一段對兩版（pure/impure）是**同一條呼叫路徑**，無法用「pure 版跳過」的方式繞開 :247。從決策路徑呼叫一次，`rootdiff.NAMED_WEIGHT` 就會混入決策端的計數 —— 跟你原本抓到的 :194/:211 是同一個病灶，只是你只查了 `_move_cost` 本體、沒查它呼叫出去的那一支。

spec §3① 驗收目前只承諾「`rootdiff.TERRAIN_SPEED_MULT` 計數 before/after 不變」，沒把 `rootdiff.NAMED_WEIGHT` 一起列進去 —— 這格會被這次改動污染卻沒有守衛盯著。

**要改的地方（我不裁 (a)/(b) 怎麼選，那是你的判斷，但範圍要擴大）：**
1. `_compute_base_team_speed` 也要有 pure 版（或把 bump 一起交給呼叫端做，跟 :194/:211 用同一套機制），不能只停在 `_move_cost` 這一層。
2. §3① 驗收加第三格：`rootdiff.NAMED_WEIGHT` 計數 before/after 不變（跟 TERRAIN_SPEED_MULT 那格並列）。
3. 建議順手確認 `_compute_mount_bonus` / `_compute_wagon_penalty` / `get_carry_capacity` / `get_effective_wagons` / `get_effective_mounts` / `calc_total_weight` 這幾個 `_move_cost` 呼叫鏈上還會踩到的函式沒有其他遺漏的 `Probe.bump`——我用 grep 掃過 movement_system.gd 全檔只有 :194/:211/:247 三處 `rootdiff.*` bump，這三處都在 `_move_cost` 呼叫鏈內，已窮盡（附全檔 `Probe.bump` grep 結果，見下）；跨檔（`get_effective_wagons` 等若定義在別檔）我沒查，你複驗時一併確認定義處。

## 附：movement_system.gd 全檔 Probe.bump grep（窮盡依據）

```
75/76/78/93/94/98/101/107/113/115/144/145  merge/flee/strat 系列 — 不在 _move_cost 呼叫鏈
194  rootdiff.TERRAIN_SPEED_MULT  ← 在鏈內，spec 已處理
212  rootdiff.WAGON_TERRAIN_MULT  ← 在鏈內，spec 已處理
247  rootdiff.NAMED_WEIGHT        ← 在鏈內，spec 未處理 ★本次判決重點
281/288  qty.move_n — 在 _step_team，不在 _move_cost 呼叫鏈
```

## 附帶回答你問的第 2 件事（§4③ 門檻）

單位鐵則（§2）驗過是對的：`tiles_per_day = TICKS_PER_DAY / _move_cost()`，dimensionally 成立。
但拿真常數代一下：`BASE_MOVE_TICKS=240, MIN=80, MAX=720, TICKS_PER_DAY=1440`
→ baseline（speed=1、無地形/疲勞/超載修正，cost=240）就已經是 1440/240=6 tiles/day，是舊常數 2.0 的 3 倍；
→ 全範圍 clamp 在 [80,720] ⇒ tiles_per_day 落在 [2,18]，最大到 9 倍。

你寫的「差 2–3 倍 ⇒ 才是發現」這個 anchor 本身沒錯，但只給了兩個範例點（~1440倍 vs 2–3倍），沒說 6–9 倍（baseline 到 mounted-light-plains 這段合理落點）該怎麼判。**建議改法**：把門檻從「兩個 anchor 二選一」改成「≥100 倍 ⇒ 單位接錯；<20 倍（覆蓋你算出的 clamp 全範圍 [1x,9x] 加安全邊際）⇒ 真發現」，中間留一段模糊帶也沒關係——現在的寫法在 6–9 倍那段沒有判準，遇到就會卡住不知道算誰對。

## 其餘

item①單位鐵則、item③誠實限度：CLEAN，沒有異議。

CLEAN 只差上面這一項。補完 §3①/§4③ 後不用再跑 R²，你直接 dispatch；若補完後你自己判斷範圍又變了（例如發現 :247 之外還有別的鏈），再送一輪。
