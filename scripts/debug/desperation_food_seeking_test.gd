extends SceneTree

# 絕境找糧真根修 TDD（slice: desperation-food-seeking）
# spec: docs/superpowers/specs/2026-07-15-desperation-food-seeking.md
#
# Fix A：買糧 look-before-leap——has_buyable_food（聽過 ≤MERCHANT_MAX_RANGE food 賣單）才追買糧。
# Fix B：遷移找糧——當地覓食/買糧皆不 applicable + 有可達已知糧源 → 移向它（視野內 wild_game[pop 守衛] / 賣單 pos，皆過 PathSystem）。
# Fix C：連貫窮死（QA 故事驗收，非 code gate）。

var _fail: int = 0

func _initialize() -> void:
	_test_fixA_buyfood_gate()
	_test_fixB_option_applicable()
	_test_fixB_finder_vision_reachable()
	_test_fixB_pop_guard()
	_test_fixB_reachability_filter()
	_test_a2_join_gate()
	_test_a2_rejection_cooldown()
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

# ── Layer 1：applicable gate（構 ctx 直測，不需全 world）──
func _mk_desperate_ctx() -> DecisionContext:
	var c := DecisionContext.new()
	c.food_days = 1.0   # < DESPERATION_DAYS(3)
	c.population = 5
	c.leader_values = {}
	var u := PackedFloat32Array(); u.resize(NeedHierarchy.N_LAYERS)
	c.need_urgency = u
	return c

func _test_fixA_buyfood_gate() -> void:
	print("--- Fix A：買糧 look-before-leap gate ---")
	# 有市集+有錢 但「沒聽過任何食物賣單」(has_buyable_food=false) → 買糧不入候選（不追海市蜃樓）
	var c1 := _mk_desperate_ctx()
	c1.has_food_market = true; c1.has_specie = true; c1.has_buyable_food = false
	_ok(not ("買糧" in DecisionOptions.applicable(c1)),
		"沒聽過食物賣單 → 買糧不 applicable（不追純幻覺）")
	# 聽過食物賣單（含 stale）→ 買糧入候選（合法，撲空由 B/C 承接）
	var c2 := _mk_desperate_ctx()
	c2.has_food_market = true; c2.has_specie = true; c2.has_buyable_food = true
	_ok("買糧" in DecisionOptions.applicable(c2),
		"聽過食物賣單 → 買糧 applicable（look-before-leap 通過）")

func _test_fixB_option_applicable() -> void:
	print("--- Fix B：遷移找糧 applicable（當地無出路 + 有可達糧源）---")
	# 當地覓食不可（has_forage_tile=false）、買糧不可（無市集/無 buyable）、有 food_seek_target → 遷移找糧入
	var c := _mk_desperate_ctx()
	c.has_forage_tile = false
	c.has_food_market = false; c.has_specie = false; c.has_buyable_food = false
	c.food_seek_target = Vector2i(5, 5)
	_ok("遷移找糧" in DecisionOptions.applicable(c),
		"當地無糧+有可達糧源 → 遷移找糧 applicable")
	# 有 local 覓食出路 → 優先 local，遷移找糧不入
	var c2 := _mk_desperate_ctx()
	c2.has_forage_tile = true   # 當地可覓食
	c2.food_seek_target = Vector2i(5, 5)
	_ok(not ("遷移找糧" in DecisionOptions.applicable(c2)),
		"當地可覓食 → 優先 local，遷移找糧不入")
	# 無可達糧源（食物 target=(-1,-1)）→ 不入（真無出路 → C 連貫死）
	var c3 := _mk_desperate_ctx()
	c3.has_forage_tile = false; c3.has_food_market = false
	c3.food_seek_target = Vector2i(-1, -1)
	_ok(not ("遷移找糧" in DecisionOptions.applicable(c3)),
		"無可達糧源 → 遷移找糧不入（真絕境走連貫死）")

# ── Layer 2：finder（構 tile world）──
# 建一排 plains tile (0,0)..(maxx,0)，team 在 (0,0)。
func _mk_tile_world(maxx: int) -> WorldState:
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 0
	for x in range(-1, maxx + 2):
		for y in range(-2, 3):
			var t := HexTileData.new()
			t.tile_pos = Vector2i(x, y)
			t.terrain = "plains"
			state.world.tiles[x * 1000 + y] = t
	return state

func _mk_team_at(state: WorldState, pos: Vector2i, pop: int) -> TeamData:
	var t := TeamData.new()
	t.team_id = 1
	t.faction_id = -1
	t.parent_team_id = -1
	t.tile_pos = pos
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", pop)
	state.teams[1] = t
	return t

func _test_fixB_finder_vision_reachable() -> void:
	print("--- Fix B finder：視野內可達 wild_game ---")
	var state := _mk_tile_world(4)
	var team := _mk_team_at(state, Vector2i(0, 0), 5)   # pop<=15
	# wild_game tile 在視野內(dist=2<=vrange3)可達
	state.world.tiles[2 * 1000 + 0].resources["wild_game"] = 5
	var fst: Vector2i = FactionAISystem.new()._find_food_seek_target(state, team)
	_ok(fst == Vector2i(2, 0), "找到視野內可達 wild_game (2,0)，實際=%s" % str(fst))

