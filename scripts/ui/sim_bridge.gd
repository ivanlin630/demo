# scripts/ui/sim_bridge.gd
class_name SimBridge

const TICKS_PER_TURN: int = 24

var _runner: SimRunner
var _state: WorldState
var _ticks_remaining: int = 0
var _query_api: PlayerQueryApi = PlayerQueryApi.new()
var _cmd_api: PlayerCommandApi = PlayerCommandApi.new()

func _init(runner: SimRunner, state: WorldState) -> void:
	_runner = runner
	_state  = state

func get_state() -> WorldState:
	return _state

# 請求推進 n ticks（非阻塞，由 tick_step 每 frame 分批執行）
func request_advance(n: int) -> void:
	_ticks_remaining = n

# 取消推進
func cancel_advance() -> void:
	_ticks_remaining = 0

# 是否正在推進
func is_advancing() -> bool:
	return _ticks_remaining > 0

# 每 frame 呼叫：推進 TICKS_PER_HOUR ticks，回傳結果
# 遭遇戰/新發現事件觸發時自動停止
# 返回 { "events": Array, "done": bool }
func tick_step() -> Dictionary:
	if _ticks_remaining <= 0:
		return { "events": [], "done": true }
	var n: int = mini(WorldState.TICKS_PER_HOUR, _ticks_remaining)
	var events := advance_ticks(n)
	_ticks_remaining = maxi(0, _ticks_remaining - n)
	if events.size() > 0:
		_ticks_remaining = 0   # 重要事件 → 停止推進
	return { "events": events, "done": _ticks_remaining <= 0 }

# Advance up to n world ticks (not encounter ticks).
# Stops early if a player-relevant event fires.
# Returns array of event dicts generated this call.
func advance_ticks(n: int) -> Array:
	var events: Array = []
	for _i in range(n):
		var snap := _snapshot()
		var player_pos: Vector2i = _player_tile()
		_runner.advance_tick(_state, player_pos)
		var new_evts := _diff_events(snap)
		events.append_array(new_evts)
		if new_evts.size() > 0:
			break
	return events

# Advance one encounter tick.
# Returns "player_turn" when player unit timer == 0,
# "encounter_ended" when encounter_active becomes false,
# "ongoing" otherwise.
func advance_encounter_tick() -> String:
	if not _state.encounter_active:
		return "no_encounter"
	var player_pos: Vector2i = _player_tile()
	var enc_result: String = _runner.advance_tick(_state, player_pos)
	# Translate encounter_system result to view-facing result
	match enc_result:
		"player_turn":
			return "player_turn"
		"attacker_win", "defender_win", "draw":
			return "encounter_ended"
		_:
			if not _state.encounter_active:
				return "encounter_ended"
			return "ongoing"

# ── helpers ───────────────────────────────────────────────

func _player_tile() -> Vector2i:
	if _state.player_id < 0: return Vector2i.ZERO
	var p: PersonData = _state.persons.get(_state.player_id)
	if p == null: return Vector2i.ZERO
	var t: TeamData = _state.teams.get(p.team_id)
	return t.tile_pos if t else Vector2i.ZERO

func get_player_team_id() -> int:
	if _state.player_id < 0: return -1
	var p: PersonData = _state.persons.get(_state.player_id)
	return p.team_id if p else -1

# ── Step 1: tick + player position helpers ─────────────────────────────────────

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

# ── Step 2: tile query helpers ─────────────────────────────────────────────────

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

# ── Step 3: data query wrappers ────────────────────────────────────────────────

func query_body_slots() -> Dictionary:
	return PlayerApiMapper.map_body_slots(_state)

func query_global_messages(n: int = 10) -> Array:
	return PlayerApiMapper.map_global_messages(_state, n)

func query_visible_teams_render() -> Array:
	return PlayerApiMapper.map_visible_teams_render(_state, get_player_team_id())

# ── Step 4: world tiles + tile/team spatial helpers ───────────────────────────

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

func _snapshot() -> Dictionary:
	var ptid: int = get_player_team_id()
	return {
		"encounter_active":  _state.encounter_active,
		"discovered_count":  _state.team_discovered.get(ptid, []).size() if ptid >= 0 else 0,
	}

func _diff_events(snap: Dictionary) -> Array:
	var evts: Array = []
	if _state.encounter_active and not snap["encounter_active"]:
		evts.append({ "type": "encounter_triggered" })
	var ptid: int = get_player_team_id()
	if ptid >= 0:
		var now: int = _state.team_discovered.get(ptid, []).size()
		if now > snap["discovered_count"]:
			evts.append({ "type": "new_team_spotted" })
	return evts

# ── Player API (query / command) ───────────────────────────────────────────────

func query_player(request: Dictionary = {}) -> Dictionary:
	return _query_api.get_player_snapshot(_state, request)

func query_player_team(team_id: int) -> Dictionary:
	return _query_api.get_team_details(_state, team_id)

func query_player_member(team_id: int, member_id: int) -> Dictionary:
	return _query_api.get_member_details(_state, team_id, member_id)

func query_player_location(tile_q: int, tile_r: int) -> Dictionary:
	return _query_api.get_location_context(_state, tile_q, tile_r)

func query_player_actions(request: Dictionary) -> Dictionary:
	return _query_api.get_available_actions(_state, request)

func query_trade_preview(target_team_id: int) -> Dictionary:
	return _query_api.get_trade_preview(_state, target_team_id)

func get_and_clear_alerts() -> Array:
	return PlayerQueryApi.new().get_and_clear_alerts(_state)

func command_player(name: String, args: Dictionary) -> Dictionary:
	return _cmd_api.dispatch(_state, name, args)

# 玩家主動打開互動選單時呼叫：掃描同格 NPC 加入 pending_targets
func refresh_interaction_targets() -> void:
	var cmd_sys := PlayerCommandSystem.new()
	cmd_sys.refresh_colocation_targets(_state)

# 設定玩家狀態欄位（如 tribute_rate_input）
func set_player_input(key: String, value: Variant) -> void:
	_state.player_state[key] = value

func query_faction_panel() -> Dictionary:
	return PlayerQueryApi.new().query_faction_panel(_state)

func query_outpost_panel() -> Dictionary:
	return PlayerQueryApi.new().query_outpost_panel(_state)

func query_subteam_panel() -> Dictionary:
	return PlayerQueryApi.new().query_subteam_panel(_state)

func query_advisor_advice(advisor_pid: int, situation: String) -> String:
	var p: PersonData = _state.persons.get(advisor_pid)
	if p == null: return "顧問不存在"
	return AdvisorSystem.new().get_advice(p, situation, {}, _state)
