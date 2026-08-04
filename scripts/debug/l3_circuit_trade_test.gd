extends SceneTree

# L3 循環貿易 TDD（spec 2026-08-05-L3-circuit-trade-HOW）。
# 升 _nearest_market_outpost naive→genuine _best_market_target visit-util（staleness+arb 期望−路程×人格）。
# 守：零 god-view（讀 belief/自我 last_read 記憶、非市集 live stock）；人格非死常數；determinism 純算術。

var _fail: int = 0

func _initialize() -> void:
	_test_persona_differentiation()   # ①TRADE archetype vs 膽小(慎重高)→visit_util 分化
	_test_staleness_drives()          # ②久沒讀 > 剛讀過
	_test_settled_producer_applicable() # ③無貨無 arb 有近陳舊市集→visit_util>0(settled 進得去)
	_test_explore_unknown()           # ④未 firsthand 讀(last_read 缺)→stale MAX > 剛讀(同距)
	_test_belief_not_livestock()      # ⑤感知鐵律：visit_util 不隨市集 live public_storage 變
	_test_no_hijack_far()             # ⑥遠 no-arb 市集→visit_util≤0(不劫持主 argmax)
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 建 state + team@(0,0) + 一市集 outpost@dist（owner=99 他隊）。team 人格/archetype 依參。
func _mk(dist: int, caution: float, archetype: String) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var t := TeamData.new(); t.team_id = 1; t.faction_id = 0; t.tile_pos = Vector2i(0, 0)
	t.ambition_archetype = archetype
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 8)
	var lp := PersonData.new(); lp.id = 11; lp.values = {"慎重": caution, "商業": 0.5}; state.persons[11] = lp; t.leader_id = 11
	state.teams[1] = t
	var mpos := Vector2i(dist, 0)
	var mt := HexTileData.new(); mt.tile_pos = mpos; mt.outpost_level = 1; mt.outpost_owner = 99
	state.world.tiles[mpos.x * 1000 + mpos.y] = mt
	state.team_market_known[1] = {mpos.x * 1000 + mpos.y: true}
	return [state, t, mpos.x * 1000 + mpos.y]

func _visit_util(state: WorldState, t: TeamData) -> float:
	return FactionAISystem.new()._market_best_visit_util(state, t)

# ① 人格分化：同市集(dist6 unread)，TRADE(arch1.5) vs 膽小(慎重1.0)→util 不同（RED：arch/caution neuter→齊一）。
func _test_persona_differentiation() -> void:
	print("--- ①人格分化 ---")
	var a := _mk(6, 0.5, AmbitionLadder.ARCHETYPE_TRADE)
	var b := _mk(6, 1.0, AmbitionLadder.ARCHETYPE_SETTLE)   # 非商隊(定居)+膽小
	var ua: float = _visit_util(a[0], a[1]); var ub: float = _visit_util(b[0], b[1])
	_ok(ua > ub + 1e-6, "TRADE 商隊 visit_util %.3f > 膽小(慎重高)隊 %.3f（人格 MODULATE 真 util、非齊一）" % [ua, ub])

# ② staleness 驅動：同市集，久沒讀(elapsed 大) > 剛讀過(elapsed 小)。
func _test_staleness_drives() -> void:
	print("--- ②staleness 驅動 ---")
	var a := _mk(4, 0.5, AmbitionLadder.ARCHETYPE_SETTLE); var state: WorldState = a[0]; var t: TeamData = a[1]; var tid: int = a[2]
	state.team_market_last_read[1] = {tid: state.world.current_tick - 10}   # 剛讀
	var u_fresh: float = _visit_util(state, t)
	state.team_market_last_read[1] = {tid: state.world.current_tick - BeliefSystem.SCOUT_TIMEOUT}   # 久沒讀(=norm→stale MAX)
	var u_stale: float = _visit_util(state, t)
	_ok(u_stale > u_fresh + 1e-6, "久沒讀 visit_util %.3f > 剛讀過 %.3f（staleness term load-bearing）" % [u_stale, u_fresh])

# ③ settled 產隊 applicable：無貨無 arb 但有近陳舊 known 市集→best visit_util>0。
func _test_settled_producer_applicable() -> void:
	print("--- ③settled 產隊 applicable ---")
	var a := _mk(3, 0.5, AmbitionLadder.ARCHETYPE_SETTLE); var state: WorldState = a[0]; var t: TeamData = a[1]   # dist3 近、unread(stale MAX)、無 arb
	var u: float = _visit_util(state, t)
	_ok(u > 0.0, "無貨無 arb + 近陳舊 known 市集 → visit_util=%.3f>0（has_market_visit_value→settled 產隊 applicable）" % u)

# ④ 探索未知：last_read 缺→stale MAX(1.0) > 剛讀(同距同市集)。
func _test_explore_unknown() -> void:
	print("--- ④探索未知(last_read 缺=MAX) ---")
	var a := _mk(4, 0.5, AmbitionLadder.ARCHETYPE_SETTLE); var state: WorldState = a[0]; var t: TeamData = a[1]; var tid: int = a[2]
	# unread（無 last_read 條目）
	var u_unread: float = _visit_util(state, t)
	# 剛讀過
	state.team_market_last_read[1] = {tid: state.world.current_tick}
	var u_read: float = _visit_util(state, t)
	_ok(u_unread > u_read + 1e-6, "未 firsthand 讀(last_read 缺→stale MAX) visit_util %.3f > 剛讀 %.3f（探索未知不死）" % [u_unread, u_read])

# ⑤ 感知鐵律：visit_util 讀 belief/自我 last_read、非市集 live public_storage。
func _test_belief_not_livestock() -> void:
	print("--- ⑤感知鐵律(不讀 live stock) ---")
	var a := _mk(4, 0.5, AmbitionLadder.ARCHETYPE_SETTLE); var state: WorldState = a[0]; var t: TeamData = a[1]; var tid: int = a[2]
	var u0: float = _visit_util(state, t)
	# 竄改市集 live public_storage（god-view 真貨）→ visit_util 不該變（證只讀 belief）
	var tile: HexTileData = state.world.tiles[tid]
	tile.public_storage["food"] = 99999.0
	var u1: float = _visit_util(state, t)
	_ok(absf(u1 - u0) < 1e-9, "市集 live stock 竄改後 visit_util 不變(%.4f==%.4f)=只讀 belief 非 live god-view" % [u0, u1])

# ⑥ 不劫持：遠(dist20) no-arb 市集→visit_util≤0（trip 成本壓過 staleness、不強迫巡邏）。
func _test_no_hijack_far() -> void:
	print("--- ⑥遠市集不劫持 ---")
	var a := _mk(20, 0.5, AmbitionLadder.ARCHETYPE_SETTLE); var state: WorldState = a[0]; var t: TeamData = a[1]   # dist=MAX_RANGE、unread、無 arb
	var u: float = _visit_util(state, t)
	_ok(u <= 0.0, "遠(dist20=MAX_RANGE) no-arb 市集 visit_util=%.3f≤0（trip 壓過 staleness→不劫持主 argmax、湧現非強迫巡邏）" % u)
