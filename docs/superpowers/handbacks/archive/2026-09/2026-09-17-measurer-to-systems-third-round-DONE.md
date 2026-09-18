---
from: measurer
to: systems
status: consumed
slice: 絕境卷第三輪 ｜ 交件
topic: ★母體=22(本輪自己的數，不湊18/28)｜★★★blueprint的GATE岔路：6筆in-candidate裡0筆person低/0筆odds低，全部6筆take<0.1——你的判準表落在「take低=修在估值輸入」那格，不是「person=GATE違憲」那格｜★★不在候選集16筆四道門：③reachable=false最大宗(10筆)④pop_est不夠弱5筆①不在discovered1筆②has_belief=0筆，1+0+10+5=16無差額｜★通道三布林：in-candidate(50/100/100%) vs not(43.75/93.75/100%)——比例相近，blueprint的讀法落在【不成立】那支
---

# 母體(本輪自己的，不與18/28混算)

```
seed1337=7｜seed2024=4｜seed777=11｜合計=22
在候選集(raid_factors_captured=true)=6｜不在候選集=16
```

# ★★★ASK的答案：6筆take/need/odds/person，對照你事前寫死的表

```
seed1337 team53 day4： take=0.042 need=0.197 odds=1     person=0.458
seed777  team24 day3： take=0.042 need=0.241 odds=0.833 person=0.408
seed777  team24 day4： take=0     need=0.19  odds=0.833 person=0.408
seed777  team48 day9： take=0.019 need=0.248 odds=0.667 person=0.5
seed777  team73 day9： take=0.077 need=0.368 odds=1     person=0.377
seed777  team48 day10：take=0.001 need=0.581 odds=0.667 person=0.5
```
對照表：**6筆全部take<0.1**（目標太窮/情報太薄）｜**0筆odds<0.3**｜**0筆person<0.3**。

⇒ **blueprint預註冊的「輸在person絕境仍壓=人格變成GATE=違憲」那條岔路，這6筆裡0筆支持。**
落在你表裡的「take低⇒修在估值輸入」那格，不是「person低⇒GATE證據」那格。

# 補①：16筆不在候選集的原因分佈(四格相加=16，無差額)

```
①不在team_discovered：1筆
②has_belief=false：0筆
③reachable=false：10筆——最大宗
④pop_est≥0.7×我方：5筆
1+0+10+5=16 ✓
```

# 補②：blueprint可證偽讀法——通道三布林(逐筆算，非估算)

```
在候選集(6筆)：有政權可徵50%｜有幣可買且市場可達100%｜市場可達100%
不在候選集(16筆)：有政權可徵43.75%｜有幣可買且市場可達93.75%｜市場可達100%
```
兩群比例相近(50 vs 43.75、100 vs 93.75、100 vs 100)，不是鮮明對比。
照blueprint自己寫的判準：這格落在【讀法不成立】那一支——有沒有通道看起來不是分界線。

# 過程中抓到並修好一個bug(已另信報過)

`raid.factors`的Probe全局cap=200早在day1爆滿，first-N收不到我要的樣本，
修法只清那一個key，population數字v3→v4逐字不變，證明零gameplay影響。

# 卷已更新

`docs/process/verdicts/desperation-violence-cell.measure.json` §⑤。不下WHAT/HOW結論，不調參數。
