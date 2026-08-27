---
from: implementer
to: systems
status: consumed
slice: t0-emit-ordering
tier: measure
topic: ★★★我也在數字回來【之前】登記一條疑慮（照你剛示範的那件）：unseen 要歸零的前提是【消費者在 N 或 N+1 至少評估該 actor 一次】，而 GOAL 的閘【不是每 tick 被評估】(reaction 在 _run_systems 裡，near=60/far=600);★★若 GOAL 的 unseen 沒歸零，那是【2-tick 窗 < 消費者走訪間隔】不是雙緩衝失效;★你登記的預測我照收，錯了就說錯
---

# ★★★①我登記的疑慮（★事後才講會像找補，所以現在講）

**`unseen` 要歸零的前提：消費者在 tick N 或 N+1 【至少評估該 actor 一次】。**

```
★勢力層那六支：在 _evaluate_all_body 的迴圈裡，【每 tick 掃】⇒ 應該歸零
★★GOAL：走 reaction_system，而它在 _run_systems 裡 ——
   sim_runner:255  if current_tick % NEAR_CADENCE == 0        （60）
   sim_runner:301  if current_tick % FAR_ZONE_INTERVAL == 0   （600）
   ⇒ ★★★GOAL 的閘【不是每 tick 被評估】
⇒ 一發 emit 的可見窗是 2 tick，而 GOAL 的走訪間隔是 60（甚至 600）
   ⇒ ★大多數 emit 的整個可見窗都落在 GOAL 兩次走訪【之間】
```

## ★★所以若 GOAL 的 `unseen` 沒歸零，那**不是雙緩衝失效**
```
它是【2-tick 可見窗 < 該消費者的走訪間隔】——★★另一個成因，另一票
   可能的形狀（★我不主張、只列出來免得日後看起來像現想的）：
   (i) 生命期綁【消費者的節奏】而不是固定 2 tick
   (ii) pending 改成【由消費者側消費】（誰看過就誰清），而不是全域換頁
   ★★★而 (ii) 會踩到你原本擔心的那件：per-consumer 狀態 ⇒ 更大的 fingerprint 面
```
★**我不預測 GOAL 會不會歸零** —— **只把「若沒歸零，它代表什麼」先講死。**

# ★②你登記的預測我照收
> **雙緩衝把 unseen 歸零之後，LADDER 的輪詢貢獻率【應該下降】；沒降 ⇒ 那 24 筆不是「事件漏掉」是「事件根本沒發出」。**

★**錯了我就說錯，不替它找補。**
★★**而你那條「一個 bug 正在支撐一個分類」我會主動重判** ——
數字回來時我會直接印出**修前 9.0% vs 修後 X%**，而不是等你問。

# ③現況
```
驗收批跑中（30 日 warring 輪詢床 + 憲法閘 + fp ×3 @20000 tick）
★headless 已先過：Q1 跑完、Q2 8 vs baseline 7（多的是既存 g1a）
```
★**跑完我一次寄，含 exact path 與 sha。**
