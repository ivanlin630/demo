# 批次 2 — 玩家行動 API Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補齊玩家互動缺口：G-02 征服、G-03 離開/背叛勢力、G-05 建設據點、G-06 子隊管理、G-07 投降、G-09 勢力策略下令。完成後達 ~23 個 action_id，同步做 T-01 action registry 重構。

**Architecture:** 先加新資料欄位（G-09 需要），再逐缺口加 `player_command_system` actions，最後重構為 registry 模式（T-01）。底層系統（OutpostSystem、SubteamSystem、InteractionSystem）皆已完整，此批次只是 API 接線。

**Tech Stack:** GDScript 4.2.2，無外部依賴。

---

## 修改檔案一覽

| 檔案 | 動作 | 涵蓋 |
|---|---|---|
| `scripts/data/faction_data.gd` | 加 `player_goal_override` | G-09 |
| `scripts/data/team_data.gd` | 加 `player_commanded_task` | G-09 |
| `scripts/simulation/outpost_system.gd` | 修改 `_tick_construction`、加 `_has_control`、`demolish_with_control` | G-05 |
| `scripts/simulation/interaction_system.gd` | `_try_subjugate` 改公開；`_resolve_combat_end` 玩家分支 | G-02 |
| `scripts/simulation/encounter_system.gd` | `resolve_encounter_end` 加 `can_subjugate` flag | G-02 |
| `scripts/simulation/faction_ai_system.gd` | `_update_goals` 讀 `player_goal_override`；`_assign_tasks` 讀 `player_commanded_task` | G-09 |
| `scripts/simulation/player_command_system.gd` | 加全部新 actions + registry 重構（T-01） | 全部 |
| `scripts/debug/headless_test.gd` | 加新行動驗證輸出 | 測試 |

---

## Task 1：新增資料欄位（G-09 前置）

**Files:**
- Modify: `scripts/data/faction_data.gd`
- Modify: `scripts/data/team_data.gd`

- [ ] **Step 1: `faction_data.gd` 加 `player_goal_override`**

在 `known_member_states` 後加：

```gdscript
var player_goal_override: String = ""
# 玩家設定的勢力目標；"" = 無 override（faction_ai 自動計算）
# 有效值："expand" / "defend" / "trade_net"
```

- [ ] **Step 2: `team_data.gd` 加 `player_commanded_task`**

在 `order_task` 後加：

```gdscript
var player_commanded_task: String = ""
# 玩家對此 team 的直接指令；"" = 無指令（faction_ai 自動計算）
# 有效值：任意 TASK_ 常數
```

- [ ] **Step 3: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 4: Commit**

```
git add scripts/data/faction_data.gd scripts/data/team_data.gd
git commit -m "feat(data): add player_goal_override + player_commanded_task fields"
```

---

## Task 2：G-05 — 據點建設 API

**Files:**
- Modify: `scripts/simulation/outpost_system.gd`
- Modify: `scripts/simulation/player_command_system.gd`

### 2A：修改 `_tick_construction`（接手機制）

目前 `_tick_construction` 只有原始 `construction_team_id` 的 team 可推進。改為：同格上任何 `current_task == "建設"` 的 team 皆可推進，並成為 owner。

- [ ] **Step 1: 修改 `outpost_system._tick_construction`**

```gdscript
func _tick_construction(state: WorldState, tile: HexTileData) -> void:
	# 找同格上所有 current_task == "建設" 的 team（接手機制）
	var active_team: TeamData = null
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == tile.tile_pos and t.current_task == TeamData.TASK_BUILD:
			active_team = t
			break
	if active_team == null:
		return  # 無施工隊在格，暫停
	# 更新施工 team（接手：任何在格上建設的 team 都可繼續）
	tile.construction_team_id = active_team.team_id
	tile.construction_ticks_left -= maxi(active_team.population, 1)
	if tile.construction_ticks_left <= 0:
		_complete_construction(state, tile, active_team)
```

### 2B：加 `_has_control`（支配權檢查）

- [ ] **Step 2: 在 `outpost_system.gd` 加 `_has_control`**

