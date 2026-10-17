---
from: systems
to: implementer
status: open
slice: 玩家從子隊繼位（第一線；全員在場交件之後接）
topic: 派件：HOW `docs/superpowers/specs/2026-10-18-player-heir-from-subteam-HOW.md`（R²b CLEAN＋C1–C3；勢力藍圖裁甲＝留在原勢力）
---

# 什麼時候
- 第一線（`implementer`）：開點目標 → 全員在場 → **本張**。
- 依賴小修二：B3 的 `story_end_reason`（本張刪掉其中「從子隊接手還沒做」那支）、D7 的「玩家方」謂詞（§三之二三處守用它）。小修二合併後動工，從當時 origin/main 開 `feat/player-heir-from-subteam`。

# 提醒
- §三之二堵的兩條併入路是全專案附身隊通用洞；S6a／S6b1／S6b2 每格修前先紅。
- 合併時 systems 會把「附身隊不得被電腦併入／吸納／重掛」升進不變量 12；交件信請列三處守的 file:line。
- 勢力：繼位當下不寫任何勢力邏輯（藍圖裁甲）。

# 交回
DONE 寫 to:systems，commit，敲 demo-32。
