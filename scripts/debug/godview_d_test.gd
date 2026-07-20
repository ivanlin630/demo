extends SceneTree

# god-view Slice D TDD（spec 2026-07-20-godview-slice-D-pathsystem-freshness-gate）。
# path_system 位置 leak：讀 live tile_pos 算 velocity/eta/intercept = god-view（追蹤脫視野隊）。
# ★差異化 belief-gate（velocity ≠ position）：
#   velocity（observe_velocity/predict_intercept）：本 tick 可見(belief last_tick==current_tick)才有意義；斷視線→invisible(非 last-seen)。
#   position（estimate_catch_up catch_cost/threat dist_factor）：斷視線→belief last-seen；positionless→不可達/dist_factor=0。
# freshness = belief last_tick == current_tick。

var _fail: int = 0
const TICK := 100000

func _initialize() -> void:
	_test_velocity_visible_this_tick()     # ① observe_velocity 本 tick 可見→live velocity
	_test_velocity_stale_invisible()       # ② observe_velocity 斷視線→{visible:false}（非 last-seen）
	_test_intercept_stale_belief_lastseen()# ③ predict_intercept 斷視線→belief last-seen；無 belief→(-1,-1)
	_test_catchup_stale_uses_belief()      # ④ estimate_catch_up 斷視線→belief last-seen 位（無 belief→不可達）
	_test_moving_away_zero_dir_false()     # ⑤ _is_moving_away_observed dir ZERO→false（級聯保護 verify）
	_test_threat_dist_belief_gated()       # ⑦ threat dist_factor：positionless→0；visible→live 距
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

func _grid_state() -> WorldState:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = TICK
	for x in range(-1, 12):
		for y in range(-1, 12):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	return state

func _mk(state: WorldState, tid: int, pos: Vector2i, last: Vector2i = Vector2i(-999, -999)) -> TeamData:
	var t := TeamData.new(); t.team_id = tid; t.faction_id = tid; t.tile_pos = pos
	t.last_tile_pos = last
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 5); state.teams[tid] = t
	return t

# belief：obs 對 tgt（last_tick 控 freshness；tile_pos=belief last-seen 位）
func _bel(state: WorldState, obs: int, tgt: int, bpos: Vector2i, last_tick: int) -> void:
	if not state.team_intel.has(obs): state.team_intel[obs] = {}
	state.team_intel[obs][tgt] = {"tier": 2, "population_est": 5, "tile_pos": bpos, "last_tick": last_tick, "armed_est": 2}

# ① 本 tick 可見（belief last_tick==current）→ observe_velocity live velocity
func _test_velocity_visible_this_tick() -> void:
	print("--- ① observe_velocity 本 tick 可見→live velocity ---")
	var s := _grid_state()
	var obs := _mk(s, 1, Vector2i(0, 0))
	var tgt := _mk(s, 2, Vector2i(5, 5), Vector2i(4, 5))   # live velocity=(1,0)
	_bel(s, 1, 2, Vector2i(5, 5), TICK)   # 本 tick 可見
	PathSystem.suppress_observe_noise = true   # 零 RNG（測 determinism 友善）
	var r: Dictionary = PathSystem.observe_velocity(s, obs, tgt)
	_ok(r.get("visible", false), "本 tick 可見 → visible:true")
	_ok(r.get("direction", Vector2i.ZERO) == Vector2i(1, 0), "live velocity=(1,0)（got %s）" % str(r.get("direction")))

# ② 斷視線（belief last_tick<current）→ {visible:false}（非 last-seen）
func _test_velocity_stale_invisible() -> void:
	print("--- ② observe_velocity 斷視線→invisible（非 last-seen）---")
	var s := _grid_state()
	var obs := _mk(s, 1, Vector2i(0, 0))
	var tgt := _mk(s, 2, Vector2i(5, 5), Vector2i(4, 5))
	_bel(s, 1, 2, Vector2i(3, 3), TICK - 1000)   # 斷視線（過期）
	var r: Dictionary = PathSystem.observe_velocity(s, obs, tgt)
	_ok(not r.get("visible", true), "斷視線 → {visible:false}（不回 stale velocity garbage）")

