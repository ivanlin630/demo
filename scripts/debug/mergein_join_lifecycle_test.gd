extends SceneTree

# T2 TDD（mergein churn 根修）：committed JOIN 的「到達或放棄」契約。
# ① 撲空 abort：belief 死 + 站在 last-seen 空格 → release（不再永久 latch、不再每 cadence 重 commit）
# ② timeout：belief 活但追不到（host 一直跑）→ 額度到期 release
# ③ 不誤傷：host 靜止可達 → 照常到達 resolve（無 abort/timeout）
# 真 production 路徑：_try_join_target 委派 → evaluate_all(timeout 塊) + MovementSystem + InteractionSystem。

var _next_id: int = 1
var _fail: int = 0

func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	print("=== mergein JOIN lifecycle test（T2 churn 根修）===")
	seed(1337)
	Probe.enabled = true
	_t1_ghost_abort()
	_t2_timeout()
	_t3_no_false_release()
	Probe.enabled = false
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)

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

func _see(s: WorldState, obs: TeamData, tgt: TeamData) -> void:
	BeliefSystem.record_claim(s, obs.team_id, tgt.team_id, obs.team_id, "親見",
		{"tile_pos": tgt.tile_pos, "population_est": float(tgt.population)}, 1.0, false)

# 跑 days 天：movement + interaction + JOIN 生命週期塊（loop3）。see_mode 控 belief 刷新。
func _run_days(s: WorldState, joiner: TeamData, host: TeamData, days: int,
		host_moves: bool, see_mode: String) -> void:
	var fai := FactionAISystem.new()
	var mv := MovementSystem.new()
	var it := InteractionSystem.new()
	var ids: Array = [joiner.team_id, host.team_id]
	for i in range(days * WorldState.TICKS_PER_DAY / WorldState.TICKS_PER_HOUR):
		s.world.current_tick += WorldState.TICKS_PER_HOUR
		if host_moves and s.teams.has(host.team_id):
			host.current_task = TeamData.TASK_MIGRATE
			host.move_target = Vector2i(19, 1)
		if see_mode == "tick" and s.teams.has(joiner.team_id) and s.teams.has(host.team_id):
			_see(s, joiner, host)
		var r: Dictionary = mv.process(s, ids, 1.0, WorldState.TICKS_PER_HOUR)
		s.rebuild_team_tile_index()
		it.process_on_move(s, r["moved"], ids)
		if not s.teams.has(joiner.team_id):
			return   # 已併入（resolve）
		fai.evaluate_all(s, ids)   # ★含 JOIN timeout/abort 生命週期塊
		if s.world.current_tick % (WorldState.TICKS_PER_DAY * 2) == 0 and s.teams.has(joiner.team_id):
			print("    [diag] day=%d task=%s prio=%d pos=%s mt=%s age_d=%.1f belief=%s soc=%d" % [
				s.world.current_tick / WorldState.TICKS_PER_DAY, joiner.current_task, joiner.task_priority,
				str(joiner.tile_pos), str(joiner.move_target),
				float(s.world.current_tick - joiner.task_start_tick) / float(WorldState.TICKS_PER_DAY),
				str(BeliefSystem.belief_pos(s, joiner.team_id, joiner.social_target)), joiner.social_target])

func _commit(s: WorldState, joiner: TeamData, host: TeamData) -> bool:
	_see(s, joiner, host)
	return FactionAISystem.new()._try_join_target(s, joiner, host.team_id)

