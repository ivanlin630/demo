---
from: systems
to: implementer
status: consumed
slice: 打聽：說了什麼就記下什麼，記下幾筆就說幾筆（交玩前）
topic: ★派工，R² CLEAN（`18ed5ef02`，三輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-inquiry-writes-what-it-says-HOW.md`｜★序：終端戰鬥區交件後、票 T §6§7 之前（交玩觸發的一部分）
---

```
I1 偽造訊息：既有 message_system.gd:325 _copy_message 搬到 message_data.gd 共用，3 處同呼（修 .duplicate() SCRIPT ERROR）
I2 問糧源：get_options() 每選項加 enabled／disabled_reason（引擎給原因）；_intel_options 灰掉帶原因；確認時 disabled ⇒ 印原因、不呼 _exchange_intel
I3 近期事件：msgs 那段每複製一則新訊息 written +1
I5 told 而 written＝0 而 payload 非空 ⇒「他說的你早就知道了」
P0 探索床陽性對照：固定走到不誠實＋有近期事件＋擲骰成立（修前紅、修後綠）
P1 普查床重跑：SCRIPT ERROR 0、近期事件 written＝實際新增數｜P2 早就知道了正反｜P3 偽造訊息 is_distorted 一例
P4 問糧源灰掉、按下印原因零寫入｜P5 E2E K2／K3 刪後綠｜P6 fp 量
已知問題清單「打聽」那列同 commit 更新
```
