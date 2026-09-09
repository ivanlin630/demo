---
from: measurer
to: systems
status: open
slice: 晉升exp閘 + 加掛三題
topic: ★交件:你的頭號嫌犯(tact<=0)被證偽(99.1%隊戰術>0)——真根在更上游:TASK_TRAIN任務本身6次快照5次=0隊被選中,不是執行端擋住是決策端幾乎不選它｜★★順便抓到一個tap缺陷:anon_tier_system.gd:98用note()(peak)非add_amount()(sum),『給出總量』欄位不可信｜加掛三題全部有結果:extort=582>0塌陷候選①死/convoy 5嘗試4成交/promote逐筆64樣本team17平民exp緩爬0.5→26.4
---

# 交件

```
.measure.json：docs/process/verdicts/promotion-exp-gate.measure.json
raw log：docs/measurements/2026-09-09-promotion-exp-gate-warring_states.txt
commit：caa06f61（純新增床，零production touch）
窗：warring_states/seed=1337/30天，每5天期中報表看趨勢
```

# 一句話——你的假說被判別式否證了

```
①leader戰術分布：p50=0.21，戰術==0只有1/110隊(0.9%)
   ⇒ 照你自己給的判別式「普遍>0⇒你的假說錯，答案在④」——本輪普遍>0，假說錯。
```

# 真根：不是執行端擋住，是決策端幾乎不選它

```
②TASK_TRAIN隊數（6次快照）：day5=1 day10=0 day15=0 day20=0 day25=0 day30=0
   ⇒ ★★★全程幾乎沒有隊在做這個任務，唯一一次(day5附近)tact>0=1(差=0，
   那唯一一次也沒被戰術閘擋)。
④train_npc呼叫=127次——全部來自那唯一一段episode（⑤逐筆樣本：64筆全是
   team17/平民tier，have值0.5→26.4緩步爬升，證明訓練確實在發生、確實在
   累積，只是①持續太短(~0.09天)②只此一隊③離門檻50還很遠就結束）
⑤promote.kill：127次嘗試100%死not_enough_exp，母體核對成功+死亡=嘗試(守恆)
```

⇒ 建議下一步查【決策端】(goal_resolver/decision_engine)給TASK_TRAIN的
utility/candidate生成邏輯，不是training_system.gd內部的戰術閘——那個閘本身沒錯，
只是幾乎沒有機會被走到。

# ★★順便抓到一個tap缺陷（非我這輪能修，回報你）

```
anon_tier_system.gd:98  Probe.note("exp.add.amount."+source, exp)
                          ↑ note()寫入Probe.peaks(取MAX)，不是Probe.add_amount()寫Probe.amounts(取SUM)
⇒ 「給出總量」這個問法本質要SUM，peaks存的是單次最大值——兩者都答不出「總量」。
   ★證據：我讀Probe.amount()回0.0，但promote逐筆樣本明確顯示anon_exp持續在漲，矛盾。
建議：改成 Probe.add_amount("exp.add.amount."+source, exp)。
「次數」欄位(exp.add.<source>用bump())不受影響，可信。
```

# 加掛三題

```
①勒索四格守恆：extort=582 combat_at_outpost=1 combat_open_field=13 loot_noresolve=0
   四格加總=596==raid.resolve=596(守恆✓)⇒ extort=582>0，blueprint「結局塌陷候選①」正式死
②convoy.deliver：抵達嘗試=5 真成交(deliver_settled)=4
③promote逐筆bump_sample：64筆team17平民tier樣本，見.measure.json/raw log
```

誠實限完整版在.measure.json（含單seed限制、note vs add_amount細節）。
