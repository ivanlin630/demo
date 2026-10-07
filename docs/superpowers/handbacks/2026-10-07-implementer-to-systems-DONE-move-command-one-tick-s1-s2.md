---
from: implementer
to: systems
status: open
slice: M 票 §1＋§2（M＝設目標＋一顆 tick／L 走到抵達／推進停點讀事件匯流排／敵人逼近／休息兩段確認）
topic: ★交件｜branch `feat/move-command-one-tick` tip `63f9e5f47`（已推）｜全電池 BATTERY_RC=0｜world-fp 不變 6019f170d4daba106ea44bf5d2b46824
---

## 結果

- branch：`feat/move-command-one-tick`，tip **`63f9e5f47`**（遠端已推）。
- 全電池：`bash .claude/hooks/merge-gates.sh` ⇒ **BATTERY_RC=0**（第二輪；scripted-exploration artifact 從這輪 commit）。
- world-fp：**不變** `6019f170d4daba106ea44bf5d2b46824`（新欄 `player_adjacent_hostiles` 只在非空時印 `P|adjacent_hostile=`，headless 世界沒玩家逼近事件 ⇒ 指紋不動；fp-excludes-derived 棘輪未增）。
- main 自分支後只多 `scripts/debug/ticket9_seg1_tile_known.gd`（未進註冊表）⇒ 不影響本件。

## §1（M＝一顆 tick；L＝走到抵達）

- `text_ui_main.gd`：KEY_M 不再 `request_advance(ADVANCE_UNTIL_EVENT)`；`_process` 的「移動中 ⇒ 再推一次」拿掉。
- 新鍵 **L**（`ARRIVE_KEY`）進 `GLOBAL_ADVANCE_KEYS` ⇒ 強制回應字母配發自動跳過；走 `_global_advance_key`。抵達偵測＝`_last_move_target` 被清成 (-1,-1) 且人在那格 ⇒ 事件流「抵達 (q,r)」、L 模式 cancel_advance。
- 結果行：M ⇒「開始走向 (q,r)，預計 N 分鐘」（`PathSystem.eta_ticks`）；L ⇒「抵達 (q,r)」或「停下：<事件句>（停在 (q,r)）」。
- MODE_KEYMAP main 加「[L]走到抵達」；已知問題清單那列標已修。

## §2（停點＝事件匯流排；敵人逼近；休息確認）

- `world_events.gd`：`ADVANCE_STOP_KINDS = [forced_event_arrived, combat_engaged, combat_start, hostile_adjacent, member_died, member_left]`＋`static func stop_event_since(state, seq0)`（kind∈集合且 subjects 含玩家隊）。新 kind **hostile_adjacent**（KIND_LABEL「敵人逼近」、describe「%s 逼近到你旁邊（%d 格）」）。
- `sim_runner.gd`：`_step2_move_teams` 後 `_note_hostile_adjacent(state)`：玩家敵對隊距離 ≤1、**邊緣觸發**（進入才發，留著不重發；靠 `WorldState.player_adjacent_hostiles` 記）。
- `sim_bridge.gd`：advance_ticks 每 tick 以 seq0 問 `stop_event_since` ⇒ events 加 `{type:"stop_event", kind, text}`；`_is_stop`／`_any_stop`（迴圈，不用 lambda——4.2 lambda 呼 static 解不到）。`_diff_events` 裡我先前加的兩段（forced／pre_encounter）**退場**（同一停點只剩一個來源）；new_team_spotted 不停。
- 停點重疊說明：強制事件逾時若發生在同一推進步內，舊路（快照 diff）看不到；新路讀匯流排 seq ⇒ 看得到。這就是 E2E M2 修前紅的原因。
- 休息兩段確認：掛在**自家隊數字鍵執行**那支（不是目標動作那支）：第一次「TeamN 在 d 格外，確定要休息？再按一次休息」且不下令；第二次才下。

## E2E（terminal_e2e_bed.gd）

- 新格 M1/M2/M3、S1–S4。修前紅：§1 7 條、§2 6 條（S2 修前即綠＝守衛格）；修後 errors 0。
- S1 停點常數／函式用動態讀（修前不存在時紅在格上，不讓整支床 parse 失敗）。S3 佈置 `pt.fatigue=0.6`（休息有前置檢查）。M 格先清強制事件（否則面板接管）。
- 負對照（各自 detached worktree 各改回一處）：nm1/nm2/nm3、ns1（不發 hostile_adjacent）、ns3（休息不問直接下）**皆紅在自己格**。

## 一處改判（請過目）

- **ui-flow P18**「UI 用到哨兵 2 處」⇒ 改「≥ 1 處」。理由：M 票拿掉兩處（M 自動推到事件、移動中續推），L 用一處；該格意圖＝「這種用法真的在 UI 裡」，不是釘次數。註解已寫在格上（`5846084e5`）。單跑 ui-flow 81/81 綠。

## 下一張

照序 ⇒ C2 普查床（`feat/census-c2-real-stall`，WIP 已推 `eac587b52`），在 713c86bd6 樹量 C2′ 基準。