```gdscript
func _has_control(state: WorldState, team_id: int, tile: HexTileData) -> bool:
	# 條件 1：自己是 owner
	if tile.outpost_owner == team_id: return true
	var team: TeamData = state.teams.get(team_id)
	if team == null: return false
	var owner: TeamData = state.teams.get(tile.outpost_owner)
	# 條件 2：owner 不存在（已滅）
	if owner == null: return true
	# 條件 3：同勢力
	if team.faction_id != -1 and team.faction_id == owner.faction_id: return true
	# 條件 4：owner 同勢力無 team 在場（無人駐守，佔領者可拆）
	var owner_faction_present: bool = false
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == tile.tile_pos and t.faction_id == owner.faction_id:
			owner_faction_present = true
			break
	return not owner_faction_present
```

### 2C：加玩家 actions

- [ ] **Step 3: 在 `player_command_system.execute_action` 的 match 加 5 個 action**

```gdscript
"build_outpost":
	var outpost_type: String = str(state.player_state.get("build_type", "civilian"))
	if outpost_type not in ["civilian", "military"]:
		return { "ok": false, "msg": "無效據點類型" }
	var _os := OutpostSystem.new()
	var ok: bool = _os.start_build(state, pt, outpost_type, 1)
	if not ok:
		return { "ok": false, "msg": "無法建造（資源不足或距離限制）" }
	print("[PlayerCmd] build_outpost type=%s" % outpost_type)
	return { "ok": true, "msg": "開始建造 %s" % outpost_type }

"upgrade_outpost":
	var _os2 := OutpostSystem.new()
	var ok2: bool = _os2.start_upgrade_level(state, pt)
	if not ok2:
		return { "ok": false, "msg": "無法升級（非 owner 或已滿級）" }
	return { "ok": true, "msg": "開始升級據點" }

"upgrade_farming":
	var _os3 := OutpostSystem.new()
	var ok3: bool = _os3.start_upgrade_farming(state, pt)
	if not ok3:
		return { "ok": false, "msg": "無法升級農業（非 civilian 或已滿）" }
	return { "ok": true, "msg": "開始升級農業" }

"upgrade_manufacturing":
	var _os4 := OutpostSystem.new()
	var ok4: bool = _os4.start_upgrade_manufacturing(state, pt)
	if not ok4:
		return { "ok": false, "msg": "無法升級製造（條件不符）" }
	return { "ok": true, "msg": "開始升級製造" }

"demolish_outpost":
	var _os5 := OutpostSystem.new()
	var tile_id5: int = pt.tile_pos.x * 1000 + pt.tile_pos.y
	var tile5: HexTileData = state.world.tiles.get(tile_id5)
	if tile5 == null:
		return { "ok": false, "msg": "格子不存在" }
	# 施工中：任何人可清除
	if tile5.construction_ticks_left > 0 and tile5.outpost_level == 0:
		tile5.construction_team_id   = -1
		tile5.construction_ticks_left = 0
		tile5.construction_target     = {}
		pt.current_task = TeamData.TASK_IDLE
		return { "ok": true, "msg": "取消施工" }
	# 完成據點：需支配權
	if not _os5._has_control(state, pt_id, tile5):
		return { "ok": false, "msg": "無支配權，無法拆除" }
	var ok5: bool = _os5.start_demolish(state, pt)
	if not ok5:
		return { "ok": false, "msg": "無法拆除" }
	return { "ok": true, "msg": "開始拆除據點" }
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 5: Commit**

```
git add scripts/simulation/outpost_system.gd scripts/simulation/player_command_system.gd
git commit -m "feat(outpost,player_cmd): G-05 build/demolish outpost player actions + takeover mechanic"
```

---

## Task 3：G-06 — 子隊管理 API

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`

SubteamSystem.dispatch() 已有完整底層。

- [ ] **Step 1: 在 `execute_action` 加 `dispatch_subteam`**

