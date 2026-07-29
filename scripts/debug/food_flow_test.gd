extends SceneTree

# 糧流感知 Slice A TDD（HOW spec 2026-07-29 §2-4）：runway 感官 + safe_ratio×persist + team14 人格根治。

var _fail: int = 0

func _initialize() -> void:
	_test_runway_surplus_infinite()   # net≥0(inflow≥burn)→runway 大值(不缺)
	_test_runway_starving_finite()    # inflow<burn→runway=food/(-net) 有限
	_test_inflow_harvest_only()       # 無自家 outpost→inflow=0(狩獵延後 B)
	_test_safe_factor_build_scales()  # TASK_BUILD:runway 高→persist 全;低→persist→0(乘法縮放)
	_test_team14_personality_floor()  # ★team14 根治:務實提前放/固執撐久(ratio_floor 人格分化)
	_test_5task_excluded()            # 5 無 ETA task(CONSTRUCT 等)→走原 persist,safe_ratio 不介入
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

func _mk(pop: int, vals: Dictionary) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	for x in range(3, 9):
		for y in range(3, 9):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5)
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", pop); team.armed_anon_ratio = 0.0
	var l := PersonData.new(); l.id = 10; l.values = vals; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	return [state, team]

func _own_outpost(state: WorldState, pos: Vector2i, terrain: String, level: int) -> HexTileData:
	var t: HexTileData = state.world.tiles[pos.x * 1000 + pos.y]
	t.terrain = terrain; t.outpost_owner = 1; t.outpost_level = level; t.harvest_factor = 1.0
	return t

var _mid := {"慎重": 0.5, "義氣": 0.5, "貪婪": 0.5, "野心": 0.5}

func _test_runway_surplus_infinite() -> void:
	print("--- ①runway surplus(net≥0) ---")
	var w: Array = _mk(4, _mid); var state: WorldState = w[0]; var team: TeamData = w[1]
	_own_outpost(state, Vector2i(5, 5), "plains", 2)   # plains regen 8×harvest_factor×mult → inflow 高
	team.resources["food"] = 20.0
	FoodFlow.update(state, team)
	_ok(team.food_runway >= FoodFlow.RUNWAY_CAP - 0.01, "plains outpost pop4 inflow≥burn → runway=CAP(不缺,%.0f)" % team.food_runway)

func _test_runway_starving_finite() -> void:
	print("--- ②runway starving(inflow<burn) ---")
	var w: Array = _mk(30, _mid); var state: WorldState = w[0]; var team: TeamData = w[1]
	_own_outpost(state, Vector2i(5, 5), "mountain", 1)   # mountain regen 0.5 低 + pop30 burn 高 → net<0
	team.resources["food"] = 24.0
	FoodFlow.update(state, team)
	_ok(team.food_runway > 0.0 and team.food_runway < FoodFlow.RUNWAY_CAP,
		"mountain pop30 inflow<burn → runway 有限(%.1f 天)" % team.food_runway)

func _test_inflow_harvest_only() -> void:
	print("--- ③inflow harvest-only(無 outpost=0) ---")
	var w: Array = _mk(10, _mid); var state: WorldState = w[0]; var team: TeamData = w[1]
	# 不設 outpost（tile.outpost_level=0）→ inflow=0（狩獵延後 B）→ net=-burn → runway 有限
	team.resources["food"] = 8.0
	FoodFlow.update(state, team)
	_ok(team.food_runway < FoodFlow.RUNWAY_CAP, "無自家 outpost→inflow=0(狩獵延後B)→runway 有限(%.1f)" % team.food_runway)

func _mk_building(pop: int, vals: Dictionary, runway: float, ticks_left: int) -> Array:
	var w: Array = _mk(pop, vals); var state: WorldState = w[0]; var team: TeamData = w[1]
	var tile: HexTileData = state.world.tiles[5 * 1000 + 5]
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	tile.construction_team_id = 1
	tile.construction_target = {"action": "build", "type": "civilian", "level": 1}
	tile.construction_ticks_left = ticks_left
	team.current_task = TeamData.TASK_BUILD
	team.task_start_tick = state.world.current_tick - 100000   # progress 飽和(base persist 高,凸顯 safe_factor 調制)
	team.food_runway = runway
	return [state, team]

func _test_safe_factor_build_scales() -> void:
	print("--- ④safe_factor 乘法縮放(TASK_BUILD) ---")
	# ETA=ticks_left/pop=60/6=10 天。runway 高(50)→safe_ratio 5>RATIO_SAFE→factor 1;runway 低(1)→factor 0
	var ws: Array = _mk_building(6, _mid, 50.0, 60)   # 糧充裕
	var wl: Array = _mk_building(6, _mid, 1.0, 60)    # 糧見底
	var ps_hi: float = PersistStrength._value(ws[0], ws[1])
	var ps_lo: float = PersistStrength._value(wl[0], wl[1])
	_ok(ps_hi > ps_lo, "糧充裕 persist(%.3f) > 糧見底 persist(%.3f)（safe_ratio 乘法縮放）" % [ps_hi, ps_lo])
	_ok(ps_lo < 0.01, "糧見底(runway 1<ETA 10)→safe_factor→0→persist_eff→0(放手求生)")
	_ok(ps_hi > 0.05, "糧充裕→persist 維持(committed 黏著)")

func _test_team14_personality_floor() -> void:
	print("--- ★⑤team14 人格 ratio_floor 分化 ---")
	# 同 runway(中間), 務實(flex 高→floor 高→早放 factor 低) vs 固執(stick 高→floor 低→撐久 factor 高)
	var stubborn := {"慎重": 0.9, "義氣": 0.9, "貪婪": 0.1, "野心": 0.1}
	var pragmatic := {"慎重": 0.1, "義氣": 0.1, "貪婪": 0.9, "野心": 0.9}
	# ETA=60/6=10;runway=8→safe_ratio=0.8。固執 floor≈0.1(0.8>0.1 撐)/務實 floor≈0.9(0.8<0.9 放)
	var wsub: Array = _mk_building(6, stubborn, 8.0, 60)
	var wprag: Array = _mk_building(6, pragmatic, 8.0, 60)
	var ps_sub: float = PersistStrength._value(wsub[0], wsub[1])
	var ps_prag: float = PersistStrength._value(wprag[0], wprag[1])
	_ok(ps_sub > ps_prag, "同 runway：固執撐久 persist(%.3f) > 務實提前放(%.3f)（ratio_floor 人格分化=team14 根治）" % [ps_sub, ps_prag])
	_ok(ps_prag < 0.02, "務實隊 runway 下坡提前放手(safe_factor→0，非撐 food=0)")

func _test_5task_excluded() -> void:
	print("--- ⑥5 無 ETA task 排除 ---")
	# TASK_CONSTRUCT(在途,無真 ticks ETA) + runway 極低 → safe_ratio 不介入 → 走原 persist(不因糧塌)
	var w: Array = _mk(6, _mid); var state: WorldState = w[0]; var team: TeamData = w[1]
	team.current_task = TeamData.TASK_CONSTRUCT   # 5 排除 task 之一
	team.task_start_tick = state.world.current_tick - 100000   # progress 飽和
	team.food_runway = 0.5   # 糧見底
	var ps: float = PersistStrength._value(state, team)
	_ok(ps > 0.05, "TASK_CONSTRUCT(無 ETA)+runway 0.5→走原 persist(%.3f，safe_ratio 不介入,維持 Slice1-4)" % ps)
