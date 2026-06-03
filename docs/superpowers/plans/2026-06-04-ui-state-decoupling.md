# UI State Decoupling Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 4 個 UI 檔案（text_ui_main、right_sidebar、bottom_bar、world_map_view）零 WorldState 直讀。所有狀態透過 SimBridge / PlayerQueryApi / PlayerApiMapper 取得。

**Architecture:** 先擴充 PlayerApiMapper（3 新 static 函式）+ SimBridge（12 新 helper 方法），再逐一清除各 UI 檔的 `_state.` 直讀。成功標準：`Select-String -Path "scripts\ui\text_ui_main.gd","scripts\ui\right_sidebar.gd","scripts\ui\bottom_bar.gd","scripts\ui\world_map_view.gd" -Pattern "_state\."` 零輸出。

**Tech Stack:** Godot 4.2.2 GDScript，無外部依賴。前置條件：Plan 1（ui-api-completeness）已完成。

---

## 檔案結構

| 檔案 | 改動 |
|---|---|
| `scripts/simulation/player_api_mapper.gd` | 加 map_body_slots / map_global_messages / map_visible_teams_render；補 map_controlled_team wounded；補 map_player_summary loyalty/stress |
| `scripts/ui/sim_bridge.gd` | 加 12 個 helper 方法 |
| `scripts/ui/text_ui_main.gd` | 移除 `var _state`，所有 `_state.` 改 bridge 呼叫 |
| `scripts/ui/right_sidebar.gd` | refresh_player() 改用 snapshot，刪 `_find_team_at` |
| `scripts/ui/bottom_bar.gd` | show_tile_info() 改用 bridge 方法 |
| `scripts/ui/world_map_view.gd` | 加快取欄位，_draw() 改用快取資料，刪 state 直讀 |

---

### Task 1: PlayerApiMapper — 新 static 函式 + 欄位補全

**Files:**
- Modify: `scripts/simulation/player_api_mapper.gd`

- [ ] **Step 1: 在 map_controlled_team 加 wounded 欄位**

找到 `map_controlled_team` 函式回傳的 Dictionary（約 line 90-120），在 `"population"` 行後加：

```gdscript
"wounded":         t.wounded,
```

- [ ] **Step 2: 在 map_player_summary 加 loyalty / stress**

找到 `map_player_summary` 回傳的 Dictionary（約 line 46-58），在 `"hp_status"` 後加：

```gdscript
"loyalty": p.loyalty,
"stress":  p.stress,
```

- [ ] **Step 3: 在檔案末尾加 map_body_slots**

```gdscript
# ── Body slots ─────────────────────────────────────────────────────────────────

static func map_body_slots(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	if p == null:
		return {"head": "", "torso": "", "right_arm": "", "left_arm": "", "right_leg": "", "left_leg": ""}
	var slots: Array = ["head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"]
	var result: Dictionary = {}
	for slot in slots:
		result[slot] = p.equipment.get(slot, {}).get("grade", "")
	return result
```

- [ ] **Step 4: 在檔案末尾加 map_global_messages**

```gdscript
# ── Global messages ────────────────────────────────────────────────────────────

static func map_global_messages(state: WorldState, n: int = 10) -> Array:
	var msgs: Array = []
	var start: int = maxi(0, state.global_messages.size() - n)
	for i in range(start, state.global_messages.size()):
		var m = state.global_messages[i]
		msgs.append(m.get("description", str(m)) if m is Dictionary else str(m))
	return msgs
```

- [ ] **Step 5: 在檔案末尾加 map_visible_teams_render**