```gdscript
"dispatch_subteam":
	# player_state 需預先設定：sub_leader_id, pop_count, task, move_target_q, move_target_r
	var sub_leader_id: int = int(state.player_state.get("sub_leader_id", -1))
	var pop_count: int     = int(state.player_state.get("sub_pop_count", 1))
	var task: String       = str(state.player_state.get("sub_task", TeamData.TASK_IDLE))
	var tq: int = int(state.player_state.get("sub_move_q", -1))
	var tr: int = int(state.player_state.get("sub_move_r", -1))
	var move_tgt: Vector2i = Vector2i(tq, tr)
	if sub_leader_id == -1 or not state.persons.has(sub_leader_id):
		return { "ok": false, "msg": "未指定子隊 leader" }
	if pop_count < 1 or pop_count >= pt.population:
		return { "ok": false, "msg": "人數不合法（1 ~ population-1）" }
	var sub_id: int = SubteamSystem.new().dispatch(state, pt_id, sub_leader_id, pop_count, task, move_tgt)
	if sub_id == -1:
		return { "ok": false, "msg": "派遣失敗" }
	return { "ok": true, "msg": "派出子隊 Team%d" % sub_id, "sub_id": sub_id }
```

- [ ] **Step 2: 加 `order_subteam`**

```gdscript
"order_subteam":
	# player_state 需設定：order_sub_id, sub_new_task, sub_new_move_q/r
	var sub_id2: int   = int(state.player_state.get("order_sub_id", -1))
	var new_task: String = str(state.player_state.get("sub_new_task", TeamData.TASK_IDLE))
	var nq: int = int(state.player_state.get("sub_new_move_q", -1))
	var nr: int = int(state.player_state.get("sub_new_move_r", -1))
	var sub2: TeamData = state.teams.get(sub_id2)
	if sub2 == null or sub2.parent_team_id != pt_id:
		return { "ok": false, "msg": "目標不是玩家子隊" }
	sub2.current_task = new_task
	sub2.move_target  = Vector2i(nq, nr)
	print("[PlayerCmd] order_subteam Team%d → task=%s move=(%d,%d)" % [sub_id2, new_task, nq, nr])
	return { "ok": true, "msg": "已下令 Team%d" % sub_id2 }
```

- [ ] **Step 3: 加 `recall_subteam`（派信使帶召回令）**

```gdscript
"recall_subteam":
	# player_state 需設定：recall_sub_id（目標子隊）
	# herald 由玩家本隊派出，order_task=TASK_MERGE，目標=子隊
	var recall_sub_id: int = int(state.player_state.get("recall_sub_id", -1))
	var recall_sub: TeamData = state.teams.get(recall_sub_id)
	if recall_sub == null or recall_sub.parent_team_id != pt_id:
		return { "ok": false, "msg": "目標不是玩家子隊" }
	if pt.population < 2:
		return { "ok": false, "msg": "人數不足以派信使" }
	# 派 1 人信使：TASK_HERALD，目標 = recall_sub 當前位置（快照座標）
	var herald_id: int = SubteamSystem.new().dispatch(
		state, pt_id, -1, 1, TeamData.TASK_HERALD,
		recall_sub.tile_pos, recall_sub_id, TeamData.TASK_MERGE)
	if herald_id == -1:
		return { "ok": false, "msg": "派信使失敗" }
	return { "ok": true, "msg": "信使已出發至 Team%d" % recall_sub_id }
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 5: Commit**

```
git add scripts/simulation/player_command_system.gd
git commit -m "feat(player_cmd): G-06 dispatch_subteam / order_subteam / recall_subteam"
```

---

## Task 4：G-02 — 征服（戰後收編）

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/simulation/player_command_system.gd`

### 4A：`encounter_system.resolve_encounter_end` — 玩家勝利時不自動收編

- [ ] **Step 1: 讀 `resolve_encounter_end` 完整內容確認修改點**

```powershell
# 確認 resolve_encounter_end 函式範圍
```

從已讀程式碼（第 795 行起），在結果寫入 `last_encounter_result` 後，NPC 部分交給 `interaction_system` 自動呼叫 `_try_subjugate`。玩家勝利需攔截。

- [ ] **Step 2: 在 `encounter_system.resolve_encounter_end` 加 `can_subjugate` flag**

找到 `last_encounter_result` 的寫入點，加：

