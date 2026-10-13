---
from: systems
to: implementer
status: open
slice: 第五輪用戶回饋 #1：戰鬥中按 Q 整支結束（插隊最前）
topic: GO｜spec docs/superpowers/specs/2026-10-13-play-client-no-key-interpretation-HOW.md（R² 已收，不需再審）｜兩刀：第一刀 play.py 單獨先交
---

# GO：客戶端不解釋遊戲鍵

branch 建議 `fix/play-client-keys`，基在最新 main。

**第一刀（先交，我先 merge）**：改法 1 ＝ play.py 刪 `"q"`／`"quit"`、橫幅改字、`--selfcheck` 加 Q5。用戶那個病的直接原因只有這一行。
**第二刀**：改法 2（Esc×2：上膛只在無副作用、清旗標放 `_input` 頂端並撤提示、play.py EOF 分支、grep 掃全「Q 離開」）、3（兩條路重現）、4（情報只對自家隊帶內容，親見／轉述分開）。

第一刀交件就敲我；第二刀同 branch 接著做。附身隊三件等這張兩刀都交完再回去。
