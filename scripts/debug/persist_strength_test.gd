extends SceneTree

# 持守統一 Slice 1 TDD（HOW spec 2026-07-28 §4/§8）：persist_strength 公式 + progressive-only + 人格加權 + clamp。

var _fail: int = 0

func _initialize() -> void:
	_test_progressive_only_gate()   # FLEE/IDLE → 0（開放式不套持守）
	_test_sunk_cost_progress()      # committed 越久 → persist 越高（sunk-cost）
	_test_personality_weigh()       # 人格加權（weigh 非 gate）：固執型 vs 務實型分化
	_test_clamp_below_crisis()      # clamp ≤ PERSIST_CAP < 危機量級（latch 反例：永可打斷）
	_test_compute_writes_field()    # compute 寫 team.persist_strength 欄
	_test_real_construction_progress()  # ★Slice 2:施工中用真 construction-tick 進度(非時間 proxy)
	_test_freshness_on_tick()           # ★Slice 2:construction tick 倒數→persist 即升(新鮮,非 cadence 舊值)
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

func _mk(task: String, elapsed_days: float, vals: Dictionary) -> Array:
	var state := WorldState.new(); state.world = WorldData.new()
	state.world.current_tick = int(elapsed_days * float(WorldState.TICKS_PER_DAY)) + 100000
	var team := TeamData.new(); team.team_id = 1
	team.current_task = task
	team.task_start_tick = state.world.current_tick - int(elapsed_days * float(WorldState.TICKS_PER_DAY))
	var l := PersonData.new(); l.id = 10; l.values = vals
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	return [state, team]

func _test_progressive_only_gate() -> void:
	print("--- ①progressive-only gate ---")
	var mid := {"慎重": 0.5, "義氣": 0.5, "貪婪": 0.5, "野心": 0.5}
	var w1: Array = _mk(TeamData.TASK_FLEE, 5.0, mid)
	_ok(PersistStrength._value(w1[0], w1[1]) == 0.0, "FLEE（開放式）→ persist=0（不套持守，走既有 timeout）")
	var w2: Array = _mk(TeamData.TASK_IDLE, 5.0, mid)
	_ok(PersistStrength._value(w2[0], w2[1]) == 0.0, "IDLE（無承諾）→ persist=0")
	var w3: Array = _mk(TeamData.TASK_BUILD, 5.0, mid)
	_ok(PersistStrength._value(w3[0], w3[1]) > 0.0, "TASK_BUILD（progressive committed）→ persist>0")

func _test_sunk_cost_progress() -> void:
	print("--- ②sunk-cost progress ---")
	var mid := {"慎重": 0.5, "義氣": 0.5, "貪婪": 0.5, "野心": 0.5}
	var w0: Array = _mk(TeamData.TASK_BUILD, 0.0, mid)     # 剛 committed
	var wmid: Array = _mk(TeamData.TASK_BUILD, 2.5, mid)   # committed 一半視野
	var wfull: Array = _mk(TeamData.TASK_BUILD, 10.0, mid) # committed 遠超視野（飽和）
	var p0: float = PersistStrength._value(w0[0], w0[1])
	var pm: float = PersistStrength._value(wmid[0], wmid[1])
	var pf: float = PersistStrength._value(wfull[0], wfull[1])
	_ok(p0 < pm and pm <= pf, "committed 越久 persist 越高（sunk-cost：%.3f<%.3f≤%.3f）" % [p0, pm, pf])
	_ok(p0 < 0.01, "剛 committed（elapsed≈0）→ persist≈0（易轉，無鎖）")

func _test_personality_weigh() -> void:
	print("--- ③人格加權（weigh 非 gate）---")
	# 同 progress（飽和），固執型（慎重/義氣高）vs 務實型（貪婪/野心高）persist 分化
	var stubborn := {"慎重": 0.9, "義氣": 0.9, "貪婪": 0.1, "野心": 0.1}
	var pragmatic := {"慎重": 0.1, "義氣": 0.1, "貪婪": 0.9, "野心": 0.9}
	var ws: Array = _mk(TeamData.TASK_BUILD, 10.0, stubborn)
	var wp: Array = _mk(TeamData.TASK_BUILD, 10.0, pragmatic)
	var ps_val: float = PersistStrength._value(ws[0], ws[1])
	var pp_val: float = PersistStrength._value(wp[0], wp[1])
	# 兩者皆 progressive→>0（weigh 非 gate：務實型非硬排除，只權重不同）；固執型 sunk 權重高
	_ok(ps_val > 0.0 and pp_val > 0.0, "固執/務實皆 persist>0（weigh 非硬類別 gate：%.3f/%.3f）" % [ps_val, pp_val])
	_ok(ps_val >= pp_val, "固執型 persist ≥ 務實型（慎重/義氣→sunk 死硬完成；vs 貪婪/野心→prospect 靈活）")

