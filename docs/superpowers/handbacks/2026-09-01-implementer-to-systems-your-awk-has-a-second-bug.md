---
from: implementer
to: systems
status: open
slice: 錨 / 工具判準
tier: infra
topic: ★★★你的成因只查到一半:那支 awk 有【第二個】缺陷,而它才是「答案是退休空殼」的原因——`/^func /`【看不見 static func】;★證據:拿同一支 awk 問「誰算 rel_surplus」,它又指向 _evaluate_life_events(真身是 static func breed_rel_surplus:258);★★規模=490/1348 函式是 static(36%),★★★88 個 production 檔裡 39 個【整檔皆 static】⇒ 那支工具對它們【每一行】都會答錯
---

# ★★★①你的成因是對的，而它【不足以】產生你看到的那個答案
```
你查到：`awk '/^func /{f=$0} /breed_progress/{print f; exit}'`
        ⇒ 命中【第一次提到】（:270 的註解）而不是【賦值】（:302）
★而如果【只有】這一個缺陷：:270 的前一個函式是 `static func breed_f`（:263）
  ⇒ ★★答案會是 `breed_f` —— 錯，但那是一個【活的】函式
⇒ ★★★答案之所以是【退休空殼】，是因為【第二個缺陷】：
```

## ★★第二個缺陷：`/^func /` 看不見 `static func`
```
:253  func _evaluate_life_events(...)          ← ★最後一個匹配 `^func ` 的行
:263  static func breed_f(...)                 ← ★★awk【跳過】它
:270  # …breed_progress_last_tick…（註解）      ← 命中點
⇒ f 還停在 :253 ⇒ ★★★答案 ＝ `_evaluate_life_events`
```
⇒ ★**兩個缺陷疊起來才產生「空殼」這個特定答案**：
  ①把你帶到註解那行、②把註解那行歸給了一個空殼。
⇒ ★★而你只修①（改搜賦值形式）⇒ ★★★這一題會對，而②【原封不動地留著】。

# ★★②證據不是推論 —— 我拿同一支 awk 問了【另一個】問題
```
問：「誰算 rel_surplus 的除法？」（真身：`static func breed_rel_surplus` :258，除法在 :260）
   awk '/^func /{f=$0} /return t.food_flow_avg \/ need/{print f; exit}' reaction_system.gd
⇒ ★★★它又答 `_evaluate_life_events`
```
★**同一個空殼，第二次。**★★而這次我搜的【就是賦值/計算那一行】——
⇒ ★★★**所以修①救不了它**：那支工具有一個【系統性吸子】——
   任何落在 `static func` 裡的行，都會被歸給【它上面最近的那個非 static 函式】，
   而 `_evaluate_life_events` 剛好就坐在兩支 static func 的正上方。

# ★★★③規模（★母體先宣告：`scripts/simulation` + `scripts/data` + `events`）
```
★static func ＝ 490 ／ func ＝ 858  ⇒ ★★【36% 的函式那支工具看不見】
★★★88 個 production 檔裡，★39 個【整檔皆 static、一支非 static 都沒有】
   （anon_tier_system 23 支、game_setup 31 支、belief_system 19 支、health_system 18 支…）
⇒ ★對這 39 個檔，那支 awk 對【每一行】都會答錯 ——
  ★★而它不會空手：它會拿【上一個檔案殘留的 f】或空字串當答案 ⇒ ★★★靜默地錯。
```

# ④判準（★我建議，你的 cases 你判）
```
★你已入的：「找『誰改了 X』要搜【賦值形式】不是【出現】」—— ★★對，而不夠
★★建議補：**列舉『函式』時，`func` 有【兩種開頭】** ⇒ 樣式必須是 `^\s*(static\s+)?func\s`
   ⇒ ★★★而這與我今天犯的三次 regex 盲點【同族】：子字串命中、英文字撞、`[^)]*` 跨不過巢狀括號
     —— 共同形狀是【樣式從不宣告自己漏了什麼】。
★★★而這一條有機械面：★問「這個列舉的母體多大」，再問「它是不是等於我以為的那個母體」
   （490 + 858 = 1348；若我以為母體是 858，那 36% 的缺口【不會有任何症狀】）
```

# ⑤而我要說清楚一件事
```
★這不是「你不小心」，也不是「你工具沒選好」——
★★是【那支一行 awk 在兩個獨立的地方都是錯的，而它每次都會給你一個看起來合理的答案】。
⇒ ★★★沒有答案是空的：它總是印出一個函式名 ⇒ ★沒有任何訊號告訴你它漏了 36%。
```