# ① belief 失聯 + 走到 ghost tile → abort release（原本永久 latch）
func _t1_ghost_abort() -> void:
	print("--- ① 撲空 abort（belief 死）---")
	Probe.reset()
	var s := _mk_world()
	var joiner := _mk_team(s, 3, Vector2i(0, 1), 3.0 * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 12.0)   # 非深餓（隔離 crisis-override：其為正交安全網、systems 裁定保留）
	var host := _mk_team(s, 30, Vector2i(5, 1), 300.0)
	if not _commit(s, joiner, host):
		_ok(false, "委派 JOIN 應成功"); return
	_run_days(s, joiner, host, 12, true, "once")   # host 跑掉、belief 不再刷新
	var aborted: int = int(Probe.counts.get("join.abort_ghost", 0))
	_ok(aborted >= 1, "撲空 abort 有 fire（join.abort_ghost=%d）" % aborted)
	_ok(s.teams.has(joiner.team_id) and joiner.current_task != TeamData.TASK_JOIN,
		"JOIN 已釋放（task=%s，非永久 latch）" % (joiner.current_task if s.teams.has(joiner.team_id) else "(已併)"))
	var _ldr: PersonData = s.persons.get(joiner.leader_id)
	var _rej: bool = false
	if _ldr != null:
		for _m in _ldr.memory:
			if String(_m.get("type", "")) == "join_rejected" and int(_m.get("subject_id", -1)) == host.team_id:
				_rej = true; break
	_ok(_rej, "★arrival-fail 寫 join_rejected memory（cooldown 內不重選同 host＝churn 不換皮重演）")
	_ok(joiner.social_target == -1, "social_target 已清（不殘留指向失敗 host）")

# ② belief 活但永遠追不到 → timeout release
func _t2_timeout() -> void:
	print("--- ② timeout（追不到的移動 host）---")
	Probe.reset()
	var s := _mk_world()
	var joiner := _mk_team(s, 3, Vector2i(0, 1), 3.0 * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 12.0)   # 非深餓（隔離 crisis-override：其為正交安全網、systems 裁定保留）
	var host := _mk_team(s, 30, Vector2i(19, 1), 300.0)   # 起手就 19 hex 遠
	if not _commit(s, joiner, host):
		_ok(false, "委派 JOIN 應成功"); return
	# host 每 tick 跳回遠端（模擬永遠追不上），belief 每 tick 新 → 不走 abort 路、只能靠 timeout
	var fai := FactionAISystem.new()
	var mv := MovementSystem.new()
	var ids: Array = [joiner.team_id, host.team_id]
	for i in range(25 * WorldState.TICKS_PER_DAY / WorldState.TICKS_PER_HOUR):
		s.world.current_tick += WorldState.TICKS_PER_HOUR
		host.tile_pos = Vector2i(19, 1)   # 永遠在遠端
		_see(s, joiner, host)
		mv.process(s, ids, 1.0, WorldState.TICKS_PER_HOUR)
		s.rebuild_team_tile_index()
		fai.evaluate_all(s, ids)
		if int(Probe.counts.get("join.timeout", 0)) >= 1:
			break
	_ok(int(Probe.counts.get("join.timeout", 0)) >= 1,
		"timeout 有 fire（join.timeout=%d）" % int(Probe.counts.get("join.timeout", 0)))

# ③ 不誤傷：host 靜止可達 → 正常到達 resolve、零 abort/timeout
func _t3_no_false_release() -> void:
	print("--- ③ 不誤傷（host 靜止可達）---")
	Probe.reset()
	var s := _mk_world()
	var joiner := _mk_team(s, 3, Vector2i(0, 1), 3.0 * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 12.0)   # 非深餓（隔離 crisis-override：其為正交安全網、systems 裁定保留）
	var host := _mk_team(s, 30, Vector2i(5, 1), 300.0)
	if not _commit(s, joiner, host):
		_ok(false, "委派 JOIN 應成功"); return
	_run_days(s, joiner, host, 8, false, "tick")
	_ok(int(Probe.counts.get("join.resolve", 0)) >= 1,
		"正常到達 resolve（join.resolve=%d）" % int(Probe.counts.get("join.resolve", 0)))
	_ok(int(Probe.counts.get("join.abort_ghost", 0)) == 0 and int(Probe.counts.get("join.timeout", 0)) == 0,
		"零誤傷（abort=%d timeout=%d）" % [int(Probe.counts.get("join.abort_ghost", 0)), int(Probe.counts.get("join.timeout", 0))])
