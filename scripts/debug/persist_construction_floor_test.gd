extends SceneTree

# active-construction persist floor TDD（HOW spec 2026-07-30 §1/§2/§4/§5）。
# 坐實根:bed dump 0b6523db construct.stall=29101/complete_build=0（remote founding 子隊 cold-start
# persist<PERSIST_HOLD_THRESHOLD→routine argmax 搶班）。fix=施工中隊 hard-floor persist≥CONSTRUCTION_ACTIVE_FLOOR。
# 驗:①cold-start/低lean 施工中隊 persist≥floor>threshold ②非施工(ticks_left=0)不 floor
#    ③floor 令 persist.hold 擋 routine argmax 搶班 ④crisis(≥THREAT)照 bypass floor 打斷施工(team14 保留)。
# 純算術零 RNG。

var _fail: int = 0

func _initialize() -> void:
	_test_floor_active_construction_coldstart_lowlean()
	_test_no_floor_when_not_building()
	_test_floor_blocks_routine_preempt()
	_test_crisis_bypasses_floor()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

# 建施工中隊 fixture：務實 leader(lean=0.2)、cold-start(progress≈0)、糧充裕(safe_factor=1)。
func _mk_state_team(ticks_left: int) -> Array:
	var state := WorldState.new()
	var team := TeamData.new()
	team.team_id = 1
	team.tile_pos = Vector2i(0, 0)
	team.current_task = TeamData.TASK_BUILD
	team.task_priority = TaskArbiter.PRIO_DISPATCH
	team.task_start_tick = 0
	team.food_runway = 9999.0   # 糧充裕 → safe_factor=1（隔離，只測 floor）
	var leader := PersonData.new()
	leader.id = 1000
	leader.team_id = 1
	leader.values = {"貪婪": 0.9, "野心": 0.9, "慎重": 0.1, "義氣": 0.1}   # 務實→lean=0.2
	team.leader_id = leader.id
	state.persons[leader.id] = leader
	state.teams[1] = team
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0)
	tile.construction_ticks_left = ticks_left
	tile.construction_team_id = 1
	tile.construction_target = {"action": "build", "type": "civilian", "level": 1}
	state.world.tiles[0] = tile
	return [state, team]

func _test_floor_active_construction_coldstart_lowlean() -> void:
	var st: Array = _mk_state_team(999999)
	var v: float = PersistStrength._value(st[0], st[1])
	# cold-start(progress≈0)+務實(lean=0.2)→computed≈0；floor 撐到 0.15。
	if v >= PersistStrength.CONSTRUCTION_ACTIVE_FLOOR - 0.0001 and v > TaskArbiter.PERSIST_HOLD_THRESHOLD:
		_ok("cold-start 低lean 施工中隊 persist=%.3f ≥floor(%.2f)>threshold(%.2f)" % [
			v, PersistStrength.CONSTRUCTION_ACTIVE_FLOOR, TaskArbiter.PERSIST_HOLD_THRESHOLD])
	else:
		_bad("施工中隊 persist=%.3f 未達 floor(%.2f)/threshold(%.2f)" % [
			v, PersistStrength.CONSTRUCTION_ACTIVE_FLOOR, TaskArbiter.PERSIST_HOLD_THRESHOLD])

func _test_no_floor_when_not_building() -> void:
	# TASK_BUILD 但 construction_ticks_left=0（未真施工/en-route）→ 不 floor（progress≈0→persist≈0<floor）。
	var st: Array = _mk_state_team(0)
	var v: float = PersistStrength._value(st[0], st[1])
	if v < PersistStrength.CONSTRUCTION_ACTIVE_FLOOR:
		_ok("非施工(ticks_left=0) 不 floor persist=%.3f<floor（floor 只護 active-construction）" % v)
	else:
		_bad("非施工卻被 floor persist=%.3f≥floor（floor 洩到 non-active）" % v)

func _test_floor_blocks_routine_preempt() -> void:
	# floor 後 persist>threshold → persist.hold 擋 routine argmax 搶班（覓食@PRIO_DISPATCH,source=unified）。
	var st: Array = _mk_state_team(999999)
	var state: WorldState = st[0]; var team: TeamData = st[1]
	PersistStrength.compute(state, team)   # 寫 team.persist_strength（floored）
	Probe.enabled = true; Probe.reset()
	var got: bool = TaskArbiter.try_set(state, team, TeamData.TASK_FORAGE,
		Vector2i(0, 0), TaskArbiter.PRIO_DISPATCH, "unified")
	Probe.enabled = false
	if not got and team.current_task == TeamData.TASK_BUILD and int(Probe.counts.get("persist.hold", 0)) > 0:
		_ok("routine argmax 覓食@DISPATCH 被 persist.hold 擋（留 TASK_BUILD，persist.hold bump=%d）" % int(Probe.counts.get("persist.hold", 0)))
	else:
		_bad("routine 搶班未被擋 got=%s task=%s hold=%d" % [str(got), team.current_task, int(Probe.counts.get("persist.hold", 0))])

func _test_crisis_bypasses_floor() -> void:
	# crisis(survival@PRIO_SURVIVAL≥THREAT)照 bypass persist.hold 打斷施工（team14 餓死照放手保留）。
	var st: Array = _mk_state_team(999999)
	var state: WorldState = st[0]; var team: TeamData = st[1]
	PersistStrength.compute(state, team)
	Probe.enabled = true; Probe.reset()
	var got: bool = TaskArbiter.try_set(state, team, TeamData.TASK_FORAGE,
		Vector2i(0, 0), TaskArbiter.PRIO_SURVIVAL, "survival")
	Probe.enabled = false
	if got and team.current_task == TeamData.TASK_FORAGE:
		_ok("crisis survival@SURVIVAL bypass floor 打斷施工（離 TASK_BUILD→覓食，team14 保留）")
	else:
		_bad("crisis 未 bypass floor got=%s task=%s（floor 誤擋 crisis=破 team14）" % [str(got), team.current_task])

func _ok(m: String) -> void: print("  [PASS] " + m)
func _bad(m: String) -> void:
	_fail += 1
	print("  [FAIL] " + m)
