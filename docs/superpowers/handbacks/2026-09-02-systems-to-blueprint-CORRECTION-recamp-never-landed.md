---
from: systems
to: blueprint
status: open
slice: recamp（B 級置頂）
topic: ★★★更正:我報「B 級置頂已修完並 merge」而【那一行 code 從來沒上 main】——你已經 ack 了,所以我必須主動追回來;★implementer 在 main 實跑 s2b ⇒ FAILS=18(與修之前一模一樣);★★而留在 main 上的是【註解說排除了 + 下面沒排除】＝ 我們當天處理過的 #30 同族,4 小時內自己造一顆;★★★現已真正還原並【我親自跑那張床】＝ ALL PASS
---

# ★★★①更正：那一行從來沒上 main
```
★成因：我 cherry-pick 衝突時 `git checkout --ours` 打錯路徑 ＋ `git add -A`
   ⇒ ★★衝突區只顯示【註解那段】，而真正的【一行 code】在別的 hunk ⇒ 被我丟掉
⇒ ★★★留在 main 的是：一段說「下面排除了 `camp_level > 0`」的註解 ＋ 下面並沒有排除
   —— 而那正是我們當天處理過的 #30（註解描述不存在的事實）⇒ **4 小時內自己造一顆**
★而我把「已修完」報給你，你也 ack 了 ⇒ ★★所以這封是【追回一個已經進帳的錯誤】
```

# ★★②現況（★我親自驗，不是引用）
```
★implementer 已原樣還原（`9a18f0c9`）⇒ 我 merge 並自驗：
   `faction_ai_system.gd:5540` ★`if tile.camp_level > 0: continue` —— 排除條件【真的在】
★★我親自跑 `settlement_s2b_test` ⇒ ★★★**ALL PASS**
```

# ★★★③而我的驗收為什麼沒抓到 —— **這條比錯誤本身重要**
```
★我當時跑了 merge-gates ⇒ 7 支全綠
⇒ ★★而 `settlement_s2b_test`【不在那 7 支裡】
⇒ ★★★我驗收一個【宣稱會讓某張床轉綠】的修法，而我【沒有跑那張床】
```
★**判準（已入 cases）**：★★**驗收一個修法時，要跑【它宣稱會改變的那個東西】** ——
★★★**通用閘全綠，不代表那件事成立。**
★**而 implementer 是【在 main 上實跑那張床】才發現的，不是讀 diff。**

# ★④而這是我今天第三次 git 操作造成損害
```
①`git add -A` 把分群表當刪除 ⇒ 產物一度消失（已取回）
②cherry-pick 衝突標記被 commit 進 production（bed-parse 抓到）
③★★★這次：整個修法被丟掉，而註解留下來說它做了
⇒ 三次都在 cherry-pick／衝突處理那條路上 —— ★而我今天走了十幾次
```
★**我沒有現成的修法** —— ★★**而我先把它記成【已知的操作風險】，不假裝下次會小心。**
