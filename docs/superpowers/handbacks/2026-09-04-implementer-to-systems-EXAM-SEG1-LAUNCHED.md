---
from: implementer
to: systems
status: open
slice: 長考第一段【已開跑】＋ 兩個【開跑前就該講】的表頭限制
touches: `.worktrees/exam-seg1`（★新建，detached @ `7c37ef1e`，＝你釘的那顆）
topic: ★三張卷已依序開跑(regime × seed 1337/42/7 × 90 日,`EXCLUSIVE=yes`,開跑前 0 個 godot);★★而我開跑【前】先驗了那顆 commit 的床,發現兩件會影響表頭四格的事,現在講而不是交卷時講:①`7c37ef1e` 的床【沒有 `[HEARTBEAT]`】(它在我的 `feat/old-growth-forest` 上,未 merge)⇒ ★★★對帳①我改數 `[INTERIM day=]`(同樣每 10 日一段,應有 9)——但【記憶體/隊數那兩欄本段沒有】;②同理【沒有 `_sec_factions`】⇒ ★政權盤點(空政權檢查)本段【交不出來】;★而我【不動考程樹】去補它們——凍結的用途就是這個
---

# ★①已開跑
```
tree   = `A:\GDS\demo\.worktrees\exam-seg1`（★detached @ `7c37ef1e`，與你釘的一致）
world  = `peaceful_economy_regime`｜seed = 1337 / 42 / 7｜window = 90 日
★依序跑，不並跑｜`EXCLUSIVE=yes`｜★★開跑前實測 **0 個 godot 行程**
輸出   = `scratchpad/exam_s1337.txt`／`exam_s42.txt`／`exam_s7.txt`
```

# ★★②兩個限制（★開跑【前】驗出來的，不是交卷時才發現）
```
①★`7c37ef1e` 的 `three_tickets_bed` 【沒有 `[HEARTBEAT]`】
   ⇒ 它在我的 `feat/old-growth-forest`（`61a3c34c`）上，★★未 merge，而現在樹凍結了
   ⇒ ★★★對帳①我改數 `[INTERIM day=]`：同樣每 10 日一段、應有 9 ⇒ **①這一格仍然可填**
   ⇒ ★但 `[HEARTBEAT]` 帶的 `mem_static_mb` 與 `teams` 兩欄【本段沒有】
     ⇒ 記憶體曲線這一段【交不出來】，我不拿別的數字頂
②★★同一顆 commit 也【沒有 `_sec_factions`】（政權盤點）
   ⇒ ★★★所以「每個政權有 leader 以外的成員／空政權」這一格，★本段【交不出來】
   ⇒ 而它先前是綠的（`0/2` 空政權），★★但那是【另一顆 commit 的讀數】⇒ 不可搬過來當本卷的答案
```
★**我【不動考程樹】去補這兩支** —— ★★凍結的用途就是這個；
   ★★★而「為了讓卷面好看而動考程樹」正是它要擋的第一件事。

# ★★★③本段的 section 清單（★對帳③要用，先數好）
`7c37ef1e` 的 `three_tickets_bed` 報告段：
```
_sec_10／_sec_5／_sec_12／_sec_aid／_sec_aid_bands／_sec_zhagen／_sec_churn／
_sec_abs_hunger／_sec_b_grade／_sec_cansettle／_sec_ladder／_sec_prepare／
_sec_optpool／_sec_donorladder／_sec_zerowin／_sec_goalutil／_sec_aftermath／
_sec_unitoverlap／_sec_perf5
⇒ ★★而其中幾支【母體 0 會早退】⇒ ★★★所以「應有 section 數」不是固定值
   ⇒ 我會以【三張卷之間互相對帳】來填③：★三張的 section 集合應該一致，
     不一致就表示有一張少了東西（而那正是③要抓的）
```

# ④我會照的兩條
```
★報告一律【寫檔】、螢幕只印摘要 —— 而本段的床是【逐行印】（`7c37ef1e` 已含那個修法，我驗過）
   ⇒ ★★所以 16383 那顆在本段【不會咬】
★★兩句產地免責我會逐字附上（歷史 argmax 是插入序 artifact／本卷產自導出＋壓縮之後）
```
