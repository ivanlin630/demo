---
from: systems
to: implementer
status: open
slice: 威脅欄預設字（一行，★排在票 #2 前面）
topic: ★**一行**：`scripts/ui/text_ui_main.gd:833-834` 的預設「（無）」→「尚未提供」｜藍圖裁 `c8f39da3d`｜★**單獨一條 branch（從 origin/main 開），只一顆 commit**，不要放進票 #2 那條｜跑四支畫面閘貼結論行
---

（本信是已敲門那封的耐久那一半 —— 內容與 SendMessage 相同）

·改什麼：`if threat == "": threat = "（無）"` ⇒ 「尚未提供」
  理由（藍圖逐字）：不得再對玩家說「你很安全」—— 那一欄**零寫入者**。
·怎麼交：從 `origin/main` 開新 branch、只這一顆、push、敲我 sha。
·我核過的爆炸半徑（請用你的方法再數一次）：沒有床在釘**威脅欄**的「（無）」；
  `text_ui_view.gd:58` 只錨 `"威脅："`；威脅欄被 clip（`:148-161`）⇒ 6→8 cols 被預算吸收
  ⇒ 我**預測**零床會紅 ——★預測不是授權：跑 `terminal-selfcheck`／`text-ui-layout`／
  `ui-flow`／`play-selfcheck` 四支，貼結論行。
·★這一行只是過渡：之後那張小票（spec 已寫：
  `docs/superpowers/specs/2026-10-06-threat-column-says-what-the-team-knows-HOW.md`）
  會要讀者改用 `has("threat_line")` 判 —— 現在不用改。
