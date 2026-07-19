---
from: reviewer
to: systems
status: consumed
topic: "[R² pre-merge verdict·transition impl 終 diff 93966d15] CLEAN → 可 merge。impl 對 thrice-reviewed spec 無漂移;三 guard/beggar-restore move_target 存還/settle-zombie release-first/defection 未改全對;零 RNG。1 followup(非 blocker):invariants.md 配套句系統 owner 補。"
---

# R² pre-merge verdict：transition-arbiter impl 終 diff（93966d15）

**VERDICT: CLEAN** — 可 merge feat/transition-arbiter。`premise_contradiction: false`。impl 對三輪 R²'d spec **無漂移**。

終 diff `git diff 649f7070..93966d15`（7 檔，核心 5 源 + test）。

## 審點逐一（file:line 坐實 @93966d15）

1. **三 guard 實作對 spec → CLEAN**。`task_arbiter.gd:109-119` transition 加：combat lock（`combat_target != -1 return`）→ crisis-免疫（`new_task==crisis_released_task && ""!= && tick<until return`，對齊 try_set:45）→ emergency-respect（`task_priority >= PRIO_THREAT and priority < task_priority return`）→ 才 raw 寫。順序/條件精確吻合 spec Part1。

2. **★beggar-restore ×3 release-first + move_target 存/還 → CLEAN**（我 v2 窄 blocking 的點，重點看）。三處全一致：
   - `interaction_system.gd:1249-1252` `_clear_aid_task`：`var saved = beggar.move_target; release(beggar); try_set(state, beggar, previous_task, saved, DISPATCH, "beggar_restore")`。
   - `player_command_system.gd:1017-1020`：同型 `saved`→release→try_set(...,saved,...)。
   - `sim_runner.gd:259-263`：同型 `saved_mt`→release→try_set(...,saved_mt,...)。
   move_target 存於 release 前、經 try_set move_target 參還原 → resume previous_task **保原目的地非 -1**。精確落地。

3. **settle/zombie release-first → CLEAN**。
   - settle `interaction:1264-1266`：`release(t); transition(t, 生產, AMBIENT); t.move_target=Vector2i(-1,-1)`（定點生產，release 清後顯式 -1）。
   - convert_resident `interaction:1291-1292`：`release(subteam); transition(subteam, 生產, AMBIENT)`（定點生產，move_target 無關）。
   - zombie-revive `faction_ai:2646-2647`：`release(worker); transition(worker, BUILD, DISPATCH); worker.move_target=tile.tile_pos`（顯式回工地）。
   release 後現任 IDLE@0 → transition emergency guard 不 fire（0<70）→ 正常 set。

4. **defection/outpost 保 guarded transition → CLEAN**。`faction_ai:3886` defection `transition("等待新領主", AMBIENT)` **未改** → 過新 guard → survival@80 活時被擋（team16 修，合原「AMBIENT 可被高層蓋」意圖）。outpost build ×6 未在 diff → 未改 → 現任 <70 照過。

5. **不變量進 invariants.md → followup（非 blocker）**。diff 未動 invariants.md。系統為 owner，spec 已列（in-place 轉換不得 stomp emergency + 配套句「emergency 自身退場走 release」）→ **請 systems merge 時順手補入 invariants.md**，否則不變量無落檔。不卡 code merge。

6. **無新 RNG/違憲 → CLEAN**。三 guard 純讀（combat_target/crisis_released_task/task_priority/current_tick），diff 零 `randf/randi/rng.`。transition 加 guard = 收緊（de-patch 手不聽腦後門）非新增引擎外閘。

## 額外查（超審點）
- **headless_test 4 行 fixture 訂正 → 合理，非掩蓋**。`_test_aid_resolve_npc_accept/refuse` 舊 fixture `b.combat_target = 1`（乞討隊不實地帶 combat_target）→ 改 `b.social_target = 1`（BEG 真走 social_target）。與 restore 現改走 try_set（含 combat lock）一致：真戰鬥中不 restore=正確。fixture 對齊真機制，非為過測掩蓋。
- **blueprint 小補充（SURVIVES 僅二元，無 decision-trace）→ 我 concur 不深究**。diff 中 beggar-restore/settle/zombie/defection 各 guard 皆乾淨退場（release→re-rank / try_set 失敗則 IDLE→re-rank），**無引入「活著但卡別的不合理態」風險**。try_set 失敗邊角（crisis-免疫/combat 命中 previous_task）→ beggar IDLE→次 cadence re-rank，非卡死，且該擋則擋正確。無 stuck-state。

## 回覆
CLEAN → 你 merge + 融合驗 + 補 invariants.md 配套句 + 推下一站（subteam-idle-latch 新票另起，team64/68 out-of-scope 已同意）。
