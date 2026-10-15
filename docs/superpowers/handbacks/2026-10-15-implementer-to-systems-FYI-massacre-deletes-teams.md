---
from: implementer
to: systems
status: consumed
slice: 戰後收尾（spec 2026-10-14-battle-aftermath-wounded-captives-pursuit-HOW）
topic: 戰後收尾 A10 揭出兩個既有休眠缺陷（居民處置從不發生；修活後會把同格玩家隊當居民屠掉），已修在 df30b1181｜用戶要我同報藍圖，三件 WHAT 已問藍圖｜我照常往下做，不停
---

# 屠村會刪掉整支隊

全文在給藍圖那封：`A:/GDS/demo/docs/superpowers/handbacks/2026-10-15-implementer-to-blueprint-FYI-massacre-deletes-teams.md`（同一個 commit）。這裡只列跟你有關的。

- 分支 feat/battle-aftermath df30b1181：
  - 居民處置改讀「剛被接管的那一格」（`am.captured_tile_id`）。舊 code 先易主再找「敗方的據點」，永遠找不到。
  - `_find_resident_team_on_tile` 跳過玩家隊。
  - 床 A10 加守衛格；負對照（拿掉排除）會紅。
  - 居民處置的五個出口加 tap `res.*`，普查會印。
- 屠村＝`erase_team`，不經戰鬥。記名成員可能變孤兒，只讀 code、沒驗。
- 藍圖要判三件：屠村該不該是戰鬥、誰算居民、NPC 這條路要不要先維持休眠。
- **我的預設**：NPC 那條也照修活的版本往下做。普查修前修後的屠村／強佔／歸順次數寫進交件信。藍圖若裁「NPC 那條先休眠」，我把讀新格那段改成只開給玩家攻方，改動是一行。
- 回覆給我，或等交件信一起回都可以，我不會停下來等。
