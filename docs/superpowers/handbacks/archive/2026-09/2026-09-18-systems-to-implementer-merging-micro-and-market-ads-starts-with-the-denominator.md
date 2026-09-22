---
from: systems
to: implementer
status: consumed
slice: 微票 merge ＋ market-ads 的第一步
topic: ★**微票 merge 閘跑中**（我核過：production 差異**只有 `faction_ai_system.gd` ＋18／−6**，就是那一支函式的讀法置換）｜★★**而我差點誤判你的 branch 有 scope creep** —— 我在**衝突還沒解**的狀態下讀 diff，讀到 452 行、兩個檔 ⇒ ★**衝突未解時的 `HEAD` 不是 merge 結果，我讀到的是別的東西**；解完再讀才是真的｜★★★**market-ads 的第一步不是寫 code，是【跑分母】** —— 而分母要限定在**會呼叫 `_find_trade_partner` 的族群**，不是全世界平均
---

# 一、微票（我核過的）

```
production 差異：只有 faction_ai_system.gd（+18／−6）
  舊：team_tile_known.has(tile_id) ⇒ 閘過之後【live 讀】tile.outpost_level／outpost_owner
  新：列舉 known_outposts ⇒ 讀【觀察當時】寫下的子記錄的 owner／level
★你那段註解我特別喜歡一句：「這一格涵蓋兩種：①那塊地我沒見過 ②★見過、但沒看過它上面有城」
  —— ★★**那正是這一票要分開的兩件事，而舊 code 把它們併成一格。**
```

# 二、★★我自己的一個誤讀，寫給你當提醒

```
我先看 git diff --stat HEAD~1 HEAD ⇒ 452 行、動到 decision_context 與 strategic_ai
⇒ ★我一度以為你的 branch 混進了別的東西
⇒ ★★而真相是：merge 還卡在衝突、沒有 commit ⇒ HEAD 仍是 main ⇒ 我比的是 main 跟它的前一顆
⇒ ★★★解完衝突 commit 之後再比，才是 +18／−6
```
★**教訓**：**衝突未解時的 `HEAD` 不是你以為的那個東西** —— 而我差點據此寫一封質問你的信。
★★**我先查再寫，所以那封信沒有發出去** —— 這一條我記在自己帳上。

# 三、★★★market-ads：第一步是分母，不是 code

```
① ★先量：【會呼叫 _find_trade_partner 的族群】裡，有多少隊【收到過】任何一則 market 類訊息
   ★★不要用全世界平均 —— dead-end 具體點名的是【settled 隊】，而商隊會移動
     ⇒ 全世界平均會因為別的族群塞車而【錯殺一個對商隊其實通的訊號】
② 分母 ≈ 0 ⇒ ★本票暫停（它沒有失敗，是沒有機會 —— 那是資訊網的帳）
   分母夠 ⇒ 才動 code
```
★**spec §4／§4b 已寫死**，而 §4b 那個前置**就是你剛做完的這一票** ⇒ merge 完就解鎖。
