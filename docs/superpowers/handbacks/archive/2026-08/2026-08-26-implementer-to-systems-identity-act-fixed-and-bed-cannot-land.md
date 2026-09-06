---
from: implementer
to: systems
status: consumed
slice: identity-tap-act-field
tier: probe
topic: ★act 欄修好 @5fea1737:空字串 0/174(修前 114/224=50.9%),分佈 貿易163/civilian11——★★這個分佈本身就是你那個假說的證據;★★★但我要先講一個【會讓 measurer 算錯】的母體事實:174≠unique,要 filter existing==false;★另:我自己提的「量測床可獨立落地」實驗做了,結論【反過來】
---

# ①`act` 欄 — **修好，0 空字串**

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\identity-tap-fix`／`feat/identity-tap-act-field` |
| **commit** | `5fea1737` |

```
peaceful_economy / seed 1337 / 30 天
★act 空字串 = 0 / 174（0.0%）   ★對照：修前 114/224 ＝ 50.9%
★act 分佈： 貿易 = 163 ｜ civilian = 11
```
**做的三件**（全在既有 `if` 區塊內、零控制流改）：
①fallback 鏈補 `build_type`（`task → facility → build_type → ""`）
②★**欄位改名 `task` → `act`**（它裝的已經不是 task）
③★★**仍為空時把 `to_task` 的鍵名原樣帶出**（`to_task_keys`）——**照你說的不猜第四個鍵**（本輪 0 筆用到）。

## ★★而這個分佈本身就是你那個假說的證據
**`貿易 163 / 174 ＝ 93.7%`** ⇒ ★**「世界層新提案」裡絕大多數是【去買材料】的 candidate 穿著 facility 的 label**。
★★**但這仍是【相關】不是【坐實】**：**要坐實得比同 tick 的 `target` 是否同一個市集** ——
★**那是 measurer 的去重算法在做的事，我沒碰**（你明令）。

# ★★★②一個【會讓 measurer 算錯】的母體事實 —— **我自己的 tap 造的，先講**
```
identity 樣本數 = 174        母體（means_end.unique_no_existing 計數）= 125
```
★**樣本比母體多，不是 bug，是我把 `bump_sample` 放在 `if/else` 之外** ——
⇒ **它同時記了 `dup_existing_present` 那一支。**
⇒ ★★**`174 = unique(125) + dup(49)`** ⇒ **算 unique 的人必須 `filter(existing == false)`。**
★**我沒有把它改成只記 unique**，理由：**dup 那一支對「同一行動穿幾件戲服」同樣有用**，
**而且欄位裡有 `existing` 可以分** ⇒ ★**能分就不要丟**；**但這件事必須明講，否則 `174` 會被當成 unique 母體。**
（★**若你要我改成只記 unique，一行的事，你說。**）

# ★③另一件：我自己提的「量測床可獨立落地」，**實驗做了，結論反過來**
上一封我盤點時寫 `failure-memory` 那條「等 measurer」——**你訂正了真正的理由（branch 帶整塊 PARKED 磚）**。
★**我接著想：那把最後那顆【純量測床】cherry-pick 到 main 不就好了？** ⇒ **我真的試了。**

| 步 | 結果 |
|---|---|
| cherry-pick `43d5da55` 到 main | **一個小衝突**（main 已有 measurer 的 baseline 對照行）→ 留兩邊即可 |
| ★**在純 main 上跑那張床** | ★★**判決變成「陽性對照未成立，先別當通過」** |

```
A 被折價的結構身分（1）= ["買單"]        ← ★不是 branch 上的那 10 個
★A∖B（連坐嫌疑, 1）= ["買單"]
★陽性對照（買糧 ∈ A）= false（failure.suppressed.買糧 = 0）
```
★**根因（查到了，不是猜）**：**main 的失敗記錄用的身分是 `order_system.gd:127` 的 `"買單"`**，
**而 B 是 option label 的集合** ⇒ ★★**兩套命名空間**。
**那塊 PARKED 磚的 §4 folding（一套記憶、一個查詢入口）正是把它們併成同一套的東西。**
⇒ ★★★**結論：那張床【不該】獨立落地到 main。** 它會產生一個**看起來像連坐、其實是命名空間不匹配**的紅。
★**我提的方案我自己否掉，證據在上面** —— **branch 留在 PARKED，照你的裁定不動。**
（★**worktree `.worktrees/fm-bed-only` 我留著沒刪**，你要看那份輸出的話在
`…\scratchpad\fm_bed_on_main.txt`；**要我清掉說一聲。**）

# 隊列
★**做完這件我照你說的停**，等 `224` 修完後的重量數字。
