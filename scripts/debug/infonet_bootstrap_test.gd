extends SceneTree

# 資訊網 bootstrap-fix TDD（spec 2026-08-04-infonet-bootstrap-fix-HOW）。
# 病:help/scout_target_pos 卡 live-belief;faction 成員從不 meet→無 belief 位→herald/scout 永不 applicable（0 fire 死結）。
# 修:名冊 fallback（fresh belief 優先→無→自家勢力固定據點位=組織常識）。守 5 硬界。util 一字不改（非 crank）。

var _fail: int = 0

func _initialize() -> void:
	_test_roster_pos_boundaries()   # ①_faction_roster_pos 守 5 界（同勢力/敵/移動/隱匿）
	_test_help_via_roster()         # ②無 belief→名冊 fallback→help applicable（破 bootstrap）
	_test_scout_via_roster()        # ③無 belief 子民→名冊 fallback→scout target(max staleness)
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# ① _faction_roster_pos 5 界。
func _test_roster_pos_boundaries() -> void:
	print("--- ①roster_pos 5 界 ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	# target team5 同勢力、固定 outpost @(7,7)
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(7,7); tile.outpost_level = 1; tile.outpost_owner = 5
	state.world.tiles[7*1000+7] = tile
	var member := TeamData.new(); member.team_id = 1; member.faction_id = 0; state.teams[1] = member
	var target := TeamData.new(); target.team_id = 5; target.faction_id = 0; state.teams[5] = target
	var fa := FactionAISystem
	_ok(fa._faction_roster_pos(state, member, 5) == Vector2i(7,7), "同勢力+固定 outpost → 名冊位(7,7)")
	# ③敵勢力 → -1
	target.faction_id = 9
	_ok(fa._faction_roster_pos(state, member, 5) == Vector2i(-1,-1), "他勢力 → -1（③敵不含）")
	target.faction_id = 0
	# ②移動隊（無固定 outpost）→ -1
	tile.outpost_owner = 99
	_ok(fa._faction_roster_pos(state, member, 5) == Vector2i(-1,-1), "target 無固定 outpost → -1（②移動隊落 belief）")
	tile.outpost_owner = 5
	# ⑤隱匿據點 → -1
	tile.outpost_hidden = true
	_ok(fa._faction_roster_pos(state, member, 5) == Vector2i(-1,-1), "隱匿據點 → -1（⑤ not outpost_hidden）")

# ② help：needy resident 無領主 belief → 名冊 fallback → help_target 成立（破 bootstrap 死結）。
func _test_help_via_roster() -> void:
	print("--- ②help via 名冊（破 bootstrap）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	# 領主 team1 固定 outpost @(9,9)（resident 從無 belief 但知名冊位）
	var lt := HexTileData.new(); lt.tile_pos = Vector2i(9,9); lt.outpost_level = 1; lt.outpost_owner = 1
	state.world.tiles[9*1000+9] = lt
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(9,9)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 20); state.teams[1] = lord
	var r := TeamData.new(); r.team_id = 2; r.faction_id = 0; r.tile_pos = Vector2i(5,5)
	r.tags = [TeamData.TAG_PRODUCE]; AnonCohort.add(r.anon_cohorts, "平民", "healthy", 10); r.resources = {"food": 0.0}
	var lr := PersonData.new(); lr.id = 12; lr.values = {"求生欲": 0.6, "野心": 0.3, "義氣": 0.6}; state.persons[12] = lr; r.leader_id = 12
	state.teams[2] = r
	# ★不注入任何 belief（模擬從不 meet）→ 舊 code help_target_id=-1（0 fire）；修後名冊 fallback。
	var ctx: DecisionContext = DecisionContext.gather(state, r)
	_ok(ctx.help_target_id == 1 and ctx.help_target_pos == Vector2i(9,9),
		"無 belief→名冊 fallback→help_target_id=1 pos=%s（破 bootstrap、herald 可 applicable）" % str(ctx.help_target_pos))

# ③ scout：領主無子民 belief → 名冊 fallback → scout_target(staleness=1.0 從沒親聞)。
func _test_scout_via_roster() -> void:
	print("--- ③scout via 名冊 ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(5,5)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 20)
	var ll := PersonData.new(); ll.id = 11; ll.values = {"統領": 0.7, "野心": 0.3}; state.persons[11] = ll; lord.leader_id = 11
	state.teams[1] = lord
	# 子民 team2 固定 outpost @(8,8)（領主從無 belief 但知名冊位）
	var st := HexTileData.new(); st.tile_pos = Vector2i(8,8); st.outpost_level = 1; st.outpost_owner = 2
	state.world.tiles[8*1000+8] = st
	var sub := TeamData.new(); sub.team_id = 2; sub.faction_id = 0; sub.tile_pos = Vector2i(8,8)
	AnonCohort.add(sub.anon_cohorts, "平民", "healthy", 10); state.teams[2] = sub
	var ctx: DecisionContext = DecisionContext.gather(state, lord)
	_ok(ctx.scout_target_id == 2 and ctx.scout_target_pos == Vector2i(8,8) and ctx.scout_staleness == 1.0,
		"無 belief 子民→名冊 fallback→scout_target=2 pos=%s staleness=%.1f（從沒親聞=max）" % [str(ctx.scout_target_pos), ctx.scout_staleness])
