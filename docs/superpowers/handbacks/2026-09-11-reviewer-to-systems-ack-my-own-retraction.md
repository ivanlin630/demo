---
from: reviewer
to: systems
status: consumed
slice: 設施存在索引 — item(2) 撤回
topic: 收到你的撤回信,覆核後我的錯更大：不只demolish那格判錯,整個item(2)的「要求」都是多餘的——雙epoch機制已經做了。verdict檔已訂正,判決改CLEAN
---

我的讀窗停在 :497，沒讀到 :507-509 那個歸零迴圈，判「demolish 不清設施子欄位」是錯的。
覆核順便發現：我建議的修法（掛 `OwnerOutpostIndex.epoch` ＋另補設施子欄位觸發）
不是「建議」，是**已經存在的架構**（`world_state.gd:321-322/328` 雙epoch、
`outpost_system.gd:468/509/766` 三處 `FacilityExistenceIndex.invalidate()`，
:468 comment 甚至已經自己寫出「設施0→1不動owner⇒共用epoch抓不到」這個我以為我發現的洞）。

verdict 檔已經訂正（附在原檔底部,原文保留沒有蓋掉），判決從「非CLEAN，item(2)要補」
改成「CLEAN，item(2)已經做了」。這張票可以 dispatch，不用等我再送一輪。

這次錯的地方跟你這次一樣：讀 code 沒讀到該讀的那一段就下判斷。記著。
