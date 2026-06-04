# UI API Completeness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補全 PlayerApiMapper / PlayerQueryApi / SimBridge，使 UI 能透過 API 取得勢力面板、前哨站面板、子隊面板所需資料，並修正 payload 轉發 bug。

**Architecture:** 在 PlayerApiMapper 加 3 個 static map 函式，在 PlayerQueryApi 加 3 個 query 函式（各自加 `map_query_envelope` 包裝），SimBridge 加 wrappers；同時修正 PlayerCommandApi.execute_action 的 payload 未轉發問題，加 SimBridge.set_player_input。

**Tech Stack:** Godot 4.2.2 GDScript，無外部依賴。

---

## 檔案結構

| 檔案 | 改動 |
|---|---|
| `scripts/simulation/player_command_api.gd` | 修 execute_action：轉發底層 payload |
| `scripts/ui/sim_bridge.gd` | 加 set_player_input + 3 panel wrappers |
| `scripts/simulation/player_api_mapper.gd` | 加 map_faction_panel / map_outpost_panel / map_subteam_panel |
| `scripts/simulation/player_query_api.gd` | 加 query_faction_panel / query_outpost_panel / query_subteam_panel；擴充 _build_available_actions + _action_label |
| `scripts/debug/headless_test.gd` | 加驗證 print |

---

### Task 1: PlayerCommandApi payload 轉發修正 + SimBridge.set_player_input

**Files:**
- Modify: `scripts/simulation/player_command_api.gd:70-77`
- Modify: `scripts/ui/sim_bridge.gd`

背景：`PlayerCommandApi.execute_action` 在 line 71 建立新 payload 時完全不合併底層 command 的 payload。這導致 `gather_intel` 回傳的 `inquiry_options` 丟失。同時 UI 需要寫 `player_state` 參數（如 `tribute_rate_input`），但 SimBridge 沒有這個入口。

- [ ] **Step 1: 修正 player_command_api.gd execute_action payload 轉發**

開啟 `scripts/simulation/player_command_api.gd`，找到約 line 70-77：

```gdscript
# 原始（約 line 70-76）
	if result.get("ok", false):
		var payload: Dictionary = {"action_id": action_id, "result_summary": result.get("msg", ""), "refresh_required": true}
		if result.has("requires_preview"):
			payload["requires_preview"] = result["requires_preview"]
		if result.has("preview_target_id"):
			payload["preview_target_id"] = result["preview_target_id"]
		return PlayerApiMapper.map_command_result(true, "ok", result.get("msg", ""), payload)
```

改成：

```gdscript
	if result.get("ok", false):
		var payload: Dictionary = {"action_id": action_id, "result_summary": result.get("msg", ""), "refresh_required": true}
		payload.merge(result.get("payload", {}))   # 轉發底層 payload（inquiry_options 等）
		if result.has("requires_preview"):
			payload["requires_preview"] = result["requires_preview"]
		if result.has("preview_target_id"):
			payload["preview_target_id"] = result["preview_target_id"]
		return PlayerApiMapper.map_command_result(true, "ok", result.get("msg", ""), payload)
```

- [ ] **Step 2: 在 SimBridge 加 set_player_input**

開啟 `scripts/ui/sim_bridge.gd`，在最後加：

```gdscript
func set_player_input(key: String, value: Variant) -> void:
	_state.player_state[key] = value
```

