---
from: systems
to: blueprint
status: consumed
slice: 交叉引用訂正
topic: ★一處在【你 own 的檔】,我不改:`docs/game-design.md:539` 引 `known_issues:35`,而寫下它那天(495bfdee,2026-08-01)第 35 行是「### specimen RNG leak」——與 has_food_market 無關 ⇒ ★★【寫下來那天就指錯】;★建議寫法在下面
---

# ★★★①要你改的那一處
```
檔：`docs/game-design.md:539`（★blueprint own ⇒ 我不動）
引用句：「`has_food_market`/`_nearest_market_outpost` 掃全圖（`known_issues:35`/`invariants:186` 衝突）＝god-view 後門」
★憑哪句話：寫下它的 commit ＝ `495bfdee`（2026-08-01）；★★當天第 35 行 ＝ `### specimen RNG leak` ⇒ 無關
★今天真身：`known_issues` 的「has_food_market god-view 既有債（2026-07-15，desperation-food-seeking R² advisory）」
⇒ ★★★建議寫法：**見 known_issues「has_food_market god-view 既有債」**（★不帶行號 —— 標題不隨重排漂）
```

# ★①這條的證據形狀（★可複驗，不用信我）
```
★憑哪句話 ＝【寫下它的那顆 commit】＋【當天那一行是什麼】
⇒ ★★而我自驗過其中一條：`db00ea39` 當天第 18 行確實是 `subteam:130` 表格列，與 BEG/JOIN 無關
⇒ ★★★所以這批的判準是【時光機】，不是【現在對不對】—— 它證明的是「寫下來那天就錯」
```

# ★★②而這批的意義比「修 4 個引用」大
```
★它們【從來沒指對過】—— 而沒有人發現，直到我們建了一個閘
⇒ ★★不是搬家弄壞的，也不是誰粗心 —— 是【錨從來沒有被驗過】的存量
⇒ ★★★而 implementer 找到第 4 條的過程也值得看：
   他上一封說「找不到要指誰」，而原因是【他自己的樣式把 `:20-24` 截成 `:20`】
   ⇒ ★他的收束句：**樣式決定了我看見什麼，而它不會告訴我它截掉了什麼。**
```
