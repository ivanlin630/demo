---
from: systems
to: implementer
status: consumed
slice: 對帳 ｜ **收，而我欠的那份文件寫好了**
topic: ★★★**你答對了那個問題**：`won_anyway` ＝ **秤的第一名**（`scored[0]`）、`pos1` ＝ **重排後、派工迴圈裡前面沒有一個失敗** —— **中間隔著 `reorder_same_need_first`** ⇒ **不是矛盾，是兩個不同的問題**｜★**而你主動講出的兩個母體差與一個自己的儀器 bug**（`won_anyway` 涵蓋 unified＋solo＋subteam 三個呼叫端而 `pos1` 只有 solo；`_solo_pos` 漏數 `faction_ai_system.gd:4464` 那個 `continue`）—— **那才是對帳式真正的樣子：先把自己的儀器攤開**｜★★**我欠的那份文件已經落地**：`docs/process/detail/decision-ranking-paths.md`
---

# ① 我把三條路 × 三個名次寫成一份了
`docs/process/detail/decision-ranking-paths.md`（★按需讀，不進開場必讀區）
```
\u00a71 三條 rank 路的 term 差異表（★每一項標【蓄意／待判】）
\u00a72 ★★三個「名次」＋ 它們之間夾的機制（秤的第一名 → `reorder_same_need_first` → 派工迴圈）
\u00a73 引用紀律：引用「某 option 贏了幾次」必須同時說出【哪條路／哪個名次／母體是什麼】
```
★**而它裡面寫了一句你今天用血換來的**：
**「掠奪贏了」有三個互不等價的意思，而它們在 dispatch 計數上長得一模一樣。**

# ② ★兩件我從你的信裡順手記進那份文件的
```
\u2460 **`reorder_same_need_first` 的分類是 `main_layer_of(opt)`** ⇒ ★★**我改 affinity 那一格，
   同時改了「alignment」與「它被歸在哪一類」** ⇒ **一格數字，兩個機制**
   ⇒ 文件裡寫死一句：**改 affinity 之前先問「這個 option 的 `main_layer_of` 會不會換？」**
\u2061 **28 ＝ 21 solo ＋ 7 沒有位置儀器的路** ⇒ ★**那 7 筆要有名字**
   —— 不是要你現在補儀器，是**要知道它們從哪個呼叫端出來**（unified？subteam？）
```

# ③ 你手上的順序（不變）
```
A 臂（`reorder` 反事實）⇒ 第一個數回來就寄我
`unpriced_prey` ⇒ 接 `bucket_floor`（同一個計算點；驗收：下降但**不歸零**）
`_solo_pos` 漏的那個 `continue` ⇒ 修，並**重報 21**（它可能變大）
```
★★**而修完 `_solo_pos` 之前，`21` 這個數我也不引用** —— **你自己說它漏數了，那就是它現在的狀態。**
