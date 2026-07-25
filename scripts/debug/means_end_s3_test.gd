extends SceneTree

# means-end S3 定位型 + tile-resolver TDD（HOW spec §10 S3）。解 material 核心缺口:
# 缺料+買不到→移動到 forest tile→(建 outpost→採)=means-end 湧現順序。★★must-fix②:tile 查詢拆兩類
# (i)純地形=公共地理全圖掃 # gate-ok (ii)所有權/control=team_tile_known belief 禁 god-view。

var _fail: int = 0

func _initialize() -> void:
	_test_material_gap_chain()      # ①material 缺口鏈:缺料+無 forest outpost+買不到→移動 forest candidate
	_test_build_closure()           # ★REDO:隊在 forest tile 未建→build-closure candidate;建成→採 satisfied(閉環)
	_test_tile_resolver_two_class() # ②tile-resolver 兩類分流(地形查詢 vs control 走不同源)
	_test_belief_only_discovered()  # ③team_tile_known 只存已發現 tile(非全圖)
	_test_belief_reachable_bounded()# ⑤belief-reachable(bounded,遠 tile 不選)
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

func _mk() -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(0, 20):
		for y in range(0, 20):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 10); team.armed_anon_ratio = 0.0
	var l := PersonData.new(); l.id = 10; l.values = {"好戰": 0.9, "貪婪": 0.5, "慎重": 0.5, "野心": 0.5}; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	return [state, team]

func _set_forest(state: WorldState, pos: Vector2i) -> void:
	state.world.tiles[pos.x * 1000 + pos.y].terrain = "forest"