```gdscript
# ── Visible teams render ───────────────────────────────────────────────────────

static func map_visible_teams_render(state: WorldState, observer_tid: int) -> Array:
	if observer_tid < 0:
		return []
	var observer: TeamData = state.teams.get(observer_tid)
	if observer == null:
		return []
	var discovered: Array = state.team_discovered.get(observer_tid, [])
	var result: Array = []
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		var is_player: bool = tid == observer_tid
		if is_player:
			result.append({
				"team_id": tid, "tile_pos": team.tile_pos,
				"faction_id": team.faction_id, "population": team.population,
				"is_player": true, "is_hostile": false, "draw_mode": "current"
			})
			continue
		if not discovered.has(tid):
			continue
		var ddx: int = team.tile_pos.x - observer.tile_pos.x
		var ddy: int = team.tile_pos.y - observer.tile_pos.y
		var cur_dist: int = (abs(ddx) + abs(ddx + ddy) + abs(ddy)) / 2
		if cur_dist <= 3:
			result.append({
				"team_id": tid, "tile_pos": team.tile_pos,
				"faction_id": team.faction_id, "population": team.population,
				"is_player": false, "is_hostile": state.player_hostile_teams.has(tid),
				"draw_mode": "current"
			})
		else:
			var intel: Dictionary = state.team_intel.get(observer_tid, {}).get(tid, {})
			if intel.has("tile_pos"):
				result.append({
					"team_id": tid, "tile_pos": intel["tile_pos"],
					"faction_id": team.faction_id, "population": team.population,
					"is_player": false, "is_hostile": state.player_hostile_teams.has(tid),
					"draw_mode": "ghost"
				})
	return result
```

- [ ] **Step 6: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 7: Commit**

```
git add scripts/simulation/player_api_mapper.gd
git commit -m "feat(api): add map_body_slots, map_global_messages, map_visible_teams_render; add wounded/loyalty/stress fields"
```

---

### Task 2: SimBridge — 12 個 helper 方法

**Files:**
- Modify: `scripts/ui/sim_bridge.gd`

- [ ] **Step 1: 在 get_player_team_id() 後加 tick + player position helpers**

```gdscript
func get_current_tick() -> int:
	return _state.world.current_tick

func get_player_tile_pos() -> Vector2i:
	var tid: int = get_player_team_id()
	if tid < 0: return Vector2i.ZERO
	var t: TeamData = _state.teams.get(tid)
	return t.tile_pos if t else Vector2i.ZERO

func get_player_move_target() -> Vector2i:
	var tid: int = get_player_team_id()
	if tid < 0: return Vector2i(-1, -1)
	var t: TeamData = _state.teams.get(tid)
	return t.move_target if t else Vector2i(-1, -1)
```

- [ ] **Step 2: 加 tile query helpers**

```gdscript
func is_valid_tile(q: int, r: int) -> bool:
	return _state.world.tiles.has(q * 1000 + r)

func query_tile(q: int, r: int) -> Dictionary:
	var key: int = q * 1000 + r
	var tile: HexTileData = _state.world.tiles.get(key)
	if tile == null: return {}
	return {
		"terrain":        tile.terrain,
		"productivity":   tile.harvest_factor,
		"harvest_factor": tile.harvest_factor,
		"resources":      tile.resources.duplicate(),
		"outpost_type":   tile.outpost_type,
		"outpost_level":  tile.outpost_level,
		"outpost_owner":  tile.outpost_owner,
	}

func render_text_map(player_tid: int, cursor: Vector2i) -> String:
	return TextMapRenderer.render(_state, player_tid, cursor)
```

- [ ] **Step 3: 加 data query wrappers**

```gdscript
func query_body_slots() -> Dictionary:
	return PlayerApiMapper.map_body_slots(_state)

func query_global_messages(n: int = 10) -> Array:
	return PlayerApiMapper.map_global_messages(_state, n)

func query_visible_teams_render() -> Array:
	return PlayerApiMapper.map_visible_teams_render(_state, get_player_team_id())
```

- [ ] **Step 4: 加 world tiles + tile/team spatial helpers**