```gdscript
# 在寫完 last_encounter_result 後加：
# G-02：玩家勝利 → 標記 can_subjugate，讓玩家自選；NPC 勝利維持自動
var is_player_winner: bool = (state.player_id != -1 and winner_id == state.player_id)
state.last_encounter_result["can_subjugate"] = is_player_winner
```

### 4B：`interaction_system` — 玩家勝利不自動呼叫 `_try_subjugate`

`_try_subjugate` 在 `_resolve_combat_end` 和 `_force_retreat` 被呼叫（第 450、466 行）。

- [ ] **Step 3: 修改兩處 `_try_subjugate` 呼叫，跳過玩家勝利**

```gdscript
# _resolve_combat_end 第 450 行 改為：
if state.player_id == -1 or winner_id != state.player_id:
    _try_subjugate(state, winner_id, loser_id)

# _force_retreat 第 466 行 改為：
if state.player_id == -1 or pursuer_id != state.player_id:
    _try_subjugate(state, pursuer_id, retreater_id)
```

### 4C：`interaction_system` — 加公開 `subjugate_team`

- [ ] **Step 4: 在 `interaction_system.gd` 加公開 wrapper**

```gdscript
func subjugate_team(state: WorldState, winner_id: int, loser_id: int) -> void:
	_try_subjugate(state, winner_id, loser_id)
```

### 4D：`player_command_system` — 加 `subjugate_enemy` action

- [ ] **Step 5: 在 `execute_action` 加 `subjugate_enemy`**

```gdscript
"subjugate_enemy":
	var result: Dictionary = state.last_encounter_result
	if result.is_empty() or not result.get("can_subjugate", false):
		return { "ok": false, "msg": "無可收編的敗者" }
	var loser_id: int = int(result.get("loser_id", -1))
	var loser: TeamData = state.teams.get(loser_id)
	if loser == null:
		return { "ok": false, "msg": "敗者已消滅" }
	_interaction.subjugate_team(state, pt_id, loser_id)
	state.last_encounter_result["can_subjugate"] = false
	return { "ok": true, "msg": "收編 Team%d" % loser_id }
```

- [ ] **Step 6: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`，NPC 勝利仍觸發 `[Faction]` 收編訊息。

- [ ] **Step 7: Commit**

```
git add scripts/simulation/encounter_system.gd scripts/simulation/interaction_system.gd scripts/simulation/player_command_system.gd
git commit -m "feat(encounter,interaction,player_cmd): G-02 player subjugation choice"
```

---

## Task 5：G-03 — 離開/背叛/解散勢力

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`

底層 `state.disband_faction()` 已有。`_execute_betrayal` 邏輯複製到玩家版本。

- [ ] **Step 1: 加 `leave_faction` action**

```gdscript
"leave_faction":
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var fid3: int = pt.faction_id
	var f3: FactionData = state.factions.get(fid3)
	if f3 == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f3.leader_team_id == pt_id:
		return { "ok": false, "msg": "請使用 disband_faction（leader 不能普通離開）" }
	# 離開：移除成員
	pt.faction_id = -1
	f3.member_team_ids.erase(pt_id)
	# 原 leader loyalty 下降
	var leader_team3: TeamData = state.teams.get(f3.leader_team_id)
	if leader_team3 != null:
		var leader_p3: PersonData = state.persons.get(leader_team3.leader_id)
		if leader_p3:
			leader_p3.loyalty = maxf(leader_p3.loyalty - 0.15, 0.0)
	print("[PlayerCmd] 玩家離開勢力%d" % fid3)
	return { "ok": true, "msg": "已離開勢力" }
```

- [ ] **Step 2: 加 `betray_faction` action**

