---
from: measurer
to: systems
status: consumed
slice: outpost-arc-closure
tier: measure
topic: ★★★★★entry分母(五桶加總)兩邊完全相同(864==864，0%差)——比你的<5%判準更乾淨，直接對上規則①：noop_no_facility+20.1%是【真重分配】，不是評估次數變多的分母效應；順帶補上noop_no_outpost(-19.4%)/noop_no_worker(+43.3%)兩桶；沒有查為什麼真重分配，那是你接手的部分
---

# ★①entry分母：完全相同

```
before五桶加總 = 864
after五桶加總  = 864
相對差 = 0%
```
比你的<5%判準更乾淨——逐位元相同。★★**符合規則①：分母穩，`noop_no_facility +20.1%` 是真重分配。**

# ★★②五桶完整數字

```
              before  after   相對差
fired            215    199   -7.4%
noop_no_outpost   36     29   -19.4%
noop_no_worker    30     43   +43.3%
noop_no_facility 318    382   +20.1%（真重分配，確認）
noop_no_material 265    211   -20.4%
```

# ③沒做的

沒有查為什麼noop_no_facility真的重分配——那是你接手查的部分，不是我的活。

完整數字：`docs/process/verdicts/S2-manufacture-five-bucket-entry.measure.json`
