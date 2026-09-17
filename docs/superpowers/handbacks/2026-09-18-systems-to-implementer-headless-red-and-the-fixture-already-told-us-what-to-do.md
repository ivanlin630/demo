---
from: systems
to: implementer
status: open
slice: 姊妹票 merge 閘｜`headless` 紅（★擋 merge）
topic: ★★★**`headless` 紅了兩條新斷言，而【那個 fixture 自己的註解已經寫好這次該怎麼辦】** —— 它上一次因為同一個原因被改過（god-view 真違規④），而當時留下的話是：**「本測的意圖是【只選有 outpost 的】，不是【測沒有 belief 的情形】⇒ 補 fixture 讓它變合理，★★★不是翻斷言」**｜★**這次是同一個梯子往上再爬一階**：上次要補的是【對那支隊的 claim】，**這次要補的是【那個商隊真的看過那座城】**｜★★另一格 `defer-open` 是我的（那條 defer 的解除條件被這次 merge 達成了）—— **已退役，不用你管**
---

# 一、紅的內容

```
[HEADLESS] ★FAIL：失敗【清單】與 baseline 不同（★數量一樣也會抵消，所以比的是清單）
  > 1 SCRIPT ERROR: Assertion failed: 應選有 outpost 的 Team1，實際={ }   ← headless_test.gd:11041
  > 1 SCRIPT ERROR: Assertion failed: 應選 Team1 outpost，實際={ }        ← headless_test.gd:11761
HARD-FAILS ＝ 3 ｜ baseline ＝ 3   ★★數量沒變，是【換了兩條】
```

# 二、★★★那個 fixture 自己留的話（`:11034-11037` 逐字）

```
★★★fixture 補 belief（god-view 真違規④修法之後）：候選母體從 team_discovered
  換成 BeliefSystem.known_targets ⇒ ★沒有 claim 的隊【不再是候選】
★★意圖確認：本測的意圖是【只選有 outpost 的】，不是【測沒有 belief 的情形】
⇒ 補 fixture 讓它變合理，★★★不是翻斷言
```
★**上一代剝掉的是「不用有 claim 也看得見」** ⇒ 當時補了 `record_claim`。
★★**這一代剝掉的是「不用看過那座城也知道它是誰的」** ⇒ **這次要補的是【tile 知識 ＋ 據點子記錄】。**
★★★**梯子沒變，只是又高了一階** —— **而那個 fixture 已經替我們寫好了判準。**

# 三、要你做的（照那條註解的精神）

```
兩處 fixture 各補一句：讓那個商隊【真的看過 (0,0) 那座城】
  ⇒ 即：state.team_tile_known[trader] 要有那個 tile，且帶 outpost 子記錄（owner=1）
  ★用正式的寫入路徑補（跟 record_claim 一樣走真的 API），★★不要直接手塞 Dictionary
★★★而請照上一代的做法，在旁邊留一句同樣形狀的註解：
   「這一代剝掉的是【不用看過那座城也知道它是誰的】⇒ 補【看過】，不是翻斷言」
   —— ★下一代還會有人站在這裡。
```
★**若你補完發現斷言【仍然】紅** ⇒ **那就不是 fixture 的問題，回報我**（★那會是類④：意圖被本票推翻，要 WHAT 點頭）。

# 四、另一格我已處理
`defer-open` ✗ 的是 `settle-scan-reads-live-outpost-after-tile-gate` ——
★**它的解除條件（三支都改讀 `known_outposts`）被這次 merge 達成了**（我核過三支各命中 2）⇒ **已退役。**
