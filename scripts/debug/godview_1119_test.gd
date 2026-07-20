extends SceneTree

# god-view 1119 TDD（spec 2026-07-20-godview-1119）。arc 最後 leak。
# _precond_met can_reach 舊讀 live state.teams[target].tile_pos 算距=god-view → belief_pos。
# 可見/斷視線→belief 位算距;positionless/無 belief→can_reach false（不瞬鎖真位）。
# ★<999 near-vacuous → 有位恆 true;關鍵=無 belief→false（舊讀 live→true=god-view leak）。

var _fail: int = 0

func _initialize() -> void:
	_test_has_belief_reachable()   # ① 有 belief 位 → can_reach true
	_test_no_belief_false()        # ② 無 belief 位 → can_reach false（★load-bearing：舊讀 live god-view）
	_test_no_target_false()        # ③ target_id -1 → false
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

func _mk() -> Array:   # [state, f, leader_team]
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var f := FactionData.new(); f.faction_id = 5; f.leader_team_id = 1; state.factions[5] = f
	var lt := TeamData.new(); lt.team_id = 1; lt.faction_id = 5; lt.tile_pos = Vector2i(0, 0)
	state.teams[1] = lt
	var tgt := TeamData.new(); tgt.team_id = 2; tgt.faction_id = 6; tgt.tile_pos = Vector2i(9, 9)   # live @9,9
	state.teams[2] = tgt
	return [state, f, lt]

# ① 有 belief 位（親見）→ can_reach true
func _test_has_belief_reachable() -> void:
	print("--- ① 有 belief → can_reach true ---")
	var w: Array = _mk()
	var state: WorldState = w[0]
	state.team_intel[1] = {2: {"tier": 2, "population_est": 5, "tile_pos": Vector2i(5, 5), "last_tick": 100000}}   # belief 位
	var ok: bool = FactionAISystem.new()._precond_met(state, w[1], w[2], "can_reach", 2)
	_ok(ok, "有 belief 位 → can_reach true（belief 距<999）")

# ② 無 belief 位 → can_reach false（★舊讀 live(9,9) dist<999→true=god-view leak）
func _test_no_belief_false() -> void:
	print("--- ② 無 belief → can_reach false（load-bearing）---")
	var w: Array = _mk()
	var state: WorldState = w[0]
	# 無 team_intel → belief_pos (-1,-1) → can_reach false（不讀 live 9,9 god-view）
	var ok: bool = FactionAISystem.new()._precond_met(state, w[1], w[2], "can_reach", 2)
	_ok(not ok, "無 belief 位 → can_reach false（不瞬鎖 live 真位算可達）")

# ③ target_id -1 → false
func _test_no_target_false() -> void:
	print("--- ③ target_id -1 → false ---")
	var w: Array = _mk()
	var ok: bool = FactionAISystem.new()._precond_met(w[0], w[1], w[2], "can_reach", -1)
	_ok(not ok, "target_id -1 → can_reach false")
