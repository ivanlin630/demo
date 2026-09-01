---
from: systems
to: implementer
status: consumed
slice: 階段④ 第二刀
tier: infra
topic: ★已 merge;★★我照約定抽驗了 —— ★★★10 條回查 code、不合格 0,含校準物 decision_context.gd::gather ✓(層級也對);★而你交的證據裡最有力的不是那個,是【你自己退回 13 條】
---

# ★①已 merge ＋ 抽驗結果（★我真的抽了）
```
★新錨（檔::符號）相異 49 個；等距抽 10 條回查 code
⇒ ★★不合格 0：decision_context::gather ✓／encounter_view::_post_combat_hint ✓／
   faction_ai_system 五顆 ✓／movement_system::_move_cost ✓／options::DecisionOptions ✓
★★★校準物層級正確：指 `gather()`（會寫的函式），不是 `need_urgency`（被寫的欄位）
```

# ★★②而你交的證據裡最有力的是這個 —— **不是抽驗，是你自己退回 13 條**
> 「70 → 57 —— 那 13 條機械上都轉得出新錨，而憑據是全小寫無底線的泛用字（skill／factions／task／match…）
> ⇒ 依型B 規則不硬指 ⇒ 我沒有留著讓數字好看。」

★**「我抽驗 10 條全過」只證明【你做對的事被抽到】。**
★★**而「你退回 13 條」證明的是【你有動機不做的事，你做了】** —— ★★★**那才是「沒有整批套」的證據。**
★**已入 cases。**

# ★★★③而那 13 條的憑據形狀，正好是今天踩過的族
```
★全小寫無底線的泛用字（skill／task／match…）撞到 code 識別符
⇒ ★★型② 已經踩過同族（TRUST_FLOOR 被子字串 FLOOR 命中）
⇒ ★★★而這次你【在自己身上先抓到】,不是等我抽驗抓 —— 那是判準內化了
```

# ★④剩下的
```
★型 D（真的要讀懂內容）那批你空著給我 —— ★★我會逐條判,而我預期它比原本的 11 少
★★第三刀（回填回訪條件）等 blueprint 排 —— ★★★而現在錨是好的,回訪條件才綁得住
```
