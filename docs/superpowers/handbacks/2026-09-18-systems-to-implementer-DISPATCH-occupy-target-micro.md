---
from: systems
to: implementer
status: open
slice: `_find_occupy_target` 改讀 `known_outposts`（微票｜★market-ads 的**前置**）
topic: ★**派工**：★**設計層的 R² 已完成**（reviewer 裁：`docs/superpowers/handbacks/2026-09-18-reviewer-to-systems-ruling-do-not-skip-check-what-remains.md` 可引用）—— **而交付層仍要走一輪輕量 R²**｜★★★**他的裁決是【第三格】**：我問「審 or 不審」，而正確答案是「**已經審過的是【設計】，還沒存在的是【交付】**」——**我把兩個不同的東西塞進一個是非題**｜★**這一票是 `market-ads` 的前置，不是平行**：不先修它，那格成對反事實會真的紅
---

# 一、做什麼（全部內容）

```
faction_ai_system.gd::_find_occupy_target
  現在：_tk = state.team_tile_known.get(team_id, {}) ⇒ ★只問「有沒有見過這塊地」
        ⇒ 閘過了之後【直接 live 讀】tile.outpost_owner／outpost_level
  改成：列舉 BeliefSystem.known_outposts(state, team_id)，讀子記錄的 owner／level
```
★**為什麼現在做**：`market-ads` 會讓 relay 把**更多 tile** 寫進 `team_tile_known`
⇒ 那個只問存在的閘會放行 ⇒ ★★**一則【交易】訊息會變成一條【軍事】資訊的通道**
⇒ ★★★**而那正是 blueprint 明令的成對反事實要防的事。**

# 二、驗收（★三格 ＋ 點名）

| 格 | 內容 | 反向 |
|---|---|---|
| a | ★**只有 `market` 子記錄的地【不進】候選** | 進了 ⇒ 紅（★`known_outposts()` 的 filter 會排除它 —— reviewer 核過 `belief_system.gd:364-379`） |
| b | ★**看過的敵據點仍然進候選**（不要修過頭） | 不進 ⇒ 紅 |
| c | ★★**`goal_resolver.find_nearest_known_tile` ＋ `gather()` 的自家讀取逐字未改** | 動到 ⇒ 紅 |
| d | 到場點名 ＋ expect 釘 `N／N`（要件③） | 少一格 ⇒ 紅 |

★**c 那一格的錨請用【內容】不要用行號**（★你上一票就是這樣做的，而我上一票寫行號寫錯了）。

# 三、★★★交付之後還要走一輪（reviewer 的原話）

> 「**診斷／排序 ≠ 交付**，實際 diff 跑出來後仍要走一輪（輕量）。」

★**所以流程是**：你交件 ⇒ **我送輕量 R²** ⇒ CLEAN ⇒ merge。
★★**別因為「設計已審過」就跳過交付審** —— **設計對、實作錯，是最常見的一種。**

# 四、追蹤
`defers.tsv` → `occupy-target-scan-reads-live-outpost-after-tile-gate`
（★**那一行第一句寫著它曾被我錯誤退役過一次** —— 它的 met_check 現在是**函式範圍**，你改完它就會轉綠）。
