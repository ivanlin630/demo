extends SceneTree

# construction commitment latch TDD（spec 2026-07-25-construction-commitment-latch-A1-fix §TDD）。
# 根:施工隊(TASK_BUILD)每 cadence 被 _decide_unified argmax 搶去外交→stall 95.6%。
# 修:_should_reeval 施工中 skip 例行 cadence reeval(build latch);威脅 force_reeval 繞(不悶逃命);
#    check_construction_timeout release 對稱。
# ★★execution-end 驅真 tick(advance_tick),禁 teleport;outpost_level>0 真完工才算。

var _fail: int = 0

func _initialize() -> void:
	_test_latch_predicate()        # ①_should_reeval build latch(RED-able:build→false,force→true,IDLE/PRODUCE 保留)
	_test_execution_end_complete() # ★★②驅真 advance_tick:施工隊 latch 保 TASK_BUILD→outpost 真完工 level>0
	_test_completion_release()     # ③完工後 current_task 釋放(非卡 TASK_BUILD)
	_test_threat_bypass_latch()    # ★★④威脅 force 繞 latch(施工中壓境→能逃,非悶住)
	_test_deep_starve_bypass()     # ⑤深餓 crisis edge 繞 latch(不餓死工地;與威脅分開)
	_test_directive_leak_resume()  # ★★⑥2nd-layer:施工隊被 leak 拉走→resume 召回原隊→驅真 tick 完工(load-bearing)
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

func _mk_world() -> WorldState:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(-2, 8):
		for y in range(-2, 8):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	return state

func _mk_team(state: WorldState, id: int, pos: Vector2i, pop: int, vals: Dictionary) -> TeamData:
	var team := TeamData.new(); team.team_id = id; team.tile_pos = pos; team.faction_id = -1
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", pop); team.armed_anon_ratio = 0.5
	var l := PersonData.new(); l.id = id * 100 + 10; l.values = vals; l.skills = {"統領": 0.5}
	state.persons[l.id] = l; team.leader_id = l.id; team.named_members = [l.id]
	team.resources["food"] = float(pop) * 100.0   # 充足糧(非 crisis)
	state.teams[id] = team
	return team

# ①_should_reeval build latch predicate（load-bearing：移除 latch → 此測 RED）
func _test_latch_predicate() -> void:
	print("--- ①latch predicate ---")
	var state := _mk_world()
	var team := _mk_team(state, 1, Vector2i(2, 2), 10, {"慎重": 0.5, "好戰": 0.5, "貪婪": 0.5, "野心": 0.5, "求生欲": 0.5})
	var fai := FactionAISystem.new()
	# 施工中 + cadence due（decision_eval_next_tick 過期）
	team.current_task = TeamData.TASK_BUILD
	team.decision_eval_next_tick = 0   # < current_tick 1000 → cadence due
	_ok(fai._should_reeval(state, team) == false, "施工中+cadence due → build latch 擋(false)（RED without latch）")
	_ok(fai._should_reeval(state, team, true) == true, "force_reeval=true → 繞 latch(true)（威脅逃命路）")
	# IDLE 不被 latch 誤擋
	team.current_task = TeamData.TASK_IDLE
	_ok(fai._should_reeval(state, team) == true, "IDLE → reeval(true，latch 只針對 TASK_BUILD)")
	# PRODUCE + cadence due → cadence 路 true（latch 只擋 BUILD 非全 task）
	team.current_task = TeamData.TASK_PRODUCE
	team.decision_eval_next_tick = 0
	_ok(fai._should_reeval(state, team) == true, "PRODUCE+cadence due → reeval(true，latch build-specific)")

