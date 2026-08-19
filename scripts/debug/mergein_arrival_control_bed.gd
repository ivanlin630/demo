extends SceneTree

# T1 控制床（mergein churn (b)arrival-never pin·systems dispatch 2026-08-19）。
# 真 production 路徑：FactionAISystem._try_join_target 委派 TASK_JOIN → MovementSystem.process
# → InteractionSystem.process_on_moved → _resolve_join。逐 tick 量 dist(joiner,host)。
# 三場景鑑別 sub-cause：
#   A host 靜止        → 若到達+resolve = movement 執行正常（(i) 排除）
#   B host 移動(同速)   → 若永不到達 = (iii) host-chase（joiner 追移動目標、同速追不上）
#   C host 移動 + 每 cadence 重委派 → 看 (ii) 重委派是否額外惡化（task_start/move 是否被重置）
# 純量測 debug script，零 production 邏輯改動（trace tap 為 T1 temp、T2 移）。

var _next_id: int = 1

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	print("=== mergein arrival 控制床（(b)arrival-never sub-cause pin）===")
	seed(1337)
	Probe.enabled = true
	_scenario("A: host 靜止 + belief 每 tick 新", false, false, "tick")
	_scenario("B: host 移動(同速逃離) + belief 每 tick 新", true, false, "tick")
	_scenario("C: host 移動 + 每 cadence 重委派 + belief 每 tick 新", true, true, "tick")
	_scenario("D: host 移動 + belief 只在委派當下(之後失聯)", true, true, "once")
	_scenario("E: host 移動 + belief 每 3 日刷新(lag)", true, true, "3d")
	_scenario("F: host 靜止 + belief 只在委派當下", false, false, "once")
	Probe.enabled = false
	print("\n=== 控制床 DONE ===")

func _mk_world() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	for x in range(0, 20):
		for y in range(0, 3):
			var t := HexTileData.new()
			t.tile_pos = Vector2i(x, y); t.terrain = "plains"
			t.resources = {"food": 50.0}; t.resource_cap = {"food": 200.0}
			s.world.tiles[x * 1000 + y] = t
	s.world.current_tick = 100
	return s

func _mk_team(s: WorldState, pop: int, pos: Vector2i, food: float) -> TeamData:
	var p := PersonData.new(); p.id = _next_id; _next_id += 1
	p.values = {"求生欲": 0.8}; p.skills = {"統領": 0.5}
	s.persons[p.id] = p
	var t := TeamData.new(); t.team_id = _next_id; _next_id += 1
	t.leader_id = p.id; p.team_id = t.team_id
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", maxi(pop - 1, 0))
	t.tile_pos = pos; t.faction_id = -1; t.parent_team_id = -1
	t.resources = {"food": food}
	t.current_task = TeamData.TASK_IDLE
	s.teams[t.team_id] = t
	return t

# firsthand 親見 claim（emulate vision：joiner 每 tick 看得到 host 現位=perfect-info 上界；
# 真 sim belief 只會更差[last-seen lag]→本床是「最有利 joiner」的上界測）。
func _see(s: WorldState, obs: TeamData, tgt: TeamData) -> void:
	BeliefSystem.record_claim(s, obs.team_id, tgt.team_id, obs.team_id, "親見",
		{"tile_pos": tgt.tile_pos, "population_est": float(tgt.population)}, 1.0, false)

func _scenario(label: String, host_moves: bool, recommit: bool, see_mode: String) -> void:
	print("\n--- 場景 %s ---" % label)
	var s := _mk_world()
	var joiner := _mk_team(s, 3, Vector2i(0, 1), 1.0)      # 絕境弱隊
	var host := _mk_team(s, 30, Vector2i(5, 1), 300.0)     # 富大隊
	var fai := FactionAISystem.new()
	var mv := MovementSystem.new()
	var it := InteractionSystem.new()

	_see(s, joiner, host)
	var committed: bool = fai._try_join_target(s, joiner, host.team_id)
	print("  commit JOIN = %s（task=%s move_target=%s social_target=%d）" % [
		str(committed), joiner.current_task, str(joiner.move_target), joiner.social_target])
	if not committed:
		print("  [SKIP] 委派失敗"); return

	var d0: int = FactionAISystem._hex_dist(joiner.tile_pos, host.tile_pos)
	var resolved_tick: int = -1
	var ids: Array = [joiner.team_id, host.team_id]
	var days: int = 20
	for i in range(days * WorldState.TICKS_PER_DAY / WorldState.TICKS_PER_HOUR):
		s.world.current_tick += WorldState.TICKS_PER_HOUR
		if host_moves:
			# host 同速逃離（往 x 增方向）：真 move_target 設遠端 → 每 tick 前進
			host.current_task = TeamData.TASK_MIGRATE
			host.move_target = Vector2i(19, 1)
		# belief 刷新模式：tick=每 tick 親見(上界)、once=只委派當下(失聯)、3d=每 3 日刷新(lag)
		if see_mode == "tick":
			_see(s, joiner, host)
		elif see_mode == "3d" and s.world.current_tick % (WorldState.TICKS_PER_DAY * 3) == 0:
			_see(s, joiner, host)
		if recommit and s.world.current_tick % (FactionAISystem.DECISION_CADENCE) == 0:
			fai._try_join_target(s, joiner, host.team_id)   # (ii) 每 cadence 重委派
		var r: Dictionary = mv.process(s, ids, 1.0, WorldState.TICKS_PER_HOUR)
		s.rebuild_team_tile_index()   # 鏡射 sim_runner:188 post-move rebuild（co-location 查 post-move 位）
		it.process_on_move(s, r["moved"], ids)
		if not s.teams.has(joiner.team_id) or joiner.current_task != TeamData.TASK_JOIN:
			resolved_tick = s.world.current_tick
			break
		if joiner.tile_pos == host.tile_pos:
			resolved_tick = s.world.current_tick
			break
	var d1: int = FactionAISystem._hex_dist(joiner.tile_pos, host.tile_pos) if s.teams.has(joiner.team_id) else 0
	print("  dist 起=%d → 末=%d | joiner=%s host=%s" % [d0, d1,
		str(joiner.tile_pos) if s.teams.has(joiner.team_id) else "(消失=已併)",
		str(host.tile_pos)])
	print("  belief: stale=%d lag=%d | mv_seen=%d in_transit=%d at_target_host_absent=%d colocated=%d" % [
		int(Probe.counts.get("jt.belief_stale", 0)), int(Probe.counts.get("jt.belief_lag", 0)),
		int(Probe.counts.get("jt.mv_seen", 0)), int(Probe.counts.get("jt.in_transit", 0)),
		int(Probe.counts.get("jt.at_target_host_absent", 0)), int(Probe.counts.get("jt.colocated", 0))])
	print("  join.resolve=%d  結果=%s" % [int(Probe.counts.get("join.resolve", 0)),
		("★到達/resolve @tick=%d" % resolved_tick) if resolved_tick != -1 else "✗%d 天內從未到達（arrival-never）" % days])
	Probe.reset()
