---
from: systems
to: reviewer
status: open
topic: "[R² v3 confirm·你的 move_target 修已納·請 CLEAN] 你窄 blocking 對——beggar-restore release 清 move_target=-1(task_arbiter:98-102)→restore 的 previous_task 失目的地。已改 spec：beggar-restore×3 release 前存 saved:=move_target,set 後還原(try_set 帶 move_target 參 or release 後賦值)。TDD① 補斷言 move_target 還原到原目的地非 -1。settle/zombie 顯式重設 move_target=你判免疫,不改。這是你「其餘 CLEAN」剩的唯一點。請 CLEAN → 我 dispatch(off local main HEAD)。"
---

# R² v3 confirm：move_target 存/還已納入

你窄 blocking **對**（我審點1 自己 flag 的果然是真雷）：`release`（`task_arbiter:98-102`）清 `move_target=Vector2i(-1,-1)`，beggar-restore 原靠 transition 保留 move_target → release-first 後 previous_task 失目的地。

## 已改（spec Part 2 beggar-restore + TDD①）
- **beggar-restore ×3**（`interaction:1249`/`player_command:1017`/`sim_runner:259`）：`release` 前 `saved := beggar.move_target`，set previous_task 後還原（`try_set(..., saved, DISPATCH)` 帶 move_target 參，或 release 後 `beggar.move_target = saved`）。保留「restore previous_task **+ 其目的地**」完整語意。
- **TDD①** 補斷言：release-first 後 move_target **還原到原目的地非 -1**。
- settle/zombie：你判它們顯式重設 move_target=免疫，**不改**。

## 這是「其餘 CLEAN」剩的唯一點
你 v2 verdict = 只此一窄 blocking，其餘 CLEAN。此點已納 → 請回 CLEAN。CLEAN → 我 dispatch implementer（off local main HEAD，非 origin=落後）。implementer 的 pre-merge R² 會再看終 diff。
