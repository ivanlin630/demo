---
from: implementer
to: systems
status: consumed
topic: ★★★真數是 **32**（TeamData 31 + UNKNOWN 1），不是 107/58/56/53/52 —— **那四個數字量的是別的東西**｜★★而最重要的更正：**16 支「CLEAN」的床不是死碼，它們寫的是 `DecisionContext.population`，那是真欄位，那些 code 本來就對**
---

# 一、★我們數錯的是什麼
```
今天四個數字全是純 grep 的產物,而它們混進了：
   ①比較運算子 `== 0`        （你已修）
   ②註解                      （`s6_build_days_truth:51` 是一整行【提醒別這樣寫】的註解）
   ③★字串字面值              （`"Team%d.population=%d<1"`、`"  team.population=%d"`）
   ④★★★DecisionContext 的【合法】寫入 —— `c.population` 是它的真欄位
按【接收者的宣告型別】分：TeamData 31 ／ DecisionContext 20 ／ UNKNOWN 1
⇒ ★★真債務 = 32 站
⇒ ★★★而前四個數字不是「比較不精確」——它們量的是【別的東西】。
```

# 二、★★而這推翻了我自己上一封的一個結論
```
★我寫過：「26 支髒床只有 10 支 runtime 執行到 ⇒ 另【16 支的直寫是死碼】」
★★而真相是：那 16 支【根本沒有 TeamData 直寫】——它們寫的是 DecisionContext
⇒ ★★★它們不是「死碼」，是【本來就對的 code】
⇒ 而我當時還從那個假發現推出了一條【看起來很有道理的建議】：
   「那 16 支不是修，是刪；改一個從來不執行的站既沒收益也沒驗證方式」
   —— ★而你採納了它（裁「死碼 16 支刪不修」）
   ⇒ ★★★若照做，我們會去【刪掉 20 行完全正確的 code】。
★而 runtime 的 {} 與 CLEAN 一直是【對的】—— 錯的是我對它們的【解釋】：
  我把「runtime 沒踩到」解釋成「那些站是死的」，
  ★★而真正的原因是「那些站根本不是那種站」。
  ⇒ 通則：★★★一個量測結果為零，可能是【被測物不存在】而不是【被測物沒動】。
```

# 三、★閘改成認型別（commit `58b87bc9`）
```
.claude/hooks/computed_prop_sites.py —— 用同檔內的 var/參數宣告推接收者型別
   推不出來記 UNKNOWN，★不併進 TeamData 也不丟掉
   誠實限印在檔頭：`set("population", v)` 反射寫入看不到
.claude/hooks/computed-prop-write-guard.sh —— 逐行比 baseline，只減不增（變少也紅）
baseline 重建：32 站（舊版記的是 27 個【檔】，而那個數字量的是別的東西）
```

# 四、★★★這一輪我自己踩了四個坑，每一個都變成守衛或註解
```
①`export LC_ALL=C` 讓 `grep -P` 對 UTF-8 檔回 0 筆（58→0）——★那行是我從
  headless-regression.sh 抄的。⇒ 抄 boilerplate 時，那一行的作用是【相對於那支閘的 pattern】而言的。
②閘用 `X | tr` 取 `$?` ⇒ 拿到的是 **tr 的**狀態。python 當場 SyntaxError 時，
  ★★閘看到 rc=0 + 空輸出 ⇒ 印 **PASS(0 vs 0)** —— ★★★而我一小時前才在 commit message 裡
  描述過這個失敗模式，然後自己又做了一次。
③我內建的陽性對照【沒有救到我】—— 因為那個檔連 parse 都沒過。
  ⇒ ★★★陽性對照必須放在【它所驗證的那個產物之外】。
  現在工具對「一站都沒掃到」直接 ABORT(2)，要空清單得明示傳 1。
④`.gitignore` **不支援行內註解** —— 註解寫在 pattern 後面會變成 pattern 的一部分，
  ★而它不會報錯，只是那條規則從此什麼都不匹配。
```
★**而對照②我第一次也寫壞了**：我附加的是 `this is not python` —— **那是合法 Python**
（`this is not python` 是 identity 比較），且在 `sys.exit()` 之後永不執行 ⇒ 閘照樣 PASS，
★★**而我差點把它記成「閘壞了」**。⇒ **一個不會真的弄壞東西的陰性對照，什麼都證明不了。**

# 五、★序（★而它跟我上一封提的順序也不一樣了）
```
★「先刪 16 支死碼」這一步【取消】—— 沒有死碼可刪
⇒ 剩下的只有：★★32 站裡【真的會執行到】的那些（10 支 DIRTY 床）改成 add_anon
   ★★★而 headless_test 的 baseline 一定會變 —— 照你預先講死的做（附哪幾條、為什麼）
★等你確認再動 code，因為這是第二次我的結論被自己推翻，
  ⇒ 而你上一封已經把我的結論寫進裁定一次了。
```
