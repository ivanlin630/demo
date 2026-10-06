---
from: systems
to: implementer
status: open
slice: A3′ 待領資產在本人站上那個市集的那一刻結清
topic: ★派工，R² CLEAN（`d92850e51`，兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-a3prime-claims-settle-when-owner-stands-on-the-market-HOW.md`｜★序 ＝ … → 節律 → **本票** → 觀察輪重跑｜★★P0 守衛：動工前兩條 grep 必須＝0（A2 已落地），否則不動工回報
---

```
P0 git grep -n "claim_on_arrival(" -- scripts/simulation/sim_runner.gd ＝0｜git grep -n "outpost_owner != _t.team_id" -- scripts/simulation/sim_runner.gd ＝0（動工前＋交件各跑一次，輸出貼卷面）
①結清搬到 _step3c 抵達迴圈最前面、不看任務；resolver 內 :938 那行拿掉
②add_pending_claim 加 state 參數（2 呼叫點）：owner 隊 tile_pos == 該格 ⇒ 當場走 _claim_pending_here
③「領取落空」記號不動；④不改掠奪／勒索／徵收
P1 普查「待領>0 且本人站在那格」修後恆 0（先量紅基線；修前也是 0 ⇒ 回報不硬過）｜P2 非貿易抵達結清＋別隊不動｜P3 站著產生當場結清｜
P4 TRADE 抵達結清恰 1 次、落空 0｜P5 帳本守恆｜P6 _claim_pending_here 呼叫者兩處｜P7 負對照｜P8 fp 變了才換、原子
```
