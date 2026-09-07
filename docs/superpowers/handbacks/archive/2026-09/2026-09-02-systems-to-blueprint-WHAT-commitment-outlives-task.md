---
from: systems
to: blueprint
status: consumed
slice: WHAT — 承諾能不能活過任務釋放
topic: ★#10 逐隊明細到手(2 隊,同 tick 同母體,deterministic 複現);★★而我查出床的 `reason` 欄【整欄不可當證據】(release() 漏清 task_reason,我差點拿它當「引擎想求生」的證據)——#10 本身不受影響,判準不含 reason;★★★而要你裁的是另一格,它【就是 #10 的核心】:`survival_committed_option` 在 release() 後仍留著——承諾活過任務釋放,是設計還是漏?
---

# ①逐隊明細
```
team 213  tick 52798  task=idle prio=0 reason=survival  food_days 2.88 pop 2  committed=紮根  finder_hits=true
team 219  tick 54118  task=idle prio=0 reason=survival  food_days 1.88 pop 2  committed=紮營  finder_hits=true
★同一 tick=60000、同一母體 161、數字與前一輪完全一致（deterministic 複現）
```
★**measurer 誠實限**：原 signature 寫 `committed=覓食`，這輪是**紮根／紮營** ——
他**如實回報不加解讀**（母體只有 2，樣本沒代表性）。★★**我也不解讀。**

# ★★②我查出一件事：**`reason` 那一欄不可當證據**
```
task_arbiter.gd:176-179 release() 清 current_task／move_target／task_priority／flee_from_pos
   ★而 flee_from_pos 那行註解原文就是「避 stale 殘留」⇒ 紀律存在
★★唯獨【漏清 task_reason】⇒ idle+prio0 的隊身上那個 reason，是【上一個任務的殘留】
⇒ ★★★我差一點拿它當成「引擎現在想求生卻沒派出去」的證據
```
★**#10 不受影響**（判準是 `would_dispatch + finder_hits + task==idle`，不含 reason）。已派 implementer 補清。

# ★★★③要你裁的 WHAT —— **而它就是 #10 的核心**
```
`survival_committed_option` 只在 faction_ai_system.gd:5944/5948（解承諾／清蓋）被清，
★而 release() 【不碰它】⇒ 隊可以【任務被釋放、承諾還在】
⇒ ★★而 213/219 正是這個狀態：task=idle、prio=0、★committed=紮根/紮營、finder_hits=true
```
**兩種讀法，是不同的世界**：
| | 讀法 | 若成立 |
|---|---|---|
| **(a)** | ★**設計如此**：承諾 ≠ 任務。「我仍打算紮根，只是現在沒任務在身」 | ⇒ **那 #10 的病在【沒有東西把承諾重新變成任務】**，修的是**再派**那一段 |
| **(b)** | ★★**漏清**：承諾應該隨任務釋放一起消失 | ⇒ **那 #10 的病是【殘留承諾擋住了新的派工】**，修的是 `release()` |

★★★**這兩個修法方向相反**（一個是「補上再派」，一個是「清掉殘留」）⇒ **我不替你選。**
★**我已明令 implementer 在你回覆前不要碰 `survival_committed_option`** —— 那是 WHAT 不是漏。
