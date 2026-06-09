# 玩家 Person 死亡保護（H）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 玩家 team leader 死亡時，forced event 等玩家選繼承人；無人 → Game Over；選繼承人期間世界凍結。

**Architecture:**
- WorldState 加 `game_over` + `game_over_reason`
- `faction_ai_system._promote_successor` 分流：玩家 team → `_handle_player_leader_death`
- `_handle_player_leader_death` 發 forced event 或設 game_over
- `player_command_system` 加 `choose_heir` action
- `sim_runner.advance_tick` 開頭凍結（game_over 或 awaiting_heir）
- `sim_runner` forced_event 超時跳過 choose_heir

**Spec:** `docs/superpowers/specs/2026-06-09-player-death-protection-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/data/world_state.gd` | 加 `game_over: bool` + `game_over_reason: String` |
| `scripts/simulation/faction_ai_system.gd` | 加 `_handle_player_leader_death` + `_get_player_team_id` + 改 `_promote_successor` |
| `scripts/simulation/player_command_system.gd` | 加 `choose_heir` action |
| `scripts/simulation/sim_runner.gd` | `advance_tick` 開頭凍結 + forced_event 超時跳過 choose_heir |
| `scripts/debug/headless_test.gd` | 8 個測試 |

## 測試命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

---

## Task 1: WorldState 加 game_over 欄位

**Files:**
- Modify: `scripts/data/world_state.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_game_over_field() -> void:
	print("--- Death Task1: game_over 欄位 ---")
	var s := WorldState.new()
	assert(s.game_over == false, "預設 false")
	assert(s.game_over_reason == "", "預設空字串")
	s.game_over = true
	s.game_over_reason = "test"
	assert(s.game_over and s.game_over_reason == "test")
	print("Death Task1 OK")
```

於 `_initialize()` 加 `_test_game_over_field()`。

- [ ] **Step 2: 加欄位**

`scripts/data/world_state.gd` 末尾或合適區加：

```gdscript
var game_over: bool = false
var game_over_reason: String = ""
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/data/world_state.gd scripts/debug/headless_test.gd
git commit -m "feat(world): add game_over + reason fields (Task 1)"
```

---

