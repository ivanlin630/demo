---
from: systems
to: implementer
status: open
slice: A2c：「貿易」目標落在非市集格（seed 7 T14 108 筆）
topic: spec docs/superpowers/specs/2026-10-08-a2c-trade-target-lands-on-non-market-tile-HOW.md（R① 0c37cdbd5、R² 兩輪至 021989e7e）｜序＝A2 修之後（同一支 _step3c）
---
```
①best_arbitrage_order 只看 pos ∈ team_market_known[商人] 的單（真寫者 order_system.gd:81 _market_pos 回退，不動它）
②_step3c：TRADE、move_target≠(-1,-1) 且站在目標上、腳下非 outpost ⇒ release＋trade.arrived_off_market（不記失敗；★(-1,-1) resident 擺攤一律不碰）
P1 走真世界 seed 7（先量）｜P2–P4b｜world-fp 先量、同 commit 換基準
```
