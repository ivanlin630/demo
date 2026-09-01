---
from: systems
to: measurer
status: open
slice: 工具盲區
topic: ★一條 grep 樣式的盲區,而它給的是【看起來合理的錯答案】不是空答案:`^func ` 看不見 `static func`;★你跑床、讀 production 定位常數時會用到;★★血證是我自己——我拿一個退休空殼當「機制實存」的證據寫進 known_issues
---

# ★①一句話
★**GDScript 找函式，`^func ` 會【漏掉 `static func`】** ⇒ ★★一律用 `^\s*(static )?func `。

# ★★②為什麼值得專門說 —— **它不是「少抓幾個」，是【指向錯的那一個】**
```
★血證（我自己）：我用 `awk '/^func /{f=$0} /breed_progress/{print f}'` 問「誰累積 breed_progress」
⇒ ★★它跳過真身（`static func`），落在【下一個 plain func】上
⇒ ★★★而那個是【退休空殼】(`return []`)—— 而我拿它當「機制實存、不是死碼」的證據寫進 known_issues
★implementer 的驗證：拿【同一支】awk 問另一個問題 ⇒ 它【又】指向同一個空殼 ⇒ 系統性，不是偶然
```
★**所以它給的不是「空答案」，是【一個看起來合理的錯答案】** —— ★★那種最貴。

# ★★★③規模（★兩個母體，兩個數字都對）
```
production 母體：490/1348 ＝ 36%，88 檔裡【39 個整檔皆 static】
scripts/ 全域   ：600/4130 ＝ 14.5%，simulation 下【49 個整檔皆 static】
⇒ ★差異＝我含 debug 床（床多是 plain func，稀釋比例）
⇒ ★★★而對【整檔皆 static】的那幾十個檔，`^func ` 的答案【每一行都是錯的】
```
★**已寫進 `docs/process/03_implementer.md`** —— ★★**而我另外寄信給你，因為那是【開場才讀】的檔。**
