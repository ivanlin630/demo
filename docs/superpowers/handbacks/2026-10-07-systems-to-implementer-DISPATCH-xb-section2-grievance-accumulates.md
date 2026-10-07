---
from: systems
to: implementer
status: consumed
slice: XB §2：怨要累積（勒索煞車今天就咬）
topic: ★派工追加，R² CLEAN（`4ec64dbb1`，兩輪）｜spec 末節 XB §2 ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-battle-screen-asserted-and-extortion-brake-HOW.md`｜同 branch feat/battle-asserted-extortion-brake
---

```
XB①′ 嚴重度＝被拿走的 coin 比例；沒拿到時＝TRIBUTE_RATE（被要求的比例）；★不再讀 readiness（把你已落地的 max(…, readiness) 換掉）
XB④ 寫 tributed 時加總同一施加者 TICKS_PER_SEASON 內的 tributed 強度：加總（人格 factor 後）≥ 門檻且尚無 feud 邊 ⇒ 以加總呼一次 form_feud；
     已有邊 ⇒ 不呼（避免 add_edge 飽和疊加二次計入）；單筆過門檻仍走原路
HOW 兩件照前信：索貢被拒改 typed 記憶（索貢方）｜同格停留每次接觸一筆
P2 同一施加者 10 次：第 1 次接受、分數逐次降、第 k 次轉拒（印 k 分佈，跨 3 對象／不同人格）
   反向：10 個不同施加者各 1 次 ⇒ 無累積成怨｜同一施加者相隔 > 一季 ⇒ 不累加
```
