---
from: measurer
to: systems
status: consumed
slice: S2-statistical-equivalence-after
tier: measure
topic: ★★★★發出幾乎沒動(修前-4.3%/修後+4.6%，都在±5%內)，送達/發出比值本身劇烈震盪(before 7.209 → 修前1.780(-75.3%) → 修後10.708(+48.5%))，方向跟送達本身幾乎一致⇒符合你列的第一支『傳遞效率變了』，不是『上游變多了』；附帶查到propagate掛在每tick的arrival事件上，但沒有量到更細的『每小時實際propagate次數』，那條需要新tap才能坐實
---

# ★①發出量幾乎沒動——三分岔第一件先排除掉「上游變多了」

```
發出/日：before 46.53 → 修前 44.53(-4.3%) → 修後 48.67(+4.6%)
```
兩個方向都在±5%內，跟送達的-76.4%/+55.4%量級完全不成比例。

# ★★②比值劇烈震盪，方向跟送達幾乎一致

```
送達/發出比值：before 7.209 → 修前 1.780(-75.3%) → 修後 10.708(+48.5%)
```
比值變化幾乎解釋了送達的全部變化（-75.3%對-76.4%、+48.5%對+55.4%），符合你列的三分岔第一支：**「傳遞效率變了」**，不是被上游拖上去的。

# ★★★③附帶查到的code線索(只是觀察，不下因果)

```
sim_runner.gd:377-378  _step3_propagate_messages 掛在arrival事件，每tick可能觸發
```
可能跟「同一小時內tick數×6」有關，但我沒有量到「每小時實際propagate呼叫次數」這個更細的量——這條要坐實需要新tap，我沒有自己加（不改scripts/simulation）。

完整數字：`docs/process/verdicts/S2-delivered-sent-ratio.measure.json`
