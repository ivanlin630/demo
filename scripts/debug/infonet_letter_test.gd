extends SceneTree

# 資訊網 B carrier TDD（spec 2026-08-04-infonet-herald-carrier-HOW）。
# herald 從「假裝 team」→ 還原成 in-transit 訊息物件（state.in_transit_letters）——免撞 succession/cull/subteam/
# on_leader_death/combat 全 team 機具（B root=team-ness 根治）。
# 守：payload=origin 自己 need snapshot（零 live god-view）/物理走 delay/攔截·timeout 零 RNG/detach 1 pop 真成本/全量 tap。

var _fail: int = 0

func _initialize() -> void:
	seed(1337)
	_test_spawn_letter()          # ① spawn：建 letter 物件（非 team）+ detach 1 anon 真成本 + payload snapshot
	_test_move_delay()            # ② move：1 hex/tick 朝 target（物理 delay、PathSystem 真地形）
	_test_deliver_lord()          # ③ 抵 seat + lord co-located → deposit 進 lord.team_known（order_buy）
	_test_deliver_board()         # ④ 抵 seat + lord 不在 → register 進 seat outpost board（Part1 接力等取）
	_test_timeout()               # ⑤ 超 budget → remove（letter_timeout、pop 已耗）
	_test_intercept()             # ⑥ 途中敵 faction 隊在場 → 攔截 killed（letter_intercepted、物理零 RNG）
	_test_a3_nearest_outpost()    # ⑦ A③：target=最近自家 faction 固定 outpost（治 mobile-lord）
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 建 plains 格網 [0..12]×[0..12]（find_path 需 tile 存在才走）。
func _grid(state: WorldState) -> void:
	for x in range(13):
		for y in range(13):
			var t := HexTileData.new(); t.tile_pos = Vector2i(x, y); t.terrain = "plains"
			state.world.tiles[x * 1000 + y] = t

# faction 0：lord@lord_pos 固定 outpost；resident@res_pos 深餓（food=0.2）+ pop5 anon。
# 回 [state, resident, lord]。
func _setup(lord_pos: Vector2i, res_pos: Vector2i) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	_grid(state)
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lt: HexTileData = state.world.tiles[lord_pos.x * 1000 + lord_pos.y]
	lt.outpost_level = 1; lt.outpost_owner = 1
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = lord_pos
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 20)
	state.teams[1] = lord; _idx(state, lord)
	var r := TeamData.new(); r.team_id = 2; r.faction_id = 0; r.tile_pos = res_pos; r.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(r.anon_cohorts, "平民", "healthy", 5); r.resources = {"food": 0.2}
	var lr := PersonData.new(); lr.id = 12; lr.values = {"求生欲": 1.0, "野心": 0.0, "義氣": 0.6}
	state.persons[12] = lr; r.leader_id = 12
	state.teams[2] = r; _idx(state, r)
	return [state, r, lord]

# teams_by_tile 索引（攔截判定讀它；手構 state 無跑 sim step 需自填）。
func _idx(state: WorldState, team: TeamData) -> void:
	var k: int = team.tile_pos.x * 1000 + team.tile_pos.y
	if not state.teams_by_tile.has(k): state.teams_by_tile[k] = []
	if not state.teams_by_tile[k].has(team.team_id): state.teams_by_tile[k].append(team.team_id)