# ★★②execution-end：驅真 advance_tick，施工隊 latch 保 TASK_BUILD 全程 → outpost 真完工 level>0
func _test_execution_end_complete() -> void:
	print("--- ★★②execution-end 驅真 advance_tick 完工 ---")
	var state := _mk_world()
	var pos := Vector2i(2, 2)
	var team := _mk_team(state, 1, pos, 10, {"慎重": 0.5, "好戰": 0.3, "貪婪": 0.6, "野心": 0.5, "求生欲": 0.3})
	team.resources["material"] = 200.0
	# 就地 start_build（team 站空 tile→建 civilian outpost；模擬施工啟動）
	var os := OutpostSystem.new()
	var began: bool = os.start_build(state, team, "civilian", 1)
	_ok(began, "start_build 成功 → team.current_task=%s" % team.current_task)
	_ok(team.current_task == TeamData.TASK_BUILD, "施工啟動 → current_task=TASK_BUILD")
	team.decision_eval_next_tick = 0   # cadence due 每 tick（無 latch 會每 tick 被搶）
	# 驅真 tick 迴圈（advance_tick=全 pipeline：faction AI + movement + construction），非 teleport
	var runner := SimRunner.new()
	var tile: HexTileData = state.world.tiles[pos.x * 1000 + pos.y]
	var stayed_build: bool = true
	for _i in range(4000):
		runner.advance_tick(state, pos)   # player_pos=pos → 工地在近區跑 construction tick
		if state.teams.has(1) and state.teams[1].current_task != TeamData.TASK_BUILD \
				and tile.outpost_level == 0 and tile.construction_ticks_left > 0:
			stayed_build = false   # 施工未完卻離 BUILD = latch 失效被搶
		if tile.outpost_level > 0:
			break
	_ok(tile.outpost_level > 0, "★★outpost 真完工(level=%d>0)（latch 保施工隊不被 argmax 搶→construction 進度不停）" % tile.outpost_level)
	_ok(stayed_build, "★施工期間 current_task 全程 TASK_BUILD（未被外交/例行 argmax 蓋）")

# ③完工後 current_task 釋放（_complete_construction release，latch 自解）→ 非永卡 TASK_BUILD
func _test_completion_release() -> void:
	print("--- ③完工釋放（_complete_construction release）---")
	var state := _mk_world()
	var pos := Vector2i(2, 2)
	var team := _mk_team(state, 1, pos, 10, {"慎重": 0.5, "好戰": 0.3, "貪婪": 0.5, "野心": 0.5, "求生欲": 0.3})
	team.current_task = TeamData.TASK_BUILD
	# 模擬施工中工地（build action，team 為施工隊）
	var tile: HexTileData = state.world.tiles[pos.x * 1000 + pos.y]
	tile.construction_team_id = 1
	tile.construction_target = {"action": "build", "type": "civilian", "level": 1}
	tile.construction_ticks_left = 5
	var os := OutpostSystem.new()
	os._complete_construction(state, tile, team)
	_ok(tile.outpost_level == 1, "完工 outpost_level=1")
	# 完工 → TaskArbiter.release → latch 自解（current_task 非 TASK_BUILD）→ 可接新 task
	_ok(team.current_task != TeamData.TASK_BUILD,
		"完工後 release→current_task=%s(非永卡 TASK_BUILD，latch 自解)" % team.current_task)

# ★★④威脅 force 繞 latch：施工中隊被壓境威脅 → _evaluate_threat :401-423 force reeval → 繞 latch 能逃（非悶死）
func _test_threat_bypass_latch() -> void:
	print("--- ★★④威脅 force 繞 latch ---")
	var state := _mk_world()
	# 施工中隊（弱，pop 5，求生欲高→壓境會逃）
	var team := _mk_team(state, 1, Vector2i(2, 2), 5, {"慎重": 0.2, "好戰": 0.1, "貪婪": 0.1, "野心": 0.2, "求生欲": 0.9, "信義": 0.1})
	team.current_task = TeamData.TASK_BUILD
	team.task_priority = TaskArbiter.PRIO_DISPATCH
	team.threat_eval_next_tick = 0   # threat cadence due
	# 壓境強敵（pop 40）鄰格 dist 1 + belief 可見（本 tick）
	var enemy := _mk_team(state, 2, Vector2i(3, 2), 40, {"好戰": 0.9})
	state.team_discovered[1] = [2]
	state.team_intel[1] = { 2: { "population_est": 40, "tile_pos": Vector2i(3, 2), "last_tick": 1000 } }
	var fai := FactionAISystem.new()
	fai._evaluate_threat(state, team)
	# 威脅 force 繞 latch → 施工隊重評 → 逃/威脅反應（非被 latch 悶在 TASK_BUILD）
	_ok(state.teams[1].current_task != TeamData.TASK_BUILD,
		"★施工中遇壓境威脅 → force 繞 latch 能逃/反應(task=%s，非悶死工地)" % state.teams[1].current_task)

