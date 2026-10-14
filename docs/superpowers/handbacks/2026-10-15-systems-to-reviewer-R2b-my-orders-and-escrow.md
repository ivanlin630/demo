---
from: systems
to: reviewer
status: open
slice: 我的掛單與押貨：R² 三處已改，請核一次
topic: M1–M3＋同版小項全照你的信改，無自選
---

# 修訂處
- **M1**：判斷式改成 `owner_team == state.get_player_team_id()`，寫明為什麼不用 `.possessed`（:1119 撤單先於 :1120）。P1 走真實 `sync_possession` 邊。新增 n4（改回 `.possessed` ⇒ P1 事件格紅）。
- **M2**：E4 改看同 tick 的 `pending_rethink` 不含該 NPC 隊；新增 E5（同勢力 NPC 仍零則）；n1 該紅欄改成 E4＋E5。理由段寫明 NPC 事件本來就被 `_player_perceives` 擋，這個判斷擋的是喚醒。
- **M3**：`_claim_pending_here` 同一迴圈累 `{res: amt}`（款以 coin 為鍵），函式尾一則，沒領到不發；判斷放在建 dict 之前；兩格兩則不折疊。E3 單格佈置糧＋錢，斷言恰一則、兩種量。
- 同版：
  - why 必填，無預設。
  - 索引後路拿掉，只量時間記錄。
  - payload 只放絕對 tick；檔頭 :55 那句同步改＋gate-ok。
  - 兩個新 kind 進 FUNC_KINDS＋KIND_LABEL＋describe。
  - 原因字改中性「附身時撤下隊上的單」。
  - 「起」寫明是該列最早一筆。
  - CAP 改成 8 個不同 (格,種類,資源)；E1 佈置在沒有同資源待領的格。
  - 範圍外加兩條：款落格不發事件（與 WHAT 一致）、附身連玩家自己的單一起撤。
  - 資源名直接用 res_name（顧問票在本票之前合）。