```gdscript
func query_world_tiles() -> Dictionary:
	var result: Dictionary = {}
	for key in _state.world.tiles:
		var tile: HexTileData = _state.world.tiles[key]
		result[key] = {
			"tile_pos":       tile.tile_pos,
			"terrain":        tile.terrain,
			"harvest_factor": tile.harvest_factor,
			"resources":      tile.resources.duplicate(),
			"outpost_type":   tile.outpost_type,
			"outpost_level":  tile.outpost_level,
			"outpost_owner":  tile.outpost_owner,
		}
	return result

func is_tile_in_vision(q: int, r: int) -> bool:
	var tid: int = get_player_team_id()
	if tid < 0: return true
	var t: TeamData = _state.teams.get(tid)
	if t == null: return false
	var dx: int = q - t.tile_pos.x
	var dy: int = r - t.tile_pos.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2 <= 3

func has_tile_intel(q: int, r: int) -> bool:
	var player_tid: int = get_player_team_id()
	if player_tid < 0: return false
	var discovered: Array = _state.team_discovered.get(player_tid, [])
	var pos := Vector2i(q, r)
	for tid in discovered:
		var intel: Dictionary = _state.team_intel.get(player_tid, {}).get(tid, {})
		if intel.get("tile_pos", Vector2i(-999, -999)) == pos:
			return true
	return false

func get_teams_at_tile(q: int, r: int) -> Array:
	var pos := Vector2i(q, r)
	var result: Array = []
	for tid in _state.teams:
		var t: TeamData = _state.teams[tid]
		if t.tile_pos == pos:
			result.append({
				"id": tid, "faction_id": t.faction_id,
				"population": t.population, "current_task": t.current_task
			})
	return result

func get_all_teams_debug() -> Array:
	var result: Array = []
	for tid in _state.teams:
		var t: TeamData = _state.teams[tid]
		result.append({"id": tid, "pos": t.tile_pos, "pop": t.population, "task": t.current_task})
	return result

func query_render_context() -> Dictionary:
	var ptid: int = get_player_team_id()
	var player_team: TeamData = _state.teams.get(ptid) if ptid >= 0 else null
	var discovered: Array = _state.team_discovered.get(ptid, []) if ptid >= 0 else []
	var disc_positions: Array = []
	for tid in discovered:
		var t: TeamData = _state.teams.get(tid)
		if t: disc_positions.append(t.tile_pos)
	return {
		"player_tile_pos":           player_team.tile_pos if player_team else Vector2i(-1, -1),
		"discovered_team_positions": disc_positions,
		"vision_radius":             3,
	}
```

- [ ] **Step 5: 跑 headless test**

Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 6: Commit**

```
git add scripts/ui/sim_bridge.gd
git commit -m "feat(bridge): add 12 helper methods for UI state decoupling"
```

---

### Task 3: text_ui_main.gd 清除直讀

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

本 task 移除 `var _state: WorldState`，替換所有 `_state.` 用 bridge 呼叫。

- [ ] **Step 1: 移除 _state 欄位**

刪除 line 4：
```gdscript
var _state: WorldState
```

- [ ] **Step 2: 修正 _ready()**

將原 `_ready()` 改為（WorldState 本地建立後不保存在 `_state`）：

```gdscript
func _ready() -> void:
	var ws := WorldState.new()
	_runner = SimRunner.new()
	_bridge = SimBridge.new(_runner, ws)
	var config := GameSetup.load_config("res://config/default.json")
	GameSetup.setup(ws, config)
	_player_tid = _bridge.get_player_team_id()
	_cursor = _bridge.get_player_tile_pos()
	_refresh()
```

- [ ] **Step 3: 修正 _process() — move_target + current_tick**

將 _process 內讀 `_state.teams.get(_player_tid)` 的兩處改為：