func _test_clamp_below_crisis() -> void:
	print("--- ④clamp < 危機量級（latch 反例）---")
	var extreme := {"慎重": 1.0, "義氣": 1.0, "貪婪": 1.0, "野心": 1.0}
	var w: Array = _mk(TeamData.TASK_BUILD, 100.0, extreme)
	var p: float = PersistStrength._value(w[0], w[1])
	_ok(p <= PersistStrength.PERSIST_CAP + 0.0001, "persist %.3f ≤ PERSIST_CAP %.2f（clamp）" % [p, PersistStrength.PERSIST_CAP])
	_ok(PersistStrength.PERSIST_CAP < DecisionEngine.SURVIVAL_BOOST_MAX,
		"PERSIST_CAP %.2f < SURVIVAL_BOOST_MAX %.1f（危機永可打斷=latch 反例，永不凍世界）" % [PersistStrength.PERSIST_CAP, DecisionEngine.SURVIVAL_BOOST_MAX])

func _test_compute_writes_field() -> void:
	print("--- ⑤compute 寫欄 ---")
	var mid := {"慎重": 0.5, "義氣": 0.5, "貪婪": 0.5, "野心": 0.5}
	var w: Array = _mk(TeamData.TASK_BUILD, 3.0, mid)
	var team: TeamData = w[1]
	team.persist_strength = -1.0
	var ret: float = PersistStrength.compute(w[0], team)
	_ok(team.persist_strength == ret and ret >= 0.0, "compute 寫 team.persist_strength（=回傳值 %.3f，供 Slice 2 執行層讀）" % ret)

# 建施工中隊（tile 有 active construction）：team 站 tile、current_task=BUILD、tile 有 construction_target/ticks。
func _mk_building(ticks_left: int, total_type_level: Array, vals: Dictionary) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 200000
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5, 5); tile.terrain = "plains"
	tile.outpost_type = String(total_type_level[0]); tile.outpost_level = 1
	tile.construction_team_id = 1
	tile.construction_target = {"action": "build", "type": String(total_type_level[0]), "level": int(total_type_level[1])}
	tile.construction_ticks_left = ticks_left
	state.world.tiles[5 * 1000 + 5] = tile
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5)
	team.current_task = TeamData.TASK_BUILD
	team.task_start_tick = state.world.current_tick - 100   # 剛開工(時間 proxy 極低)→證用的是真 construction 進度非時間
	var l := PersonData.new(); l.id = 10; l.values = vals
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	return [state, team, tile]

# ★Slice 2：施工中用真 construction-tick 進度（非時間 proxy）——time 剛開工但 construction 已近完 → persist 高。
func _test_real_construction_progress() -> void:
	print("--- ⑥Slice2 真 construction-tick 進度 ---")
	var mid := {"慎重": 0.5, "義氣": 0.5, "貪婪": 0.5, "野心": 0.5}
	# civilian lv1 total=100 person-ticks。ticks_left=10 → progress=(100-10)/100=0.9（近完）；task_start 才 -100 tick（時間 proxy≈0.008）。
	var wn: Array = _mk_building(10, ["civilian", 1], mid)   # 近完成
	var we: Array = _mk_building(90, ["civilian", 1], mid)   # 剛開工
	var pn: float = PersistStrength._value(wn[0], wn[1])
	var pe: float = PersistStrength._value(we[0], we[1])
	_ok(pn > pe, "construction 近完(left=10) persist > 剛開工(left=90)：%.3f>%.3f（用真 tick 進度非時間 proxy）" % [pn, pe])
	# 若是時間 proxy，兩者 task_start 同→persist 同；pn>pe 證用 construction 進度。
	_ok(pn > 0.1, "近完成 persist 高(%.3f>0.1，真 sunk-cost 反映近完；mid lean 0.5×0.9×0.3=0.135)" % pn)

# ★Slice 2：新鮮度——construction tick 倒數（進度事件）→ persist 即反映（非等 cadence）。
func _test_freshness_on_tick() -> void:
	print("--- ⑦Slice2 新鮮度(進度事件即更新) ---")
	var mid := {"慎重": 0.5, "義氣": 0.5, "貪婪": 0.5, "野心": 0.5}
	var w: Array = _mk_building(60, ["civilian", 1], mid)
	var state: WorldState = w[0]; var team: TeamData = w[1]; var tile: HexTileData = w[2]
	var p_before: float = PersistStrength.compute(state, team)   # progress=(100-60)/100=0.4
	# 模擬 construction tick 倒數（進度前進）
	tile.construction_ticks_left = 20   # progress=(100-20)/100=0.8
	var p_after: float = PersistStrength.compute(state, team)
	_ok(p_after > p_before, "construction tick 倒數(left 60→20)→persist 即升(%.3f→%.3f，新鮮非 cadence 舊值)" % [p_before, p_after])
	_ok(team.persist_strength == p_after, "team.persist_strength 反映當下進度(執行層 Slice 3 讀新鮮)")
