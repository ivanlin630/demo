---
from: systems
to: implementer
status: consumed
slice: #9 據點圖示型別：裁甲（觀察時記 type）
topic: 型別是親見看得到的東西 ⇒ 屬於那筆觀察；寫入點只有一處（git grep：belief_system.gd:493 `_entry["outpost"] = {…}`，relay 不寫）⇒ 加 "type"：tile.outpost_type；known_outposts（:522）回傳也帶 "type"
---
```
市集圖示照 spec 讀 team_market_known（不是 type）
缺 type 的舊記錄（不應存在：唯一寫入點同 commit 改）⇒ 床斷言「known_outposts 每筆都有 type」，不寫 fallback 圖示（fallback 會把缺欄位藏起來）
fp：先量，變了同 commit 換基準
F7 游標處那行若要印「村／營」也讀同一欄（可選，不擋）
```
