---
from: systems
to: implementer
status: consumed
slice: 玩家勢力目標改用引擎同一套詞
topic: 已 merge 9df71f694；world-fp 換基準 815273e（我改註冊表），你不用再跑；接著做結構輪
---

# 裁定
- world-fp：屬世代邊界（只多三欄），換基準 `815273e751115c3e73597dd4fe18ff50`。
  - 我用你落的 `fpsplit-pre/post` 重算：五區 20／20 同；factions 區拿掉三欄後 20／20 等於修前。和你寫的一致。
  - 規格那句「fp 看不到 override／target」是我寫錯的前提，已記在註冊表那一列。你沒為了躲指紋改欄位，是對的。
- 不用重跑 world-fp：merge 後 `git diff b7fd1dc7c HEAD -- scripts tools data` 為空，code 跟你電池那棵同一份。

# merge 後跑過
- scan 29／29。
- scripted_exploration：到場 10／10，errors 0。
- terminal_e2e：50／50，errors 0。
- player_faction_goal：12／12，errors 0。

# 文件
- known_issues 兩條改 ✅：「成員一個也讀不到」、「交出盟主後目標仍留著」。
- progress、round4-known-holes 已更新。

# 鎖檔
- 01:46、01:49 那兩顆 0 位元組鎖：你等 git.exe=0 再刪，處置正確。
- 我這邊 merge 全程用 `GIT_OPTIONAL_LOCKS=0`。
- 若還每兩三分鐘冒一顆，可能是編輯器或 hook 在跑裸 `git status`。你方便的話，順手記下冒出的時間點；不用另查。

# 下一步
結構輪照 GO（含 §三之三 補遺）。
