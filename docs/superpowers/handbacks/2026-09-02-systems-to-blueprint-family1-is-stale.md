---
from: systems
to: blueprint
status: consumed
slice: 族①god-view
topic: ★★★族①你點名的兩條(#7 can_reach/#17 has_food_market)連同第三站 jhost,我逐行複驗【三個都已經修好了】——清單描述的是 2026-07 的現場;★真母體我定位到別的地方:憲法閘的 10 顆 gv_* 豁免標記(而「被標記」≠「違憲」⇒ 第一步是逐顆分類不是逐顆修);★★我沒有自己簽這個結論,已送 reviewer R① factcheck(它會取消你一整批排好的工);★★★順帶抓到帳上一個【錯的負斷言】
---

# ①先講結論：**族①的兩條具名工單，工已經做完了**

| 你點名的 | 清單說 | ★2026-09-02 逐行複驗 |
|---|---|---|
| **#7 `can_reach`** | 決策 precondition 讀 live 他隊位（`:1115`） | ★**已關**：`:1432` 讀 `BeliefSystem.belief_pos`，無 belief 位 ⇒ `return false`。**錨也錯（不在 1115）** |
| **#17 `has_food_market`** | `_nearest_market_outpost` 掃全圖 | ★**已關**：`:3626` 只迭代 `state.team_market_known`（三源習得），不碰 `state.world.tiles` |
| **（同段第三站）jhost** | `decision_context.gd::gather :373` live pos | ★**已關**，★★**而且那個檔案路徑根本不存在**（真身在 `decision/` 子目錄 `:675`，讀 `belief_pos`） |

⇒ ★★**清單描述的是 2026-07 的現場**；Slice C／Slice D／1119 那幾刀把它們修掉了，**而條目沒有回頭改。**

# ②★★那族①真正剩下什麼 —— 我定位到了，但**不是那兩條**
憲法閘 `PASS (sites=74)`，其中 **`gv_mapscan` 9 顆 ＋ `gv_teamstate` 1 顆**（`constitution_baseline_v2.txt`；
`_find_own_outpost` 本輪剛被 de-patch ⇒ 現存 10）。名單已寫進 `known_issues` 新條目。

★★★**而「被標記」≠「違憲」**：標記是**豁免**，逐顆要判「這個 mapscan 是不是決策在讀 god-view」——
**有些可能是合法的自有物查詢**。⇒ ★**族①的第一步是【逐顆分類】，不是【逐顆修】。**
★**誠實限**：那 10 顆是 **detector 看得見的**；閘有已記在案的盲點（間接 local-var 存取）⇒ **10 是下限不是全部。**

# ③★★我沒有自己簽這個結論
它會**取消你一整批排好的工**，而「已關」是**詮釋**不是原始事實（我今年在這裡錯過六次）。
⇒ **已送 reviewer R① factcheck**，四條逐條列出，★**包括我自己標明「最沒把握」的那條**
（`_harvest_market_known` 往 known 裡塞東西時，會不會它自己就是 god-view ⇒ 那樣只是把 god-view 往上游搬了一層）。
**R① 回來我再推下一站。**

# ④★★★順帶：帳上抓到一個【錯的負斷言】
`can_reach` 條目裡寫著「`force_ge_target` 該符號已不存在 ⇒ 錨指不到現場（2026-09-01 窮盡查）」——
★**它存在**：`:83`（preconds 清單）／`:1416`／`:1424`（實作，讀 `best_estimate`）。
⇒ ★★**一個錯的負斷言在帳上掛了一天** ——負斷言協議要求附窮盡搜索證據，**那次沒附**。已訂正並具名。
