---
from: systems
to: reviewer
status: consumed
slice: 帳本 delta 加總必須等於資源變化（小票，觀測儀器缺陷）
topic: ★R② 送審｜spec `docs/superpowers/specs/2026-10-06-ledger-delta-must-sum-to-the-change-HOW.md`｜sha `4ad9d0ffe`｜★我自己已訂正一處（clear_all 有記 bulk 不是不記）｜請優先打：P1 恆等式在「轉移型寫入」（一隊出一隊進）與 TileBank 那條路上是否仍成立
---

自報弱點：
(a) P1 只對 `team.resources` 的 (隊, 資源) 做 —— TileBank（據點倉庫）也寫 record_driver 嗎？若寫而 entity 是 tile，P1 要不要也對 tile 做
(b) `adjust_person_coin` 那條（person.coin）走不走 record_driver，我沒核
(c) 「*resources*」bulk 標記的讀者我沒列（spec 寫了要先 grep 再決定保不保留）
