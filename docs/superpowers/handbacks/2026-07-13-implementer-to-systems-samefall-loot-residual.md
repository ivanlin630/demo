---
from: implementer
to: systems
status: consumed
topic: [卡點·裁A後] survival-set分組解p2a但掠奪-in-set致fed溫和隊loot-via-fallthrough(spec掠奪殘留);需裁
---
# 卡點：裁 A survival-set 分組解 p2a，但 掠奪-in-set 致 fed 溫和隊 loot

`_need_category`（裁 A）實作完，`_test_reorder_same_need`（含 survival-set 案）PASS，**p2a 2 測回綠**（投靠不被埋）。但新破 `_test_p1_loot_option:15506`——**正是 spec §驗收「掠奪 排除殘留」的另一半**（裁 A 把 併入+掠奪 都納 survival-set）。

## 現象
- `_test_p1_loot_option`(b)：**食足(food 500)** 溫和隊（低殘忍/好戰）+ 鄰弱獵物 → 期望 `!= TASK_LOOT`，**實際 = 掠奪(LOOT)**。
- (a) 殘忍隊→掠奪 仍綠（正確）。

## 機制
- 掠奪 ∈ `SURVIVAL_OPTION_SET` → `_need_category`="survival"（裁 A）。
- fed 溫和隊 rank[0] 為某 survival-set 成員（佔村/覓食類）→ top_cat="survival" → 掠奪 grouped 進 survival 組。
- 組內 util 序：溫和隊 掠奪 util 低（低 weight）=組內末，但其他 survival 組員（覓食/佔村…）此 setup 不可派（無 forage tile/佔村條件不足）→ walk fallthrough **唯一可派=掠奪** → LOOT。
- ∴ 掠奪 納 survival fallthrough 組 → fed 溫和隊在「同組其他不可派」時落到掠奪，**繞過人格 weight gate 的原意**（溫和不劫掠）。

## 判斷：非硬 survival-dominance 失效，是 掠奪-fallthrough 語意 tradeoff
- 溫和隊 fed → 不是餓，本不該進 survival fallthrough；但其 rank[0] 恰為 survival-set 成員使 top_cat=survival。
- 掠奪作為「絕境搶糧」fallthrough（餓隊）合理；但 **fed 溫和隊經 fallthrough 掠奪 = 人格 gate 被繞**（weight 低但 last-resort dispatchable 仍中）。

## 需裁決（不猜，spec §已 flag 掠奪）
**A. 掠奪 排除出 fallthrough 組（併入保留）**：`_need_category` survival-set 但掠奪例外→按 affinity(esteem)。餓隊 fallthrough 保覓食/買糧/紮營/併入/乞食/返家(食物+投靠)，**掠奪不納**（掠奪是主動搶非被動求生，人格 weight 應主導非 fallthrough 保底）。解 p1，保 p2a。
**B. 掠奪納組但加人格 gate**：fallthrough 到掠奪時檢 weight/殘忍門檻（低殘忍不落掠奪）。較複雜、動 dispatch loop body（spec 說 loop body 不動）。
**C. 放寬 `_test_p1_loot_option`(b)**：fed 溫和隊在唯一可派=掠奪時掠奪=合理絕境（即使不餓，鄰弱獵物+其他不可派）→ 標 organic-verified。但「溫和不劫掠」是刻意人格 invariant，放寬恐掩損失。

我傾向 **A**（掠奪≠被動求生，是主動掠奪-人格驅動；fallthrough 保底該是「求生食物+投靠」非「劫掠」。併入=認慫求保護 vs 掠奪=侵略，語意不同，fallthrough 納併入不納掠奪合理）。解 p1 + 保 p2a。但涉 `_need_category` 準則（哪些 survival-set 成員真該 fallthrough）——**你裁**。

## 附
- `_need_category` + reorder + wire code + tests（reorder PASS/p2a 綠）在工作區未 commit（等準則定）。
- 餘 headless = 3 pre-existing。determinism/融合閘待裁後跑。standby，不自改準則、不問 user。
