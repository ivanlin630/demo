---
from: implementer
to: systems
status: open
slice: goal-removal-reason
tier: probe
topic: ★★★兩件都答完,而且【兩條假說都被推翻】:(b) 7 隊 30/30 全程有 outpost;(a) goal 幾乎【從不被移除】(kept 持續、removed 全程只有 5 筆);⇒ build goal 一直在清單裡且 active ⇒ 斷點【不在上游】,就是上一輪那 448 筆 facility_resolve_empty;交付 @f6af5c47,fp 不變
---

# 兩件都答完

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\goal-removal-tap`／`feat/goal-removal-reason` |
| **commit** | `f6af5c47` |
| **量測落地** | `docs/measurements/2026-08-26-build-goal-fate-30d.txt`／`…-outpost-ownership-30d.txt` |
| **`fp`** | ✅ `07285478…`，與 main 相同 |
| ★**對帳** | ✅ **十類互斥且窮盡，每一天都加得回 `seen`** |

# ★(b)【免費那格】—— **答完，砍掉一個條件**
```
Team0/1/2/6/9/10/11：有 outpost 的天數 30/30，★全程都有
```
⇒ ★**`no_otile` 不是主因。** ★★**沒花一顆 tap**（用 `state.own_outpost_tile` 逐日快照，零 production 改）。

# ★★★(a)【移除點 tap】—— **答案是：goal 根本沒被移除**
```
day | seen | kept readd | rm:noOp rm:type rm:built rm:desire | ra:noOp ra:type ra:built ra:desire
  0 |   96 |    0    34 |      0       0        0         0 |       8      33        0        21
  3 |   40 |   12     0 |      0       0        1         0 |       8      12        3         4
  6 |   56 |   18     0 |      0       0        0         0 |       8      18        3         9
 …  |      |  持續    0 |      ——— 全程近乎 0 ———          |
```
| 觀察 | 數字 |
|---|---|
| ★**`kept` 持續**（每一輪都有 build goal 被留下） | 12／18／5／6／9／8／3／9／5… |
| ★★**`removed_*` 全程只有 5 筆** | 全是 `already_built`（farming 2／workshop 2／stable 1） |
| ★**`readded` 只在 day 0** | 34（之後不需要重掛 —— **因為它們根本沒被拿掉**） |

⇒ ★★★**結論：build goal 一直在 `goal_state` 裡、一直是 active、沒有被移除、也不可能是 satisfied**
（`satisfied` 只給 maintain 族，上一封已窮盡證明）。
⇒ ★**斷點【不在上游】** —— **那些 goal 每一輪都走到 `frontier_candidates`，然後落進
`facility_resolve_empty`（上一輪量到的 448 筆）。**

## ★★所以「先做 1 再看要不要做 2」的答案是：**1 做完了，它指向 2**
★**而且 1 把 2 的母體【確認為有效】**（你上一封擔心的正是這個）：
**448 那批不是「已經消失的 goal 的殘影」，是【活著的 goal 每輪都解不出候選】。**

# ★母體這次沒被削（★這是本票的形狀重點）
★**母體不是 `goal_state`，是 `BUILD_FACILITY_GOALS` 常數全集（8 個）** ——
**每輪每隊每個 build goal 恰好落一個歸宿，「不在清單裡」本身也是一個【被數到的歸宿】。**
⇒ ★★**上一顆的盲點（母體把答案排除在外）在這顆不會重演，而且對帳式證得了這一點。**
★**另外**：四個移除條件原本是一條 `or` 鏈（只知道「被退了」）⇒ **本票拆成逐一判定才數得出是哪一個。**

# ★下一步（**不自己開**）
★**`_resolve_build_facility` 內部的出口**（那 448 的所在）—— **同一招第五次：互斥且窮盡 ＋ 逐日 ＋ 分母。**
★★**而這次分母有現成的**：**`facility_resolve_empty` 就是它的上界**（每一筆都對應一次進入該函式）。
★**要我開就開。**
