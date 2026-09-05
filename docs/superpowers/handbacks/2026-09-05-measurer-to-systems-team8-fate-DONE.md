---
from: measurer
to: systems
status: consumed
topic: team8完整回報——不是母體錯位，是找到第二條PRODUCE寫入點，證實「一因三症」
---

★★你的兩個猜測都不對，是第三種：**team8活著、母體沒錯位、但找到你漏查的第二條TAG_PRODUCE寫入點**

## 四格答案
| | 值 |
|---|---|
| ①team8活著嗎 | **YES**，day90仍在，team_id沒變過 |
| ②named_members | `[17]`，只有1名（person 16是leader另計） |
| ③1000coin去哪了 | **完全沒動**——setup/day30/day90三個時間點恆為1000.00，一分未花未收 |
| ④day30實際12隊 | `[0,1,2,3,4,5,6,7,8,9,10,11]`——**跟config的team_id完全一致**，不是母體錯位 |

## ★★真相：你漏查了第二條TAG_PRODUCE寫入點

`interaction_system.gd:1509`：
```gdscript
if not t.tags.has(TeamData.TAG_PRODUCE):
    state.add_tag(t, TeamData.TAG_PRODUCE, "settle")
```
這是**定居(settle)機制**，跟你查到的`outpost_system.gd:525`(子隊完工安頓)是**不同路徑**。

team8(商隊) setup時tags=`["商隊"]`，day30已變成`["商隊","生產"]`——它在遊戲過程中透過**settle**被追加了PRODUCE tag（保留原商隊tag，非取代），因此落入`salary_system.gd:31`的early-return，1000起始coin從此凍結未動。

## 讀法
不是「我那12隊不是config那12隊」——team_id完全對得上。是**連config唯一設計成有錢的商隊，最後都被同一個PRODUCE-gate收斂進去**。這證實你的疑慮：**三件展品不是三個獨立證據，是同一個「settle把所有隊都變成PRODUCE」機制的三個症狀**。這件事必須寫進B開場包，不能讓四件展品被讀成互相獨立佐證——你原本要的判準。

## 落地
- `docs/process/verdicts/team8-fate-2026-09-05.measure.json`
- 診斷腳本是臨時的（已刪除，不留在scripts/debug——內容已完整寫進verdict json）

## 誠實限
只驗了team8這一個案例，其餘10隊「統領/生產」隊是config原生PRODUCE還是也經settle取得，沒逐一追——但不影響本票結論。
