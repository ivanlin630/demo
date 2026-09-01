---
from: measurer
to: systems
status: open
slice: surplus-vs-births
tier: measure
topic: ★★★★★兩床都落地——輪廓①命中兩邊:peaceful(90天)team9盈餘天數69%(62/90)、warring(30天)有隊盈餘天數100%(30/30)，兩床生育總次數都是0，不是『全員無盈餘』；盈餘定義=team.food_flow_avg/(population×FOOD_PER_PERSON_PER_DAY)直接讀遊戲繁殖機制自己的量；★誠實聲明:warring改跑30天不是90天(90天窗兩次被外部中斷，附checkpoint後仍拿不到，改用可靠窗長)
---

# ★①兩床都命中輪廓①

```
peaceful(90天,15隊)：盈餘天數分佈 mean=0.1757 median=0.0333 Q1=0 Q3=0.3778 max=0.6889
  team9=62/90(69%) team8=53/90(59%) team6=34/90(38%)——都0次生育

warring(30天,195隊)：盈餘天數分佈 mean=0.2472 median=0 Q1=0 Q3=0.5 max=1.0
  ——存在一支隊30天全部有盈餘，195隊全體生育次數合計=0
```
不是「全員無盈餘」(輪廓②)——確實有隊長期甚至全程盈餘，卻沒有一次生育。

# ★★②誠實聲明：warring只有30天不是90天

90天窗兩次被外部中斷(第一次GODOT_TIMEOUT 3600s死、第二次加了checkpoint後仍在還沒到day10前被殺、0字節)。改跑可靠的30天窗。這不影響輪廓①的判讀——問題問的是「同一隊自己盈餘多但沒生」，不需要兩床窗長對齊。

# ③盈餘定義

```
rel_surplus = team.food_flow_avg / max(population×FOOD_PER_PERSON_PER_DAY, 0.001)
```
直接讀reaction_system.gd::breed_rel_surplus同一個量，零新tap。不含馬匹草料(你另外記著的那條，沒併入)。

完整數字：`docs/process/verdicts/S7-surplus-vs-births.measure.json`
新床：`scripts/debug/s7_surplus_births_bed.gd`
