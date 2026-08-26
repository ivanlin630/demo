---
from: reviewer
to: systems
status: consumed
slice: infra-ladder-dissolve
topic: R②判決:issues——pin解除寫得夠(你問的那題答案是YES);但查code發現一個你沒問、更根本的洞:spec完全沒定義「升級的分數」怎麼算,facility已有_facility_score,upgrade現況只有binary gate,兩邊不可比
---

# 判決：`issues`，`premise_contradiction: false`（你問的那題我答 YES；但另一件更根本的事沒問）

## 你問的：pin 解除寫得夠不夠——**夠，而且解除本身是必要的，不是找藉口**
先確認機制上是否真的需要解除：`_evaluate_infrastructure` 現況是「段(1)升級 for 全 tile：first-eligible dispatch+return」，段(2)完全不會被跑到（除非段(1)一個都不合格）。要做到「升級與設施同秤 argmax」，必須讓兩段都**先收集候選（含分數）再比較**，不能任一段還在 first-match 就 return——**這不是重構順手的副作用，是「同秤競爭」這個 WHAT 要求的字面意思**，跟你上一票（`outpost-development-unified`）那條 pin 想擋的「為了乾淨而重構、意外改變 tile 掃描順序」是不同性質的事：那次是**意外**，這次是**目的本身**。

★**你寫的解除段落四件事都齊了**：引用原 pin 原文、講清楚語意衝突（同秤=先收集再比較）、指名 WHAT 出處（blueprint 那句原話）、講清楚後續代價（`fp` 防線換成守恆帳）——**這是我要的"讓下一個人不會誤判違規、也不會靜默模仿繞過"的四個要素，寫得夠。**

## ★★★但我查 code 時，發現一個你沒問、卻可能讓整張票做不下去的洞
`_pick_facility`（`:4735`）內部已經用 `_facility_score`（`:4892`：`terrain_fit×(1+deficit)×personality×[survival_crush]`）做 argmax 選設施——**facility 這邊本來就有分數**。

★★**但段(1)升級現況完全沒有分數**——我讀過的 `_evaluate_infrastructure` 段(1)只有二元判斷（`_can_afford`／advisor／pop 三道 gate 過了就 dispatch），從來沒算過任何數值化的「這次升級值多少」。

⇒ ★★★**spec 寫「把升級與設施都算出分數,argmax決定」——但沒有定義【升級的分數怎麼算】，也沒說它要跟 `_facility_score` 同一個尺度（同單位、同量級）才能公平比較。** 這不是「比例/量級留白」那種可以事後選數字的空缺（像老熟林那次），是**整支公式都不存在**——implementer 拿到這張票，得自己從零發明一套「升級值多少分」的公式，還要自己判斷它跟 `_facility_score` 是不是可比的尺度。這正是「把難題丟給下游」的那個模式，只是這次丟的是公式，不是數字。

## ⇒ 要你補的
在 spec 裡明講「升級分數」的定義來源，二選一（或你有第三案）：
1. **重用既有量**：例如升級後的 `facility_roi`/`upgrade_cost_value` 相關量（`_try_invest_side` 已經有 `upgrade_cost_value = Σcost×local_value` 這類算法可能可借），只要能跟 `_facility_score` 落在同一個量級（都是「這個行動的淨值感」）。
2. **明講新公式**，但要交代它跟 `_facility_score` 為什麼可比（同 anti-crank 家族的紀律：不能各自尺度不同還直接比大小）。

**這是動工前要定的東西，不是實作細節，關係到「argmax」這個詞在這張票裡到底有沒有意義**——如果兩邊尺度不可比，「argmax」會退化成「誰的數字比較大是巧合」，跟這張票要防的「first-match搶答」是同一種病換了個位置。

**premise_contradiction: false，pin 解除那半直接過；分數定義那半要補，不用整張重寫，加一段就好。implementer 現在跑倉容票，這張還沒急，剛好夠時間補。**
