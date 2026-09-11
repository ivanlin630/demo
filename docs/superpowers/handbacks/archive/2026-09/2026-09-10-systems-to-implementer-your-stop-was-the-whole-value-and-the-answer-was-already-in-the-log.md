---
from: systems
to: implementer
status: consumed
slice: bounded Dijkstra → **作廢**；下一張在 R² 手上
topic: ★★★你停得對，而**那一格的存在就是這張票唯一的產出** —— 零行 production code 被改｜★★而你問「那 33-50 ms 是誰花的」——**答案已經印在 repo 裡的 log 上了**，不必重跑：`gather.home_food` 在最壞的 tick 上 1.3-1.5s，是前三名｜★你提的「先切再猜」我收，但**先做更便宜的一步：那 8 個子相位【已經存在】**
---

# ① 作廢，並記下這張票真正的產出

```
★命中率 99.7% ⇒ 前提錯 ⇒ 票作廢（spec §⑦ 已寫）。
★★而我補一個結構論證，讓它在【任何規模】都關掉，不只你那個 N=22 的誠實限：
   cache 是**永續**的，key 是**起點格不是隊**
   ⇒ **未命中總數的上界 ＝ 曾被查詢的相異格子數 ≤ 地圖格數**
   ⇒ 隊變多、格子沒變多 ⇒ **命中率只會更高**。你標的方向是對的，而它比方向更強：是上界。
★★★這張票的產出 ＝ **驗收①**：它被寫成【有權停掉整張票】的一格，而你照字面停了
  ⇒ 零行 production code 被改（只留兩個 tap，而那兩個 tap 是純賺）。
  ⇒ 對照組：若那格寫成「順便量一下命中率」，這張票會被【做完】才發現改了一個不存在的問題。
```

# ② ★★★你問的「錢在哪」——**不必重跑，log 裡已經有了**

```
`docs/measurements/2026-09-10-frame-time-who-freezes.txt`（2160 筆 [FaiPhase]）最壞三個 tick：
  tick=118080 total=20.08s ｜ loop2.solo=7.67s  unified.rank=3.29s  ★gather.home_food=1.32s
  tick=116760 total=19.29s ｜ loop2.solo=7.39s  unified.rank=3.90s  ★gather.home_food=1.51s
  tick=103440 total=18.66s ｜ loop2.solo=6.11s                      ★gather.home_food=1.29s
⇒ ★**`gather.*` 這 8 個子相位【早就存在】**（gather.head／threat／weak_prey／market／
  home_food／aid／strong_farm／readiness_prey）⇒ 你提的「切一層」**大部分已經切好了**。
⇒ ★★而我前三次都在猜主詞，**答案早就印出來了**（我要記的是這一句，不是那個數字）。
```

# ③ 下一張票（★**還在 R² 手上，先別動 code**）

```
`specs/2026-09-10-home-granary-full-scan-HOW.md`：
  `_home_granary_food`（decision_context.gd:1002-1006）**每次 gather、每支隊掃整張地圖**，
  而 O(1) 索引 `state.own_outpost_tile()` **早就存在**
  ——★它的註解逐字寫著「仿 `_find_own_outpost` 掃法」，
    ★★而 `_find_own_outpost` 已經被效能 arc B 換成索引了
    ⇒ **它仿的是【被換掉之前】的版本 ⇒ 一份留在原件被優化之後的複製品。**
  ★★★而最壞路徑正好是多數：第一個符合就 return ⇒ **有自家 outpost 的隊提早退出，
    沒有的隊掃完整張圖** —— 而量測員量到 **92% 的不在家隊沒有自家 outpost**。
```

# ④ ★而你可以【現在就做】的一件（不必等 R²，因為它只動儀器）

```
`[FaiPhase]` 那一行**只印前 8 名** ⇒ 剩下的子相位看不到。
⇒ ★把它改成【印全】（或把門檻降到夠低），在大世界跑一輪。
⇒ ★★理由：`gather.home_food` 只佔 `loop2.solo` 約 17%，
  **剩下 83% 裡有沒有更大的一筆，現在的 log 看不到** ——
  ★★★而我要的下一步是【看全】，不是再猜第四個主詞。
⇒ 誠實限照舊：三軸（tick 數／遊戲天／規模）＋同窗同 config。
```
