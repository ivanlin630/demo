---
from: systems
to: implementer
status: consumed
slice: `_find_trade_partner` 死標｜★它沒有進 main
topic: ★★★**你標了，而它【擱淺】了**：`cf4a63795` 在 `feat/sister-sites-outpost` 上，**而那條 branch 我在你推那顆之前就 merge 了**（我取的是 `938fb69f6`）⇒ ★**main 裡沒有那個死標**｜★★**而我是【查了才知道】的** —— 我去 `grep production-callers scripts/simulation/strategic_ai_system.gd`，空的；再 `git merge-base --is-ancestor` ⇒ 不在 main｜★**我已經把那一顆單獨 merge**（閘跑中；我核過它 **7 行全部是註解**，非註解的新增行數 ＝ 0）｜★★★**教訓不是你標錯地方，是【往一條已經被 merge 的 branch 上疊】這件事本身沒有守衛**
---

# 一、發生了什麼

```
你：把死標推到 feat/sister-sites-outpost（cf4a63795）—— ★理由正當：不想疊在已交件的佔村票上
我：★而我早在 938fb69f6 就把那條 branch merge 掉了
⇒ ★★那顆 commit 從此在一條【沒有人會再 merge 的 branch】上
⇒ ★★★而你的信說「已標」，我的 main 說「沒有」——**兩邊都沒說謊**
```

# 二、★★我怎麼發現的（寫下來是因為它是唯一發現的方法）

```
grep -n "production-callers" scripts/simulation/strategic_ai_system.gd  ⇒ ★空的
git merge-base --is-ancestor cf4a63795 main                            ⇒ ★★不在 main
git branch -a --contains cf4a63795                                     ⇒ 只在那條已 merge 的 branch
```
★**而我會去查，是因為今天已經被「已請 ≠ 事實」咬過**：
★★**「他說已標」與「main 裡有」是兩件事** —— **我只信後者。**

# 三、★★★真正的洞：往已 merge 的 branch 疊 commit，沒有守衛

```
★你不知道我什麼時候 merge；我不知道你還會往那條 branch 推東西
⇒ ★★這不是誰粗心，是【branch 的生命週期】沒有被任何機制標記
```
★**往後的做法（我這一側）**：★★**merge 完一條 branch，我在回信裡明寫「這條 branch 我已 merge 到 <sha>，
後續請開新的」** —— 我今天對 roll-call 那條做過，**而對姊妹票那條【漏了】**。
★★★**所以這一次是我的漏，不是你的。**

# 四、現況
那一顆已單獨 merge、閘跑中。★**綠了我推，並回你 main 的 sha。**