# ① spawn：letter 物件建立 + detach 1 anon 真成本 + payload snapshot（origin 自己 need）。
func _test_spawn_letter() -> void:
	print("--- ① spawn letter（非 team、detach 1 anon、payload snapshot）---")
	var a := _setup(Vector2i(9, 5), Vector2i(5, 5)); var state: WorldState = a[0]; var r: TeamData = a[1]
	var pop_before: int = r.population
	var fa := FactionAISystem.new()
	Probe.reset(); Probe.enabled = true
	fa._try_herald_side(state, r)
	Probe.enabled = false
	_ok(state.in_transit_letters.size() == 1, "建 1 letter 物件（in_transit_letters；非 state.teams）")
	_ok(int(Probe.counts.get("help.letter_dispatched", 0)) == 1, "help.letter_dispatched=1")
	if state.in_transit_letters.size() == 1:
		var L: Dictionary = state.in_transit_letters[0]
		_ok(int(L["origin_team_id"]) == 2 and int(L["target_lord_id"]) == 1 and L["target_pos"] == Vector2i(9, 5),
			"letter 欄位：origin=2 target_lord=1 target_pos=(9,5)")
		_ok((L["payload"] as Array).size() >= 1, "payload 非空（origin 自己 food need snapshot；深餓→runway-deficit synth）")
		_ok(L["current_pos"] == Vector2i(5, 5), "current_pos=origin 出發位(5,5)")
	_ok(r.population == pop_before - 1, "detach 1 anon 真成本（pop %d→%d）" % [pop_before, r.population])

# ② move：letter 每 tick 1 hex 朝 target（物理 delay）。
func _test_move_delay() -> void:
	print("--- ② move 1 hex/tick 朝 target（物理 delay）---")
	var a := _setup(Vector2i(9, 5), Vector2i(5, 5)); var state: WorldState = a[0]; var r: TeamData = a[1]
	var fa := FactionAISystem.new()
	fa._try_herald_side(state, r)
	var start: Vector2i = state.in_transit_letters[0]["current_pos"]
	state.world.current_tick += 1
	fa.tick_letters_all(state)
	var after1: Vector2i = state.in_transit_letters[0]["current_pos"] if state.in_transit_letters.size() > 0 else Vector2i(-9, -9)
	_ok(after1 != start and after1.x == start.x + 1, "1 tick 移 1 hex 朝 target（%s→%s）" % [str(start), str(after1)])

# ③ 抵 seat + lord co-located → deposit 進 lord.team_known（order_buy）。
func _test_deliver_lord() -> void:
	print("--- ③ 抵 seat + lord 在場 → deposit team_known ---")
	var a := _setup(Vector2i(8, 5), Vector2i(5, 5)); var state: WorldState = a[0]; var r: TeamData = a[1]; var lord: TeamData = a[2]
	var fa := FactionAISystem.new()
	fa._try_herald_side(state, r)
	Probe.reset(); Probe.enabled = true
	var delivered: bool = false
	for _t in range(40):
		state.world.current_tick += 1
		fa.tick_letters_all(state)
		if state.in_transit_letters.is_empty():
			delivered = true; break
	Probe.enabled = false
	_ok(delivered, "letter 物理走達 seat 後消（%d tick 內）" % 40)
	_ok(int(Probe.counts.get("help.delivered", 0)) == 1, "help.delivered=1")
	var known: Array = state.team_known.get(1, [])
	var has_buy: bool = false
	for m in known:
		if m.type == "order_buy" and int(m.params.get("origin_team", -1)) == 2: has_buy = true
	_ok(has_buy, "lord.team_known 得 origin=2 的 order_buy（領主聞子民 need）")

# ④ 抵 seat + lord 不在 → register 進 seat outpost board（Part1 接力）。
func _test_deliver_board() -> void:
	print("--- ④ 抵 seat + lord 不在 → seat board register ---")
	var a := _setup(Vector2i(8, 5), Vector2i(5, 5)); var state: WorldState = a[0]; var r: TeamData = a[1]; var lord: TeamData = a[2]
	var fa := FactionAISystem.new()
	fa._try_herald_side(state, r)
	# lord 離開 seat（移到別處）→ 交付走 board 分支
	lord.tile_pos = Vector2i(0, 0)
	Probe.reset(); Probe.enabled = true
	for _t in range(40):
		state.world.current_tick += 1
		fa.tick_letters_all(state)
		if state.in_transit_letters.is_empty(): break
	Probe.enabled = false
	var seat: HexTileData = state.world.tiles[8 * 1000 + 5]
	var board_has: bool = false
	for e in seat.market_orders:
		if int(e.get("origin_team", -1)) == 2 and String(e.get("res", "")) == "food" and bool(e.get("relayed", false)):
			board_has = true
	_ok(board_has, "seat outpost board 得 origin=2 food 買單(relayed)（領主不在也留著等取、Part1 接力）")
	_ok(int(Probe.counts.get("help.delivered", 0)) == 1, "help.delivered=1（board 分支亦計交付）")

