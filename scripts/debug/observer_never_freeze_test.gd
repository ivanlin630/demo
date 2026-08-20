extends SceneTree
# 觀察者世界永不凍結 TDD。
# ①無玩家世界不凍：清 player_id 後殺該隊 leader 且 named 空 → 世界照常推進、game_over 保持 false
# ②★有玩家仍凍、不得誤傷：player_id != -1 同款情境 → game_over=true、advance_tick 回 "game_over"
# ④T4 守衛真的 print（故意不清 player_id、以 player_pos=(-1,-1) 跑三 tick）

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk() -> Array:
	var s := WorldState.new(); s.world = WorldData.new()
	s.world.current_tick = 500
	for x in range(0, 3):
		var t := HexTileData.new(); t.tile_id = x*1000; t.tile_pos = Vector2i(x,0); t.terrain = "plains"
		t.resources = {"food": 60.0}; t.resource_cap = {"food": 200.0}
		s.world.tiles[t.tile_id] = t
	var ldr := PersonData.new(); ldr.id = 500; ldr.team_id = 48
	s.persons[500] = ldr
	var team := TeamData.new(); team.team_id = 48; team.leader_id = 500; team.tile_pos = Vector2i(0,0)
	team.faction_id = -1
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 4)
	team.resources = {"food": 50.0}
	s.teams[48] = team
	return [s, team]

func _run() -> void:
	print("=== observer never freeze test ===")
	# ① 無玩家：player_id=-1（觀察者世界）→ leader 死 + named 空 → 不得凍
	var w := _mk(); var s: WorldState = w[0]; var team: TeamData = w[1]
	s.player_id = -1
	var ok1: bool = EventSystem.new().handle_player_succession(s, team)
	_ok(not s.game_over, "★無玩家：leader 死 + named 空 → game_over 仍為 false（世界不凍）")
	_ok(not ok1, "回傳 false（無 named 繼承人）＝語意保留")
	var runner := SimRunner.new()
	var r1: String = runner.advance_tick(s, Vector2i(-1, -1))
	_ok(r1 != "game_over", "advance_tick 照常推進（回 %s）" % r1)
	# ② 有玩家：player_id != -1 → 同款情境仍須凍（不得誤傷）
	var w2 := _mk(); var s2: WorldState = w2[0]; var t2: TeamData = w2[1]
	s2.player_id = 500   # 該隊 leader 就是玩家
	EventSystem.new().handle_player_succession(s2, t2)
	_ok(s2.game_over, "★有玩家：同款情境 game_over=true（H 不變量沒被誤傷）")
	var r2: String = SimRunner.new().advance_tick(s2, Vector2i(0, 0))
	_ok(r2 == "game_over", "advance_tick 回 'game_over'（%s）" % r2)
	# ④ T4 守衛：宣稱無玩家但 state 有玩家 → print 一次（一次性旗標）
	var w3 := _mk(); var s3: WorldState = w3[0]
	s3.player_id = 500
	SimRunner._observer_guard_warned = false
	print("  --- 以下應出現一次 [ObserverGuard] ---")
	var r3 := SimRunner.new()
	for _i in range(3):
		r3.advance_tick(s3, Vector2i(-1, -1))
	_ok(SimRunner._observer_guard_warned, "★T4 守衛已觸發（一次性旗標翻真；上方應只印一行）")
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
