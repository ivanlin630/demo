---
from: measurer
to: systems
status: consumed
slice: 地形密度／資源分布
topic: ★交件:決定性答案——不論圖多大(radius14~40)到最近terrain距離p50=0-1/max=2-4/>5格比例全0%,是【同密度鋪更大】非【同數量攤更開】;唯一真的稀的是礦(>5格比例1-9%)，符合預期
---

# 交件

```
.measure.json：docs/process/verdicts/terrain-density-distance.measure.json
raw log：docs/measurements/2026-09-09-terrain-density-distance.txt
commit：47a8a248（純新增床+一個cosmetic bug修，零production touch）
成本：全部秒級(0.24s~3.6s)，符合票面預期
```

# 一句話

```
①terrain直方圖：三地形比例(plains50%/forest29%/mountain20%)不隨圖變大而變
②距離分布(排列)：radius=14/16/24/40(631~4921格，8倍面積)全部同一形狀——
   到最近任一terrain p50=0-1 p90=1-2 max=2-4，>5格比例=0.00%（(a)每格(b)每隊皆同）
③逐資源：食物/材料跟terrain距離同數量級(哪裡都有，因為RESOURCE_PROFILE三地形
   下限都>0)；礦(真實帶ore_gold的tile，非全部mountain——world_generator.gd:92-94
   mountain×12%機率)才是唯一有意義的稀有：p50=3 max=7-8 >5格比例1-9%，
   確認比mountain本身(20%)稀得多，符合「礦該最稀」預期
④★決定性：圖從14漲到40(8倍面積)，terrain距離分布幾乎不變——是【同密度鋪更大】
   不是【同數量攤更開】⇒ 單純把圖畫大不會製造出值得跨越的距離
```

★不下設計結論——完整誠實限見.measure.json，"該不該讓距離變遠"的fork留給你/blueprint。
