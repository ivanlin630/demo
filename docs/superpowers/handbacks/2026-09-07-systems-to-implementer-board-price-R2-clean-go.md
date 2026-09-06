---
from: systems
to: implementer
status: open
slice: 單據帶價 —— ★R² 過了（issues 小、已改完）⇒ **GO**
topic: ★R² issues(小)三點我全改完 ⇒ GO,spec = docs/superpowers/specs/2026-09-07-board-declared-price-HOW.md(97 行);★★而三點裡有兩點會直接影響你怎麼寫:①【求援信轉掛那格 price 寫死 0.0】(faction_ai_system.gd:2020-2038 `_deliver_letter_to_board` 是 charity 請求不是商業報價,套 local_value 公式語意就錯了)——而它【留在分母裡】不排除,所以驗收①的 1.0 是真的達成得到的 ②reviewer 獨立窮盡(含 `=` 重賦值不只 `.append`)確認 board entry 只有【3 個構造點】沒有第 4 個 ⇒ 你不用再自己掃一次;★★★另:我在 spec 裡【撤回了】原本那句「現行撮合當下重算=資訊瞬時傳遞」——那是錯的(那兩處在同格巧遇/當面交易函式裡,讀對方 local_value 是「共位保證見」既有例外),★而本案的正當性靠 §0 的可行性論證就夠,不靠那句
---

# ★GO
```
spec:docs/superpowers/specs/2026-09-07-board-declared-price-HOW.md（97 行，已含 R² 三點）
R²:issues(小)⇒ 我改完 ⇒ ★GO,不再回送一輪
```

# ★★兩點直接影響你怎麼寫
```
①★求援信轉掛那格:faction_ai_system.gd:2020-2038 `_deliver_letter_to_board`
   {"kind":"buy","res":"food"} 是【charity 請求】不是【商業報價】
   ⇒ ★★price 寫死 `0.0`,對齊既有 free_dist ／ ⑩「零價可成交」的 gift 慣例
   ⇒ ★★★而它【留在分母裡】不排除 —— 所以驗收①「relayed 帶價比例 = 1.0」是【真的達成得到】的,
      不是恆紅假判準(那正是我送審時擔心的那一格,而 reviewer 給的解法比排除好)
②★board entry 的構造點:reviewer 獨立窮盡(★含 `=` 重賦值,不只 `.append`)
   ⇒ production 只有【3 個】,沒有第 4 個 ⇒ 你不用再自己掃一次
```

# ★★★三、我撤回了 spec 裡的一句話，你不要引用它
```
原句:「現行【撮合當下重算】等於資訊瞬時傳遞,與資訊網鐵律不一致」
★而 factcheck:interaction_system.gd:1027／:1137 兩處都在【同格巧遇/當面交易】的函式裡
   ⇒ 讀對方 local_value 是【共位保證見】那條既有例外在【正確運作】
⇒ ★★所以本案【不是】在修一個既有的感知漏洞,它就是【新增資訊】
⇒ ★★★而正當性靠 §0 就夠:捕獲剩餘兩式在現行資料下【兩半都不可行】—— 那是你查出來的
```
★**spec 裡我保留了原文並加撤回註記**（不刪）——★★**因為那句會被拿來當正當性，
刪掉會讓「我曾經這樣論證過」從紀錄裡消失。**
