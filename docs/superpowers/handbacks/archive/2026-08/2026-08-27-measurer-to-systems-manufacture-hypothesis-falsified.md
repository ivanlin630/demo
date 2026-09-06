---
from: measurer
to: systems
status: consumed
slice: outpost-arc-closure
tier: measure
topic: ★★★★★你的先驗被證偽——設施普查兩邊完全相同(manufacturing_level=3/apothecary_level=6/smelter=weaponsmith=armorsmith=0，一座都沒變)，但noop_no_facility確實漲了+20.1%(方向跟先驗一致)。普查證明【不是設施組合變了】，症狀跟先驗方向吻合是巧合，真正驅動noop_no_facility上升的是別的東西，我沒有查(職權外)
---

# ★①三桶：全部都在動，不是單一桶

```
fired            215→199   -7.4%（跟前一輪的-7.5%殘差同一訊號）
noop_no_facility 318→382   +20.1%
noop_no_material 265→211   -20.4%
```

# ★★②設施普查：完全相同——你的先驗被推翻

```
before: manufacturing_level=3座 apothecary_level=6座 smelter=weaponsmith=armorsmith=0座
after:  manufacturing_level=3座 apothecary_level=6座 smelter=weaponsmith=armorsmith=0座
```
一座都沒變。**「設施組合變了」這個機制假設不成立。**

# ★★★③而這正是你要防的那種陷阱的鏡像版

`noop_no_facility+20.1%`表面上方向跟你的先驗一致，但普查(比三桶更直接的量)戳穿了：**設施沒少，是別的東西讓「判定成無設施」的事件變多**。方向吻合不等於機制成立——這次抓到的是這個。

# ④沒查的部分

普查回答了「是不是設施組合變了」(不是)，沒有回答「那noop_no_facility為什麼漲」——那需要往哪查是下一輪的事，我沒有猜測誰共址、勞力池分配、tile_pos指派這些，職權外。

完整數字：`docs/process/verdicts/S2-manufacture-three-bucket-probe.measure.json`
床改動：`scripts/debug/qty_tap_bed.gd`(L3，讀既有Probe.counts+讀state.world.tiles，零新tap)
