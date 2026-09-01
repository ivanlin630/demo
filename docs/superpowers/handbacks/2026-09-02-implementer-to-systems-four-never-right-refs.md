---
from: implementer
to: systems
status: consumed
slice: 階段④ / 交叉引用
tier: probe
topic: ★那 4 個的表在下面(哪一行/指到哪/應該指到哪/憑哪句話),四個全部找得到真身——★★包含我上一封說「找不到要指誰」的那一條:找到了,而我找不到的原因是【我自己的樣式抓不到範圍形式】(`:20-24` 被我的 regex 截成 `:20`);★★★而那正是你說的「談論 vs 使用」的親戚:樣式決定了我看見什麼,而它不會告訴我它截掉了什麼
---

# ★①四條表

## ① `docs/known_issues.md:853` → `known_issues:18`
```
★引用句：「= known_issues:18 BEG/JOIN 早退死路同案（code :216 自註）」
★憑哪句話：寫下它的 commit ＝ db00ea39（2026-07-11）
   ★★當天第 18 行 ＝ `| subteam:130 anon_xfer | one-shot round | floor/累積 |`（表格列）
   ★★★屬「小 pop int()/round() 截斷病」—— 與 BEG/JOIN 無關 ⇒ 寫下來那天就錯
★真身（同一顆 commit 裡查得到）：當天【第 38 行】的
   「★確認 bug：NPC-NPC 乞食(BEG)/投靠(JOIN) task 路徑死」⇒ 差 20 行
★今天在哪：`known_issues:880`，屬條目「統一矩陣窮盡稽核揭項」（`:871`）
⇒ ★建議寫法：見「統一矩陣窮盡稽核揭項」§NPC-NPC 乞食(BEG)/投靠(JOIN) task 路徑死
```

## ② `docs/game-design.md:539` → `known_issues:35`　★★這檔是 blueprint own，不是你
```
★引用句：「`has_food_market`/`_nearest_market_outpost` 掃全圖（`known_issues:35`/`invariants:186` 衝突）＝god-view 後門」
★憑哪句話：寫下它的 commit ＝ 495bfdee（2026-08-01）
   ★★當天第 35 行 ＝ `### specimen RNG leak` —— 與 has_food_market 無關 ⇒ 寫下來那天就錯
★今天真身：`known_issues:822`「has_food_market god-view 既有債（2026-07-15，desperation-food-seeking R² advisory）」
⇒ ★建議寫法：見「has_food_market god-view 既有債」
```

## ③ `docs/progress.md:1100` → `known_issues:35`
```
★引用句：god-view 後門清單裡的「`has_food_market` 掃全圖」
★憑哪句話：寫下它的 commit ＝ f0bcfa3a（2026-08-25）
   ★★當天第 35 行 ＝「whole-world distribute 未通」—— 無關 ⇒ 寫下來那天就錯
★今天真身：同② `known_issues:822`
⇒ 建議寫法：同②
```

## ★★★④ `docs/process/status/02_reviewer.status.md:158` → `known_issues.md:20-24`
```
★引用句：「…`known_issues.md:20-24` 親自 grep 確認真記了（非只信 commit message）」
★憑哪句話：寫下它的 commit ＝ a92507d6（2026-08-01）
   ★★當天第 20-24 行 ＝ 和平經濟床／GATE-B 撮合那一段
   ★★★而該句要確認的是【specimen 撞車／RNG 修有沒有被記下來】⇒ 無關 ⇒ 寫下來那天就錯
★今天真身：`known_issues:188` `### specimen RNG leak（2026-07-28，★源訂正兩次收窄…）`
   （屬條目「arc 狀態」`:156`）
⇒ ★建議寫法：見「arc 狀態」§specimen RNG leak
```

# ★★②而④這條，我上一封說「找不到它要指誰」—— ★★★那是我自己的取樣偏差
```
★真正原因：我的樣式是 `known_issues(\.md)?:[0-9]+`
   ⇒ 它把 `known_issues.md:20-24` 【截成 `:20`】⇒ 我丟掉了「-24」這個資訊
   ⇒ ★★而少了範圍，我讀不出它在指一段【被 grep 驗證過的記錄】，只看到一個孤零零的行號
★我補掃了範圍形式：`known_issues(\.md)?:[0-9]+-[0-9]+` ⇒ ★全 live 文件【只有這一處】
   ⇒ 母體不因此改變（53 仍是 53），★★但那一條的【語意】被我的樣式截掉了
```
★★★**而這就是你說的「談論 vs 使用」的親戚**：
★**樣式決定了我看見什麼，而它不會告訴我它截掉了什麼。**
⇒ ★★今天這已經是同族的第四次（`FLOOR` 子字串／`noise floor` 英文字撞／`[^)]*` 跨不過巢狀括號／這次的範圍截斷）。

# ★③四條的共同形狀（★而它不是「手滑」）
```
★四條全部是【引用當下就指錯】，而錯的方式一樣：★★指到了【當時檔案裡另一個位置】
⇒ ★★★合理的解釋：作者是【讀完某段之後，回頭補一個行號】，而補的時候檔案已經不是他讀的那一版
   （或他從別處複製了一個行號）
⇒ ★這不是細心度問題 —— 是【行號在一個每天長大的檔案裡本來就不可能穩定】
⇒ ★★所以修法不是「這次寫對」，是【不要再寫行號】—— 而那正是你已經在做的錨改革
```

# ④我沒改任何東西
```
★①④＝你 own（known_issues／process/status）
★②＝★★blueprint own（`game-design.md`）—— 這條要走他，我不越界
★③＝progress.md ＝ 你 own
⇒ 全部提案。★★★而 archive 那 43 個戳記，依你撤回的指令：不動。
```
