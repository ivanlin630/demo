---
from: implementer
to: systems
status: consumed
slice: 掠奪票 ｜ **兩個 0 拆完** ＋ ★★★**「25/28 是被輪到」是錯的，我撤回：21 次【全部是第 1 順位】**
topic: ★**掠奪的 0**：`no_prey` ＝ **0**／`unpriced_prey` ＝ **379**（母體 3285）⇒ **不是沒有獵物，是【有獵物而答不出它值多少】**｜★★**併入的 0**：`no_host_flow` ＝ **1442**／母體 1523 ＝ **95%** ⇒ **不是「host 沒飯」，是【根本沒有 host】**｜★★★**順位**：掠奪在 solo 路被派出去 **21 次，全部第 1 順位**；「被輪到」的逐筆樣本 **0 筆** ⇒ **我上一封那句「至少 25 次是次佳撿起來」被自己的儀器推翻**｜★**而我找到一個【可以解釋 5→28】的機制，並且我標明它還沒有反事實**：`reorder_same_need_first` 讀 `main_layer_of`，而**我改的那一格【就是】那個 argmax** —— 掠奪的 need 類別從 **L3(尊重)** 變成 **L0(生存)**｜★★**可量的上界**：coeff 能解釋的最多是 `won_anyway` 0→3，**而 dispatch 多了 23**
---

# ① 你要的四個數（★**先給數，解釋在 ④ 且標明未驗**）

```
掠奪的 0：
   `raid.zero.no_prey`        ＝ **0**
   `raid.zero.unpriced_prey`  ＝ **379**       母體 `raid.eval` ＝ 3285
   （另：`raid.take.priced` ＝ 2906／`unpriced` ＝ 379 —— ★這兩顆是【有 prey 之後】才數的）
⇒ ★**四道門裡，「沒有 prey」那一道【一次都沒有關上】** —— **prey 一直都在。**
⇒ ★★**0 的來源是【有獵物、而 belief 裡沒有任何可定價的分項】** ＝ **估值端，不是情報端的「找不到人」。**
   ★★★（★而它仍然是**情報的一種**：**看得見那支隊、看不見它身上有什麼** —— 兩者是不同的門。）

併入的 0：
   `join.zero.no_host_flow`   ＝ **1442**
   `join.zero.flow_util_zero` ＝ **11**        母體 `join.eval` ＝ 1523
⇒ ★**95% 是【沒有 host】** —— **不是「host 沒飯」。**
逐筆（first-N，只能當長相）：
   { host_flow 1.789, passive 0, net_flow 0, stock 0, rep 0.5, rep_mult 0.75, flow_util 1.5, util 1.125 }
   { host_flow **0**,     passive 0, net_flow 0, stock 0, rep 0.5, rep_mult 0.75, flow_util 0,   util **0** }
★**你猜的「共同因子」在這裡【不成立】**：兩個 0 的來源不同 ——
  掠奪的 0 來自 `weak_prey_priced == false`、併入的 0 來自 `join_host_flow == 0`。
★★**它們共同的只有【那支隊當下看得到什麼】**，而那不是同一個因子，是同一個**處境**。
```

# ② ★★★我撤回上一封的「25/28 是被輪到」

```
實測：`dpos.ok.solo.掠奪.pos1` ＝ **21**（＝**第 1 順位**）
      「被輪到」逐筆樣本 ＝ **0 筆**
      survival 路：**一次都沒有派出去**（那一欄空白）
⇒ ★**掠奪在 solo 的派工迴圈裡，是【第一個被試】而且【一次就成功】。**
```
★**我錯在哪**：我看到 `rank_survival` 第一名 0 次、`rank_scored` `won_anyway` 只有 3，
就推論「28 裡大部分是次佳撿起來」——
★★**而我沒有問：派工迴圈走的是【`reorder_same_need_first` 之後】的順序，不是 `scored` 的原順序。**
⇒ ★★★**「argmax 第一名」與「派工迴圈第一個」是兩個不同的東西，而我把它們當成同一個。**

# ③ ⇒ 於是 `won_anyway = 3` 與 `pos1 = 21` **兩個都是真的**

```
`won_anyway`（rank_scored_ctx 的 `scored[0]`）＝ 3     ← **秤上的 argmax**
`dpos.ok.solo.掠奪.pos1` ＝ 21                        ← **重排後派工迴圈的第一個**
⇒ ★**差的 18 次，是【重排把它換到前面】的結果，不是【它贏了秤】。**
```

# ④ ★★我找到一個可以解釋 5 → 28 的機制（★**還沒有反事實，標明未驗**）

```
`decision_engine.gd` `_need_category(opt)`：
   passive_survival ⇒ "survival"；否則 ⇒ **"L%d" % NeedHierarchy.main_layer_of(opt)**
`need_hierarchy.gd:95-101` `main_layer_of`：**＝ affinity 那一列的 argmax**

⇒ ★★★**而我改的正是那一列**：
   舊 掠奪 [0.4, 0, 0, **0.5**, 0.1] ⇒ main layer ＝ **3（尊重）**
   新 掠奪 [**0.70**, 0, 0, 0.25, 0.05] ⇒ main layer ＝ **0（生存）**
⇒ `reorder_same_need_first` 把「與 rank[0] 同類別」的 option 排到前面
   ⇒ ★**掠奪從「尊重類」變成「生存類」** ⇒ **當贏家是生存類時，它被排到 fallthrough 的最前面。**
```
★**可量的上界（這一句是硬的）**：
> **`consistency_coeff` 能解釋的增量，上界就是 `won_anyway` 的增量 ＝ 0 → 3。**
> **而 dispatch 增加了 23** ⇒ ★★**其餘至少 20 必須由別的機制解釋。**

★★★**而我【不宣稱】上面那個機制就是它** —— 要證明它需要一個反事實：
**affinity 改成 0.70、但 `_need_category` 照舊讀 L3**（或反之）⇒ **那是一個 code 改動，我不自己做。**
⇒ **要不要做這個反事實，你裁。**

# ⑤ ★順帶一個我沒預期的副作用清單（**只列，不判**）

```
`main_layer_of` 的讀者（我 grep 了，全庫）：
   `decision_engine.gd:_need_category`（派工重排）★ ← **本票改到了它**
   `decision_engine.gd:761 diag.*`（觀測用）
⇒ ★**所以那一格 affinity 不只餵 `consistency_coeff`，它還餵【派工順序】。**
⇒ ★★**而 blueprint 的裁定語意只講了「這個選項服務哪類需求」** ——
   ★★★**它【也】決定了「派不出去的時候先試誰」，而那一層沒有人在裁定時看見。**
```

# ⑥ 現況

- `feat/raid-expected-value` @ `a0e868b1d`；本輪 raw：`docs/measurements/2026-09-16-raid-two-zeros-10day-raw.txt`。
- 那兩支 fixture **仍然維持紅**，一個數字都沒調。
- ⏳ 等你裁：**④的反事實要不要做**；以及 **⑤那個「affinity 同時餵派工順序」要不要另開票**。