func _test_fixB_pop_guard() -> void:
	print("--- Fix B：pop>FORAGE_VIABLE_POP 不追野味 ---")
	var state := _mk_tile_world(4)
	var team := _mk_team_at(state, Vector2i(0, 0), 20)   # pop>15
	state.world.tiles[2 * 1000 + 0].resources["wild_game"] = 5
	var fst: Vector2i = FactionAISystem.new()._find_food_seek_target(state, team)
	_ok(fst == Vector2i(-1, -1), "pop=20 不選 wild_game（追不到餓死防護），實際=%s" % str(fst))

func _test_fixB_reachability_filter() -> void:
	print("--- Fix B：不可達 wild_game 排除（防死循環）---")
	var state := _mk_tile_world(4)
	var team := _mk_team_at(state, Vector2i(0, 0), 5)
	# 唯一 wild_game 在視野內(0,2)(dist=2<=3)，但 island 化：erase 其全部在網格內鄰格 → 無路可達。
	state.world.tiles[0 * 1000 + 2].resources["wild_game"] = 5
	for nb in [Vector2i(1, 2), Vector2i(-1, 2), Vector2i(0, 1), Vector2i(1, 1)]:   # (0,2) 的 6 hex 鄰格中在網格內者
		state.world.tiles.erase(nb.x * 1000 + nb.y)
	var fst: Vector2i = FactionAISystem.new()._find_food_seek_target(state, team)
	_ok(fst == Vector2i(-1, -1), "不可達 wild_game(0,2) 被排除→(-1,-1)（可達過濾防死循環），實際=%s" % str(fst))

# ── Fix A-2 v2：併入 look-before-leap（rejection-learning）──
func _test_a2_join_gate() -> void:
	print("--- Fix A-2 v2：併入 gate (has_acceptable_join_host) ---")
	# 有 host 候選 + 餓，但 host 不 acceptable（剛拒/不可達）→ 併入不入候選（不追必被拒幻覺）
	var c1 := _mk_desperate_ctx()
	c1.has_strong_neighbor = true; c1.strong_neighbor_id = 2
	c1.threat = 0.0; c1.threat_threshold = 1.0
	c1.has_acceptable_join_host = false
	_ok(not ("併入" in DecisionOptions.applicable(c1)),
		"host 不 acceptable(剛拒/不可達) → 併入不入候選")
	# host acceptable（可達+未拒）→ 併入入（不誤殺真投靠）
	var c2 := _mk_desperate_ctx()
	c2.has_strong_neighbor = true; c2.strong_neighbor_id = 2
	c2.has_acceptable_join_host = true
	_ok("併入" in DecisionOptions.applicable(c2),
		"host acceptable(可達+未拒) → 併入入候選(不誤殺)")

func _test_a2_rejection_cooldown() -> void:
	print("--- Fix A-2 v2：rejection memory cooldown（gather 計算）---")
	# 世界：joiner(1)@(0,0) + host(2)@(2,0)，consolidate_target=2、無 strong_neighbor → host mirror 取 consolidate。
	var state := _mk_tile_world(4)
	state.world.current_tick = 10000
	var joiner := _mk_team_at(state, Vector2i(0, 0), 5)   # id=1
	var jl := PersonData.new(); jl.id = 10; state.persons[10] = jl; joiner.leader_id = 10
	joiner.consolidate_target_cache = 2
	joiner.consolidate_eval_next_tick = 999999   # 用 cache 不重算 finder
	var host := TeamData.new(); host.team_id = 2; host.tile_pos = Vector2i(2, 0); host.faction_id = -1
	AnonCohort.add(host.anon_cohorts, "平民", "healthy", 10)
	state.teams[2] = host
	# (a) 沒拒過 + 可達 → acceptable（給一次真試）
	var ca := DecisionContext.gather(state, joiner)
	_ok(ca.has_acceptable_join_host, "host 沒拒過+可達 → acceptable(給一次真試不誤殺)")
	# (b) 剛拒過（join_rejected memory 在 cooldown 內）→ 不 acceptable（破恆拒 loop）
	jl.memory.append({"type": "join_rejected", "subject_id": 2, "tick": 10000 - 100, "intensity": 0.5})
	var cb := DecisionContext.gather(state, joiner)
	_ok(not cb.has_acceptable_join_host, "host 剛拒(cooldown 內) → 不 acceptable(不重纏)")
	# (c) cooldown 過期 → 可再試（非永久黑名單）
	jl.memory.clear()
	jl.memory.append({"type": "join_rejected", "subject_id": 2,
		"tick": 10000 - DecisionContext.JOIN_REJECT_COOLDOWN_TICKS - 10, "intensity": 0.5})
	var cc := DecisionContext.gather(state, joiner)
	_ok(cc.has_acceptable_join_host, "cooldown 過期 → 再 acceptable(非永久黑名單，撲空 emergent)")
