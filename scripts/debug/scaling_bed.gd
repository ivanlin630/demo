extends SceneTree

# 後期 scaling 測床（P0 加固前後對照）。量三指標 vs N（隊數階梯）：
#   1. evaluate_all wall-time — faction AI 核心 O(N²)/hr（_has_hostile_within 全掃）。加固=空間索引 Task 3。
#   2. die-off erase wall-time — 滅團潮 erase_team O(N)/erase 放大器（known_issues #erase）。
#   3. 整合 advance_tick TickPerf（Task 1 儀器，日邊界 flush）。
# 用法：.\tools\godot.ps1 --headless --script scripts/debug/scaling_bed.gd
# baseline（加固前）先跑記數；Task 3/4 後重跑對照（Task 5）。

const LADDER: Array = [100, 200, 400]
const MAP_RADIUS: int = 16          # 3R²+3R+1 ≈ 817 tiles > 2×max_N → 隊分散 → hostile-within 近全掃 = worst-case O(N²)
const EVAL_REPS: int = 5            # evaluate_all 重複取平均（去單次噪）
const TICK_RUN: int = 240           # 整合跑 1 day → 1 次 TickPerf flush
const DIEOFF_RATIO: float = 0.3     # 滅團潮：erase 30% 隊，量 erase 尖峰

func _initialize() -> void:
	print("=== ScalingBed START (map_radius=%d) ===" % MAP_RADIUS)
	for n in LADDER:
		_run_scale(n)
	print("=== ScalingBed DONE ===")
	quit()

func _run_scale(n: int) -> void:
	seed(hash(n))
	var state := WorldState.new()
	var runner := SimRunner.new()
	_gen_map(state)
	_seed_teams(state, n)
	print("[ScalingBed] --- N=%d seeded teams=%d tiles=%d ---" % [
		n, state.teams.size(), state.world.tiles.size()])

	# 指標1：evaluate_all 核心（faction AI hourly O(N²) 目標）
	var fai: Object = runner._faction_ai_system
	var team_ids: Array = state.teams.keys()
	var eval_total: int = 0
	for _r in range(EVAL_REPS):
		var t0: int = Time.get_ticks_usec()
		fai.evaluate_all(state, team_ids)
		eval_total += Time.get_ticks_usec() - t0
	print("[ScalingBed] N=%d evaluate_all avg=%d us (reps=%d, teams=%d)" % [
		n, eval_total / EVAL_REPS, EVAL_REPS, state.teams.size()])

	# 指標3：整合 advance_tick（TickPerf 日 flush 會印 [TickPerf] ...）
	var pp: Vector2i = _center_pos(state)
	for _tick in range(TICK_RUN):
		runner.advance_tick(state, pp)

	# 指標2：滅團潮 erase 尖峰（erase_team O(N) 放大器）
	_measure_dieoff(state, n)

func _gen_map(state: WorldState) -> void:
	var gen: Object = load("res://scripts/simulation/world_generator.gd").new()
	gen.generate(state, { "radius": MAP_RADIUS, "seed": 42, "resource_multiplier": 1.0 })

func _seed_teams(state: WorldState, n: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var tile_keys: Array = state.world.tiles.keys()
	for i in range(n):
		var team := TeamData.new()
		team.team_id = 1000 + i
		team.tags = [TeamData.TAG_MILITARY]   # 軍隊 → prosperity/threat 加速評估，最大化 _has_hostile_within 觸發
		var k: int = tile_keys[rng.randi() % tile_keys.size()]
		team.tile_pos = Vector2i(k / 1000, k % 1000)
		team.armed_anon_ratio = 0.5
		team.resources = { "food": 500.0, "coin": 10 }   # 糧足 → warm ticks 不因飢餓滅團（不污染曲線）
		var leader: PersonData = PersonGenerator.generate(state, rng.randi(), "leader")
		leader.team_id = team.team_id
		state.persons[leader.id] = leader
		team.leader_id = leader.id
		AnonCohort.add(team.anon_cohorts, AnonCohort.TIER_PLEB, "healthy", 12)
		state.teams[team.team_id] = team
		state.team_known[team.team_id] = []
		state.team_discovered[team.team_id] = []

func _center_pos(state: WorldState) -> Vector2i:
	# 取任一 tile 當 player 錨（LOD near/far 分割用；直接量指標不倚賴此值精度）
	var keys: Array = state.world.tiles.keys()
	if keys.is_empty(): return Vector2i(0, 0)
	var k: int = keys[keys.size() / 2]
	return Vector2i(k / 1000, k % 1000)

func _measure_dieoff(state: WorldState, n: int) -> void:
	var ids: Array = state.teams.keys()
	var kill: int = int(ids.size() * DIEOFF_RATIO)
	var t0: int = Time.get_ticks_usec()
	var erased: int = 0
	for i in range(kill):
		if state.teams.has(ids[i]):
			state.erase_team(ids[i])
			erased += 1
	var dt: int = Time.get_ticks_usec() - t0
	var per: float = float(dt) / maxf(erased, 1)
	print("[ScalingBed] N=%d die-off erased=%d in %d us (%.1f us/erase, remaining=%d)" % [
		n, erased, dt, per, state.teams.size()])
