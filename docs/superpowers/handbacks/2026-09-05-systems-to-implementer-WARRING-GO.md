---
from: systems
to: implementer
status: open
slice: ★★★warring × 3 × 90 日【開跑】（≈8.5 小時）
tier: slice
topic: ★基線接受、warring 授權在(用戶既有授權,blueprint 已推 TG 通知非請示);★★凍結已重建(C-seg2),★而我訂正了 world_sha 的定義:【不要用 HEAD:scripts】—— 它含 scripts/debug,而一次卷面補印就讓它從 edaeb4ad 變 f7f6b142 ⇒ 改用【sim/data/config 三棵樹】,與凍結閘的 WORLD_RE 同一組;★★★而 8.5 小時的跑只有一條紀律最重要:【每張跑完立刻對帳】—— 被砍時只損那一張,而不是在終點才發現
---

# ①開跑
```
world=warring_states｜seed=1337/42/7｜90 日｜★單位成本 169.3 分/張 ⇒ ★★總計 ≈8.5 小時
commit=44b25eb7｜★★★world_sha: sim=61f2ab27 data=c9ca7ae7 config=c7ceb6b3
★檔名帶 run-id｜★★EXCLUSIVE=yes（時間類要獨佔；★而計數類可並跑，但這一跑很重，建議序列）
```

# ★★②world_sha 定義我訂正了（★你會用到）
```
★原本我寫 `HEAD:scripts` ⇒ ★★而它含 `scripts/debug` —— 一次卷面補印就讓它變了
   ⇒ 那正是這個欄位要【避免】的混淆:卷面改動看起來像世界改動
⇒ ★★★改用三棵樹:sim=`HEAD:scripts/simulation`／data=`HEAD:scripts/data`／config=`HEAD:config`
   ⇒ ★與凍結閘的 WORLD_RE 同一組 —— 兩個判準用同一個定義,才不會各說各話
```

# ★★★③8.5 小時的跑，最重要的一條紀律
```
★【每張跑完立刻四格對帳】—— ★★不要等三張都跑完
⇒ ★★★被砍時只損【那一張】,而不是在終點才發現(而 warring 今天被砍過五次)
★而逐段落地已在:串流 wrapper ＋ 逐日 TickPerf ＋ 每 10 日 HEARTBEAT
   ⇒ ★被砍留得下已跑段落;★★而「0 bytes」那個形狀已不會重現
★★★若某張被砍:【只重跑那一張】,而作廢的產物【刪掉】不是「記得不要用」
```

# ④卷面（★沿用模板，而本段有四件特別的）
```
①★存活【四分】,而【卡在單一迴圈】那格【由 QA 填】—— ★★判定來源＝故事稽核
   ⇒ ★★★而 QA 給的簽名要用上:【同一 option 反覆 committed ＋ 至少一項資源全程完全不變】
     （★比我原本的「資源沒下降」準:那個包含上升,方向會不一致）
②★【合併屍體】另列一行,不計入存活分類母體 —— ★★而每個 per-team 率要標【含/不含】
③★徵收五站(贏→dispatch→committed→軌跡→資源真的移動)—— ★★peaceful 基線是 dispatch 94 → 真轉移 8（8.5%）
   ⇒ ★★★warring 是【併入需求更高】的世界,這一鏈的數字是本段最想看的東西之一
④★兩格【答不了】照舊並附原因(需要 production tap 而凍結中)
```

# ⑤★而收斂則在本段仍然有效
```
★輪次已用畢 ⇒ ★★本段【無論撈出什麼只標不修】—— 具名上卷,不重跑、不開刀
⇒ ★★★而那不是「不修」,是【不讓修法推遲終卷】—— 撈到的東西在終卷之後排隊
```
