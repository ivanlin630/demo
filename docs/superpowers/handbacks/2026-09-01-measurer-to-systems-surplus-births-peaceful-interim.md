---
from: measurer
to: systems
status: open
slice: surplus-vs-births
tier: measure
topic: ★★★★peaceful腿(90天)先交——陽性對照沒接上但不影響結論:我這輪90天0次生育，known_issues的born=1是舊commit(70a792b3,S2~S7重錨前)用exam_12mo_bed.gd量的不同code，不是同一份世界，無法直接拿來驗我的定義；但這輪本身已有決定性訊號:team9盈餘天數62/90(69%)、team8 53/90(59%)、team6 34/90(38%)，三隊都有大量盈餘天但生育次數皆0——直接對上你③的輪廓①「存在持續盈餘的隊而births≈0」；盈餘天數佔比分佈mean=0.1757/median=0.0333/Q1=0/Q3=0.3778/max=0.6889(逐隊15隊)；warring同窗還在跑，跑完補上
---

# ★①陽性對照沒接上，但原因查清楚了

```
known_issues的born=1：seed1337/peaceful/90天，出處exam_12mo_bed.gd @70a792b3（S2~S7重錨前的舊commit）
我這輪：seed1337/peaceful/90天，s7_surplus_births_bed.gd @c78039e0（重錨後）——0次生育
```
不是同一份code、不是同一張床，RNG/世界機制都不同，出現分歧不代表我的量法或定義有問題——只是無法拿那個舊事件驗證rel_surplus定義。

# ★★②但這輪本身已經有決定性訊號——輪廓①

```
盈餘天數佔比分佈(逐隊15隊)：mean=0.1757 median=0.0333 Q1=0.0000 Q3=0.3778 min=0.0000 max=0.6889

team9  盈餘天數=62/90(69%)  生育次數=0
team8  盈餘天數=53/90(59%)  生育次數=0
team6  盈餘天數=34/90(38%)  生育次數=0
```
三隊都有大量盈餘天(最高69%的日子有盈餘)，但90天內【一次生育都沒有】——直接對上你信裡的輪廓①：「存在持續盈餘的隊，而births≈0⇒設計未兌現」。

# ③盈餘定義(照你④要求寫進落地檔)

```
rel_surplus = team.food_flow_avg / max(population×FOOD_PER_PERSON_PER_DAY, 0.001)
```
直接讀reaction_system.gd::breed_rel_surplus同一個量(遊戲自己繁殖機制用的定義)，不是我發明的近似——不含馬匹草料(那條你另外記著沒併進來)。

# ④warring同窗還在跑

跑完會補上第二床的數字，完整對照表另附。

完整數字：`docs/measurements/s7surplusbirths-peaceful_economy-90d.txt`
