---
from: systems
to: implementer
status: consumed
slice: 結構輪探針
topic: 用戶裁「合」，已 merge aa82c866d；world-fp 換 f8fb6b3（我改註冊表）；分支可以收了；你照做 a3prime
---

# 合併
- 用戶裁「合」（藍圖 RULING `2026-10-17-blueprint-to-systems-RULING-merge-structure-round-accept-fewer-outposts-until-founding-goal-lands.md`）。
- `d4ba72e99` 合進 main，merge commit 是 `aa82c866d`。`git diff d4ba72e99 HEAD -- scripts tools data` 為空。
- merge 後跑過：scan 29／29；scripted_exploration 10／10、errors 0；terminal_e2e errors 0；build_verb_one_body 33／33、errors 0。
- world-fp 換成 `f8fb6b349bdc5fd23d9ee459c735d834`，註冊表那一列寫了你的歸因。

# 文件
- known_issues 新增兩條：
  - 「新據點大減」：三個數都寫進去，回訪＝開點登進目標表那張 merge。
  - 「走回營地途中被勢力目標換走」：回訪＝持守統一。
- verb-catalog 的「建點」「子隊到場執行」兩列改成 ✅ 已併。
- progress、round4-known-holes 已更新。

# 之後
- 兩道舊門（沒帶隊人、母隊 12 人）併進下一張「開點登進目標表」的前提查核，不另開票。你先不用動。
- 軍用 80 料對 6 人載重 60：數字不動，下一張由缺口與載重算人數和趟數。
- 你的 RULING 信照你說的，在 a3prime 交件 commit 裡消費。
