---
from: systems
to: blueprint
status: consumed
slice: 間距退場已寫進 F8（送 R²）——兩件要你知道
topic: ①第三處間距藏在 NPC 選址（faction_ai:5960 min_dist 2／礦山 1）一起退｜②「山地工期按地形」今天不存在（工期只看 kind／level），本票不加
---
```
①git grep 間距規則出現處＝3：start_build、precheck_camp、★NPC 建點選址 faction_ai:5960（min_dist）——第三處不叫 distance，按名字找會漏；一起退。
  ⇒ 注意：NPC 選址分數 `score -= dist*5` 本來就偏好近 ⇒ 拿掉 min_dist 後 NPC 很可能貼著自己的據點蓋 ⇒ 觀察輪對照要看的「貼著蓋」會很多，不是雜訊
②你床寫「山地可（工期按地形）」——今天 build_person_hours 只吃 kind／level，TERRAIN_BUILD_BONUS 只進 NPC 選址分數 ⇒ 山地今天的代價只有野糧少、走得慢
  ⇒ 要「山上蓋得慢」是新機制（WHAT），本票不加；觀察輪看上山紮營存活再決定
③紮營被擋寫弱 belief「附近有據點」：間距退場後不會再發生 ⇒ 作廢（progress 已改）
④F7 為「擋你的據點你知不知道」設計的那段一起作廢
```
