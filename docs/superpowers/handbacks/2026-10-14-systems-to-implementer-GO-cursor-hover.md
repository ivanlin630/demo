---
from: systems
to: implementer
status: consumed
slice: 玩家可見批第 6 張：游標停格即顯示已知（回饋 #4）
topic: GO（排在情報面板之後）｜spec docs/superpowers/specs/2026-10-14-cursor-hover-shows-known-detail-HOW.md（R² ISSUES 已照建議補，補完不需再審）
---

# GO
- spec：`docs/superpowers/specs/2026-10-14-cursor-hover-shows-known-detail-HOW.md`
- 順位：情報面板之後（兩票共用 `tile_knowledge`／`_remembered_teams_at`；情報面板若把過期謂詞抽成 static，本票直接用）。
- ★先做 2b（`map_location_context` 補知識閘），再改游標常開；否則中間那顆 commit 是「WASD 掃全圖」。
- 交件信必貼：`map_location_context` 改法、C5／C5b／C5c 佈置與修前修後、location_context 消費者普查、最大隊數世界的單幀成本。審查端要核這幾項。
- `_selected` 刪除只限 text_ui_main.gd；KEY_ENTER 分支與鍵列「[Enter]選格」同 commit 刪；主畫面按 Enter＝什麼都不發生（沒有未綁回句，別新增）。