```gdscript
"betray_faction":
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var fid4: int = pt.faction_id
	var f4: FactionData = state.factions.get(fid4)
	if f4 == null:
		return { "ok": false, "msg": "勢力不存在" }
	# 背叛：所有原勢力成員 → player_hostile_teams
	for tid4 in f4.member_team_ids:
		if tid4 == pt_id: continue
		if not state.player_hostile_teams.has(tid4):
			state.player_hostile_teams.append(tid4)
	pt.faction_id = -1
	f4.member_team_ids.erase(pt_id)
	# 背叛計數（影響未來外交）
	state.player_state["betrayal_count"] = int(state.player_state.get("betrayal_count", 0)) + 1
	# 在原 leader 記憶中留下背叛記錄
	var leader_team4: TeamData = state.teams.get(f4.leader_team_id)
	if leader_team4 != null:
		var leader_p4: PersonData = state.persons.get(leader_team4.leader_id)
		if leader_p4:
			leader_p4.memory.append({
				"type": "betrayal", "subject_id": pt.leader_id,
				"tick": state.world.current_tick, "intensity": 0.9
			})
	print("[PlayerCmd] 玩家背叛勢力%d（betrayal_count=%d）" % [
		fid4, state.player_state["betrayal_count"]])
	return { "ok": true, "msg": "背叛勢力，原成員已敵對" }
```

- [ ] **Step 3: 加 `disband_faction` action**

```gdscript
"disband_faction":
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var fid5: int = pt.faction_id
	var f5: FactionData = state.factions.get(fid5)
	if f5 == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f5.leader_team_id != pt_id:
		return { "ok": false, "msg": "只有 leader 可解散勢力" }
	# 所有成員 loyalty 下降
	for tid5 in f5.member_team_ids:
		if tid5 == pt_id: continue
		var mt5: TeamData = state.teams.get(tid5)
		if mt5 == null: continue
		var lp5: PersonData = state.persons.get(mt5.leader_id)
		if lp5:
			lp5.loyalty = maxf(lp5.loyalty - 0.3, 0.0)
	state.disband_faction(fid5)
	return { "ok": true, "msg": "勢力已解散" }
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 5: Commit**

```
git add scripts/simulation/player_command_system.gd
git commit -m "feat(player_cmd): G-03 leave_faction / betray_faction / disband_faction"
```

---

## Task 6：G-07 — 投降

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`

`handle_diplomacy_message("offer_surrender")` 在 `DiplomaticAiSystem` 已有底層邏輯。

- [ ] **Step 1: 加 `offer_surrender` action（外交通道）**

```gdscript
"offer_surrender":
	var tgt6: TeamData = state.teams.get(target_id)
	if tgt6 == null:
		return { "ok": false, "msg": "目標不存在" }
	var resp6: String = _diplomatic.handle_diplomacy_message(state, tgt6, pt, "offer_surrender")
	state.player_pending_targets.erase(target_id)
	if resp6 == "accept":
		# 接受：資源轉移 30%，玩家被收編
		for res6 in ["food", "coin", "goods"]:
			var amount6: float = float(pt.resources.get(res6, 0)) * 0.3
			pt.resources[res6]   = float(pt.resources.get(res6, 0)) - amount6
			tgt6.resources[res6] = float(tgt6.resources.get(res6, 0)) + amount6
		_interaction.subjugate_team(state, target_id, pt_id)
		print("[PlayerCmd] 玩家投降 Team%d 接受" % target_id)
		return { "ok": true, "msg": "投降被接受，已被收編" }
	else:
		return { "ok": false, "msg": "對方拒絕接受投降" }
```

- [ ] **Step 2: 加 `surrender_in_encounter` action（遭遇戰中）**

```gdscript
"surrender_in_encounter":
	if not state.encounter_active:
		return { "ok": false, "msg": "非戰鬥中" }
	# 找對手 team
	var enemy_id6: int = state.encounter_defender_id if state.encounter_attacker_id == pt_id \
		else state.encounter_attacker_id
	var enemy6: TeamData = state.teams.get(enemy_id6)
	if enemy6 == null:
		return { "ok": false, "msg": "找不到對手" }
	var resp6b: String = _diplomatic.handle_diplomacy_message(state, enemy6, pt, "offer_surrender")
	if resp6b == "accept":
		# 接受：強制結束遭遇戰，資源轉移
		for res6b in ["food", "coin", "goods"]:
			var amt6b: float = float(pt.resources.get(res6b, 0)) * 0.3
			pt.resources[res6b]    = float(pt.resources.get(res6b, 0)) - amt6b
			enemy6.resources[res6b] = float(enemy6.resources.get(res6b, 0)) + amt6b
		_interaction.subjugate_team(state, enemy_id6, pt_id)
		state.encounter_active = false
		state.encounter_units  = []
		print("[PlayerCmd] 玩家戰中投降，Team%d 接受" % enemy_id6)
		return { "ok": true, "msg": "投降被接受" }
	else:
		return { "ok": false, "msg": "對方拒絕" }
```

