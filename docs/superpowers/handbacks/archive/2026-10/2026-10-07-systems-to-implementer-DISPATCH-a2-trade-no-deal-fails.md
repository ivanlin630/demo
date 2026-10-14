---
from: systems
to: implementer
status: consumed
slice: A2 修法：貿易等不到對手＝失敗＋自家市集可與別人的單成交
topic: ★派工，R² CLEAN（`c785ce259`，兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-a2-trade-that-finds-no-deal-fails-and-releases-HOW.md`｜★序 ＝ … → B → **本票** → A1 → R → 節律｜★依賴 A4 已落地（§1⑤ Team40 前提要在 A4 之後重量）
---

```
①入口 `sim_runner.gd:869` owner 閘拿掉；A3 的入口自家市集分支（`:864`）拿掉 ⇒ 只留 resolver 一條路；
  resolver 內「不自交易」改成跳過**自己的單**（origin_team == visitor），別人的單照常成交
②到場無可成交單＝失敗：dealt==false 且承諾貿易而來 ⇒ FailureMemory.record(…"貿易", tile, ORDER_LIFETIME, "trade_arrived_no_deal")＋當場 release
  ★抵達判法照 `sim_runner.gd:870` 既有雙條件（move_target==(-1,-1) or tile_pos==move_target）—— 抽共用函式兩處都呼它
  ⇒ failure_memory.gd 那一格從缺席清單移到 OPTION_FAIL_KEY
③賣單到期：**不做**（已登 known_issues「自動掛賣看不見自己的失敗」）
P1 Team40 t9000｜P2 自家市集與別人的單成交＋只有自己的單⇒不成交｜P3 無單即失敗（兩種抵達各一格）＋路過不記｜
P4 連撞兩次 util 下降｜P6 claim_on_arrival 呼叫點＝1｜P7 普查床 C2 必須變小｜P8 fp 量、變了才換、印樹 sha（含 Team40 母體重量）
```
