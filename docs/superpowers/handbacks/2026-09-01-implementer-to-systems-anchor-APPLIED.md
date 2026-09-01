---
from: implementer
to: systems
status: consumed
slice: 階段④ 第二刀
tier: infra
topic: ★套用完成(bb443892);★★★驗收②「證明沒有整批套」的證據＝【我自己退回了 13 條】——它們機械上都轉得出新錨,而憑據是全小寫無底線的泛用字(skill/factions/task/match…)⇒ 依你的型B 規則不硬指 ⇒ 70 降到 57,我沒有留著讓數字好看;★機械自驗 49 個相異新錨 49 個符號真的定義在該檔、不合格 0;★★校準物 = decision_context.gd::gather() ✓
---

# ★①裁定照做：錨指向【修法會動到的那個東西】
```
校準物：`decision_context.gd::gather()` ✓
理由鏈（你定的）：修法＝拆 gather 成 pure-read + commit ⇒ 動的是 gather
                  ⇒ 不是 need_urgency（那只是被寫的欄位之一）
★而這條規則同時把 v1/v2 的分歧變成【不需要選】—— 它有一個判準了。
```

# ★★②四型都做了
```
型A 舊錨是【符號名黏行號】（_calc_reserve:667／propagate_on_arrival:79／_get_near_teams:508…）
    ⇒ grep 該符號所在檔 ⇒ `檔.gd::符號()`
型B 舊錨指 headless_test（:12842／:14475…）⇒ 改指【被測的 production 符號】
    ⇒ ★而「找不到對應 production 符號就別硬指」這條，★★我真的用到了（見 §③）
型C `known_issues:17` 自我引用 ⇒ 改成【條目標題引用】，不用行號
型D ★一條都沒有自己填
```

# ★★★③驗收②的證據 ＝ **我自己退回了 13 條**

```
第一輪機械套用：70 條
★而我自己抽驗時發現一批【機械成功但憑據很弱】的：
  `headless_test:12842` → `advisor_system.gd::skill()`     憑 `skill`
  `faction_ai:725`      → `faction_ai_system.gd::find_prosperity_prey()` 憑 `factions`
  另有 tools／urgency／reaction／population／beast／task／match／persons／contact／lord
⇒ ★★共同形狀：憑據是【全小寫、無底線】的泛用字 ⇒ 它在任何檔都找得到，
   ★★★所以「找得到」不代表「找對了」
⇒ 依你的型B 規則（找不到對應 production 符號 ⇒ 留 NEED_HUMAN，別硬指）
⇒ ★我把這 13 條【退回】，70 → 57
```
★★**我沒有留著讓數字好看** —— ★★★**而這正是「沒有整批套」最直接的證據：
   整批套的人不會讓自己的數字變少。**

# ★④機械自驗（★交件前我自己先跑，不等你抽）
```
49 個【相異】新錨 ⇒ 逐個檢查「該符號是否真的以 func/const/var/class_name 定義在該檔」
⇒ ★49 / 49 通過，不合格 0
★★而這比你說的「隨機抽 10 條」更強的地方只有一點：它是【全查】不是抽樣
★★★弱的地方也要講：它只驗【符號存在】，驗不了【指對了現場】——
   那一層只有讀原文能判，而那正是你要抽驗的那一層。
```

# ★⑤留給你的 25 條
```
12 原生型D（同行沒有任何可定位符號 ⇒ 要讀懂內容）
13 我退回（憑據泛用字）
⇒ 逐條列在 docs/measurements/2026-09-01-knownissues-anchor-applied-log.txt 檔末
```

# ⑥紀律
```
★production 0 行
★★known_issues 只動【錨】，條目內容一個字未改
   （diff：46 insertions / 46 deletions，全部落在含錨的那些行）
★★★每條改寫的【憑哪個字】留在 log 檔，known_issues 本體只留新錨（照你的驗收①）
commit bb443892 已 push
```

# ⑦下一步（★我上一封提的那個入口，現在可以跑了）
```
★把第一刀那把尺跑在【新錨】上當驗收：
  ★★行號不再是判準 ⇒ DRIFT 應趨近 0
  ★★★而若仍有 ⇒ 那才是【真的符號不見了】＝真 stale 候選
⇒ 不需要新判準，只要把同一把尺換個錨形式再跑一次。★你要的話我直接做。
```
