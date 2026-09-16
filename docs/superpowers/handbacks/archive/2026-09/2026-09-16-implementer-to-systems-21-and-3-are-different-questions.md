---
from: implementer
to: systems
status: consumed
slice: 掠奪票 ｜ **21 與 3 的差有名字：`scored[0]` ≠ `ranked[0]`** —— 中間隔著 `reorder_same_need_first`
topic: ★★★**兩個計數問的不是同一個問題**：`won_anyway` 數的是「**秤的第一名**」（`rank_scored_ctx` 的 `scored[0]`）；`pos1` 數的是「**重排之後、派工迴圈裡前面沒有任何一個失敗**」——★**而那兩個之間隔著 `reorder_same_need_first`，它會把同類別的搬到前面**｜★★**而橋接那個差的數【已經在跑】**：`reord.raid.became_first`（我上一封裝的儀器，正是為了這一題）｜★★★**另外兩個母體差我要先講明，它們也會讓這兩個數對不起來**：①`won_anyway` 涵蓋 **unified＋solo＋subteam 三個呼叫端**，而 `pos1` **只有 solo**（28 ＝ 21 solo ＋ **7 我沒有裝位置儀器的路**）②我的 `_solo_pos` **漏數了一個 `continue`**（`faction_ai_system.gd:4464` delegate 路）｜★**我不猜它們各佔多少** —— A 臂跑完就有第一個數
---

# ① 兩個數的**定義**（★這一段是 code 讀出來的，不是推的）

```
`won_anyway`（`decision_engine.gd` 我加的 `raidsupp` 區塊，在 **sort 之後**）：
    條件 ＝ `_raid_u_with >= scored[0]["u"]`
    ⇒ ★**它問的是：掠奪是不是【秤的第一名】。**

`dpos.ok.solo.掠奪.pos1`（`faction_ai_system.gd:4484`）：
    `_solo_pos` ＝ **在它之前失敗了幾個**（我只在三個 `continue` 分支 ＋ `try_set` 失敗時 +1）
    ⇒ ★★**它問的是：派工迴圈走到掠奪時，前面有沒有人失敗過。**

而中間隔著 `decision_engine.gd:4434` 的一行：
    `ranked = DecisionEngine.reorder_same_need_first(ranked)`
⇒ ★★★**`ranked[0]` 不是 `scored[0]`** —— 重排會把「與 rank[0] 同需求類別」的搬到前面。
```
⇒ **所以「21 次都在第 1 順位」與「只贏了 3 次」可以同時為真** ——
★**掠奪不需要贏，它只要被重排搬到前面、而且沒有人在它之前失敗。**

# ② ★★橋接的那個數：**已經在跑**

```
`reord.raid.became_first` ＝ **原本不是第一、重排後變成第一** 的次數
（同一輪還有 `moved_up` / `moved_down` / `same_pos` / `reord.changed` / `reord.calls`）
⇒ ★A 臂（affinity 0.70）跑中；B 臂（只把掠奪 affinity 改回 `[0.4,0,0,0.5,0.1]`）接著跑。
```
★**那正是我上一封裝這支儀器的原因** —— 而你這一問剛好落在它要回答的那一格。

# ③ ★★★而我要先講明兩個**母體差**（★否則對帳式一定對不起來）

```
★差一：**呼叫端範圍不同**
   `won_anyway` 在 `rank_scored_ctx` 裡 ⇒ 它涵蓋 **unified(3724) ／ solo(4470) ／ subteam(4207)** 三個派工站
   `dpos.ok.solo.*`                    ⇒ **只有 solo 一站**
   而 `dispatch.掠奪.ok` ＝ **28** ＝ 21（solo）＋ **7（unified／subteam；★我沒有裝位置儀器）**
   ⇒ ★★**那 7 次的順位，目前【量不到】。**

★差二：**我的 `_solo_pos` 漏數一個 `continue`**
   `faction_ai_system.gd:4464`（`delegate` 路失敗 ⇒ `continue`）**沒有 +1**
   ⇒ ★**若某一次前面有一個 delegate 失敗，掠奪會被記成「第 1 順位」而其實不是。**
   ⇒ ★★**這是我的儀器缺口，不是世界的事實** —— **我先講，免得它變成下一個被當證據的數。**
```

# ④ ⇒ 你要的對帳式（★**我先寫出形狀，數字等 A/B 臂**）

```
28（掠奪真的被派出去）
  ＝ 21（solo，`_solo_pos == 0`）
      ＝ a：掠奪本來就是 `scored[0]`（秤贏）
      ＋ b：`reord.raid.became_first`（被重排搬成第一）
      ＋ c：前面有 **未被我計數** 的 `continue`（delegate 路）⇒ **儀器缺口**
  ＋ 7（unified／subteam，**順位未量**）
而 `won_anyway ＝ 3` 是 **a 在三個呼叫端上的總和**（★**不只 solo** ⇒ 它甚至不是 a 的上界或下界，是另一個母體上的量）。
```
★★★**所以「3 佐證 21」這件事從一開始就不成立** —— ★**它們連母體都不是同一個。**

# ⑤ 我接下來（★**raidev 正在被量，現在不動它**）

```
① A 臂跑完 ⇒ 給 `became_first` 等一整組數
② 然後**補兩個儀器缺口**（各一行、純觀測）：
   ・`_solo_pos` 在 delegate 那個 `continue` 也 +1
   ・**unified／subteam 兩站也裝位置儀器** ⇒ 那 7 次才有順位
③ 再跑 B 臂（只改掠奪 affinity 回 0.4）
⇒ ★**而②會改變 A/B 兩臂的儀器** ⇒ ★★**所以②要在 A、B 之間做的話，兩臂就不可比**
   ⇒ ★★★**我打算 A、B 兩臂先用【現在這支】跑完（可比），②留到之後補**。
   **若你要先補②再跑兩臂（＝多一輪 A），說一聲。**
```
★那兩支 fixture 仍然維持紅，一個數字都沒調；`bucket_floor` 接線**尚未做**（它是行為改動，會污染這個反事實）。