```gdscript
func _process(_delta: float) -> void:
	if not _bridge.is_advancing(): return
	var result := _bridge.tick_step()
	_events.append_array(result.get("events", []))
	if _events.size() > 100:
		_events = _events.slice(_events.size() - 100)

	var move_target: Vector2i = _bridge.get_player_move_target()
	if move_target == Vector2i(-1, -1) and _input_bar.text.begins_with("移動中"):
		_bridge.cancel_advance()
		_input_bar.text = ""
		var pos: Vector2i = _bridge.get_player_tile_pos()
		_log_event("Team%d 到達 (%d,%d)" % [_player_tid, pos.x, pos.y])

	if result.get("done", false):
		var mt2: Vector2i = _bridge.get_player_move_target()
		if _input_bar.text.begins_with("移動中") and mt2 != Vector2i(-1, -1):
			_bridge.request_advance(99999)
		else:
			_input_bar.text = ""
	elif not _input_bar.text.begins_with("移動中"):
		_input_bar.text = "推進中 Tick:%d [Esc]停止" % _bridge.get_current_tick()
	_refresh()
	if _cached_snapshot.get("player_summary", {}).get("encounter_active", false):
		_bridge.cancel_advance()
```

- [ ] **Step 4: 修正 _move_cursor() — 用 is_valid_tile**

```gdscript
func _move_cursor(delta: Vector2i) -> void:
	var new_pos := _cursor + delta
	if _bridge.is_valid_tile(new_pos.x, new_pos.y):
		_cursor = new_pos
	_refresh()
```

- [ ] **Step 5: 修正 KEY_H handler**

```gdscript
KEY_H:
	_cursor = _bridge.get_player_tile_pos()
	_refresh()
```

- [ ] **Step 6: 修正 _refresh() — TextMapRenderer call**

```gdscript
_map_label.text = _bridge.render_text_map(_player_tid, _cursor)
```

- [ ] **Step 7: 修正 _build_state_str() — tile + tick**

找到 `if _selected != Vector2i(-1, -1):` 區塊，替換為：

```gdscript
if _selected != Vector2i(-1, -1):
	var sel_tile: Dictionary = _bridge.query_tile(_selected.x, _selected.y)
	lines.append("────────────────")
	if not sel_tile.is_empty():
		lines.append("選中: (%d,%d) %s" % [_selected.x, _selected.y, sel_tile.get("terrain", "?")])
		lines.append("  農:%.0f%%  食:%d" % [
			sel_tile.get("productivity", 0) * 100,
			int(sel_tile.get("resources", {}).get("food", 0))])
		var occ: Array = lc.get("occupants", [])
		if not occ.is_empty():
			var vts: Array = _cached_snapshot.get("visible_teams", [])
			for o in occ:
				var oid: int = o.get("team_id", -1)
				var f_display: String = "?"
				var pop: int = 0
				for vt in vts:
					if vt.get("id", -1) == oid:
						f_display = vt.get("faction_display", "?")
						pop = vt.get("population", 0)
						break
				lines.append("  %s [%s] 人口:%d" % [o.get("team_name", "Team?"), f_display, pop])
	else:
		lines.append("選中: (%d,%d) [無效格]" % [_selected.x, _selected.y])
```

找到 `_state.world.current_tick` 的 Tick 顯示行，替換：

```gdscript
lines.append("────────────────")
lines.append("Tick: %d  (Day %d)" % [
	_bridge.get_current_tick(),
	_bridge.get_current_tick() / WorldState.TICKS_PER_DAY])
```

- [ ] **Step 8: 修正 _build_debug_str() — teams + messages + tick**

替換整個 `_build_debug_str()`：

