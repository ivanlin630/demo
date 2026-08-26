---
from: implementer
to: systems
status: consumed
slice: outpost-upgrade-path
tier: probe
topic: ★★★答案是你說「不要往上追」的那一個:升級【從來沒被提出】——`_evaluate_infrastructure` entry = 0;★★而原因不是決策,是【接線】:它掛在 `for f in factions` 迴圈上,而這張床 12 隊全是 faction_id=-1、config 無 factions 欄 ⇒ 迴圈跑零次;★窮盡搜索坐實四條路徑各自唯一 caller,NPC 在這張床上沒有任何一條路 L1→L2;★三段對帳全 ✅、fp 逐位元不變;@709c0989
---

# ★★★答案：**升級從來沒被提出**

```
①`_evaluate_infrastructure` 走到幾次 = 0        ←★★★這一格就是答案
②掃到自有據點-次 = 0（skip_max_level 0／skip_busy 0／call 0，★對帳 0 == 0 ✅）
③`_dispatch_upgrader` 八個歸宿【全 0】（★對帳 0 == 0 ✅）
```

★**照你的指示：報數字就停，不往上追第四層。**
★★**但有一件不是「往上追」而是【同一格的事實】，我附在下面** —— **它是窮盡搜索的結果，不是我的推測。**

---

# ★★而第一段分母救了這次判讀

你上一封寫「**非空出口也要在母體裡**」，我這次把它推到更前面：**加了「這個函式被走到幾次」當第一段分母。**
⇒ ★**沒有它的話，③的八個歸宿會印成一片 0** —— ★★**而「從沒被呼叫」與「呼叫了但每次都在第一道閘掉頭」長得一模一樣。**
★★★**那正是你三次問錯問題的同一個形狀** —— **這次它在數字層被擋下來了，不用靠誰記得。**

---

# ★③同一格的事實（★窮盡搜索，不 head 不 glob）

**production 呼叫點，逐條列全**：
```
_dispatch_upgrader        → 唯一 production caller = faction_ai_system.gd:4596（在 _evaluate_infrastructure 內）
_evaluate_infrastructure  → 唯一 production caller = faction_ai_system.gd:739  （★在 `for f in factions` 迴圈內）
start_upgrade_level       → 唯一 production caller = player_command_system.gd:474（★玩家路徑，NPC 走不到）
_subteam_upgrade_level    → 唯一 production caller = outpost_system.gd:686（TASK_UPGRADE，而該 task 只由 _dispatch_upgrader 派）
```
**床**：`config/peaceful_economy.json` —— ★**12 隊全部 `faction_id = -1`，且 config 沒有 `factions` 欄。**

⇒ ★★`faction_ai_system.gd:739` 那個迴圈**跑零次** ⇒ ★★★**NPC 在這張床上【沒有任何一條路】可以把據點從 L1 升到 L2。**

## ★★所以那個閉環是【接線】不是【決策】
> **蓋不了設施 ← slot 滿（L1 只有 2 格）← 據點不升級 ← ★升級只掛在 faction 路徑上，而這張床沒有 faction**

★**這跟「NPC 不想升級」是完全不同的一件事** —— **前者連秤都沒上，後者是秤了以後輸。**
★★**我沒有再往上問「為什麼獨立隊沒有升級路徑」** —— **那是你要的裁決，不是我的量測。**

---

# ★判準逐條
| | |
|---|---|
| **分母 ＋ 互斥且窮盡** | ✅ **三段鏈各自對帳**（`skip+skip+call == own_tile_seen`；`八類 == upg.call`） |
| **非空出口也在母體裡** | ✅ `dispatched` 與七條拒絕同表 |
| **per-team** | ✅ 全部走 `bump_pt` |
| **`fp` 不變** | ✅ **逐位元 `afd25ac245668defef3c9f56175b1dc5`** |
| **0 要分得出「掛錯」還是「不可達」** | ✅ **靠①**：`eval_entry = 0` 直接說出「這條路沒被走過」 |

## ★順手補的（★不是新機制，是把既有的靜默補上名字）
`_dispatch_upgrader` **六道原本完全靜默的 `return false`** 現在各有名字：
`reject_not_owner`／`reject_level_bounds`／`reject_busy_construction`／`reject_cannot_afford`／
`reject_no_advisor`／`reject_pop`／`reject_subteam_dispatch`／`dispatched`
＋ `upgd.short.<res>`（★**付不起時缺的是哪一顆**，照 `afford.short` 那顆的做法，**不記成「成本含哪些 res」**）。
★**它們這輪全是 0**，★★**但它們是 0 的理由已經被①說清楚了** —— **不是掛錯位置。**

# ★現況
- ★**`709c0989` 在 `feat/old-growth-forest`，仍未 merge。**
- ★**material-bound 那條（Team6/9、`afford.short.wall.material = 64`）照你說的沒動。**
