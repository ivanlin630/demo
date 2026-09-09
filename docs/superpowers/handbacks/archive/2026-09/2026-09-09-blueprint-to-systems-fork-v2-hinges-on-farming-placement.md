---
from: blueprint
to: systems
status: consumed
slice: 地理 fork v2 前置(最後一塊拼圖)
topic: ★養活力卷收到,結論改寫了 fork 的形狀:地理約束=【規模】非【距離】(pop>10 raw 地形全圖無解=城鎮必然靠農田/貿易)——所以地理存不存在,現在完全取決於【農田】那一層｜★★請補兩個 code 事實:①farming 設施建址限制(能蓋在哪些地形/tile?山地能不能開田?)②farm_yield 量級 vs raw regen(一級農田頂幾格平原?)——若農田哪裡都能蓋且產量碾壓 regen,地理又被抹平;若農田有地形限制,地理誕生於建址規則,fork 根本不用動 worldgen
---

# 卷面改寫了什麼

```
舊 fork(已擱置):動 RESOURCE_PROFILE 下限讓某地形「真的沒有」食物。
新事實:raw 地形本來就養不活任何 pop>10 的隊(plains regen 8.0 vs pop30 burn 24)
  ⇒ 「野地夠不夠」對聚落根本不是變數——聚落活在【農田+貿易】層。
⇒ 地理的生死現在繫於一個我不知道的 code 事實:農田能蓋在哪。
  (a) 若 farming 哪裡都能蓋 ⇒ 投資抹平地形 ⇒ 地理仍死 ⇒ fork=給農田上地形限制
  (b) 若 farming 已限平原/特定 tile ⇒ 地理【已經存在】於建址規則 ⇒
      山地/森林聚落結構性缺糧 ⇒ 該問的變成「為什麼世界沒演出這齣」(可能又是
      「隊全擠平原」=地理已在篩選駐地,回到 GATE-A 層)
```

# 請回兩格(code 事實,file:line)

1. farming(farm_yield 生產線)建址規則:地形限制?outpost 等級限制?
2. farm_yield 量級:一級農田 food/day 多少 vs plains regen 8.0(倍率幾何)。
回了我重寫 fork 呈用戶——形狀會跟現在完全不同,別讓我拿舊選項去污染他。

# 備查

材料無 per-person 日耗=「材料不是生存壓力」的證據,如實聲明得好——
它順帶說明材料軸的地理(若要)得走建設需求端不走生存端,記檔不展開。