```gdscript
func _build_debug_str() -> String:
	var tick: int  = _bridge.get_current_tick()
	var hour: int  = (tick / WorldState.TICKS_PER_HOUR) % 24
	var day: int   = (tick / WorldState.TICKS_PER_DAY) % 30 + 1
	var month: int = (tick / WorldState.TICKS_PER_MONTH) % 12
	var season_names: Array = ["春","春","春","夏","夏","夏","秋","秋","秋","冬","冬","冬"]
	var season: String = season_names[month]
	var lines: Array = []
	lines.append("[DEBUG] Tick:%d Hour:%d Day:%d Month:%d Season:%s" % [tick, hour, day, month + 1, season])

	var teams_debug: Array = _bridge.get_all_teams_debug()
	var team_strs: Array = []
	for td in teams_debug:
		var pos: Vector2i = td.get("pos", Vector2i.ZERO)
		team_strs.append("T%d@(%d,%d)pop=%d %s" % [td["id"], pos.x, pos.y, td["pop"], td["task"]])
	lines.append("Teams: " + " | ".join(team_strs))

	var evt_strs: Array = []
	for i in range(maxi(0, _events.size() - 10), _events.size()):
		var e = _events[i]
		evt_strs.append("[%s]%s" % [str(e.get("type","?")), str(e.get("msg",""))])
	lines.append("Events(last10): " + " | ".join(evt_strs))

	var msgs: Array = _bridge.query_global_messages(10)
	lines.append("Msgs(last10): " + " | ".join(msgs))

	return "\n".join(lines)
```

- [ ] **Step 9: 修正 _build_member_str() — current_tick**

找到 `TeamUiHelper.render_three_columns(...)` 呼叫，最後一個參數 `_state.world.current_tick` 改為 `_bridge.get_current_tick()`。

- [ ] **Step 10: 修正 _build_inv_str() — body_slots**

找到 body_slots 直讀段（約 line 442-448），替換為：

```gdscript
lines.append("── 裝備 ──")
var h1: String = equipped.get("hand_1", "")
var h2: String = equipped.get("hand_2", "")
lines.append("  右手:%s  左手:%s" % [
	h1 if not h1.is_empty() else "空",
	h2 if not h2.is_empty() else "空"])
var body_slots_data: Dictionary = _bridge.query_body_slots()
const BODY_NAMES: Dictionary = {
	"head": "頭", "torso": "胸", "right_arm": "右臂",
	"left_arm": "左臂", "right_leg": "右腿", "left_leg": "左腿"
}
var body_strs: Array = []
for slot in ["head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"]:
	var g: String = body_slots_data.get(slot, "")
	body_strs.append("%s:%s" % [BODY_NAMES[slot], g if not g.is_empty() else "空"])
lines.append("  " + " ".join(body_strs))
```

- [ ] **Step 11: 修正 _build_interact_str() — pending_targets 列表**

找到 pending_targets 的迭代 for 迴圈（約 line 562-569），替換為：

```gdscript
for target_info in pending_tgts:
	var tid: int = target_info.get("target_id", -1)
	var vts: Array = _cached_snapshot.get("visible_teams", [])
	var vt: Dictionary = {}
	for v in vts:
		if v.get("id", -1) == tid: vt = v; break
	if vt.is_empty(): continue
	var pos: Dictionary = vt.get("position", {})
	var faction_str: String = vt.get("faction_display", "?")
	lines.append("[%d] Team%d @(%d,%d) %s pop:%d" % [
		idx, tid, pos.get("q", 0), pos.get("r", 0), faction_str, vt.get("population", 0)])
	idx += 1
```

找到 `_build_interact_str()` 中已選目標的 tgt_name（約 line 529），替換：

```gdscript
var tgt_name: String = "Team%d" % _interact_target
```

- [ ] **Step 12: 確認 grep 零輸出**

```powershell
Select-String -Path "scripts\ui\text_ui_main.gd" -Pattern "_state\."
```

Expected: **零結果**。

- [ ] **Step 13: Headless test + commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

```
git add scripts/ui/text_ui_main.gd
git commit -m "refactor(ui): remove WorldState direct reads from text_ui_main"
```

---

### Task 4: right_sidebar.gd 清除直讀

**Files:**
- Modify: `scripts/ui/right_sidebar.gd`

- [ ] **Step 1: 替換整個 refresh_player()**

