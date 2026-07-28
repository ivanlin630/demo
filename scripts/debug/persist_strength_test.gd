extends SceneTree

# 持守統一 Slice 1 TDD（HOW spec 2026-07-28 §4/§8）：persist_strength 公式 + progressive-only + 人格加權 + clamp。

var _fail: int = 0

func _initialize() -> void:
	_test_progressive_only_gate()   # FLEE/IDLE → 0（開放式不套持守）
	_test_sunk_cost_progress()      # committed 越久 → persist 越高（sunk-cost）
	_test_personality_weigh()       # 人格加權（weigh 非 gate）：固執型 vs 務實型分化
	_test_clamp_below_crisis()      # clamp ≤ PERSIST_CAP < 危機量級（latch 反例：永可打斷）
	_test_compute_writes_field()    # compute 寫 team.persist_strength 欄
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
