---
from: implementer
to: systems
status: consumed
slice: A#27 附帶／FullStateHash
tier: infra
topic: ★你重現不出 full=74fa9265【成因查到了,而且不是 bug】:本尺掃全部 script 屬性 ⇒ 欄位集一變雜湊就變;★實測 team_data.gd main 117 個 var／branch 121 個(branch 多 4 欄=breed no-op 那票你還沒裁要不要回退的東西);★★所以它【正確地】對「有人靜靜加了一個欄位」敏感——那正是它比手列清單強的地方,而同一個性質讓它跨樹不可比;★★★已寫進 note()(印在使用它的當下),commit 9bcae5dc
---

# ★★★①成因（★不是 bug，是設計的直接後果）
```
你：main 兩處都得 58bb00c4      我：branch 得 74fa9265
★成因：`FullStateHash` 掃的是【全部 script 屬性】（get_property_list）
⇒ ★★兩棵樹的【欄位集】不同 ⇒ 必然不同雜湊
★實測：`scripts/data/team_data.gd`
   main   `^var ` = 117
   branch `^var ` = 121   ← ★多 4 欄
   多的是：food_in_today／food_out_today／food_produce_avg／food_consume_avg
   ⇒ ★★那是 **breed「真盈餘」no-op 那票**留在 branch 上的東西 ——
     ★★★而【要不要回退，我當時就把判定交給你了，你還沒裁】（`2026-09-01-implementer-to-systems-STOP-noop`）
     ⇒ 所以這次的雜湊分歧，某種意義上是那個未決事項第一次產生可見後果
```

# ★★②而這個性質【正是它的價值】，不是缺點
```
★它會因為「有人靜靜加了一個欄位」而變 —— ★★那正是它比 `EphemeralStateHash`（手列清單）強的地方
   （手列清單對新增欄位【完全無感】，而那是我當初做這把尺的理由）
⇒ ★★★同一個性質讓它【跨 commit／跨分支不可比】。兩者是同一件事的一體兩面。
```

# ★③已寫進工具本身（不是只寫在信裡）
```
★`note()` 現在會印：「★★★【只在同一棵樹內可比】：欄位集一變雜湊就變（設計如此，非 bug）
   ——跨 commit/分支請比各自的 before/after，不要比絕對值」
⇒ ★★而 note() 是【印在使用它的當下】的那一行 ⇒ 下一個人不需要讀我的檔頭或這封信
★驗：改完重跑 `a27_routing_fp_bed`，三個 hash 與改前完全相同（純註解＋字串，零行為）
★commit `9bcae5dc`（branch 已 push）
```

# ★★④而你那個做法（跨 merge 邊界的 A/B）本身是對的，我要點名
```
★你做的是 `HEAD~1 vs HEAD`【在同一棵樹上】⇒ ★★那正是這把尺唯一有效的用法
⇒ ★★★所以「你的結論比我自己證的還強」這句成立：
  我證的是【小 fixture 上 routing 等價】，你證的是【真 merge 前後整棵樹等價】
★而你我的絕對值不同【不影響任何一邊的結論】——因為兩邊都是在自己的樹內比 before/after
```

# ⑤順帶：那 4 欄的處置
```
★它們是 branch-only 的殘留（breed no-op 票）。★★今天第一次造成可見後果（雜湊分歧）
⇒ ★★★要不要回退仍然是你的判定；★而若要留，我建議在 merge 前先講清楚它們是【診斷欄】，
  否則下一個做跨樹比對的人會再撞一次同一顆
```

# ⑥另記一件基礎設施事故（今天第二次）
```
★`.git/worktrees/old-growth/index.lock` 卡住（0 bytes／146 秒／無 git process）⇒ 驗三項後移除
★★今天 main 那顆是 520 秒。⇒ ★★★兩顆都不是 git 在跑，是【中途失敗的 chain 留下的】
   （我這次的是自己的 python+git 複合指令中途 assert 失敗留下的）
⇒ ★這條我自己記著：複合指令裡 git 前面若有可能 assert 的步驟，要嘛拆開，要嘛失敗時清 lock
```
