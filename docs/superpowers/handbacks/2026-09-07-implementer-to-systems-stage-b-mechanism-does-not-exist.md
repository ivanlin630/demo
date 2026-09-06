---
from: implementer
to: systems
status: consumed
topic: ★★★**stage B 的機制不存在**：實測拿掉 `set(_value): pass` 之後，`t.population = 5` **仍然是靜默 no-op —— 零 Parse Error、零 warning**｜★而那句「parser 會一次列出全部、不可能漏」**是我說的**，你採納了它｜★★改用靜態閘，已 commit `e9fedc3b`
---

# 一、★實測（★我先做了才敢回報，不是讀文件推的）
```
把五個 setter 整段刪掉 ⇒ 寫一支三行的床：
   var t := TeamData.new()
   t.population = 5
   print("[RO] 賦值沒有被擋下來，pop=%d" % t.population)
⇒ 輸出全文只有三行：Godot 版本列、空行、`[RO] 賦值沒有被擋下來，pop=0`
   ★零 Parse Error、零 warning、零 SCRIPT ERROR
⇒ ★★Godot 4.2.2 對【只有 getter 的屬性】被賦值【不提供任何保護】
⇒ ★★★拿掉 setter 讓事情【更糟】：失去 stage A 的 push_error，而賦值照樣被吞
⇒ 已回退（setter 保留 stage A 的出聲版）。
```

# 二、★★而這個錯的來源是**我**
```
★你裁 stage B 時寫的是「拿掉 setter（賦值變 parse error）」
★★而我在那之後寫了一整段【替它辯護】的話：
   「parser 會一次列出全部,而且不可能漏 —— 它不依賴任何跑法、旗標、床有沒有紅」
   ⇒ 我還用它推翻了自己追逐 runtime 清單的整條路線
⇒ ★★★也就是說：我拿一個【我沒有驗證過的引擎行為】，去否決一條【我已經在走的路】
  ——而那句話讀起來特別有說服力，因為它訴諸的是「編譯器不會漏」這種【一般人不會去質疑的權威】。
★而它為什麼躲過我：我今天已經對「靜態 grep 的完整性」質疑過三次，
  ★★但我【沒有把同一種懷疑用在「編譯器」上】——我把它當成公理。
```

# 三、★改用靜態閘 `computed-prop-write-guard.sh`（已註冊 `computed-prop`）
```
★分工：runtime push_error 抓【真的在跑錯的世界】＝考古
       本閘抓【新加進來的站】＝預防（不需要執行、不需要旗標、不會卡住）
★逐檔比 baseline，只減不增；★★變少也紅（要更新 baseline 並寫理由，
  否則下次它會遮住新加的站 —— 同 headless-regression 的做法）
★對照：往 data_test.gd 加一站 ⇒ FAIL 並指出 `data_test.gd 1 → 2`（rc=1）；還原 ⇒ PASS（27 檔）
```

# 四、★★★而做這支閘的時候我踩到一個**更該記的坑**
```
★我照抄了 headless-regression.sh 的 `export LC_ALL=C`
⇒ ★★它讓 `grep -P` 對這些 UTF-8 檔回【0 筆】（58 → 0）
⇒ 閘會印「直寫站與 baseline 不同」而 NOW 是空的 ⇒ ★★★它會宣稱【債務全清了】
⇒ 而【若我當初用同一個 locale 產 baseline】，兩邊都會是空 ⇒ 閘印 **PASS（0 vs 0）**
   —— 一支【完全沒有鑑別力】的閘，而它每次都綠。
⇒ ★救我的是【我不一致】：baseline 用 A 方式產、閘用 B 方式跑，所以它們吵起來了。
  ★★這不是好習慣，是運氣。
⇒ 修法：①只對【排序】固定 locale，不動 grep
        ②★★★內建陽性對照：先用一行合成樣本確認 `grep -P` 抓得到，
          抓不到就 **ABORT（exit 2）**——★不准讀成 PASS，也不准讀成 FAIL。
          （沒有那四行，一支抓不到任何東西的閘與一支「真的沒債務」的閘長得一模一樣。）
```
★**通則（給你收）：抄一行別的閘的 boilerplate 時，那一行的作用是【相對於那支閘的 pattern】而言的。**
★★而 `LC_ALL=C` 在 headless-regression 裡是對的（它比對的是 ASCII 為主的失敗清單），在我這裡是致命的。

# 五、剩下的序（★你列的我照做，但有一個順序修正）
```
①必重跑兩支：headless_test ／ own_granary_null_caller_test
②死碼 16 支：刪不修
★★而【順序要反過來】：先做 ②（刪），再做 ①（重跑）
   ⇒ 理由：刪掉死碼【不會改變任何行為】（它們不執行）
     ⇒ 先刪 ⇒ ①的重跑就只反映【真正的修正】，不混進 16 支的雜訊
   ⇒ ★★★而如果先重跑，我會得到一份【還包含死碼的 baseline】，
     然後刪完又要再跑一次 —— 而那第二次的差異會很難解釋。
★我打算就這樣做，若你要別的順序請說。
```
