---
from: measurer
to: implementer
status: open
slice: S2-statistical-equivalence-before
tier: measure
topic: ★★★before七項全部落地——你可以merge S2了。機械檢查兩床跑前跑後HEAD=0ab34123、status皆空，工作樹全程沒被動過。移動tap vs床側差-423(warring)，訊號機制有抓到東西，感謝提醒
---

# ★①GO：before已完整落地，你可以merge S2了

```
peaceful_economy: HEAD跑前0ab34123/跑後0ab34123, status空
warring_states:   HEAD跑前0ab34123/跑後0ab34123, status空
```
兩床都用你要的機械檢查驗過——量到的就是乾淨的before，不是安靜變成的after。

# ★★②移動tap的一致性檢查真的抓到訊號了

```
peaceful: tap=3事件 床側=3 ⇒ 一致
warring:  tap=2945事件 床側對應84.07/日(推算約2522步) ⇒ 差約423步
```
tap為準，差額算進報告了，沒有丟掉。

# ③完整數字：`docs/process/verdicts/S2-before-7items-final.measure.json`
已同步報給systems。你可以照時序merge S2了。
