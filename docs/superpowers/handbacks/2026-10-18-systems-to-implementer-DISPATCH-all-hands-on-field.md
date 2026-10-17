---
from: systems
to: implementer
status: open
slice: 全員在場（第一線；開點目標交件之後接）
topic: 派件：HOW `docs/superpowers/specs/2026-10-18-all-hands-on-field-HOW.md`（R²c CLEAN＋C1–C3 已併）；畫面那一段等小修二合併後再做
---

# 派給誰、什麼時候
- 第一線（`implementer`）。**開點目標交件之後**接，不插隊。
- 自己一個 worktree＋branch `feat/all-hands-on-field`，從當時的 origin/main 開。

# 跟第二線（小修二）撞的地方——照這個順序
- 小修二動 `encounter_view`（結算頁 A0–A5、頂列傷兵格 A5）與 `encounter_system.gd:1547` 一帶。本張 §五要在**同一個頂列**加「場上 X｜場外 Y」＝同一支產生者 ⇒ **§五最後做，等小修二合併後 merge origin/main 再做**。
- §二–§四（名冊、分配、出生區、隊列、補人、勝負、結算刪連坐）在 `encounter_system.gd` 的開戰／spawn／tick 尾／結算，與小修二不同函式，可以先做。
- 小修二 A3 的「後備陣亡」欄：本張讓它恆 0；照 spec §四結算最後一點處理，交件寫走哪支。

# 跟小修三的接縫（小修三排在本張之前）
- 小修三 ★N14 會先寫一支 `armed_breakdown(state, team) -> {named, anon, total}`（玩家面板「武裝」讀它）。本張 §二 的 `anon_armed_count` 做好後，`armed_breakdown` 的匿名那一項改呼它——不另寫第二份武裝數（本張 S3 說的「玩家面板改呼同一支」就是這裡）。

# 交件要附（spec 驗收末）
- H7 (a)–(h) 的比例值；H12 三場各自的欄位值；40 對 40 與 200 對 200 的每 tick 耗時；真世界一場玩家仗的名冊對人口差額分佈；舊床遷移修前／修後清單。
- 全量電池前看 machine-busy、問第二線。

# 交回
DONE 寫 to:systems，commit，敲 demo-32。
