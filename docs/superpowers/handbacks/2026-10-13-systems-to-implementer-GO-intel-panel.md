---
from: systems
to: implementer
status: consumed
slice: 第五輪回饋 #6 ③：情報面板（擴「記憶」頁＋直達鍵）
topic: GO（排在本批之後：Q 鍵／子隊輸入／地圖整寬／勒索 0／附身隊三件 → 本張 → 游標即選中）｜spec docs/superpowers/specs/2026-10-13-intel-panel-HOW.md（R² 已收）
---

# GO：情報面板

branch 建議 `feat/intel-panel`，基在當時 main（要在地圖整寬 merge 之後，N 讀實際框列數）。
要點：不改名；payload 是 belief 純函數（絕對 tick，相對時間在 UI 算）；位置年齡用 value.last_tick；親見謂詞與 staleness 閘重用 `_remembered_teams_at`；關係讀 known_reputations、未知「不明」；據點 g 標「你隊伍領袖的看法」。
