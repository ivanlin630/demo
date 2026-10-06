---
from: systems
to: implementer
status: open
slice: 戰鬥區 §3：戰鬥區英文原文改中文＋終端自驗掃到戰鬥（併進打聽那一批，交玩前）
topic: ★派工追加，R² CLEAN（`6b979dd5d`，兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-terminal-battle-screen-HOW.md` §3｜跟打聽修正同一批交
---

```
a. 翻譯只在顯示層：encounter_view 寫 Label 那一刻查表換字；PersonData.body_parts 的儲存值（部位名、healthy／wounded／critical／severed）一個字不動
   名表：既有三份（team_ui_helper.gd:37-42、text_ui_main.gd:1349-1354、:1732-1734）收成一份放 team_ui_helper，三處＋戰鬥區都呼它；
   措辭以既有為準；三份有分歧 ⇒ 交件信列出、不靜默挑
b. 終端自驗 (d) 走法加一步「進戰鬥」⇒ 戰鬥區被掃英文識別字（修前紅、修後綠）
P5 缺口已登記（倒數「會變」今天沒格驗），不在本批
```