- [ ] **Step 3: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 4: Commit**

```
git add scripts/simulation/player_command_system.gd
git commit -m "feat(player_cmd): G-07 offer_surrender + surrender_in_encounter"
```

---

## Task 7：G-09 — 勢力策略下令

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/simulation/player_command_system.gd`

### 7A：`faction_ai._update_goals` 讀 `player_goal_override`

- [ ] **Step 1: 修改 `faction_ai_system._update_goals`**

在 `_update_goals` 開頭加（`f.goals.clear()` 後）：

```gdscript
func _update_goals(state: WorldState, f) -> void:
	f.goals.clear()
	var leader_team: TeamData = state.teams.get(f.leader_team_id)
	if leader_team == null:
		return

	# G-09：玩家設定 override → 跳過自動計算，直接套用
	if not f.player_goal_override.is_empty():
		f.goals.append(f.player_goal_override)
		# （後續 _assign_tasks 讀 f.goals，行為不變）
		return
	# ... 以下維持原有自動計算邏輯不變
```

### 7B：`faction_ai._assign_tasks` 讀 `player_commanded_task`

找到 `_assign_tasks` 函式，在每個 member team 的 task 分配邏輯前加 loyalty 門檻：

- [ ] **Step 2: 定位 `_assign_tasks` 中 member task 分配邏輯**

在 `_assign_tasks` 開頭，針對每個 member 的 task 設定前加：

```gdscript
# G-09：檢查 player_commanded_task（loyalty 門檻）
for tid_cmd in f.member_team_ids:
    var t_cmd: TeamData = state.teams.get(tid_cmd)
    if t_cmd == null or t_cmd.player_commanded_task.is_empty(): continue
    var leader_cmd: PersonData = state.persons.get(t_cmd.leader_id)
    var loyalty_cmd: float = leader_cmd.loyalty if leader_cmd else 0.5
    if loyalty_cmd >= 0.4:
        # 執行玩家指令
        t_cmd.current_task = t_cmd.player_commanded_task
    else:
        # 不服從：unrest++
        t_cmd.unrest_turns += 1
        print("[FactionAI] Team%d 抗拒玩家指令（loyalty=%.2f）" % [tid_cmd, loyalty_cmd])
```

> **注意：** 在這段後 continue，避免覆蓋已設定的 player_commanded_task team。或在主迴圈開頭加 skip 判斷。

### 7C：玩家 actions

- [ ] **Step 3: 加 `set_faction_goal` action**

```gdscript
"set_faction_goal":
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var goal9: String = str(state.player_state.get("faction_goal_input", ""))
	if goal9 not in ["expand", "defend", "trade_net", ""]:
		return { "ok": false, "msg": "無效目標（expand/defend/trade_net/空字串清除）" }
	var f9: FactionData = state.factions.get(pt.faction_id)
	if f9 == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f9.leader_team_id != pt_id:
		return { "ok": false, "msg": "只有 leader 可設定勢力目標" }
	f9.player_goal_override = goal9
	var msg9: String = "清除 override" if goal9.is_empty() else "勢力目標設為 %s" % goal9
	print("[PlayerCmd] set_faction_goal → %s" % goal9)
	return { "ok": true, "msg": msg9 }
```

- [ ] **Step 4: 加 `order_faction_member` action**

```gdscript
"order_faction_member":
	# player_state 需設定：order_member_id, member_task, member_move_q/r
	var member_id9: int  = int(state.player_state.get("order_member_id", -1))
	var m_task9: String  = str(state.player_state.get("member_task", ""))
	var mq9: int = int(state.player_state.get("member_move_q", -1))
	var mr9: int = int(state.player_state.get("member_move_r", -1))
	var mt9: TeamData = state.teams.get(member_id9)
	if mt9 == null or mt9.faction_id != pt.faction_id:
		return { "ok": false, "msg": "目標不是同勢力成員" }
	mt9.player_commanded_task = m_task9
	if mq9 != -1:
		mt9.move_target = Vector2i(mq9, mr9)
	print("[PlayerCmd] order_faction_member Team%d → %s" % [member_id9, m_task9])
	return { "ok": true, "msg": "已下令 Team%d" % member_id9 }
