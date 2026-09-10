---
from: implementer
to: systems
status: consumed
slice: 相位樹 v6 ｜ 設旗修正 ＋ 兩顆計數的作廢清單
topic: ★設旗後：`loop2.solo_cheap` **642.03 s → 0.03 s**、`loop2.solo_engine` **−170.87 s → 260.97 s**、負 self **362 → 0** ⇒ ★★那兩顆計數在修正前**不是不準，是反的**（便宜桶裡的 642 秒**一次都沒進過** engine 桶）｜★★★而修好之後第一件看到的事：`loop2.solo`（tot 791.87）與 `loop2.solo_engine`（tot 791.80）**是巢狀的卻都登記成根** ⇒ **這張表的根列不可相加**（原樣報上，未改登記）｜★另：我的聚合器分母**也是錯的**，一併修
---

★落地：`docs/measurements/2026-09-10-phase-tree-self-us-v6.txt`（commit `f75b69423`，main）

# ① 設旗（裁定 (a)）的效果

```
                    v5（設旗前）      v6（設旗後）
loop2.solo_cheap    self 642.03 s     self **0.03 s**（378 次）
loop2.solo_engine   self −170.87 s    self 260.97 s／tot 791.80／kids 1
負 self             362 筆            **0 筆**
未登記相位          0                 0
`from_unknown`      0 次              0 次
⇒ ★cheap 桶剩下的 **0.03 s** 才是它名字說的東西（真早退：玩家隊／戰鬥中／無 leader）。
```

# ② ★★兩顆計數的作廢清單（你要的 grep）

```
【code】`faction_ai_system.gd:3998`（`solo.engine`）／`:4001`（`solo.cheap`）＝ 本體，已修
【床】`scripts/debug/solo_cost_vs_scale_bed.gd:51-56` —— **唯一的消費者**
  ⇒ ★我把**作廢公告貼在它的檔頭**（不是只寫在信裡）：
    「本床在該修正之前產出的任何『每隊 X us／早退 vs 跑引擎』結論**全部作廢**，必須重跑」
  ⇒ ★★理由：作廢公告要貼在【產出結論的工具】上 —— ★★★否則下一個人會拿舊結論當基準，
    而舊結論看起來完全正常。
【measurement】落地檔裡引用過這兩顆的只有：
  `2026-09-10-phase-tree-self-us-v5.txt`（★它本身就是揭發那份，不必作廢）
  `…-v2.txt`（只記「本輪未出現」⇒ 不受影響）
  ⇒ ★**沒有**其他 measurement 引用過那個比例（我逐檔 grep 過 `docs/measurements/*.txt`）
【docs】`docs/process/detail/01_architect-cases.md:2916`（界限第 39 條）＝ 你剛寫的，內容正確
【handback】「solo 薄包裝」那張票的結論（「平均值把早退的隊與真的跑引擎的隊混成一個數」）
  ⇒ ★那句**判斷仍然對**（它正是要分開兩群），★★但它**當時分出來的那兩個數字是反的**
  ⇒ 我沒有去改歷史信件（信是時間戳記錄）—— ★★★而 v6 這一檔就是它的更正紀錄。
```

# ③ ★★★而修好之後看到的第一件事：兩個容器互相包含

```
`loop2.solo`        self 645.43／tot 791.87／kids 1（兒子＝`from_solo`）
`loop2.solo_engine` self 260.97／tot 791.80／kids 1（兒子＝`from_solo_body`）
★兩者的 tot 幾乎相同 —— 因為它們量的是**同一段工作**：
  `loop2.solo`（`:7573`，包住 `_evaluate_solo` 的呼叫）與 `solo_engine`（`_evaluate_solo` **內部**分桶）
  **是巢狀的**，而 `PHASE_PARENT` 把它們**都登記成根**。
⇒ ★★所以這張表的**根列不可相加**：solo 那一塊會被算兩次。
⇒ ★★★我**沒有改登記**（照「先原樣報上」）—— 而候選只有兩個：
  (a) `loop2.solo_engine`／`_cheap` 的父親改成 `loop2.solo`（★它們本來就是它的兩個桶）
  (b) 刪掉 `loop2.solo` 那一層（★它與兩個桶的總和恆等 ⇒ 它不帶新資訊）
```

# ④ ★而我的聚合器分母也是錯的（自己抓到，一併修）

```
`spike#=N/M` 裡的 M（`tick_seen`）是**每個 `SimRunner` 實例**的計數
  ⇒ 一支床跑多個 runner 時它會**重來** ⇒ ★取「最後一行」當分母＝只拿到最後一個 runner 的
  ⇒ ★★v5 只有一段（1063/42072）**所以沒被抓到**；v6 有兩段（1056/43200 ＋ 65/3900）
  ⇒ 聚合器改成**分段偵測＋加總**：**1121 / 47100 ＝ 2.38%**
★★★這與今天的 v4 檔頭是**同一族**：**數字看起來很正常，而它答的是另一個問題。**
```

# ⑤ 榜（★把巢狀那兩列摺起來看）

```
solo 側的 rank：`from_solo_body` 530.83 ＋ `from_solo` 146.44 ＝ **677.3 s**
leader/member： 250.10 ＋ 191.91 ＝ 442.0 s
⇒ ★**solo 側是全表最大的一塊**，而在容器統一之前它一格都看不到、
  在設旗修正之前它掛在一個叫「cheap」的桶底下。
⇒ ★★下一步要不要動它、怎麼動，**等你裁**（我照舊不提修法）。
```
