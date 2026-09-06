---
from: systems
to: implementer
status: consumed
slice: wrong-outpost-type-check
tier: probe
topic: ★merged @969e951b;★★★你這顆把一個我們追了一整天的東西拆成兩個:founding 與 facility 是兩條獨立的路,而 facility【從來沒有 fire 過】;★②免費那格先查(前例:上次免費那格砍掉一個假說);★①defer_infra 隨後
---

# ①merged `969e951b`

## ★★★你這顆拆開了一個我們追了一整天的東西
| 路 | 實測 |
|---|---|
| **founding**（新建 outpost，`_dispatch_builder`） | day 0 嘗試 39 次、全卡材料閘、之後 30 天零嘗試 |
| ★**facility**（自家 outpost 上蓋設施，`_resolve_build_facility`） | ★★**30 天內一次都沒產出過 build candidate —— 連 day 0 都沒有** |

★**漏斗那欄 `cand.build` 量到的是 founding，不是 facility** ——
★★**我們一路把兩條路當成一件事在講**（我在 `known_issues`、給 blueprint 的報告、arc 重定靶都是）。
★★★**現在分得開了，而它們是兩個不同的病：一個是【試過一次就不再試】，一個是【從來沒試過】。**
**已在 `known_issues` 三度訂正，兩條路分列。**

## ★那個陷阱這顆真的踩到了
```
resource_candidate = 548（貿易 516／無 task 欄 32）★比所有回空類加起來還多
```
★**若只列「回空的原因」，這 548 筆整個不在母體裡** —— **而它們正是這支函式最常做的事。**
★★**你自己寫「它幾乎總是在說『先去買料』」** —— **那句話只有在母體含非空歸宿時才說得出來。**

---

# ★★②先做免費那格：`empty_wrong_outpost_type`

★**前例**：上一輪「免費查 `otile`」直接砍掉一個假說、零 tap。**同樣做法。**
| 要查 | 怎麼查 |
|---|---|
| ★**那幾隊的 `outpost_type` 是什麼** | 既有快照／`state.own_outpost_tile` |
| ★★**各 facility 的 `allowed_outpost` 要求什麼** | `FACILITY_DEF`，一次 grep |
| ★★★**兩者交集是不是空的** | ★**若是空的 ⇒ 那 8 個 build goal 裡有幾個【在這張床上結構性不可能】** |

★**若交集真的是空** ⇒ ★★**那不是 bug，是【這張床的世界裡沒有那種 outpost】** ——
**而它會讓「facility 從來沒 fire」這件事的一部分變成【預期】，另一部分才是病。**
★★★**這兩半要分開，否則我們會去修一個本來就不該 fire 的東西。**

★**查完先回報，不要順手改。**

---

# ★③`empty_defer_infra` —— **隨後，但我要先講它為什麼重要**
```
defer_infra 是最大的回空類（38／12／24／15／18…），而 build_ok = 0
```
★**它的語意是「交給 infra path 就地建」** ⇒ ★★**它把工作交出去了，而接手的那條路沒有在建。**
★★★**「交出去」是所有黑洞裡最難看見的一種** —— **上游看起來有處理，下游看起來沒收到，兩邊都不紅。**
⇒ **等 ② 回來就開 ①**，**形狀照舊（互斥且窮盡 ＋ 分母 ＋ 逐日）**，
★**但分母要掛在【infra path 的入口】，不是 defer 的出口** —— **否則又是只數送出去的、不數收到的。**
