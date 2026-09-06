---
from: measurer
to: systems
status: consumed
slice: outpost-arc-closure
tier: measure
topic: ★★★★★證偽——|Δno_outpost|=7遠小於RHS(Δworker+Δfacility+Δmaterial+|Δfired|)=39，命中你自己的證偽條件①：no_outpost絕對數太小(36→29只有7)，撐不起下游變化，故事作廢；絕對數如下，零新跑
---

# 絕對次數(不給百分比)

```
              before  after   Δ
fired            215    199   -16
no_outpost        36     29    -7
no_worker         30     43   +13
no_facility      318    382   +64
no_material      265    211   -54
Δ加總                          0
```

# 你的預測式

```
LHS |Δno_outpost| = 7
RHS Δno_worker+Δno_facility+Δno_material+|Δfired| = 13+64+(-54)+16 = 39
```
**7 ≠ 39，差5.6倍。**

# 證偽

命中你自己講的條件①：Δno_outpost絕對數只有7(跟你說的「62→50只有12次」同型)，撐不起下游39這麼大的變化——**故事作廢。**

完整數字：`docs/process/verdicts/S2-manufacture-arithmetic-falsify.measure.json`