# ① material 缺口鏈：想建 weaponsmith(construction material need)+material 0+無市場+無 forest outpost+近處 forest
# → maintain_material active → 買不到 → 採@forest → 「移動到最近 forest tile」candidate
func _test_material_gap_chain() -> void:
	print("--- ①material 缺口鏈 ---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	# military outpost(plains)→weaponsmith 想建→need_keep(material)>0
	var tile: HexTileData = state.world.tiles[5 * 1000 + 5]
	tile.outpost_owner = 1; tile.outpost_type = "military"; tile.outpost_level = 1; tile.set("weaponsmith_level", 0)
	team.resources["material"] = 0.0; team.resources["coin"] = 100.0
	_set_forest(state, Vector2i(8, 5))   # 近處 forest（dist 3）
	GoalResolver.ensure_maintain_goals(state, team)
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var cands: Array = GoalResolver.frontier_candidates(state, team, ctx)
	var found: Dictionary = {}
	for c in cands:
		if String(c.get("label", "")) == "maintain_material:location:delegate":   # ★A1:founding delegate 取代 TASK_MIGRATE
			found = c
	_ok(not found.is_empty(), "缺料+無市場+無 forest outpost → founding candidate(maintain_material:location:delegate,採@forest 派子隊建)")
	if not found.is_empty():
		_ok(String(found["to_task"].get("build_type", "")) == "civilian" \
				and found["to_task"]["target"] == Vector2i(8, 5) and found["to_task"].get("delegate", false),
			"to_task=派子隊到最近 forest tile(8,5) 建 civilian outpost（★A1:複用 _dispatch_builder,非發無 consumer TASK_MIGRATE/BUILD）")

# ★A1 二裁:隊站 forest tile（same-tile founding）→無母隊就地 outpost-build 路→靜默（followup 非 A1）；own forest outpost→採 satisfied
func _test_build_closure() -> void:
	print("--- ★A1 same-tile founding 靜默 + 閉環 satisfied ---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	# 想建 weaponsmith → material need；material 0；隊站 forest tile（7,7）未建 outpost=same-tile
	var mtile: HexTileData = state.world.tiles[5 * 1000 + 5]
	mtile.outpost_owner = 1; mtile.outpost_type = "military"; mtile.outpost_level = 1; mtile.set("weaponsmith_level", 0)
	team.resources["material"] = 0.0
	_set_forest(state, Vector2i(7, 7)); team.tile_pos = Vector2i(7, 7)
	# ★own outpost 仍在 (5,5)=military plains（own.terrain != forest）→未 satisfied
	GoalResolver.ensure_maintain_goals(state, team)
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var cands: Array = GoalResolver.frontier_candidates(state, team, ctx)
	var build_c: Dictionary = {}
	for c in cands:
		if String(c.get("label", "")) == "maintain_material:location:delegate":
			build_c = c
	_ok(build_c.is_empty(), "★隊站 forest tile(same-tile founding pos==team.tile_pos) → 無 founding candidate（裁②靜默 followup）")
	# ★閉環完成：隊 own outpost 在 forest → 採 satisfied（無 move/build candidate）
	var w2: Array = _mk(); var s2: WorldState = w2[0]; var t2: TeamData = w2[1]
	_set_forest(s2, Vector2i(6, 6))
	var ftile: HexTileData = s2.world.tiles[6 * 1000 + 6]
	ftile.outpost_owner = 1; ftile.outpost_type = "civilian"; ftile.outpost_level = 1; ftile.set("weaponsmith_level", 0)
	t2.tile_pos = Vector2i(6, 6); t2.resources["material"] = 0.0
	GoalResolver.ensure_maintain_goals(s2, t2)
	var ctx2: DecisionContext = DecisionContext.gather(s2, t2)
	var has_mat_loc_or_fac: bool = false
	for c in GoalResolver.frontier_candidates(s2, t2, ctx2):
		var lbl: String = String(c.get("label", ""))
		if lbl.begins_with("maintain_material:location") or lbl.begins_with("maintain_material:facility"): has_mat_loc_or_fac = true
	_ok(not has_mat_loc_or_fac, "★own forest outpost → 採 satisfied（無 material move/build candidate＝閉環完成）")

# ② tile-resolver 兩類分流：find_nearest_terrain_tile(公共地理全圖) vs find_nearest_known_tile(belief 只已知)
func _test_tile_resolver_two_class() -> void:
	print("--- ②tile-resolver 兩類分流 ---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	_set_forest(state, Vector2i(9, 5))   # forest，NOT 在 belief
	# (i) 純地形全圖掃 → 找得到（公共地理，不需 belief）
	var by_terrain: Vector2i = GoalResolver.find_nearest_terrain_tile(state, team, "forest", 30)
	_ok(by_terrain == Vector2i(9, 5), "find_nearest_terrain_tile 找到 forest(9,5)（公共地理全圖掃，# gate-ok）")
	# (ii) control/belief → 該 tile 不在 team_tile_known → 找不到（禁 god-view）
	state.team_tile_known[1] = {}   # 空 belief（未發現該 forest）
	var by_known: Vector2i = GoalResolver.find_nearest_known_tile(state, team, "forest")
	# _harvest_tile_known 會補 vision 半徑內 tile；(9,5) dist 4 > VISION_RADIUS 3 → 不在 belief → 找不到
	_ok(by_known == Vector2i(-1, -1), "find_nearest_known_tile 找不到 vision 外未發現 forest（belief-gate 非 god-view，兩類分流）")

# ③ team_tile_known 只存已發現 tile（vision bounded + relay），非全圖
func _test_belief_only_discovered() -> void:
	print("--- ③belief 只存已發現 ---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	GoalResolver._harvest_tile_known(state, team)
	var known: Dictionary = state.team_tile_known.get(1, {})
	var total: int = state.world.tiles.size()   # 400 tiles
	_ok(known.size() > 0 and known.size() < total, "team_tile_known %d < 全圖 %d（只 vision bounded 已發現，非全圖 god-view）" % [known.size(), total])

# ⑤ belief-reachable bounded：遠 forest（超 max_range）不選
func _test_belief_reachable_bounded() -> void:
	print("--- ⑤belief-reachable bounded ---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	_set_forest(state, Vector2i(18, 18))   # 遠 forest（dist ~26）
	var near: Vector2i = GoalResolver.find_nearest_terrain_tile(state, team, "forest", 5)   # max_range 5
	_ok(near == Vector2i(-1, -1), "max_range 5 → 遠 forest(dist>5)不選（belief-reachable bounded，非全知 PathSystem）")
	var far_ok: Vector2i = GoalResolver.find_nearest_terrain_tile(state, team, "forest", 30)
	_ok(far_ok == Vector2i(18, 18), "max_range 30 → 找到（範圍內可達）")