```gdscript
func refresh_player() -> void:
	if _bridge == null or _lbl_player_team == null: return
	var snap_result: Dictionary = _bridge.query_player({})
	var snapshot: Dictionary = snap_result.get("data", {}).get("snapshot", {})
	var ct: Dictionary = snapshot.get("controlled_team", {})
	var ps: Dictionary = snapshot.get("player_summary", {})

	if ct.is_empty():
		_lbl_player_team.text = "（無玩家隊）"
		_lbl_player_task.text = ""
		_lbl_player_pop.text  = ""
		_lbl_player_res.text  = ""
		return

	var pos: Dictionary = ct.get("position", {})
	_lbl_player_team.text = "Team%d [%s] 位置:(%d,%d)" % [
		ct.get("id", 0), ct.get("faction_display", "獨立"), pos.get("q", 0), pos.get("r", 0)]
	_lbl_player_task.text = "任務: %s  疲勞: %.0f%%" % [
		ct.get("task_summary", ""), ct.get("fatigue_pct", 0)]
	_lbl_player_pop.text  = "人口: %d | 受傷: %d | 未成年: %d" % [
		ct.get("population", 0), ct.get("wounded", 0), ct.get("minor_population", 0)]

	var person_lines: Array = []
	if ps.get("player_exists", false):
		person_lines.append("HP: %s  忠誠: %.0f%%  壓力: %.0f%%" % [
			ps.get("hp_status", ""),
			ps.get("loyalty", 0.0) * 100.0,
			ps.get("stress", 0.0) * 100.0])
		var sk_parts: Array = []
		for sk in ps.get("skills", {}):
			var v: float = float(ps["skills"][sk])
			if v > 0.01: sk_parts.append("%s:%.2f" % [sk, v])
		if sk_parts.size() > 0:
			person_lines.append("技能: " + ", ".join(sk_parts))

	var res: Dictionary = ct.get("resources", {})
	var res_parts: Array = []
	for rk in res:
		var v: float = float(res.get(rk, 0))
		if v > 0:
			res_parts.append("%s:%s" % [rk, str(int(v)) if float(v) == int(v) else "%.1f" % v])

	var all_lines: Array = person_lines
	all_lines.append("─ 資源 ─")
	all_lines.append_array(res_parts if res_parts.size() <= 8 else res_parts.slice(0, 8))
	_lbl_player_res.text = "\n".join(all_lines)
```

- [ ] **Step 2: 刪除 _find_team_at（dead code）**

刪除整個 `_find_team_at` 函式（約 line 121-125）。

- [ ] **Step 3: 確認 + test + commit**

```powershell
Select-String -Path "scripts\ui\right_sidebar.gd" -Pattern "_state\."
```

Expected: 零結果。Headless test。

```
git add scripts/ui/right_sidebar.gd scripts/simulation/player_api_mapper.gd
git commit -m "refactor(ui): remove WorldState direct reads from right_sidebar"
```

---

### Task 5: bottom_bar.gd 清除直讀

**Files:**
- Modify: `scripts/ui/bottom_bar.gd`

- [ ] **Step 1: 替換整個 show_tile_info()**

