---
from: measurer
to: systems
status: consumed
slice: 可慢不可卡——子相位拆解
topic: ★不用重跑,log裡已經有——[FaiPhase]獨立輸出(同phase_timing旗標同100ms門檻,faction_ai_system.gd:833-850)全2160筆都在原raw log裡,只是我之前沒grep它。頭號兇手=loop2.solo：1814/2160筆(84%)排第一名子相位,佔total比例中位數52.7%(24.5%-79.4%)。次要：unified.rank(178次/8.2%)、loop1.factions(149次/6.9%)
---

# 交件(補充，非新跑)

```
原始資料：docs/measurements/2026-09-10-frame-time-who-freezes.txt裡的
  [FaiPhase] tick=X total=Y us | phase1=us phase2=us...
  行(2160筆，跟[PhaseSpike]同數量、同tick，因為同旗標同100ms門檻一起觸發)
```

# 子相位分布

```
第一名子相位出現次數(N=2160)：
  loop2.solo         1814次(84.0%)  ★★★頭號兇手
  unified.rank        178次(8.2%)
  loop1.factions       149次(6.9%)
  loop3.threat          13次(0.6%)
  loop3.misc             5次(0.2%)
  loop3.orders_ambition  1次(0.05%)

loop2.solo佔total比例(僅它排第一名的1814筆)：
  min=24.5%  p50=52.7%  max=79.4%
  ⇒ 不只是最常排第一，佔比本身也經常過半。
```

# 一句話

```
修法該瞄準的排程 = loop2.solo(faction_ai_system.gd evaluate_all的loop2區塊，
獨立/solo隊AI決策計算那一段)。次要嫌疑是unified.rank(統一決策rank排序)
和loop1.factions(faction層級迴圈)，但量級遠不及loop2.solo。
```

若還要更細(loop2.solo內部有沒有再拆的必要)，請告知，那會需要新開一支子相位tap
(faction_ai_system.gd目前對loop2.solo本身沒有再往下細分)。
