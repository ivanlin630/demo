---
from: implementer
to: systems
status: consumed
slice: 改成新檔（dd07cb34）—— ★舊 `peaceful_economy.json` 已還原成【一個字不動】
touches: config/peaceful_economy_regime.json（新）／config/peaceful_economy.json（已還原）
topic: ★★★我上一顆 `c11ccf7c` 是【就地改】,方向錯了 ⇒ 本顆把舊檔還原、政權寫進新檔 `config/peaceful_economy_regime.json`;★而我沒有改寫歷史(不 rebase 不 amend)——★★用一顆【新 commit 還原】,那顆錯的留在紀錄裡;★★★而理由正是我今天自己立的那條的【資料版】:就地改會讓舊 verdict 失去它的世界,而那份世界是它唯一的證據;★驗證仍未跑:90 日 pilot 獨佔中
---

# ★①已改（★逐項可複驗）
```
`config/peaceful_economy.json`         ⇒ ★還原（`git checkout c11ccf7c^ --`），★★faction 欄位全數消失
`config/peaceful_economy_regime.json`  ⇒ ★★★新檔：A 6／B 4／獨立 2
   `_doc` 開頭寫明【本檔＝政權版、舊檔凍結存檔供舊 verdict 複現】
   ＋先前那三句（leader 是代理／`leader_team_id` 無 runtime 重指派故永久不自我修正／8↔10 拆開是商隊 tag 蓋過地理）
```

# ★★②而我【沒有改寫歷史】
```
★沒有 rebase、沒有 amend ⇒ ★★那顆錯的 `c11ccf7c` 留在紀錄裡
⇒ ★★★而那正是我今天自己講過的分界線：【時序性紀錄只能追加】
   —— commit 是紀錄，config 是【會被讀的東西】
⇒ 所以 commit 留著、檔案還原：★兩類各自照各自的規則
```

# ★★★③而 blueprint 那條，是我今天那條規則的【資料版】
```
★我今天寫：時序性紀錄（handback／commit）只能追加；狀態性文件（memory／手法檔）就地改
★★而 blueprint 這條加的是第三類：★★★【某份 verdict 的世界】——
   它既不是紀錄也不是狀態，它是【那份結論的證據】
⇒ 就地改會讓舊 verdict 失去它的世界，★而那份世界是它唯一的證據
⇒ ★★所以規則是：**被某個結論引用過的輸入，不可就地改；要改就新開一份。**
   ★★★而它跟「新檔會不會長太多」無關 —— 兩個世界都要能重建
```

# ④仍未跑（★同上一封）
```
`bo1wwhryt`（90 日 pilot）★獨佔中 ⇒ 跑 gates／床會污染它的 wall-clock
⇒ pilot 完成後才跑：政權驗收兩條硬的 ＋ 同 seed 前後對照
★★而「前後對照」現在的定義也跟著變了：不是【同一個檔改前改後】，
   是【舊檔 vs 新檔】—— ★★★而那反而更乾淨：兩個世界同時存在，可以各跑各的
```
