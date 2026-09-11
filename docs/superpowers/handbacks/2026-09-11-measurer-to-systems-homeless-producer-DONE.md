---
from: measurer
to: systems
status: open
slice: 有生產身分而無自家據點的隊
topic: ★交件:母體>0且持續成長(day10=1→day60=19)非恆0——對應blueprint出口①(綠燈,驗收改到晚一點的時間點才驗)。壽命中位29天(不短,不是快速自建村的過渡態)，52.6%在貿易維生，food_days中位僅4.6天、21.1%接近餓——這批隊有明顯「需要求居」的訊號
---

# 交件

```
.measure.json：docs/process/verdicts/homeless-producer.measure.json
raw log：docs/measurements/2026-09-11-homeless-producer.txt
床：scripts/debug/homeless_producer_bed.gd
窗：warring_states/seed=1337/60天，5次快照(day10/20/30/45/60)
謂詞逐字：TAG_PRODUCE in team.tags 且 state.own_outpost_tile(team.team_id)==null
```

# 一句話——出口①成立，母體自然有只是晚

```
①出現率：day10=1隊 day20=2隊 day30=9隊 day45=17隊 day60=19隊——單調成長，全程無0
  ⇒ ★驗收窗要對齊：day10-20母體太小(1-2隊)不足以驗，day30起才有像樣母體(9隊+)
```

# ②壽命不短——不是快速過渡態

```
母體=20隊，跨度(天)：min=2.0 p50=29.0 max=52.0(右截尾，team65從day8撐到day60仍符合)
⇒ 中位數29天(近1個月)，不符合『它們很快就蓋了自己的村』的假設，
  比較符合『它們就是那批該去求居的人』(票面④的第二個出口讀法)
```

# ③怎麼活——經濟緊繃，有需要支援的訊號

```
day60(N=19)：task分布 貿易10(52.6%)/建設2/覓食1/逃跑1/等待新領主1/乞食1/紮營1/投靠1/迎戰1
food_days：min=0.0 p50=4.6 max=135.4，<3天(接近餓)=4隊(21.1%)
⇒ 過半在貿易維生、糧食普遍緊繃——這批隊展現明顯『需要支援』的訊號，
  是求居機制的天然潛在受益者，非悠閒過渡態。
```

誠實限完整版見.measure.json（含壽命是近似值/max右截尾等）。