# ⑤深餓 crisis edge 繞 latch：施工中深餓 → _decision_crisis → _should_reeval crisis edge true（不餓死工地）
func _test_deep_starve_bypass() -> void:
	print("--- ⑤深餓 crisis 繞 latch ---")
	var state := _mk_world()
	var team := _mk_team(state, 1, Vector2i(2, 2), 10, {"慎重": 0.5, "好戰": 0.3, "貪婪": 0.5, "野心": 0.5, "求生欲": 0.5})
	team.current_task = TeamData.TASK_BUILD
	team.decision_eval_next_tick = 0
	team.crisis_latched = false
	team.food_flow_avg = -999.0   # 深餓（_decision_crisis 讀 food_flow_avg < RUNG_CRASH_FOOD_DEEP → crisis）
	var fai := FactionAISystem.new()
	# crisis edge 在 latch 上方 → 深餓施工隊仍能重評（不餓死工地）;與威脅(:401-423)分開路
	_ok(fai._should_reeval(state, team) == true,
		"深餓施工中 → crisis edge 繞 latch(true，不餓死工地；≠威脅路)")

# ★★⑥2nd-layer resume 治本：施工隊被 leak 拉去別 task(仍在工地格)→ _try_resume_construction 召回原隊 → 驅真 tick 完工
func _test_directive_leak_resume() -> void:
	print("--- ★★⑥resume 召回原施工隊(load-bearing) ---")
	var state := _mk_world()
	var pos := Vector2i(2, 2)
	var team := _mk_team(state, 1, pos, 10, {"慎重": 0.5, "好戰": 0.3, "貪婪": 0.6, "野心": 0.5, "求生欲": 0.3})
	team.resources["material"] = 200.0
	var os := OutpostSystem.new()
	os.start_build(state, team, "civilian", 1)   # → TASK_BUILD, construction active, construction_team_id=1
	var tile: HexTileData = state.world.tiles[pos.x * 1000 + pos.y]
	# 模擬 leak：原施工隊被 directive/argmax 拉去別 task（仍在工地格 pos，未離場=stall samples ct_pos==tile）
	team.current_task = TeamData.TASK_TRADE
	_ok(tile.construction_team_id == 1 and tile.construction_ticks_left > 0, "工地 active(construction_team_id=1) 但施工隊 leak 去 %s" % team.current_task)
	# _try_resume_construction → 優先召回原隊（繞 owner/resident gate；orig 在格+糧足）
	var fai := FactionAISystem.new()
	fai._try_resume_construction(state, tile, team)
	_ok(team.current_task == TeamData.TASK_BUILD, "★resume 召回原施工隊(orig_recall) → TASK_BUILD 續建（非永久棄）")
	# 驅真 tick 迴圈（advance_tick）→ 續建到 outpost_level>0 真完工
	var runner := SimRunner.new()
	for _i in range(4000):
		runner.advance_tick(state, pos)
		if tile.outpost_level > 0:
			break
	_ok(tile.outpost_level > 0, "★★resume 救回後驅真 tick → outpost 真完工(level=%d>0)＝閉環(latch 減 leak+resume 救殘 leak)" % tile.outpost_level)
