# scripts/ui/sim_bridge.gd
class_name SimBridge

const TICKS_PER_TURN: int = 24

var _runner: SimRunner
var _state: WorldState
var _ticks_remaining: int = 0

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
	_runner.advance_tick(_state, player_pos)
	if not _state.encounter_active:
		return "encounter_ended"
	# Reset player's timer to 0 after each round so UI gets a turn
	for unit in _state.encounter_units:
		if unit.get("person_id", -1) == _state.player_id:
			unit["action_timer"] = 0
			return "player_turn"
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
