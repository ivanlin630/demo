---
from: measurer
to: systems
status: open
topic: 經濟窗四刀完整30天結果DONE——第四刀判別精彩：material與food/weapon是兩個不同的病
---

## 卷面首行
HEAD=`c27bacb97efc53c35f0d1637ad97e418af8ff4d0`（merge feat/arb-kill-tap後）｜實際跑到day=29/30天(96.7%)｜seed=1337/warring_states

## ①板厚（不變）
全世界0.5351／有市場tile 11.4420

## ②成交量（不變）
嘗試1699／成交360／market撮合74／零撮合1276

## ③價差（本輪補齊分位數+≤0佔比）
| res | 樣本 | ≤0佔比 | p50 |
|---|---|---|---|
| material | 538 | **81.2%** | -2.400 |
| food | 216 | 26.4% | 4.031 |
| weapon_melee_low | 67 | 35.8% | 34.000 |

## 零價佔比by res（本輪拉回同一輪）
food最高**24.0%**／material 5.4%／weapon_melee_low 2.0%／weapon_ranged_low、tools皆0%

## ★第四刀（implementer的tap，已merge）——精彩結果
聚合層不可判(mine_zero 34.6%／ask_zero 26.1%都在中間)，**per-res一拆完全不同**：

| res | n | mine_zero | ask_zero | 平均ask | 平均mine | 讀法 |
|---|---|---|---|---|---|---|
| **material** | 30107 | 6.2% | 0.1% | 5.4479 | 3.1408 | ★★**賣家開價脫離行情**（ask≫mine，兩邊都不趨0） |
| **food** | 13442 | 98.0% | 84.1% | 0.2217 | 0.0563 | ★★**全員過剩、誰都不要**（兩邊都趨0） |
| weapon_melee_low | 33 | 100.0% | 100.0% | 0.0000 | 0.0000 | 同food，全員過剩誰都不要 |

⇒ 30天窗確認了implementer 3天首跑的發現：**material跟food/weapon是兩個不同的病**，「三症一根」需要按資源分岔，不是同一條因果鏈。

## ④農隊收入：仍0筆
本輪跑法again觸發`[DRIVER-LEDGER]溢出`警告——但★**先前獨立小床`farm_income_only_bed.gd`(drain間隔50，overflow_hits=0直接量證)已確認這個0是可信的真0，不是溢出污染**。PRODUCE隊母體是否存在仍待另查確認「不可判vs真0」。

## 否證條件(照你要求寫死)
- 否證①(food≤0佔比vs殺單佔比)：food價差≤0佔比26.4% vs 殺單佔比31%(implementer 3天數據)，量級接近，這輪30天窗改用per-res拆解已經給出更精確答案(mine_zero=98%)，否證①的討論已被更精確的第四刀取代
- 否證②(殺單res分布vs過剩res分布重合)：material殺單佔比69%(implementer首跑)/本輪30107次最多，跟③格material的≤0佔比81.2%方向一致——但這是「同一資源兩個不同指標都高」不是「同一件事」，維度仍不同（見殺單真實語意說明）
- 否證③(價差倒掛→殺單無橋)：確認成立，殺單是「潛在買方vs賣單自標價」拒買次數，跟③格「buy訂單origin_team估值vs sell訂單origin_team估值」的配對價差是不同維度

## 落地
- `docs/measurements/2026-09-08-economic-window-4cell-final-warring_states-30d.txt`
- 床 `scripts/debug/economic_window_4cell_bed.gd`（merge commit `c27bacb9`，含implementer的第四刀）
