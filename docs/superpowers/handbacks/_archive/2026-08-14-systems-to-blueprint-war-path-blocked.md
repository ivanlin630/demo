---
from: systems
to: blueprint
status: consumed
topic: "[★戰爭之路通不通=雙重堵(code-read定案兩題、evidence-only)·①occupy 7→0 flip:flip機制=_process_occupied_residents(encounter:1402)+一般outpost接管(:1348-1353)全在EncounterSystem戰鬥resolution(:1356 result==attacker_win路)、encounter=ambush/player觸發、headless-no-player encounter_active恒false(同零戰死結構根)→占村combat若走NpcCombat根本不到此flip分支/走encounter則headless不fire→flip結構0;且flip內persona-gate(encounter:1420-1440:cruelty/martial>0.7屠村flip、ambition>0.7+caution>0.5強佔flip、honor/faith>0.6 or溫和→放棄無flip)·dispatch→flip間★無tap→measurer補定7支斷哪段(到combat否/哪系統/到encounter resolution否)②faction攻擊令全年0:攻擊goal(_emit_goal :1080)gate=itype==征服(_select_intent :1058選)、12mo 0=★_select_intent從不選征服(世界survival/守成mode、同crisis-density根;12mo final_intent零CONQUER/EXPAND坐實=守成收斂)、且即使宣了combat flip仍encounter-gated(①堵第二層)·★∴戰爭之路雙重堵:(a)intent從不征服(survival-mode世界)+(b)★capture/flip機制encounter-only(headless恒false)=結構根、同零戰死同源·★重大含意:即使settlement arc把經濟修好、健康世界照樣零征服/零兴衰——因capture/flip綁encounter(headless不fire)+intent survival-gated·『戰爭之路』要通需:①capture/flip脫離encounter-only(走NpcCombat或headless可fire路)②intent survival-mode解除後征服才選得上·序:measurer補occupy funnel tap(7支斷點)→你跟用戶收『兴衰前置=encounter-gated capture根』設計討論(settlement arc後的next候選)·evidence-only禁fix·地基KEEP"
---

# ★戰爭之路通不通 = 雙重堵（code-read 定案、evidence-only）

## ① occupy 7→0 flip
- **flip 機制** = `_process_occupied_residents`（encounter:1402）+ 一般 outpost 接管（:1348-1353）**全在 EncounterSystem 戰鬥 resolution**（:1356 `result=="attacker_win"` 路）。
- encounter = **ambush/player 觸發、headless-no-player `encounter_active` 恒 false**（同零戰死結構根）→ 占村 combat 若走 NpcCombat 根本不到此 flip 分支 / 走 encounter 則 headless 不 fire → **flip 結構 0**。
- flip 內還有 **persona-gate**（encounter:1420-1440：cruelty/martial>0.7 屠村 flip、ambition>0.7+caution>0.5 強佔 flip、honor/faith>0.6 or 溫和 → 放棄無 flip）。
- **dispatch→flip 間 ★無 tap** → measurer 補定 7 支斷哪段（到 combat 否 / 哪系統 / 到 encounter resolution 否）。

## ② faction 攻擊令全年 0
- 攻擊 goal（`_emit_goal` faction_ai:1080）gate = `itype=="征服"`（`_select_intent`:1058 選）。
- 12mo 0 = ★**`_select_intent` 從不選征服**（世界 survival/守成 mode、同 crisis-density 根；12mo final_intent **零 CONQUER/EXPAND** 坐實=守成收斂）。
- 且即使宣了、combat flip 仍 encounter-gated（① 堵第二層）。

## ★∴戰爭之路雙重堵
- **(a) intent 從不征服**（survival-mode 世界）。
- **(b) ★capture/flip 機制 encounter-only**（headless 恒 false）= 結構根、**同零戰死同源**。

## ★重大含意
即使 settlement arc 把經濟修好、**健康世界照樣零征服/零興衰**——因 capture/flip 綁 encounter（headless 不 fire）+ intent survival-gated。「戰爭之路」要通需：①**capture/flip 脫離 encounter-only**（走 NpcCombat 或 headless 可 fire 路）②intent survival-mode 解除後征服才選得上。

序：measurer 補 occupy funnel tap（7 支斷點）→ 你跟用戶收「興衰前置=encounter-gated capture 根」設計討論（settlement arc 後 next 候選）。evidence-only、禁 fix。地基 KEEP。
