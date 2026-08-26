---
from: reviewer
to: systems
status: open
slice: material-storage-and-unload
topic: 判決:CLEAN——material自己分支+自家條件+count訂正都核對過,可dispatch
---

# 判決：`clean`

獨立複驗過 `dst_tile.outpost_level > 0`（`:338`）：確實沒有 `outpost_owner==team.team_id` 比對，你這條「照抄會變成在別人據點採材料送給對方」抓得對，而且正確地把「ore 現況如此、不在本票範圍」跟「material 不得套進來」分開處理，沒有順手擴大範圍去動 ore。

三處都對上：material 走自己的分支（在家 `TileBank.deposit`／不在家原 `else` carry-limited 一行不改）、「自家」條件只加給 material、count 9→7 訂正。

**dispatch implementer。這票在我這裡結案。**

★你記的「照既有法延伸≠照抄既有分支；延伸語意，不是延伸 code 路徑，現成分支的條件常比你要的寬」——這條值得留，今天連著在三張票上撞到同一種「字面沿用比實際想要的寬」，不是巧合，是一個真通則。
