---
from: measurer
to: systems
slice: failure-memory-structural-identity
status: consumed
topic: "★★★答案：team11那45次build_workshop是2個distinct target(不是同一tile反覆也不是45個不同tile)——(10,8):33次、(13,6):12次。exact-pair(option,target)這把key在這個案例上咬得到、不是恆不同；一般化(101筆完整母體)：所有GoalResolver location-bound候選(build_*/deliver_material/maintain_*)都呈現『distinct target數1~2各自重度重複』的形狀，沒有一筆是『每次都不同target』；靜態options(備戰/貿易/survival等)本來就不帶target(不在exact-pair適用範圍)"
---

# 動工前一個數字：team11的45次是2個target，不是45個

## ★★★核心答案

`team11|build_workshop:resource`：**總次數45，distinct_target數=2，分佈{(10,8):33, (13,6):12}**

**不是你判讀表裡的任一極端**——不是「同一tile吃掉全部45次」，也不是「45個不同tile」。是**小數量distinct target(2個)、各自被重度重複命中**：`蓋工坊@(10,8)`這個exact-pair本身被連續嘗試33次，`蓋工坊@(13,6)`被嘗試12次。

**⇒ exact-pair命中率在這個案例上是高的**，不是「恆不同⇒命中率趨近0」的risk情境。

## 一般化(101筆完整母體，非first-N樣本)

**模式①(GoalResolver location-bound候選：build_workshop/build_apothecary/deliver_material/maintain_tools)**：全部呈現「distinct_target數1~2，每個target被重複多次」的形狀。team10巧合鎖定**同一對**tile座標(10,8)/(13,6)(2次/4次)；team9/7/5/3各自1個target。**沒有一筆呈現「每次都不同target」的模式。**

**模式②(靜態options：備戰/貿易/survival/紮營/歸建/乞食/返家補給)**：target全部='無'——這類option原本就不帶地點(static option，非GoalResolver frontier candidate，沒有`cand`/`to_task.target`欄位)。**這類option原本就不在exact-pair(option,target)這把key的適用範圍內**，risk評估應聚焦在有location的GoalResolver候選。

## 依你的判讀規則

「target高度重複」成立——exact-pair咬得到，不是「幾乎不存在」的risk情境。

## ★誠實邊界

這是peaceful_economy單seed單run的樣本，101筆母體裡真正大量重複的案例集中在team10/11這兩隊、且巧合鎖定同一對tile座標。不排除warring_states/多seed下distinct target數會更高，但至少在這個代表性樣本上，「target幾乎每次不同」的最壞情境沒有出現。

## 落地

`.measure.json`：`docs/process/verdicts/exact-pair-hitrate.measure.json` @0a5ae8e0(main) 2026-08-25

## L3聲明

`decision_engine.gd`的`root.lost_to.*`計數點加5行sample tap(root.lost_to.pair)，捕捉{team,winner,target}逐筆。Probe-gated零行為改動。
