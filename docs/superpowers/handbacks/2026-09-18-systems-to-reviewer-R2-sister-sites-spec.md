---
from: systems
to: reviewer
status: open
slice: 兩支姊妹 site 改讀 `known_outposts`（spec `2026-09-18-sister-sites-read-known-outposts-HOW.md`）
topic: ★**R② 求審**（★**R① 我判免**：前提已由前一票的實作坐實 —— `BeliefSystem.known_outposts` 已在 main（`belief_system.gd:364`）、`faction_ai` 已改讀（命中 2）、另兩支命中 0，我剛核過）｜★★**這一票不是新設計，是把已經證明可行的做法套到剩下兩支**｜★★★**而我把兩個【不要修錯】的守衛也釘成格**：`goal_resolver.find_nearest_known_tile` 逐字未改（它讀的是 terrain ⇒ 不會變 ⇒ 合法）、`gather()` 裡 8 處自家據點讀取逐字未改｜★**請特別打我「R① 免」這個判斷**
---

# 一、★請你打的第一件：我判「R① 免」對不對

```
我的理由：前提全部是【現況事實】，而且我剛才逐一 grep 過 main：
  belief_system.gd:364        known_outposts 已存在
  faction_ai_system.gd        known_outposts 命中 2（前一票改好的）
  strategic_ai_system.gd      命中 0（未改）
  decision_context.gd         命中 0（未改）
⇒ 沒有「X 會經過 Y」這種需要 factcheck 的推論斷言
```
★**而我今天才因為「只看簽章沒看內部」栽過一次** ⇒ **若你認為這仍該走 R①，說一聲，我照做。**

# 二、★★兩個「不要修錯」的守衛（1-d／1-e）

```
1-d：goal_resolver.find_nearest_known_tile 逐字未改
     ★它閘後 live 讀的是 t.terrain —— 地形不會變 ⇒「當時」與「現在」同一個值 ⇒ 不製造不該有的知識
     ⇒ ★★判準是【那個欄位會不會變】，不是【有沒有在閘後讀 live】
1-e：gather() 裡 8 處【合法的自家據點讀取】逐字未改（讀自己的家不是 god-view）
     ★★★這正是我上一輪 met_check 寫成「函式裡不再出現 outpost_owner」會【恆假】的原因
```
★**我把「不要修錯」也做成會紅的格** —— ★★因為**只寫在信裡的「別動它」會被下一個人跳過**。

# 三、範圍
★**第三支（`faction_ai`）已在前一票做掉** ⇒ 本票只剩兩支。
★★**`BELIEF_STALE_TICKS` 物理化**（另一張 defer，條件也已達成）**另票** —— **不混進來**。

# 四、狀態
`feat/bed-roll-call`（批一～批四，四次 R² 全 CLEAN）的 **merge 閘正在跑**；綠了我 merge。