```gdscript
func show_tile_info(pos: Vector2i) -> void:
	if _bridge == null: return
	var lines: Array = []
	var in_vision: bool = _bridge.is_tile_in_vision(pos.x, pos.y)
	var tile: Dictionary = _bridge.query_tile(pos.x, pos.y)

	if tile.is_empty():
		lines.append("(%d,%d) 地圖外" % [pos.x, pos.y])
		_tile_label.text = "\n".join(lines)
		return

	if in_vision:
		lines.append("(%d,%d) 地形: %s" % [pos.x, pos.y, tile.get("terrain", "?")])

		const SPEED_MULT: Dictionary = {"plains": 1.0, "forest": 0.7, "mountain": 0.4}
		var spd: float = float(SPEED_MULT.get(tile.get("terrain", "plains"), 1.0))
		lines.append("速度: x%.1f" % spd)

		lines.append("農業效率: %.0f%%" % (tile.get("harvest_factor", 0) * 100.0))

		var res: Dictionary = tile.get("resources", {})
		var res_parts: Array = []
		for rk in ["food", "material", "ore_iron", "ore_gold", "ore_silver", "gem"]:
			var v: float = float(res.get(rk, 0))
			if v > 0:
				res_parts.append("%s:%d" % [rk, int(v)])
		if res_parts.size() > 0:
			lines.append("資源: " + ", ".join(res_parts))

		if tile.get("outpost_level", 0) > 0:
			lines.append("據點: %s Lv%d（Team%d）" % [
				tile.get("outpost_type", "?"),
				tile.get("outpost_level", 0),
				tile.get("outpost_owner", -1)])
		else:
			lines.append("無據點")

		var teams_here: Array = _bridge.get_teams_at_tile(pos.x, pos.y)
		for td in teams_here:
			var faction_str: String = "獨立" if td.get("faction_id", -1) < 0 else "勢力%d" % td["faction_id"]
			lines.append("Team%d [%s] 人口:%d 任務:%s" % [
				td["id"], faction_str, td.get("population", 0), td.get("current_task", "")])
	else:
		var player_pos: Vector2i = _bridge.get_player_tile_pos()
		var known_here: bool = _bridge.has_tile_intel(pos.x, pos.y)
		if known_here or player_pos == pos:
			lines.append("(%d,%d) 地形: %s" % [pos.x, pos.y, tile.get("terrain", "?")])
			lines.append("（視野外，情報可能過時）")
		else:
			lines.append("(%d,%d) 未知區域" % [pos.x, pos.y])

	_tile_label.text = "\n".join(lines)
```

- [ ] **Step 2: 確認 + test + commit**

```powershell
Select-String -Path "scripts\ui\bottom_bar.gd" -Pattern "_state\."
```

Expected: 零結果。Headless test。

```
git add scripts/ui/bottom_bar.gd
git commit -m "refactor(ui): remove WorldState direct reads from bottom_bar"
```

---

### Task 6: world_map_view.gd 清除直讀

**Files:**
- Modify: `scripts/ui/world_map_view.gd`

- [ ] **Step 1: 加快取欄位**

在 `var _selected: Vector2i` 後加：

```gdscript
var _cached_tiles: Dictionary = {}   # tile_key(int) → render dict
var _cached_teams: Array = []        # from query_visible_teams_render
var _render_ctx: Dictionary = {}     # player_tile_pos, discovered_team_positions, vision_radius
```

- [ ] **Step 2: 替換 setup() + 加 _refresh_cache() + 更新 refresh()**

```gdscript
func setup(bridge: SimBridge) -> void:
	_bridge = bridge
	_refresh_cache()
	_center_on_player()
	queue_redraw()

func _refresh_cache() -> void:
	if _bridge == null: return
	_cached_tiles = _bridge.query_world_tiles()
	_cached_teams = _bridge.query_visible_teams_render()
	_render_ctx   = _bridge.query_render_context()

func refresh() -> void:
	_refresh_cache()
	queue_redraw()
```

- [ ] **Step 3: 替換 _center_on_player()**

```gdscript
func _center_on_player() -> void:
	if _bridge == null: return
	var pos: Vector2i = _bridge.get_player_tile_pos()
	var wc: Vector2 = _hex_center(pos.x, pos.y)
	var vsize: Vector2 = get_viewport_rect().size
	_camera = vsize * 0.5 - wc * _zoom
```

- [ ] **Step 4: 替換 _draw() + 刪舊 helper 函式**

刪除以下函式（完整刪除）：
- `_is_tile_discovered`
- `_is_team_visible`
- `_draw_team_marker`

替換整個 `_draw()` 為：