# ⑤ timeout：超 budget → remove。
func _test_timeout() -> void:
	print("--- ⑤ timeout → remove ---")
	var a := _setup(Vector2i(12, 12), Vector2i(0, 0)); var state: WorldState = a[0]; var r: TeamData = a[1]
	var fa := FactionAISystem.new()
	fa._try_herald_side(state, r)
	state.in_transit_letters[0]["timeout"] = 2   # 強制短 budget
	Probe.reset(); Probe.enabled = true
	for _t in range(10):
		state.world.current_tick += 1
		fa.tick_letters_all(state)
		if state.in_transit_letters.is_empty(): break
	Probe.enabled = false
	_ok(state.in_transit_letters.is_empty(), "超 budget → letter 消")
	_ok(int(Probe.counts.get("help.letter_timeout", 0)) == 1, "help.letter_timeout=1（pop 已耗=真成本）")

# ⑥ intercept：途中敵 faction 隊在場 → 攔截 killed。
func _test_intercept() -> void:
	print("--- ⑥ 敵 faction 隊攔截 → killed ---")
	var a := _setup(Vector2i(9, 5), Vector2i(5, 5)); var state: WorldState = a[0]; var r: TeamData = a[1]
	var fa := FactionAISystem.new()
	fa._try_herald_side(state, r)
	# 敵隊（faction 1）駐 (6,5)=letter 第一步落點
	var enemy := TeamData.new(); enemy.team_id = 99; enemy.faction_id = 1; enemy.tile_pos = Vector2i(6, 5)
	AnonCohort.add(enemy.anon_cohorts, "平民", "healthy", 10); state.teams[99] = enemy; _idx(state, enemy)
	Probe.reset(); Probe.enabled = true
	state.world.current_tick += 1
	fa.tick_letters_all(state)
	Probe.enabled = false
	_ok(state.in_transit_letters.is_empty(), "敵 faction 隊在落點 → letter 消（攔截）")
	_ok(int(Probe.counts.get("help.letter_intercepted", 0)) == 1, "help.letter_intercepted=1（物理零 RNG）")

# ⑦ A③：target=最近自家 faction 固定 outpost（lord 無 outpost 也可解=治 mobile-lord）。
func _test_a3_nearest_outpost() -> void:
	print("--- ⑦ A③ target=最近自家 faction 固定 outpost ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	_grid(state)
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	# lord=team1 mobile（無 outpost）；faction 另有 member team3 持固定 outpost@(7,5)
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(11, 11)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 20); state.teams[1] = lord
	var holder := TeamData.new(); holder.team_id = 3; holder.faction_id = 0; holder.tile_pos = Vector2i(7, 5)
	AnonCohort.add(holder.anon_cohorts, "平民", "healthy", 8); state.teams[3] = holder
	var ht: HexTileData = state.world.tiles[7 * 1000 + 5]; ht.outpost_level = 1; ht.outpost_owner = 3
	var r := TeamData.new(); r.team_id = 2; r.faction_id = 0; r.tile_pos = Vector2i(5, 5)
	AnonCohort.add(r.anon_cohorts, "平民", "healthy", 5); r.resources = {"food": 0.2}
	state.teams[2] = r
	var tgt: Dictionary = FactionAISystem.new()._resolve_help_target(state, r)
	_ok(int(tgt["id"]) == 1 and tgt["pos"] == Vector2i(7, 5),
		"mobile-lord 無 outpost 仍解出：target_lord=1 target_pos=最近自家 outpost(7,5)（got id=%d pos=%s）" % [int(tgt["id"]), str(tgt["pos"])])
