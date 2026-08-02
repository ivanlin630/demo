---
from: implementer
to: systems
status: consumed
topic: "[done·Team3 賣方 dump·★GATE-B 真 gap=(a)decision:賣方無 deliver option] feat/peaceful-economy-bed e6a9d31b。Team3(material=400 surplus,sell×335)applicable 只 6 static(求和 0.4069 WIN/備戰/覓食/駐守/建設/survival)——★無「賣/去市場/deliver」option、無 goal candidate。全 run:ever_TASK_TRADE=false、ever_moved=false、material 400→350(50 自身 stable 耗非賣)、tile granary material=0(sell 單從不 deposit)。∴(a)decision gap:賣方決策菜單根本沒 deliver option→post 被動 order 後留家→material 物理從不離賣方→買方 order 永不 fulfilled。非(b)spatial(連 decide/move 都沒到)。dump 落地 docs/measurements/2026-07-31-peaceful-econ-bed-seller-delivery-e6a9d31b.txt。純觀測零 sim 改。"
branch: feat/peaceful-economy-bed
commit: e6a9d31b
base: 613d763d (local main HEAD)
measurement: docs/measurements/2026-07-31-peaceful-econ-bed-seller-delivery-e6a9d31b.txt
---

# done：Team3 賣方 per-option util + delivery 行為（★GATE-B 真 gap=(a) decision）

照做 measure-first。per-option util dump 擴 Team3（賣方）+ 全 run delivery 追蹤。純觀測零 sim 改零 RNG。

## ★真數（Team3 賣方，material=400 surplus，已掛 sell material×335）
per-option util 全排序（tick 500，material=350 pos=(8,10)）：
```
[static] u=+0.4069  求和   <=WIN
[static] u=+0.3537  備戰
[static] u=+0.3250  覓食
[static] u=+0.2461  駐守
[static] u=+0.1285  建設
[static] u=+0.1250  survival
```
tick 3600/7200 同型（求和 WIN，u 0.36/0.34）。★**applicable 菜單只 6 個 static，無「賣 material／去市場賣／deliver surplus」option、無 goal candidate。**

**全 run delivery 追蹤**：
```
起 pos=(8,10) 終 pos=(8,10)  ever_moved=false
ever_TASK_TRADE=false
material 起=400 終=350 最低=350   (掉 50 = 自身 stable 升級耗，非賣掉)
Team3 tile public_storage material=0   (sell 單 material 從不 deposit 到市場 granary)
```

## ★答（二選一，事實層；不下 fix 結論）
**= (a) 賣方不 decide sell-trip（decision gap）**，且更上游：**賣方決策菜單根本沒有「去賣/deliver surplus」option**。
- Team3 winner 恆 = 求和（外交），applicable set 6 個都非 sell-delivery。
- 賣方 **post 被動 sell order**（order book 掛單）**後就留家不動**（ever_moved=false / ever_TASK_TRADE=false）→ material **物理從不離賣方 inventory**（400→350 只被自身升級耗）→ 從不 deposit 到任何市場 granary（tile public_storage material=0）→ 買方（T0 決策要買、post buy order）搆不到任何 material → **order 永不 fulfilled**。
- **非 (b) spatial**：賣方連「decide 去賣 / 移動」都沒發生，談不上「空間到不了買方市場」。gap 在賣方決策層**缺 deliver option**，比 spatial 更上游。

## 診斷鏈收斂（三份 dump 串起 GATE-B）
1. trade-bail dump：order_placed=1833→seek_market=5→fulfilled=0（互動極低）。
2. 買方 dump：T0 economy 決策**贏 argmax**（build_workshop:resource 1.3953）→走 TASK_TRADE 買 material，決策側正常。
3. **賣方 dump（本份）**：Team3 決策菜單**無 deliver option**→surplus 永留家→買方搆不到。
∴ GATE-B 撮合 0 fulfilled 的**主根 = 賣方缺「physically deliver surplus 到交易點」的決策/機制**（買方要買、賣方有貨、但貨不會動）。

## 交付
- dump 落地 `docs/measurements/2026-07-31-peaceful-econ-bed-seller-delivery-e6a9d31b.txt`（已驗存在；T0+Team3 per-option util ×3 tick + Team3 全 run delivery 追蹤 + order log + 逐隊月故事）。
- bed exit0；observability/constitution 不受影響（bed 純觀測、無 marker、seed() 僅 runner 世界設置）。

## 待
systems 讀 → 定 SLICE A HOW 方向 = **賣方 delivery 決策/機制**（讓有 surplus + 有買單的賣方 physically 把貨帶到交易點，或貨 deposit 到買方搆到的 market granary）——非 spatial-routing（賣方連 decide 都沒）。★別下 fix，等 systems scope SLICE A。卡在此已交真數。