```gdscript
func _draw() -> void:
	if _bridge == null: return
	var player_pos: Vector2i = _render_ctx.get("player_tile_pos", Vector2i(-1, -1))
	var disc_positions: Array = _render_ctx.get("discovered_team_positions", [])
	var vision_r: int = _render_ctx.get("vision_radius", 3)

	# draw tiles
	for key in _cached_tiles:
		var tile_data: Dictionary = _cached_tiles[key]
		var tpos: Vector2i = tile_data.get("tile_pos", Vector2i(-1, -1))
		var center: Vector2 = _world_to_screen(_hex_center(tpos.x, tpos.y))
		var pts: PackedVector2Array = _hex_points(center.x, center.y)

		var base_color: Color = TERRAIN_COLOR.get(tile_data.get("terrain", ""), Color(0.5, 0.5, 0.5))
		draw_colored_polygon(pts, base_color)
		draw_polyline(pts + PackedVector2Array([pts[0]]), BORDER_COLOR, 1.0)

		if not _is_tile_visible(tpos, player_pos, disc_positions, vision_r):
			draw_colored_polygon(pts, FOG_COLOR)

	# draw teams
	var player_faction_id: int = -1
	for td in _cached_teams:
		if td.get("is_player", false):
			player_faction_id = td.get("faction_id", -1)
			break

	for team_data in _cached_teams:
		var tpos2: Vector2i = team_data.get("tile_pos", Vector2i(-1, -1))
		var center: Vector2 = _world_to_screen(_hex_center(tpos2.x, tpos2.y))
		var is_player: bool = team_data.get("is_player", false)
		var draw_mode: String = team_data.get("draw_mode", "current")

		if draw_mode == "ghost":
			draw_circle(center, 8.0 * _zoom, Color(0.5, 0.5, 0.5, 0.6))
			continue

		var faction_id: int = team_data.get("faction_id", -1)
		var is_hostile: bool = team_data.get("is_hostile", false)
		var border: Color
		if is_hostile:
			border = Color.RED
		elif is_player:
			border = Color.DODGER_BLUE
		elif faction_id >= 0 and faction_id == player_faction_id:
			border = Color.GREEN
		elif faction_id >= 0:
			border = Color.YELLOW
		else:
			border = Color(0.7, 0.7, 0.7)

		draw_circle(center, 10.0 * _zoom, border)
		if is_player:
			draw_circle(center, 6.0 * _zoom, Color.WHITE)

	# draw selected highlight
	if _selected.x >= 0:
		var center: Vector2 = _world_to_screen(_hex_center(_selected.x, _selected.y))
		var pts: PackedVector2Array = _hex_points(center.x, center.y)
		draw_polyline(pts + PackedVector2Array([pts[0]]), Color.WHITE, 2.0)

func _is_tile_visible(pos: Vector2i, player_pos: Vector2i,
		disc_positions: Array, vision_r: int) -> bool:
	if pos == player_pos: return true
	var dx: int = pos.x - player_pos.x
	var dy: int = pos.y - player_pos.y
	if (abs(dx) + abs(dx + dy) + abs(dy)) / 2 <= vision_r: return true
	for dpos in disc_positions:
		if (dpos as Vector2i) == pos: return true
	return false
```

- [ ] **Step 5: 確認 + test + commit**

```powershell
Select-String -Path "scripts\ui\world_map_view.gd" -Pattern "_state\.|get_state\(\)"
```

Expected: 零結果。Headless test。

```
git add scripts/ui/world_map_view.gd
git commit -m "refactor(ui): remove WorldState direct reads from world_map_view"
```

---

### Task 7: 全面驗證

**Files:** 無新改動

- [ ] **Step 1: grep 全 4 檔**

```powershell
Select-String -Path "scripts\ui\text_ui_main.gd","scripts\ui\right_sidebar.gd","scripts\ui\bottom_bar.gd","scripts\ui\world_map_view.gd" -Pattern "_state\."
```

Expected: **零結果**。

- [ ] **Step 2: 1000 tick headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`，無 `SCRIPT ERROR`，1000 tick 無崩潰。

- [ ] **Step 3: Final commit**

```
git add -A
git commit -m "docs: verify UI state decoupling complete — grep clean"
```