```

- [ ] **Step 5: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`，`[FactionAI]` 仍運作。

- [ ] **Step 6: Commit**

```
git add scripts/simulation/faction_ai_system.gd scripts/simulation/player_command_system.gd
git commit -m "feat(faction_ai,player_cmd): G-09 faction goal override + member order with loyalty resistance"
```

---

## Task 8：T-01 — Action Registry 重構

此時 action_id 約 23 個，達重構門檻。

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`

- [ ] **Step 1: 在 `PlayerCommandSystem` 加 `_action_registry`**

在 `_init` 或 class 頂層加（`_interaction` 等 member 初始化後）：

```gdscript
var _action_registry: Dictionary = {}

func _setup_registry() -> void:
	_action_registry = {
		"trade":                  _action_trade,
		"propose_alliance":       _action_propose_alliance,
		"demand_tribute":         _action_demand_tribute,
		"attack":                 _action_attack,
		"extort":                 _action_extort,
		"recruit":                _action_recruit,
		"set_tribute_rate":       _action_set_tribute_rate,
		"build_outpost":          _action_build_outpost,
		"upgrade_outpost":        _action_upgrade_outpost,
		"upgrade_farming":        _action_upgrade_farming,
		"upgrade_manufacturing":  _action_upgrade_manufacturing,
		"demolish_outpost":       _action_demolish_outpost,
		"dispatch_subteam":       _action_dispatch_subteam,
		"order_subteam":          _action_order_subteam,
		"recall_subteam":         _action_recall_subteam,
		"subjugate_enemy":        _action_subjugate_enemy,
		"leave_faction":          _action_leave_faction,
		"betray_faction":         _action_betray_faction,
		"disband_faction":        _action_disband_faction,
		"offer_surrender":        _action_offer_surrender,
		"surrender_in_encounter": _action_surrender_in_encounter,
		"set_faction_goal":       _action_set_faction_goal,
		"order_faction_member":   _action_order_faction_member,
	}
```

- [ ] **Step 2: 把 `execute_action` match 改為 registry dispatch**

```gdscript
func execute_action(state: WorldState, target_id: int, action: String) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	if pt == null:
		return { "ok": false, "msg": "找不到玩家 team" }
	if action == "ignore":
		state.player_pending_targets.erase(target_id)
		return { "ok": true, "msg": "忽略" }
	if _action_registry.is_empty():
		_setup_registry()
	if not _action_registry.has(action):
		return { "ok": false, "msg": "未知行動: %s" % action }
	# 每個 action handler = func(state, target_id, pt, pt_id) -> Dictionary
	return _action_registry[action].call(state, target_id, pt, pt_id)
```

- [ ] **Step 3: 把所有 match case 改為獨立 handler 函式**

每個 case 改為 `func _action_<name>(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:`。

例如 trade 改為：

```gdscript
func _action_trade(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "目標不存在" }
	state.player_state["pending_trade_target"] = target_id
	return { "ok": true, "msg": "等待確認",
			 "requires_preview": true, "preview_target_id": target_id }
```

依此類推，把所有 23 個 action 重寫為 `_action_*` 函式。

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，行為與重構前完全一致。

- [ ] **Step 5: Commit**

```
git add scripts/simulation/player_command_system.gd
git commit -m "refactor(player_cmd): T-01 action registry pattern (~23 actions)"
```

---

## 最終驗證

- [ ] **全部跑過一次**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `=== DONE ===`，無 `SCRIPT ERROR`
- `[Faction]` 收編訊息仍由 NPC 觸發（玩家不自動）
- `[FactionAI]` 勢力 AI 仍運作
- `[Outpost]` 仍出現

- [ ] **Push branch**

```powershell
git push -u origin feat/batch2-player-actions
```

---

*最後更新：2026-06-04*
