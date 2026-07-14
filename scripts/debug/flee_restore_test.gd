extends SceneTree

# 恢復 flee 位移 TDD（slice: flee-restore-movement）
# spec: docs/superpowers/specs/2026-07-15-flee-restore-movement.md
#
# FLEE 曾 no-op（target=(-1,-1) 永不動）→ 治根＝恢復遠離位移。
# 3 派發站設 flee_from_pos=威脅 belief 位（感知鐵律）；mover _flee_away_tile 朝遠離算 away-tile。
# flee_from_pos=(-1,-1)→不設 target 靠 release。零 randf。

var _fail: int = 0

func _initialize() -> void:
	_test_flee_away_direction()
	_test_flee_movement_real()
	_test_flee_fallback_no_belief()
	_test_flee_threat_pos_belief()
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

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x; var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

func _mk_grid(state: WorldState, r: int) -> void:
	for x in range(-r, r + 1):
		for y in range(-r, r + 1):
			var t := HexTileData.new(); t.tile_pos = Vector2i(x, y); t.terrain = "plains"
			state.world.tiles[x * 1000 + y] = t

func _test_flee_away_direction() -> void:
	print("--- _flee_away_tile：朝遠離威脅方向 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	_mk_grid(state, 10)
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(0, 0); state.teams[1] = team
	var from_pos := Vector2i(-5, 0)   # 威脅在西 → 應朝東逃
	var away: Vector2i = MovementSystem.new()._flee_away_tile(state, team, from_pos)
	_ok(_hex_dist(away, from_pos) > _hex_dist(team.tile_pos, from_pos),
		"away-tile 距威脅(%s) 遠於原位(%s)：away=%s dist %d>%d" % [
			str(from_pos), str(team.tile_pos), str(away),
			_hex_dist(away, from_pos), _hex_dist(team.tile_pos, from_pos)])

func _test_flee_movement_real() -> void:
	print("--- FLEE movement 真逃（tile_pos 真變動遠離）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 0
	_mk_grid(state, 10)
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(0, 0)
	team.current_task = TeamData.TASK_FLEE; team.combat_target = -1
	team.flee_from_pos = Vector2i(-5, 0)   # 威脅在西
	var ldr := PersonData.new(); ldr.id = 10; state.persons[10] = ldr; team.leader_id = 10
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5); state.teams[1] = team
	var d0: int = _hex_dist(team.tile_pos, team.flee_from_pos)
	# 跑幾輪 movement（大 elapsed 確保移動）
	for _i in range(5):
		MovementSystem.new().process(state, [1], 1.0, WorldState.TICKS_PER_DAY)
	var d1: int = _hex_dist(team.tile_pos, team.flee_from_pos)
	_ok(team.tile_pos != Vector2i(0, 0), "FLEE 隊真移動（非原地凍），tile_pos=%s" % str(team.tile_pos))
	_ok(d1 > d0, "移動後距威脅拉遠（%d→%d）" % [d0, d1])

func _test_flee_fallback_no_belief() -> void:
	print("--- fallback：flee_from_pos=(-1,-1)→不設 target（不亂逃）---")
	var state := WorldState.new(); state.world = WorldData.new()
	_mk_grid(state, 5)
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(0, 0)
	team.current_task = TeamData.TASK_FLEE; team.combat_target = -1
	team.flee_from_pos = Vector2i(-1, -1)   # 無威脅情報
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5); state.teams[1] = team
	MovementSystem.new().process(state, [1], 1.0, WorldState.TICKS_PER_DAY)
	_ok(team.move_target == Vector2i(-1, -1), "無威脅情報→move_target 不設(靠 release 收)，實際=%s" % str(team.move_target))
	_ok(team.tile_pos == Vector2i(0, 0), "無威脅情報→不亂逃(tile_pos 不變)")

func _test_flee_threat_pos_belief() -> void:
	print("--- _flee_threat_pos：讀 belief 非活值（感知鐵律）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var team := TeamData.new(); team.team_id = 1; team.faction_id = 5; team.tile_pos = Vector2i(0, 0); state.teams[1] = team
	var foe := TeamData.new(); foe.team_id = 2; foe.faction_id = 6; foe.tile_pos = Vector2i(9, 9); state.teams[2] = foe
	state.team_discovered[1] = [2]
	# belief last-seen (7,7)（活值 9,9）+ 敵意 rep（威脅）
	state.team_intel[1] = {2: {"population_est": 10.0, "tile_pos": Vector2i(7, 7), "last_tick": 1000, "armed_est": 8}}
	team.known_reputations[2] = 0.1   # 低 rep=敵意→ThreatAssessment.score>0
	var fp: Vector2i = FactionAISystem.new()._flee_threat_pos(state, team)
	# 若 score>0 → 回 belief_pos(7,7)（非活值 9,9）；若 score=0(minimal 湊不出敵意)→(-1,-1)（fallback 安全）
	_ok(fp == Vector2i(7, 7) or fp == Vector2i(-1, -1),
		"_flee_threat_pos 回 belief last-seen(7,7) 或 (-1,-1)（★非活值 9,9），實際=%s" % str(fp))
	_ok(fp != Vector2i(9, 9), "★不讀活值 9,9（感知鐵律）")
