extends SceneTree

# god-view follow-up TDD（spec 2026-07-20-godview-followup；detector v3 撿 2 殘留）。
# ① jhost(decision_context:373) live pos→belief_pos（同 1119）：無 belief→不可達。
# ② enemy_outpost(faction_ai:2912) 全圖敵據點→belief-gate（belief-about-owner proxy）：只避已知敵、未見不避。

var _fail: int = 0

func _initialize() -> void:
	_test_enemy_outpost_belief_gate()   # ② owner 有 belief 納/無 belief 不納（重點,behavior-sensitive）
	_test_jhost_no_belief_unreachable() # ① jhost 無 belief→has_acceptable_join_host false（不讀 live）
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

func _grid(state: WorldState) -> void:
	for x in range(-1, 14):
		for y in range(-1, 14):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl

# ② enemy_outpost belief-gate：leader(fac5,team1)；敵據點(3,3)owner=7(有 belief)納、(8,8)owner=8(無 belief)不納
func _test_enemy_outpost_belief_gate() -> void:
	print("--- ② enemy_outpost belief-gate（belief-about-owner）---")
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 100000; _grid(s)
	var lt := TeamData.new(); lt.team_id = 1; lt.faction_id = 5; lt.tile_pos = Vector2i(0, 0); s.teams[1] = lt
	# 敵 owner 隊
	var o7 := TeamData.new(); o7.team_id = 7; o7.faction_id = 6; s.teams[7] = o7
	var o8 := TeamData.new(); o8.team_id = 8; o8.faction_id = 6; s.teams[8] = o8
	# 敵據點
	var t33: HexTileData = s.world.tiles[3 * 1000 + 3]; t33.outpost_level = 1; t33.outpost_owner = 7
	var t88: HexTileData = s.world.tiles[8 * 1000 + 8]; t88.outpost_level = 1; t88.outpost_owner = 8
	# leader(team1)對 owner 7 有 belief、對 8 無
	s.team_intel[1] = {7: {"tier": 2, "population_est": 5, "tile_pos": Vector2i(3, 3), "last_tick": 100000}}
	var out: Array = FactionAISystem.new()._enemy_outpost_positions(s, lt)
	_ok(out.has(Vector2i(3, 3)), "owner7 有 belief→納入避讓(3,3)")
	_ok(not out.has(Vector2i(8, 8)), "owner8 無 belief→不納(未見敵不避，更多衝突湧現)")

# ① jhost 無 belief → has_acceptable_join_host false（gather 讀 belief_pos，不瞬鎖 live）
func _test_jhost_no_belief_unreachable() -> void:
	print("--- ① jhost 無 belief→不可達 ---")
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 100000; _grid(s)
	var team := TeamData.new(); team.team_id = 1; team.faction_id = -1; team.tile_pos = Vector2i(0, 0)
	var ldr := PersonData.new(); ldr.id = 10; s.persons[10] = ldr; team.leader_id = 10
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5); s.teams[1] = team
	# strong neighbor 存在(live @9,9)但 team1 無 belief → jhost belief_pos (-1,-1) → 不可達 → 非 acceptable host
	var host := TeamData.new(); host.team_id = 2; host.faction_id = 3; host.tile_pos = Vector2i(9, 9)
	_seed_pop_big(host); s.teams[2] = host
	s.team_discovered[1] = [2]
	# 無 team_intel[1] → belief_pos(-1,-1)
	var ctx: DecisionContext = DecisionContext.gather(s, team)
	_ok(not ctx.has_acceptable_join_host, "jhost 無 belief 位→has_acceptable_join_host false（不讀 live god-view 算可達）")

func _seed_pop_big(t: TeamData) -> void:
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 50)
