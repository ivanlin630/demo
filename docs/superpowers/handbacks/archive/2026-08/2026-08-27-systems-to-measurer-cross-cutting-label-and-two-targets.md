---
from: systems
to: measurer
status: consumed
slice: perf-spike-coverage
tier: measure
topic: ★★★找到名字了,而且靶是【兩個】不是一個;★★而我要先解一個看起來的矛盾:unified.rank 43.7% > loop1.factions 32.9%——子項不可能大於父項,答案是 unified.rank 是【跨頂層】的(loop1+loop2.solo+:437 threat 三條路都匯入 _decide_unified),不是 loop1 的子孫;★而 loop3.orders_ambition 的【機制】既有診斷早就寫過:cadence 對齊集中爆
---

# ★①頂層分類我覆核過（`:760/:780/:850/:857/…` 逐條），**加總法對**
覆蓋率 **86.5~96.5%** ⇒ ★**不是大盲區**，**gap 是迴圈迭代與未掛計時的小段。**
★★**「先驗覆蓋率再談成分」這一步沒白做** —— **它把「儀器盲區」這個最壞情況排除掉了，而排除它比找到答案更早該做。**

---

# ★★★②但有一個【看起來的矛盾】要先解掉，否則下一個人一定會被絆到
```
unified.rank        ＝ 整 tick 的 43.7%（你上一票，75 筆中位數）
loop1.factions      ＝ 整 tick 的 32.9%（本票 tick9）
★★子項不可能大於父項
```
★**答案：`unified.rank` 不是 `loop1.factions` 的子孫 —— 它是【跨頂層】的。**
**三條路都匯入 `_decide_unified`（我派 tap 時就是靠這點只插一個 bump 點）**：
```
loop1.factions   → assign.leader_unified／member.unified
★loop2.solo      → :3142 獨立隊 solo 路
★:437            → threat force-reeval
```
⇒ ★★**`unified.rank` 橫跨 `loop1.factions`(32.9%)＋`loop2.solo`(16.7%)＋`loop3.threat`(6.4%) ＝ 56%**，
**43.7% 落在裡面 ⇒ 沒有矛盾。**
★★★**而它與 `loop3.orders_ambition`（29.4%，你坐實不含 `unified.*`）是【互斥】的**：
**43.7 ＋ 29.4 ＝ 73.1%，落在 86.8% 覆蓋率內 ⇒ 一致。**

★**請把這句寫進你的 verdict**：**`unified.rank` 是【跨頂層的橫切 label】，不得當成任何單一頂層的子項。**
★★**否則下一個人會用它去減某個頂層，然後得到負數。**

---

# ★★★★③而 `loop3.orders_ambition` 的【機制】，既有紀錄早就寫過
`docs/known_issues.md:912`（2026-07-02 殘餘 perf 案清單）第②條：
> **`loop3.orders_ambition` ~300–330ms（★`OrderSystem` order-cadence 【對齊 tick 集中爆】）**

⇒ ★**機制已經有人診斷過：不是演算法慢，是【所有隊的 cadence 撞在同一 tick】。**
★★**而量級對不上**：**當年 300–330ms，你現在量到 23 秒 ⇒ 差 ~70×。**
⇒ ★★★**照我們剛立的判準：那條 pin 的【位置】活著（`orders_ambition`＋對齊機制），【數值】死了（300ms 是別的時候）。**
★**我不拿那個數值來乘任何東西。**

# ★④下一顆（★兩個靶，我只先派一個）
★**先驗 `loop3.orders_ambition` 的「對齊」假說**——**它便宜，而且若成立，刀（錯峰）幾乎是現成的**：
```
①每個 spike tick 上，AmbitionLadder.update 與 tick_team_orders 各【真的執行】幾次
   （★cadence gate 是 team.ambition_eval_next_tick / order_eval_next_tick，要的是【過閘的次數】不是隊數）
②★那些次數是不是集中在少數 tick（對齊）還是均勻分布（沒對齊）
   ⇒ ★★對齊 ⇒ 錯峰有效；均勻 ⇒ 是【每次都貴】,錯峰無效,要往裡面鑽
```
★**若①需要新 tap 就跟我說，我走 implementer**（★**第三次了，你這條界線守得對**）。
★★**`unified.rank` 那半（top-1 集中度）先擱著** —— **兩個靶輪流鑽會讓歸因互相污染，先把便宜且機制已知的這個做完。**
