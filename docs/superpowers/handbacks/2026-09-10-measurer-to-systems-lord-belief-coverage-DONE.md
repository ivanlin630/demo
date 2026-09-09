---
from: measurer
to: systems
status: consumed
slice: 領主對自家居民的belief覆蓋率
topic: ★交件:問題問錯層——不是覆蓋率高低,是【自家居民】這個群體本身60天窗5次快照(day10-60,領主9→13隊)母體恆為0-1,「100%覆蓋率」是n=1的假象;真正的縫是幾乎沒有居民存在,不是belief接不到——跟人口卷「隊數成長靠派子隊非定居生產」同源印證
---

# 交件

```
.measure.json：docs/process/verdicts/lord-belief-coverage.measure.json
raw log：docs/measurements/2026-09-09-lord-belief-coverage-warring_states.txt
床：scripts/debug/lord_belief_coverage_bed.gd（commit 41d74313）
窗：warring_states/seed=1337/60天，5次快照(day10/20/30/45/60)
```

# ★★★真正的答案：母體本身近乎空

```
day10 領主=9隊 配對=1(faction3/Team12) 覆蓋率100%(n=1)
day20 領主=9隊 配對=0 ★母體=0不可判
day30 領主=10隊 配對=1(faction3/Team12,同一個) 覆蓋率100%(n=1)
day45 領主=11隊 配對=1(faction1/Team5,換人了) 覆蓋率100%(n=1)
day60 領主=13隊 配對=1(faction1/Team5,同上次) 覆蓋率100%(n=1)
```

⇒ 13個faction裡，任何時刻最多只有1個真的有『自家居民』，其餘12個恆為0。
你要的『覆蓋率100%』數字技術上沒錯，但n=1不能當答案——這正是你自己定的
紀律『top-1>50%⇒不得單獨當趨勢用』的極端版：分母本身=1。

# 問題問錯層

```
原問法：belief覆蓋率高不高、低覆蓋是缺產生路徑還是TTL過兇
本卷答案：問題不在belief，是【居民(is_resident_static)這個群體幾乎不存在】——
  ★與人口卷([population-census-90d])既有發現同源印證：隊數成長(49→137)
  主要靠[Sub]派子隊，不是定居生產。這個warring_states世界的隊絕大多數在
  移動作戰，極少真正『定居當居民』。
```

# 對relief機制的意涵

```
goal_resolver.gd:328 DISTRIB_RELIEF_REF_POP=5.0『領主賑濟自家居民』機制，
在這個世界配置下幾乎沒有母體可套用——不是belief接不到，是幾乎沒有居民
存在讓belief可以接。若blueprint要『relief隨belief規模變』有意義，前提
是世界要有穩定定居居民族群，本卷顯示這個前提目前不成立。
```

誠實限完整版見.measure.json（含母體太小答不出原問題的「缺產生路徑vs TTL」子問題）。
