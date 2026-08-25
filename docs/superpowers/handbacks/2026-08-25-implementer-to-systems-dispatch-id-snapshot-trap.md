---
from: implementer
to: systems
status: consumed
slice: failure-memory-structural-identity / convoy-return-task-authority
topic: ★磚裡已有現成正解(current_dispatch_id=dispatch 當下蓋身分,不反解);★★但直接拿它當放棄的身分【會記錯】——放棄被偵測到的那一刻,隊多半已經改派,current_dispatch_id 已被覆寫成新任務;身分必須在【episode 開始時快照】
---

# 一顆會讓 record 接到錯身分的雷（rebase 前先講）

## §1 磚裡已經有正解，我不另造
`_stamp_dispatch_identity()`：**dispatch 當下**把結構身分蓋在隊上
（靜態 option ⇒ id ＝ option 名；goal candidate ⇒ `goal_type:frontier_kind` **由欄位組出、不反解 label**）。
⇒ ★**convoy 的擲出點不該用 `construction_target.action`** —— 那是**反解**。
★**身分要用帶下來的，不是事後推回去的。** 我把原本寫的 `action` 版本視為錯的，會改掉。

## §2 ★★但**直接讀 `current_dispatch_id` 也是錯的**

★**時序**：`construction_abandoned` 的觸發條件就是「**承諾不見了**」——
而承諾不見的**最常見原因就是這支隊改派了別的任務**。
⇒ ★**偵測到放棄的那一刻，`current_dispatch_id` 早已被新任務覆寫。**
**寫進記憶的會是【新任務的身分】，折價折到無辜的選項頭上。**

★**這是我已經踩過一次的那一族**：A1 那次把 `record()` 接在
「`current_option` 在呼叫【之後】才被設值」的站點上 ⇒ 濾條件永遠看到舊值。
★**同一個病：讀一個【會被後續覆寫】的欄位當事實。**

## §3 修法（形狀跟你們既有的一致，我不發明新東西）
★**身分在 episode 開始時快照，跟 `commit_stall_site` 放在一起**：
```
commit_stall_site      ← 已有（哪一塊地）
commit_stall_id        ← 新增（★開工當下的結構身分）
commit_stall_target    ← 新增（★開工當下的目標）
```
`_reset_stall_episode()` 是**唯一入口**，快照就在那裡取 ——
★**與 site 同一時刻取，才保證講的是同一件事。**

⇒ 擲出點改成：
```gdscript
FailureMemory.record(state, team, team.commit_stall_id, team.commit_stall_target,
    OutpostSystem.construction_ticks_total(t), "construction_abandoned_" + reason)
```

★**要你確認的只有一點**：**快照存在隊身上（3 個欄位）**你 OK 嗎？
替代是存在 tile 的 `construction_target` 裡（工地自己記得是誰、為什麼開的）——
★**我傾向存隊上**，因為 `_reset_stall_episode` 已經是單一入口，**兩處記等於又一份 drift**。
**但這是加狀態，照規矩問你。**

## §4 現況
- convoy：最終一輪 gates＋床**跑中**（型別錯 `TileData` → `HexTileData` 已修
  ——★**`abandon_fire = 0` 當時不是「世界沒發生」，是我的 helper 當場炸了；
  三次 `SCRIPT ERROR` 剛好對上該路徑跑到的三次**）
- latch 已驗證：`stall_fire 10 → 3`、`latched_suppressed 7`，**3 次開火 ＝ 3 個工地各一次**
- ★det fp **變了**（`c1e3f7c5…` → `a91caabe…`，三跑一致）——
  ★**這不是回歸，是證據**：拿掉那段觀測之後世界 byte-level 不同
  ⇒ **經驗上證實了你那條判準「把觀測拿掉，世界會不會不一樣」。**
- 磚：接著轉過去**重量三面**
