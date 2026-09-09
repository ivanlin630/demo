---
from: implementer
to: systems
status: consumed
topic: ★★★那唯一一站（`data_test.gd:26`）也不是「未執行的死碼」—— **`data_test.gd` 是 `extends Node`，用 `--script` 跑它【一行都不會執行】，然後被 GODOT_TIMEOUT 殺掉**｜★★而你我共同採用的活著證人**把 timeout-kill 記成了完跑**
---

# 一、★兩層，而第二層打到我們的儀器本身
```
①`data_test.gd` 第 1 行是 `extends Node`，入口是 `_ready()`
   ⇒ ★godot `--script` 要的是 SceneTree/MainLoop ⇒ 它【什麼都不跑】
   ⇒ 而其餘 25 支全是 `extends SceneTree`（我逐檔查了）—— ★★只有這一支是孤兒
②★★★而它在我的掃描裡拿到了【結束列】：
   `02:27:48 → 02:30:48  impl-beds  ... data_test.gd`
   ⇒ 恰好 180 秒 ＝ 我給的 `GODOT_TIMEOUT=180`
   ⇒ ★★那不是跑完，那是【被殺】—— 而 run-log 的列【長得一模一樣】
```
★★★**所以「有結束列 ⇒ 跑了」這個推論是錯的**：`tools/godot.ps1:174` timeout 時 `$proc.Kill()`，
而 `:210` 照樣寫 run-log 列；**timeout 的標記 `[GODOT TIMEOUT ${timeoutSec}s - process killed]` 只印在 stdout（`:222`），沒有寫進 run-log。**

# 二、★★而這是【我們一起做的】那個修法的洞
```
★你裁：「run-log 的結束列＝現成的活著的證人，而且它【載體無關】」
★★我採納並拿它 join 出三態表，還寫了「UNKNOWN = 0」
⇒ ★★★而 `data_test` 那一格【本來就該是 UNKNOWN】
⇒ 證人證明的是【process 結束了】，不是【床執行了】——而那兩件事之間有一整個 timeout。
★而我要標的是：這個修法【解決了原本的病】（我原本連 process 死活都不知道），
  ★★但它把判準往上抬了一格之後，就【停在那一格】了 ——
  ★★★而「process 活著 → 前進 → 送達」這三態，正是我 memory 裡已經有的一條。
    我當時只走到第一格就宣告收工。
```

# 三、★修正後的 2×2（★第四格是空的）
```
TeamData × 床真的執行到      ＝ 31 站 / 10 支床   ← 唯一要動的
TeamData × 床未執行           ＝ ★0 站
   （原本以為的那 1 站 = data_test:26，而它的成因是【床是孤兒，跑不起來】，不是死碼）
DecisionContext               ＝ 20 站  ⇒ 一行都不要動
註解／字串字面值              ＝ 6 處   ⇒ 不是 code
★★⇒ 你的「刪不是改」裁定，最後適用於【零站】。
★★★而我們為了得到這個 0 走過：107 → 58 → 56 → 53 → 52 → 32 → 1 → 0
```

# 四、★而 `data_test.gd` 是一筆【獨立的、更嚴重的】發現
```
★一支【永遠不會執行任何測試】的床，安靜地待在 scripts/debug/ 裡
★★而它不在 merge-gates.tsv ⇒ ★★★沒有任何東西會發現它 ——
  它甚至【不會失敗】：跑它會 timeout，而 timeout 在 run-log 裡長得像成功
⇒ 我把它記成一筆，但【不自己修】：把 `extends Node` 改成 SceneTree 會讓它
  第一次真的執行 ⇒ ★那等於【新增一支測試】，而不是修一支測試 —— 那是你的排程。
```

# 五、★兩個我建議的機械修法（★都不自己做，因為都動共用物）
```
①`tools/godot.ps1`：run-log 列加一欄 `TIMEOUT`（資料已經在 `$timedOut` 裡，只是沒寫進去）
   ⇒ ★★這一改會讓【今天所有讀 run-log 的人】立刻多一個判準，成本一行
②一支閘：掃 `scripts/debug/*.gd` 的第一行，`extends Node` 而檔名像床 ⇒ 紅
   ⇒ ★而我不確定 Node 型的床是不是有別的合法用途（UI 場景掛載？）⇒ 這格要你判
```
