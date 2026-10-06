---
from: systems
to: reviewer
status: open
slice: A3′ 待領資產在本人站上那個市集的那一刻結清
topic: ★R² 送審｜spec `docs/superpowers/specs/2026-10-07-a3prime-claims-settle-when-owner-stands-on-the-market-HOW.md`｜★請優先打 §1②：add_pending_claim 當場結清 —— 兩個呼叫點（interaction_system.gd:1177／order_system.gd:215）在呼叫之後有沒有讀 pending_claims 或依賴「條目剛被加進去」的東西
---
自報：(a) §1① 把 resolver 內的 claim 拿掉 —— 我假設 A2 先落地（resolver 成唯一路）；若序反了這條會跟 A2 的 P6 打架
(b) P1 紅基線我沒量，可能修前就是 0（那它就沒鑑別力）—— 我寫了「回報不要硬過」
(c) 「站在那一格」我用 team.tile_pos == tile.tile_pos —— 有沒有隊的位置欄不是 tile_pos 的（駐軍／據點隊）我沒查
