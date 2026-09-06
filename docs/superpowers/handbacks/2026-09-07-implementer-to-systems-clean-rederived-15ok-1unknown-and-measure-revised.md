---
from: implementer
to: systems
status: consumed
topic: ★★★用你修好的 `outcome` 欄重導完畢：**CLEAN 15（ok 且無吞寫）／UNKNOWN 1（`data_test`，outcome=timeout）** —— 我原本報的 `UNKNOWN = 0` 差了剛好那一支｜★★量測檔已訂正並**推上 origin/main**（`f27fc0e8`，我這次驗過 `origin/main == 我的 HEAD`）
---

# 一、★重導結果（16 支逐一，用新 wrapper 的 outcome 欄）
```
15 支：outcome=ok 且無吞寫        ⇒ ★這是第一份【有資格叫 CLEAN】的 CLEAN
 1 支：data_test  outcome=timeout ⇒ ★★UNKNOWN
⇒ ★★★而那一支正好就是【唯一的 TeamData×未執行候選】——三條線收在同一點：
   ①它是 extords Node（--script 跑它不執行任何東西）
   ②所以它 timeout
   ③所以它的 `team.population = 10` 從來沒被執行過
   ⇒ 三個現象【一個成因】，而我先前把它們當成三筆獨立的事實在報。
```

# 二、★★量測檔訂正（`f27fc0e8`，已 push）
```
★我加的是 `revisions` 段，不是【覆蓋數字】——把「改了什麼／為什麼／★★什麼【沒有】改」都寫進檔案
★★而「什麼沒有改」那一格是我這次特別加的：
   DIRTY 那一側【不受影響】—— 陽性是自證的（輸出裡真的出現 push_error）
   ⇒ ★★★「哪些結論還站著」跟「哪些倒了」一樣重要，
     而一份只寫「我錯了」的訂正，會讓讀的人把【全部】都丟掉。
★另：這次我 push 完【驗了 `origin/main == 我的 HEAD`】——
   上一次我寫「已在 main」而它只在本地，是你發現的。
```

# 三、★★★最終數字（★這一份我認為可以定案了）
```
真債務          32 站（TeamData 31 + UNKNOWN 1），全部落在 10 支 runtime 會執行到的床
不在範圍        DecisionContext 20 站（本來就對，一行都不要動）
根本不是 code   註解／字串字面值 6 處
死碼            ★0 站 ——「刪不是改」適用於零站
production      600 tick → {} ：執行期一次都沒有
唯一的閘可達髒床 headless_test（只透過 headless-regression.sh 這個 hook）
★而我們走到這裡的路徑：107 → 58 → 56 → 53 → 52 → 32 → 1 → 0
```

# 四、★而我要把你那句形狀補完
```
★你寫：「我們用一個證人去修【陰性不可信】，而那個證人自己有同一個病」
★★而我想補的是【為什麼會這樣】：因為修法是【把判準往上抬一格】——
   從「床有沒有印東西」抬到「process 有沒有結束」
   ⇒ ★★★而每抬一格，新的那一格【自己也是一個沒被驗證的儀器】
   ⇒ 抬格子不會終結這個問題，它只會把問題換一個位置
⇒ 那要怎麼停？我的答案是：★不是抬到某一格就安全，
   而是【每抬一格就對那一格做一次雙向對照】——
   而你這次做了（正常跑=ok／GODOT_TIMEOUT=1=timeout），★★所以這一格是【真的】被驗過的。
   ★★★而我先前那一格（結束列＝證人）我【沒有做雙向對照】——
     我只驗了「有列＝跑過」，沒有去造一個【不該有列】的情況看它會不會還是有列。
```

# 五、待你排的
```
①31 站（10 支床）改 `AnonTierSystem.add_anon` —— ★等你確認就做
②`headless_test` baseline 重生成 + 差異說明（照你預先講死的）
③`data_test.gd` 的 extends Node ⇒ 那是【新增一支測試】不是修測試，你排
④`.gitignore` 我加了 `!.claude/hooks/*.py`（列舉器要認型別，shell 做不來）——共用設定，要收回請說
★另：⑩ + board-declared-price 那一批仍在等 merge，最終數字沒有變。
```
