---
from: reviewer
to: systems
status: consumed
topic: "[R² v2 verdict·transition-arbiter-bypass·issues(窄 blocking)] release-first 方向對,但你審點1 命中:beggar-restore×3 依賴 transition 的 move_target 保留(註明+begging 不動 move_target),release 清 move_target=-1→restore 的 previous_task 失目的地。settle/zombie 顯式重設 move_target=免疫。修=beggar-restore release-first 補 move_target 存/還原。其餘 CLEAN。"
---

# R² v2 verdict：transition-arbiter-bypass（release-first）

**VERDICT: issues（BLOCKING，窄）** — Part1/Part3 CLEAN，Part2 分離語意方向對，但 **你自己審點1 的疑慮命中真副作用**：beggar-restore ×3 依賴 transition 的 move_target 保留，改 release-first 會清掉目的地。修一處即 CLEAN。`premise_contradiction: false`。

factcheck 對 HEAD `1b8ab097`。

## 逐 Part

- **Part 1 transition 保三 guard → CLEAN**。只擋 (a) 外部 in-place stomp（team16 defection@AMBIENT vs survival@80），語意對。
- **Part 3 defection guarded transition / outpost ×6 → CLEAN**。
  - defection 3884：保 guarded transition 擋 stomp = team16 修，最小改合意圖（審點3 認可：transition vs try_set 兩者都擋 stomp，留 transition OK）。
  - outpost build ×6（`outpost:384/406/447/461/566/602` @DISPATCH 50）：現任常 IDLE(0)/<70 → guard 不 fire，低風險（measure 確認即可，非 blocker）。
- **Part 2 release-first → 方向對，但 beggar-restore ×3 有 move_target 副作用（BLOCKING）**。見下。

## ★審點1 命中：release-first 清 move_target → beggar-restore 失目的地

`release()`（`task_arbiter.gd:98-102`）：
```
team.current_task = TASK_IDLE
team.move_target = Vector2i(-1, -1)   # ← 清目的地
team.task_priority = 0
team.flee_from_pos = Vector2i(-1, -1)
```
transition **不碰 move_target**（`:108-113` 只寫 task/priority/reason/start_tick）→ 原 beggar-restore 靠此保留目的地。

**beggar-restore ×3（`interaction:1249` `_clear_aid_task` / `player_command:1017` / `sim_runner:259`）**：三處全 `transition(beggar, previous_task, PRIO_DISPATCH)` 後 **不重設 move_target**，註解明寫「就地轉換，move_target 保留」。且 begging 走 social_target、**不動 move_target**（grep `move_target` in interaction beg/aid 路空）→ 整個乞討episode move_target 保有 previous_task 的原目的地，transition-restore 正確 resume。
→ **改 release-first：release 清 move_target=(-1,-1) → 隨後 set previous_task 無重設 move_target → 恢復的 task（RETURN_HOME 回糧倉 / FORAGE 覓食格 / BUILD 工地…需目的地者）指向 (-1,-1) = 無處可去**。previous_task 若是移動型 → 導航斷。（PRODUCE 定點者無妨，但乞討前 previous_task 多為移動型。）
= release-first 修好 priority 誤傷，卻**回歸了 v1 沒有的 move_target 破壞**（換一種方式壞 beggar-restore）。

### 對照：settle / zombie-revive 為何免疫（已顯式重設）
- **settle**（`interaction:1264` `_execute_settlement`）：transition 後緊接 `t.move_target = Vector2i(-1, -1)`（定點生產）→ release-first 清也無妨（本就要 -1）。**CLEAN**。
- **zombie-revive**（`faction_ai:2647`）：transition 後緊接 `worker.move_target = tile.tile_pos`（回工地）→ release-first 清後被顯式覆寫。**CLEAN**。
- **convert_resident**（`interaction:1289` → 生產）：定點生產，move_target 無關（複核，應 CLEAN）。
- **∴ 唯 beggar-restore ×3 依賴「保留」而非「重設」→ 唯一破口。**

## 修（narrow，systems 定）
beggar-restore ×3 release-first 需**保存 move_target 再還原**：
```
var saved_mt := beggar.move_target
TaskArbiter.release(beggar)               # 清 task/priority/move_target
TaskArbiter.try_set(state, beggar, previous_task, saved_mt, PRIO_DISPATCH, "aid_restore")
```
（或用不清 move_target 的 release 變體；但 save/restore 最不動 release 語意。try_set 現任 IDLE@0 過 emergency guard，且帶 move_target 參數=正解。）
settle/zombie/convert **不需改**（已顯式重設）。

## 其餘審點
- **審點2（漏的 resolution caller）**：複核你分類無漏。現任可能 ≥70 的 in-place 降級路 = beggar/settle/zombie/RETURN_HOME-zombie(2646)，你都歸 release-first；defection=guarded；outpost/2638-nonzombie 現任 <70。CLEAN（outpost 現任 measure 順帶確認）。
- **審點3（defection 留 transition）→ 認可**。guarded transition 擋 stomp 足，最小改。
- **不變量配套句 → CLEAN**，字面反噬已被「emergency 自身退場走 release」補掉。

## TDD 追加要求
你補的 beggar-restore BEG@80→restore 測 **必須斷言 restore 後 move_target == 乞討前的目的地（非 -1）**，否則測綠但 move_target 破口漏網（測 previous_task 對、move_target 錯的假綠）。

## 回覆
issues（窄 blocking）→ beggar-restore ×3 補 move_target save/restore，改好回 R²（其餘 Part 全 CLEAN，這是唯一破口）。不 dispatch。修極小，一輪應收斂。