# ③ predict_intercept 斷視線→belief last-seen；無 belief→(-1,-1)（非 live）
func _test_intercept_stale_belief_lastseen() -> void:
	print("--- ③ predict_intercept 斷視線→belief last-seen / 無 belief→sentinel ---")
	var s := _grid_state()
	var obs := _mk(s, 1, Vector2i(0, 0))
	var tgt := _mk(s, 2, Vector2i(9, 9), Vector2i(8, 9))   # live @(9,9)
	_bel(s, 1, 2, Vector2i(3, 3), TICK - 500)   # 斷視線 belief last-seen @(3,3)
	var p: Vector2i = PathSystem.predict_intercept(s, obs, tgt)
	_ok(p == Vector2i(3, 3), "斷視線→belief last-seen(3,3) 非 live(9,9)（got %s）" % str(p))
	# 無 belief → sentinel (-1,-1)
	var s2 := _grid_state()
	var obs2 := _mk(s2, 1, Vector2i(0, 0))
	var tgt2 := _mk(s2, 2, Vector2i(9, 9), Vector2i(8, 9))
	var p2: Vector2i = PathSystem.predict_intercept(s2, obs2, tgt2)   # 無 team_intel
	_ok(p2 == Vector2i(-1, -1), "無 belief → sentinel(-1,-1) 非 live(9,9)（got %s）" % str(p2))

# ④ estimate_catch_up 斷視線→belief last-seen 位算 eta；無 belief→不可達
func _test_catchup_stale_uses_belief() -> void:
	print("--- ④ estimate_catch_up 斷視線→belief last-seen 位 / 無 belief→不可達 ---")
	var s := _grid_state()
	var obs := _mk(s, 1, Vector2i(0, 0))
	var _tgt := _mk(s, 2, Vector2i(9, 9), Vector2i(8, 9))   # live 遠 @(9,9)
	_bel(s, 1, 2, Vector2i(2, 2), TICK - 500)   # belief last-seen 近 @(2,2)
	var r: Dictionary = PathSystem.estimate_catch_up(s, obs, 2, true)
	_ok(r.get("reachable", false), "斷視線→用 belief last-seen(2,2) 算 eta→reachable（非 live 9,9）")
	# 無 belief → 不可達
	var s2 := _grid_state()
	var obs2 := _mk(s2, 1, Vector2i(0, 0))
	var _t2 := _mk(s2, 2, Vector2i(9, 9), Vector2i(8, 9))
	var r2: Dictionary = PathSystem.estimate_catch_up(s2, obs2, 2, true)   # 無 belief
	_ok(not r2.get("reachable", true) and r2.get("reason", "") == "no_belief_pos", "無 belief 位→不可達(no_belief_pos)（got %s）" % str(r2))

# ⑤ _is_moving_away_observed direction ZERO→false（observe_velocity invisible 級聯保護 verify）
func _test_moving_away_zero_dir_false() -> void:
	print("--- ⑤ _is_moving_away_observed dir ZERO→false（級聯保護）---")
	var s := _grid_state()
	var obs := _mk(s, 1, Vector2i(0, 0))
	var tgt := _mk(s, 2, Vector2i(5, 5))
	var r: bool = PathSystem._is_moving_away_observed(obs, tgt, Vector2i.ZERO)
	_ok(not r, "direction ZERO（invisible degrade）→ :228 短路 false（不讀 live 算 moving_away）")

# ⑦ threat_assessment dist_factor belief-gate：positionless→score 0；visible→live 距
func _test_threat_dist_belief_gated() -> void:
	print("--- ⑦ threat dist_factor belief-gate ---")
	# positionless（discovered 但無 belief 位）→ dist_factor 0 → score 0
	var s := _grid_state()
	var self_t := _mk(s, 1, Vector2i(0, 0))
	var other := _mk(s, 2, Vector2i(1, 0))   # live 逼近（1 hex）——但無 belief 位
	s.team_discovered[1] = [2]   # discovered（過 :12 gate）但無 team_intel
	self_t.known_reputations[2] = 0.0   # 高敵意（raw>0，隔離 dist_factor 效果）
	var sc: float = ThreatAssessment.score(s, self_t, other)
	_ok(sc == 0.0, "positionless 威脅（無 belief 位）→ dist_factor 0 → score 0（不依 live 真距算威脅，got %.3f）" % sc)
	# visible（belief last_tick==current + 近位）→ live 距 → score>0
	var s2 := _grid_state()
	var self2 := _mk(s2, 1, Vector2i(0, 0))
	var other2 := _mk(s2, 2, Vector2i(1, 0))
	s2.team_discovered[1] = [2]
	self2.known_reputations[2] = 0.0
	_bel(s2, 1, 2, Vector2i(1, 0), TICK)   # 本 tick 可見，近位
	var sc2: float = ThreatAssessment.score(s2, self2, other2)
	_ok(sc2 > 0.0, "本 tick 可見近敵 → dist_factor>0 → score>0（got %.3f）" % sc2)
