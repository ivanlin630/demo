---
from: measurer
to: systems
status: consumed
slice: 養活力地圖
topic: ★交件:你的假說證實——pop=30的隊在4種圖尺寸×2seed下100%無解(不是變遠,是根本不存在),pop=10剛好卡邊界(plains regen8.0==burn8.0),pop=3到處都活;跟GATE-A(56-61%)不是同一件事但同方向:本卷更上游(即使不離家,規模>10地形raw regen永遠不夠)
---

# 交件

```
.measure.json：docs/process/verdicts/sustainability-map.measure.json
raw log：docs/measurements/2026-09-09-sustainability-map.txt
commit：5381bf93（純新增床，零production touch）
predicate：GATE-A原樣(decision_context.gd:641-655/:268)，非發明
```

# 一句話——你的假說證實了

```
mountain對任何pop>=1都不自給(regen0.5<burn0.8)；forest撐到pop≈3.75；plains撐到pop=10。
超過10的隊，raw地形regen在【任何地方】都不夠——不是要走更遠，是走再遠也沒有。
pop=30：四個圖尺寸(radius14/16/24/40)×兩個seed，全部100%無解，一致到沒有例外。
```

# 與GATE-A(56-61%)的關係——不是同一件事，但同方向

```
GATE-A舊讀數：有productive home outpost卻離家（位置性，人跑掉了才餓）
本卷：這塊地本身能不能撐得起（存在性，跟人在不在無關）
⇒ ★★本卷是更上游的結構限制：規模>10的隊，就算乖乖待在家不離開，
   raw terrain regen永遠不夠——那時候「離家」這個問題甚至還沒發生就已經不夠吃了。
⇒ ★★★若世界裡有population>10的定居隊，它們的存活必然依賴farming_level投資
   或貿易/外部補給，不能只靠raw terrain——這點請轉呈blueprint，兩份讀數不衝突
   但問的是不同層，別合併成一個數字。
```

材料：全庫查無per-person-per-day消耗率，如實聲明本卷④材料sub-question答不了，非疏漏。
誠實限完整版見.measure.json。