## Task 2: `_handle_player_leader_death` + 改 `_promote_successor`

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_handle_player_leader_death() -> void:
	print("--- Death Task2: _handle_player_leader_death ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100
	var pt := TeamData.new()
	pt.team_id = 0; pt.leader_id = 100
	pt.named_members = [101, 102]
	state.teams[0] = pt
	var p := PersonData.new(); p.id = 100; p.team_id = 0
	state.persons[100] = p
	var heir1 := PersonData.new(); heir1.id = 101; heir1.team_id = 0
	state.persons[101] = heir1
	var heir2 := PersonData.new(); heir2.id = 102; heir2.team_id = 0
	state.persons[102] = heir2
	# 模擬玩家死亡：persons 中移除
	state.persons.erase(100)
	pt.leader_id = -1
	var fai := FactionAISystem.new()
	fai._handle_player_leader_death(state, pt)
	assert(not state.player_forced_event.is_empty(), "應寫入 forced_event")
	assert(state.player_forced_event.get("action") == "choose_heir")
	var cands: Array = state.player_forced_event.get("candidates", [])
	assert(cands.has(101) and cands.has(102), "candidates 應含 named_members")
	print("Death Task2 OK")

func _test_no_heir_game_over() -> void:
	print("--- Death Task2b: 無 named → game_over ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100
	var pt := TeamData.new()
	pt.team_id = 0; pt.leader_id = -1
	pt.named_members = []
	state.teams[0] = pt
	var fai := FactionAISystem.new()
	fai._handle_player_leader_death(state, pt)
	assert(state.game_over, "無 named 應 game_over")
	assert(state.game_over_reason != "", "應有原因")
	print("Death Task2b OK")
```

- [ ] **Step 2: 跑測試失敗 → 加函數**

`faction_ai_system.gd` 加：

```gdscript
func _get_player_team_id(state: WorldState) -> int:
	if state.player_id == -1: return -1
	var p: PersonData = state.persons.get(state.player_id)
	if p == null:
		# 玩家已死，找 leader_id == player_id 或 player_id in named_members 的 team
		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			if t.leader_id == state.player_id or state.player_id in t.named_members:
				return tid
		return -1
	return p.team_id

func _handle_player_leader_death(state: WorldState, team: TeamData) -> void:
	team.leader_id = -1
	if team.named_members.is_empty():
		state.game_over = true
		state.game_over_reason = "玩家絕後（Team%d 無繼承人）" % team.team_id
		print("[GameOver] %s" % state.game_over_reason)
		return
	state.player_forced_event = {
		"action": "choose_heir",
		"team_id": team.team_id,
		"candidates": team.named_members.duplicate(),
	}
	state.player_forced_event_id = "heir_%d" % state.world.current_tick
	print("[Heir] 玩家 leader 死亡，等待選繼承人 (Team%d, %d 候選)" % [
		team.team_id, team.named_members.size()])
```

改 `_promote_successor` 開頭加：

```gdscript
func _promote_successor(state: WorldState, team: TeamData) -> void:
	# H: 玩家 team 走 _handle_player_leader_death
	var player_team_id: int = _get_player_team_id(state)
	if state.player_id != -1 and team.team_id == player_team_id:
		_handle_player_leader_death(state, team)
		return
	# 既有 NPC auto-promote 邏輯不變
	# ... 原 S11 code
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(succession): _handle_player_leader_death + _promote_successor route (Task 2)"
```

---

## Task 3: `choose_heir` player action

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_choose_heir_action() -> void:
	print("--- Death Task3: choose_heir action ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100   # 此時 100 已死,但 player_id 還沒清
	var pt := TeamData.new()
	pt.team_id = 0; pt.leader_id = -1
	pt.named_members = [101, 102]
	state.teams[0] = pt
	var heir1 := PersonData.new(); heir1.id = 101; heir1.team_id = 0
	heir1.person_name = "繼承人1"
	state.persons[101] = heir1
	var heir2 := PersonData.new(); heir2.id = 102; heir2.team_id = 0
	state.persons[102] = heir2
	state.player_forced_event = {
		"action": "choose_heir",
		"team_id": 0,
		"candidates": [101, 102]
	}
	state.player_state["heir_id"] = 101
	var cmd := PlayerCommandSystem.new()
	var r = cmd.execute_action(state, -1, "choose_heir")
	assert(r.get("ok", false), "choose_heir 應成功，msg=%s" % str(r.get("msg", "")))
	assert(pt.leader_id == 101, "leader_id 應 = 101")
	assert(state.player_id == 101, "player_id 應 = 101")
	assert(heir1.role == "leader", "heir1 role 應 leader")
	assert(not pt.named_members.has(101), "heir1 應從 named_members 移除")
	assert(state.player_forced_event.is_empty(), "forced_event 應清空")
	print("Death Task3 OK")

func _test_choose_heir_invalid_candidate() -> void:
	print("--- Death Task3b: 非合法候選 reject ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_forced_event = {
		"action": "choose_heir", "team_id": 0, "candidates": [101]
	}
	state.player_state["heir_id"] = 999   # 不在候選
	var pt := TeamData.new(); pt.team_id = 0
	state.teams[0] = pt
	var cmd := PlayerCommandSystem.new()
	var r = cmd.execute_action(state, -1, "choose_heir")
	assert(not r.get("ok", true), "非合法候選應 reject")
	print("Death Task3b OK")
```

- [ ] **Step 2: 加 action**

於 `scripts/simulation/player_command_system.gd` action map 加 `"choose_heir": _action_choose_heir,` + 函數：

```gdscript
func _action_choose_heir(state: WorldState, _target: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var fe: Dictionary = state.player_forced_event
	if fe.get("action", "") != "choose_heir":
		return { "ok": false, "msg": "無待選繼承人事件" }
	var heir_id: int = int(state.player_state.get("heir_id", -1))
	if heir_id == -1:
		return { "ok": false, "msg": "未選繼承人" }
	if not fe.get("candidates", []).has(heir_id):
		return { "ok": false, "msg": "非合法候選" }
	var team_id: int = int(fe.get("team_id", -1))
	var team: TeamData = state.teams.get(team_id)
	var heir: PersonData = state.persons.get(heir_id)
	if team == null or heir == null:
		return { "ok": false, "msg": "team/person 失效" }
	team.leader_id = heir_id
	team.named_members.erase(heir_id)
	heir.role = "leader"
	state.player_id = heir_id
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	state.player_state.erase("heir_id")
	print("[Heir] %s 繼任玩家 (Team%d)" % [heir.person_name, team_id])
	return { "ok": true, "msg": "%s 繼任" % heir.person_name }
```

注意：`_action_choose_heir` 簽名 `pt` 在玩家 person 已死時可能不可用，函數內用 `state.teams.get(team_id)` 取代。

- [ ] **Step 3: 跑測試 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(player_cmd): choose_heir action (Task 3)"
```

---

## Task 4: `sim_runner.advance_tick` 凍結

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_advance_tick_game_over_freeze() -> void:
	print("--- Death Task4: advance_tick game_over 凍結 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.game_over = true
	var runner := SimRunner.new()
	var saved_tick: int = state.world.current_tick
	var r: String = runner.advance_tick(state, Vector2i(0, 0))
	assert(r == "game_over", "應回 game_over，實際=%s" % r)
	assert(state.world.current_tick == saved_tick, "tick 不應推進")
	print("Death Task4 OK")

func _test_advance_tick_awaiting_heir_freeze() -> void:
	print("--- Death Task4b: 等繼承人 awaiting_heir 凍結 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_forced_event = { "action": "choose_heir", "team_id": 0, "candidates": [101] }
	var runner := SimRunner.new()
	var saved_tick: int = state.world.current_tick
	var r: String = runner.advance_tick(state, Vector2i(0, 0))
	assert(r == "awaiting_heir", "應回 awaiting_heir")
	assert(state.world.current_tick == saved_tick, "tick 不應推進")
	print("Death Task4b OK")
```

- [ ] **Step 2: 修 advance_tick**

打開 `scripts/simulation/sim_runner.gd` 的 `advance_tick` 函數開頭：

```gdscript
func advance_tick(state: WorldState, player_pos: Vector2i) -> String:
	if state.game_over:
		return "game_over"
	if state.player_forced_event.get("action", "") == "choose_heir":
		return "awaiting_heir"
	if state.encounter_active:
		# ... 既有 encounter 邏輯
```

- [ ] **Step 3: 修 forced_event 超時跳過 choose_heir**

找 forced_event 超時邏輯（約 line 82-86）：

```gdscript
if not state.player_forced_event.is_empty():
	# H: choose_heir 不超時
	if state.player_forced_event.get("action", "") == "choose_heir":
		pass
	else:
		print("[PlayerCmd] forced_event 超時自動拒絕: %s" % str(state.player_forced_event))
		# ... 既有 aid_request 超時邏輯
		state.player_forced_event = {}
		state.player_forced_event_id = ""
```

注意：既有可能已有 aid_request 超時邏輯（B spec），需要小心保留結構。

- [ ] **Step 4: 跑測試 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/sim_runner.gd scripts/debug/headless_test.gd
git commit -m "feat(sim_runner): freeze world on game_over / awaiting_heir (Task 4)"
```

---

## Task 5: Encounter 殺玩家 leader 整合測試

**Files:**
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 整合測試（encounter 死後 forced event 出現）**

```gdscript
func _test_encounter_kills_player_triggers_heir() -> void:
	print("--- Death Task5: encounter 殺玩家觸發 forced_event ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100
	# Player team
	var pt := TeamData.new()
	pt.team_id = 0; pt.leader_id = 100
	pt.named_members = [101]
	state.teams[0] = pt
	var player_person := PersonData.new()
	player_person.id = 100; player_person.team_id = 0
	# 模擬玩家戰死：torso severed
	player_person.body_parts = { "torso": { "status": "severed", "hp": 0, "max_hp": 50 } }
	state.persons[100] = player_person
	var heir := PersonData.new(); heir.id = 101; heir.team_id = 0
	state.persons[101] = heir
	# 模擬 encounter resolve：直接呼叫 promote_successor (encounter 結束後 faction_ai 會跑)
	# encounter_system 內 line ~1042 erase 死亡 person from named_members，leader_id = -1
	pt.leader_id = -1   # 玩家戰死
	state.persons.erase(100)
	# 跑 faction_ai _promote_successor
	var fai := FactionAISystem.new()
	fai._promote_successor(state, pt)
	# 應有 forced_event 而非 auto-promote
	assert(not state.player_forced_event.is_empty(), "玩家 team 應 forced event 而非 auto")
	assert(state.player_forced_event.get("action") == "choose_heir")
	assert(pt.leader_id == -1, "leader_id 不應自動升 (等玩家選)")
	print("Death Task5 OK")
```

- [ ] **Step 2: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/debug/headless_test.gd
git commit -m "test(death): encounter kills player triggers heir forced event (Task 5)"
```

---

## Task 6: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-09-player-death-protection.md`

- [ ] **Step 1: 全 headless 跑**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

預期：所有 Death Task 通過 + game_sim_test 不破。

- [ ] **Step 2: 寫 handback**

```markdown
# Hand Back: Player Death Protection (H)

## 實作摘要

- WorldState：加 game_over + game_over_reason
- faction_ai_system：
  - _get_player_team_id helper（含玩家已死的 fallback 反查）
  - _handle_player_leader_death（forced event 或 game_over）
  - _promote_successor 開頭分流（玩家 team 走 H path）
- player_command_system：加 choose_heir action
- sim_runner.advance_tick：開頭 game_over → "game_over"、choose_heir 等待 → "awaiting_heir"
- sim_runner forced_event 超時：choose_heir 不超時

## 行為變化

- 玩家 leader 死亡 → forced event 「選繼承人」
- 玩家選 named member → 繼承為新 leader、player_id 跟隨
- 無 named member → state.game_over = true，世界凍結
- 選繼承人期間世界凍結（不超時、不自動）
- NPC team leader 死亡走 S11 auto-promote 不受影響

## 連動風險

- _get_player_team_id 在玩家死後人 person 已 null → 用 team 反查
- forced event 超時邏輯需仔細處理（保留 aid_request 既有 callback）
- UI 尚未實作繼承人面板（後續 G/I spec）

## 待主 session 確認

- UI 繼承人面板規格（玩家如何選 heir_id）
- Game Over 後重玩 / 主選單流程
- 老化 / 飢餓 / 病死 死亡來源（獨立 spec）
- 玩家被俘虜（俘虜系統 spec）
```

- [ ] **Step 3: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-09-player-death-protection.md
git commit -m "docs: H player death protection handback (Task 6)"
```