- [ ] **Step 3: 跑 headless test 確認無崩潰**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/player_command_api.gd scripts/ui/sim_bridge.gd
git commit -m "fix(api): forward inner payload in execute_action + SimBridge.set_player_input"
```

---

### Task 2: PlayerApiMapper.map_faction_panel

**Files:**
- Modify: `scripts/simulation/player_api_mapper.gd`（在檔案末尾加）

背景：FactionData 欄位：`leader_team_id`, `member_team_ids`, `tribute_rate`, `strategic_goals`, `player_goal_override`, `known_member_states`。TeamData 欄位：`team_id`, `tile_pos`, `player_commanded_task`, `leader_id`。WorldState 欄位：`player_pending_orders`（Task 1 of Plan 3 加，此 Plan 先讀時用 `.get("player_pending_orders", {})`）。

- [ ] **Step 1: 在 player_api_mapper.gd 末尾加 map_faction_panel**

```gdscript
static func map_faction_panel(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	if pid == -1:
		return {"in_faction": false, "faction_id": -1, "is_leader": false,
			"faction_goal": "", "player_goal_override": "", "tribute_rate": 0.0,
			"member_orders": [], "actions": []}
	var p: PersonData = state.persons.get(pid)
	if p == null:
		return {"in_faction": false, "faction_id": -1, "is_leader": false,
			"faction_goal": "", "player_goal_override": "", "tribute_rate": 0.0,
			"member_orders": [], "actions": []}
	var pt: TeamData = state.teams.get(p.team_id)
	if pt == null or pt.faction_id == -1:
		return {"in_faction": false, "faction_id": -1, "is_leader": false,
			"faction_goal": "", "player_goal_override": "", "tribute_rate": 0.0,
			"member_orders": [], "actions": []}
	var f = state.factions.get(pt.faction_id)
	if f == null:
		return {"in_faction": false, "faction_id": -1, "is_leader": false,
			"faction_goal": "", "player_goal_override": "", "tribute_rate": 0.0,
			"member_orders": [], "actions": []}
	var is_leader: bool = f.leader_team_id == pt.team_id
	var pending_orders: Dictionary = state.get("player_pending_orders", {}) \
		if state.has_method("get") else {}
	var member_orders: Array = []
	for mid in f.member_team_ids:
		var mt: TeamData = state.teams.get(mid)
		if mt == null: continue
		var ml: PersonData = state.persons.get(mt.leader_id)
		var name_str: String = ml.name if ml else "Team%d" % mid
		var pending: Dictionary = pending_orders.get(mid, {})
		member_orders.append({
			"team_id": mid,
			"name": name_str,
			"tile_pos": mt.tile_pos,
			"commanded_task": mt.player_commanded_task,
			"pending_task": pending.get("task", ""),
			"herald_id": pending.get("herald_id", -1),
		})
	var actions: Array = ["order_faction_member", "clear_member_order"]
	if is_leader:
		actions.append_array(["set_faction_goal", "set_tribute_rate",
			"leave_faction", "betray_faction", "disband_faction"])
	else:
		actions.append("leave_faction")
	return {
		"in_faction": true,
		"faction_id": pt.faction_id,
		"is_leader": is_leader,
		"faction_goal": f.strategic_goals[0] if f.strategic_goals.size() > 0 else "",
		"player_goal_override": f.player_goal_override,
		"tribute_rate": f.tribute_rate,
		"member_orders": member_orders,
		"actions": actions,
	}
```

**注意：** `pending_orders` 在 Plan 3 Task 1 才加到 WorldState。此函式用 `.get("player_pending_orders", {})` 相容舊版，Plan 3 完成後會直接讀 `state.player_pending_orders`。

- [ ] **Step 2: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/player_api_mapper.gd
git commit -m "feat(api): PlayerApiMapper.map_faction_panel"
```

---

### Task 3: PlayerQueryApi.query_faction_panel + SimBridge wrapper

**Files:**
- Modify: `scripts/simulation/player_query_api.gd`
- Modify: `scripts/ui/sim_bridge.gd`

- [ ] **Step 1: 在 player_query_api.gd 加 query_faction_panel**

在 `get_and_clear_alerts` 之前加：

```gdscript
func query_faction_panel(state: WorldState) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		{"faction_panel": PlayerApiMapper.map_faction_panel(state)})
```

- [ ] **Step 2: 在 sim_bridge.gd 加 wrapper**

```gdscript
func query_faction_panel() -> Dictionary:
	return PlayerQueryApi.new().query_faction_panel(_state)
```

- [ ] **Step 3: 在 headless_test.gd 加驗證**

找到 `=== DONE ===` print 前，加：

```gdscript
# --- faction_panel API ---
var _fp_api := PlayerQueryApi.new()
var _fp_result := _fp_api.query_faction_panel(state)
print("[Test] query_faction_panel ok=%s in_faction=%s" % [
	str(_fp_result.get("ok")),
	str(_fp_result.get("data", {}).get("faction_panel", {}).get("in_faction"))])
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `[Test] query_faction_panel ok=true in_faction=...` 出現（true 或 false 皆可，無 SCRIPT ERROR）。

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/player_query_api.gd scripts/ui/sim_bridge.gd scripts/debug/headless_test.gd
git commit -m "feat(api): query_faction_panel + SimBridge wrapper"
```

---

### Task 4: map_outpost_panel + query_outpost_panel + SimBridge wrapper

**Files:**
- Modify: `scripts/simulation/player_api_mapper.gd`
- Modify: `scripts/simulation/player_query_api.gd`
- Modify: `scripts/ui/sim_bridge.gd`

背景：`OutpostSystem._has_control(state, team_id, tile)` 是 private func，需用 `OutpostSystem.new()._has_control(...)`。HexTileData 欄位：`outpost_type: String`（`""` = 無）、`outpost_level: int`、`outpost_owner: int`（`-1` = 無）、`construction_team_id: int`（`-1` = 無施工）、`construction_ticks_left: int`、`construction_target: Dictionary`。

- [ ] **Step 1: 加 map_outpost_panel**

在 `player_api_mapper.gd` 末尾加：

```gdscript
static func map_outpost_panel(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	if pid == -1:
		return {"tile_pos": Vector2i(-1, -1), "outpost_type": "", "outpost_level": 0,
			"outpost_owner": -1, "has_control": false,
			"construction_in_progress": false, "ticks_left": 0, "actions": []}
	var p: PersonData = state.persons.get(pid)
	if p == null:
		return {"tile_pos": Vector2i(-1, -1), "outpost_type": "", "outpost_level": 0,
			"outpost_owner": -1, "has_control": false,
			"construction_in_progress": false, "ticks_left": 0, "actions": []}
	var pt: TeamData = state.teams.get(p.team_id)
	if pt == null:
		return {"tile_pos": Vector2i(-1, -1), "outpost_type": "", "outpost_level": 0,
			"outpost_owner": -1, "has_control": false,
			"construction_in_progress": false, "ticks_left": 0, "actions": []}
	var key: int = pt.tile_pos.x * 1000 + pt.tile_pos.y
	var tile = state.world.tiles.get(key)
	if tile == null:
		return {"tile_pos": pt.tile_pos, "outpost_type": "", "outpost_level": 0,
			"outpost_owner": -1, "has_control": false,
			"construction_in_progress": false, "ticks_left": 0, "actions": []}
	var has_ctrl: bool = OutpostSystem.new()._has_control(state, pt.team_id, tile)
	var in_progress: bool = tile.construction_team_id != -1
	var actions: Array = []
	if has_ctrl:
		if tile.outpost_type == "" and not in_progress:
			actions.append("build_outpost")
		elif tile.outpost_type != "" and not in_progress:
			actions.append_array(["upgrade_outpost", "upgrade_farming",
				"upgrade_manufacturing", "demolish_outpost"])
	return {
		"tile_pos": pt.tile_pos,
		"outpost_type": tile.outpost_type,
		"outpost_level": tile.outpost_level,
		"outpost_owner": tile.outpost_owner,
		"has_control": has_ctrl,
		"construction_in_progress": in_progress,
		"ticks_left": tile.construction_ticks_left,
		"actions": actions,
	}
```

- [ ] **Step 2: 加 query_outpost_panel + SimBridge wrapper**

在 `player_query_api.gd` 的 `query_faction_panel` 後加：

```gdscript
func query_outpost_panel(state: WorldState) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		{"outpost_panel": PlayerApiMapper.map_outpost_panel(state)})
```

在 `sim_bridge.gd` 加：

```gdscript
func query_outpost_panel() -> Dictionary:
	return PlayerQueryApi.new().query_outpost_panel(_state)
```

- [ ] **Step 3: 加 headless 驗證**

```gdscript
# --- outpost_panel API ---
var _op_result := PlayerQueryApi.new().query_outpost_panel(state)
print("[Test] query_outpost_panel ok=%s tile_pos=%s" % [
	str(_op_result.get("ok")),
	str(_op_result.get("data", {}).get("outpost_panel", {}).get("tile_pos"))])
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `[Test] query_outpost_panel ok=true tile_pos=...`，無 SCRIPT ERROR。

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/player_api_mapper.gd scripts/simulation/player_query_api.gd scripts/ui/sim_bridge.gd scripts/debug/headless_test.gd
git commit -m "feat(api): map_outpost_panel + query_outpost_panel + SimBridge wrapper"
```

---

### Task 5: map_subteam_panel + query_subteam_panel + SimBridge wrapper

**Files:**
- Modify: `scripts/simulation/player_api_mapper.gd`
- Modify: `scripts/simulation/player_query_api.gd`
- Modify: `scripts/ui/sim_bridge.gd`

背景：子隊 = `parent_team_id == player_team_id` 的所有 TeamData。TeamData 欄位：`team_id`, `tile_pos`, `current_task`, `order_task`, `population`, `player_commanded_task`, `parent_team_id`。

- [ ] **Step 1: 加 map_subteam_panel**

在 `player_api_mapper.gd` 末尾加：

```gdscript
static func map_subteam_panel(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	if pid == -1:
		return {"subteams": [], "actions_per_subteam": {}}
	var p: PersonData = state.persons.get(pid)
	if p == null:
		return {"subteams": [], "actions_per_subteam": {}}
	var ptid: int = p.team_id
	var subteams: Array = []
	var actions_per: Dictionary = {}
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.parent_team_id != ptid: continue
		subteams.append({
			"team_id": tid,
			"tile_pos": t.tile_pos,
			"current_task": t.current_task,
			"order_task": t.order_task,
			"population": t.population,
			"player_commanded_task": t.player_commanded_task,
		})
		actions_per[str(tid)] = ["order_subteam", "recall_subteam"]
	return {"subteams": subteams, "actions_per_subteam": actions_per}
```

- [ ] **Step 2: 加 query_subteam_panel + SimBridge wrapper**

在 `player_query_api.gd` 加：

```gdscript
func query_subteam_panel(state: WorldState) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		{"subteam_panel": PlayerApiMapper.map_subteam_panel(state)})
```

在 `sim_bridge.gd` 加：

```gdscript
func query_subteam_panel() -> Dictionary:
	return PlayerQueryApi.new().query_subteam_panel(_state)
```

- [ ] **Step 3: 加 headless 驗證**

```gdscript
# --- subteam_panel API ---
var _sp_result := PlayerQueryApi.new().query_subteam_panel(state)
print("[Test] query_subteam_panel ok=%s subteams=%d" % [
	str(_sp_result.get("ok")),
	_sp_result.get("data", {}).get("subteam_panel", {}).get("subteams", []).size()])
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `[Test] query_subteam_panel ok=true subteams=0`（初始無子隊），無 SCRIPT ERROR。

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/player_api_mapper.gd scripts/simulation/player_query_api.gd scripts/ui/sim_bridge.gd scripts/debug/headless_test.gd
git commit -m "feat(api): map_subteam_panel + query_subteam_panel + SimBridge wrapper"
```

---

### Task 6: _build_available_actions 擴充 + _action_label 擴充

**Files:**
- Modify: `scripts/simulation/player_query_api.gd:277-330`

背景：`_build_available_actions` 在 `player_query_api.gd` line 148。Layer 5（global actions）在 line 277 附近。`_action_label` 在 line 337。

- [ ] **Step 1: 在 Layer 5 末尾加新 global actions**

找到 `take_loot` / `leave_loot` 的 block（約 line 296-328），在其後、`return actions` 前插入：

```gdscript
	# subjugate_enemy（戰後可收編）
	var ler: Dictionary = state.last_encounter_result
	if ler.get("can_subjugate", false):
		actions.append(PlayerApiMapper.map_available_action(
			"subjugate_enemy", "收編敗者", true, "",
			{
				"allowed_kinds": PackedStringArray(["none"]),
				"requires_visible_target": false,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"execute_action",
			{"action_id": "subjugate_enemy",
			 "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}}
		))

	# confirm_gather_intel（等待選題）
	if state.player_state.has("pending_intel_target"):
		actions.append(PlayerApiMapper.map_available_action(
			"confirm_gather_intel", "確認打聽", true, "",
			{
				"allowed_kinds": PackedStringArray(["none"]),
				"requires_visible_target": false,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"execute_action",
			{"action_id": "confirm_gather_intel",
			 "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}}
		))

	# offer_surrender（戰鬥中對目標提出投降）
	if state.encounter_active and focus_team_id != -1:
		actions.append(PlayerApiMapper.map_available_action(
			"offer_surrender", "投降請和", true, "",
			{
				"allowed_kinds": PackedStringArray(["team"]),
				"requires_visible_target": true,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"execute_action",
			{"action_id": "offer_surrender",
			 "target": {"kind": "team", "team_id": focus_team_id, "member_id": -1, "tile_q": -1, "tile_r": -1}}
		))
```

- [ ] **Step 2: 在 Layer 4 的 team_actions 加 gather_intel**

找到 Layer 4 的 `for act in team_actions:` 迴圈之前，加：

`PlayerCommandSystem.get_available_actions` 已在 line 40 永遠加入 `gather_intel`，所以 `team_actions` 中已有。確認 `_action_label` 有對應 label 即可（下一步）。

- [ ] **Step 3: 擴充 _action_label**

找到 `_action_label` 函式（line 337），在 `return action_id` 之前加：

```gdscript
		"gather_intel":           return "打聽情報"
		"confirm_gather_intel":   return "確認打聽"
		"subjugate_enemy":        return "收編敗者"
		"offer_surrender":        return "投降請和"
		"surrender_in_encounter": return "戰中投降"
		"leave_faction":          return "退出勢力"
		"betray_faction":         return "背叛勢力"
		"disband_faction":        return "解散勢力"
		"set_faction_goal":       return "設定勢力目標"
		"order_faction_member":   return "下令成員"
		"clear_member_order":     return "清除指令"
		"set_tribute_rate":       return "調整徵收率"
		"build_outpost":          return "建設前哨站"
		"upgrade_outpost":        return "升級等級"
		"upgrade_farming":        return "升級農作"
		"upgrade_manufacturing":  return "升級製造"
		"demolish_outpost":       return "拆除前哨站"
		"dispatch_subteam":       return "派遣子隊"
		"order_subteam":          return "下令子隊"
		"recall_subteam":         return "召回子隊"
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`，無 SCRIPT ERROR。

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/player_query_api.gd
git commit -m "feat(api): _build_available_actions extend + _action_label batch update"
```
