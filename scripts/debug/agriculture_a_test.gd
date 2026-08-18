extends SceneTree
# 農業a TDD — 農田獨立生產線 + drift 正位。
# ①農田產出獨立入糧倉標 farm_yield ②farming_level 不再 boost gather(:289 移除) ③farm_labor 抽勞力(guns-vs-butter)
# ④harvest_factor 季節調制 ⑤無 farming_level→產出 0。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _mk_farm_tile(state: WorldState, pos: Vector2i, owner: int, farming: int, harvest: float = 1.0) -> HexTileData:
	var t := HexTileData.new()
	t.tile_id = pos.x*1000+pos.y; t.tile_pos = pos; t.terrain = "plains"
	t.outpost_owner = owner; t.outpost_level = 1; t.outpost_type = "civilian"
	t.farming_level = farming; t.harvest_factor = harvest
	t.resources = {"food": 40.0}; t.resource_cap = {"food": 200.0}
	t.public_storage = {}
	state.world.tiles[t.tile_id] = t
	return t

func _mk_prod_team(state: WorldState, tid: int, pos: Vector2i, pop: int) -> TeamData:
	var ldr := PersonData.new(); ldr.id = tid*10+1; ldr.skills = {"生產": 0.3}; state.persons[ldr.id] = ldr
	var team := TeamData.new(); team.team_id = tid; team.leader_id = ldr.id; team.tile_pos = pos
	team.tags = [TeamData.TAG_PRODUCE]; team.work_morale = 1.0
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", maxi(pop-1, 0))
	state.teams[tid] = team
	return team

func _init() -> void:
	print("=== 農業a test ===")
	_t1_farm_yield_to_granary()
	_t2_drift_removed()
	_t3_guns_vs_butter()
	_t4_harvest_season()
	_t5_no_farming_no_yield()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

# ① 農田產出獨立入自家糧倉（farm_yield）
func _t1_farm_yield_to_granary() -> void:
	print("--- ① 農田產出入糧倉 ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var tile := _mk_farm_tile(state, Vector2i(5,5), 0, 2)
	var team := _mk_prod_team(state, 0, Vector2i(5,5), 6)
	var before: float = float(tile.public_storage.get("food", 0))
	ResourceSystem.new().collect_resources(state, [0], WorldState.TICKS_PER_DAY)
	var after: float = float(tile.public_storage.get("food", 0))
	_ok(after > before, "farming_level>0 owner 隊 → 農田糧入自家糧倉（+%.2f）" % (after - before))
	# labor_mult(farm)>0 證農田工位有勞力分配
	_ok(LaborSystem.labor_mult(tile, "farm") > 0.0, "農田工位有勞力（labor_mult(farm)>0）")

# ② :289 移除：_collect_from_tile 食物 gain 不再吃 farming_level（雙源獨立）
func _t2_drift_removed() -> void:
	print("--- ② drift 正位（gather 純野地池） ---")
	var rs := ResourceSystem.new()
	# 兩塊同池、farming 0 vs 3；直呼 _collect_from_tile 只測 gather（farm 獨立線在 collect_resources 後段）
	var s0 := WorldState.new(); s0.world = WorldData.new()
	var t0 := _mk_farm_tile(s0, Vector2i(1,1), 0, 0); t0.public_storage = {}
	var tm0 := _mk_prod_team(s0, 0, Vector2i(1,1), 6)
	var s3 := WorldState.new(); s3.world = WorldData.new()
	var t3 := _mk_farm_tile(s3, Vector2i(1,1), 0, 3); t3.public_storage = {}
	var tm3 := _mk_prod_team(s3, 0, Vector2i(1,1), 6)
	# 直呼 gather（_collect_from_tile）：farming 0 vs 3 → 食物 gain 應相同（drift 移除）
	var g0 := {}; var g3 := {}
	rs._collect_from_tile(s0, tm0, t0, 1.0, t0, 1.0, 0.0, 0.0, g0, 1.0)
	rs._collect_from_tile(s3, tm3, t3, 1.0, t3, 1.0, 0.0, 0.0, g3, 1.0)
	var f0: float = float(t0.public_storage.get("food", 0))
	var f3: float = float(t3.public_storage.get("food", 0))
	_ok(abs(f0 - f3) < 1e-4, "gather food farming0(%.3f)==farming3(%.3f)（:289 移除、farming 不 boost 野地池）" % [f0, f3])

# ③ farm_labor 抽勞力 → gather:food fill 掉（guns-vs-butter）
func _t3_guns_vs_butter() -> void:
	print("--- ③ guns-vs-butter（farm 抽勞力） ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	# 無農田
	var t_nofarm := _mk_farm_tile(state, Vector2i(2,2), 0, 0)
	var tm := _mk_prod_team(state, 0, Vector2i(2,2), 6)
	LaborSystem.rebalance(state, t_nofarm)
	var gather_fill_nofarm: float = float(t_nofarm.labor_alloc.get("gather:food", {}).get("fill", 0.0))
	# 有農田（同池、農田競爭）
	var state2 := WorldState.new(); state2.world = WorldData.new(); state2.world.current_tick = 1000
	var t_farm := _mk_farm_tile(state2, Vector2i(2,2), 0, 3)
	var tm2 := _mk_prod_team(state2, 0, Vector2i(2,2), 6)
	LaborSystem.rebalance(state2, t_farm)
	var gather_fill_farm: float = float(t_farm.labor_alloc.get("gather:food", {}).get("fill", 0.0))
	_ok(t_farm.labor_alloc.has("farm"), "農田工位入勞力池 demand（farm workstation）")
	_ok(gather_fill_farm < gather_fill_nofarm + 1e-6, "farm 競爭 → gather:food fill 掉(%.3f<=%.3f) guns-vs-butter" % [gather_fill_farm, gather_fill_nofarm])

# ④ harvest_factor 季節調制農田產出
func _t4_harvest_season() -> void:
	print("--- ④ harvest_factor 季節 ---")
	var s_hi := WorldState.new(); s_hi.world = WorldData.new(); s_hi.world.current_tick = 1000
	var t_hi := _mk_farm_tile(s_hi, Vector2i(3,3), 0, 2, 1.5); _mk_prod_team(s_hi, 0, Vector2i(3,3), 6)
	var s_lo := WorldState.new(); s_lo.world = WorldData.new(); s_lo.world.current_tick = 1000
	var t_lo := _mk_farm_tile(s_lo, Vector2i(3,3), 0, 2, 0.3); _mk_prod_team(s_lo, 0, Vector2i(3,3), 6)
	ResourceSystem.new().collect_resources(s_hi, [0], WorldState.TICKS_PER_DAY)
	ResourceSystem.new().collect_resources(s_lo, [0], WorldState.TICKS_PER_DAY)
	var y_hi: float = float(t_hi.public_storage.get("food", 0))
	var y_lo: float = float(t_lo.public_storage.get("food", 0))
	_ok(y_hi > y_lo, "harvest_factor 高(1.5)產出 > 低(0.3)（季節調制、%.2f>%.2f）" % [y_hi, y_lo])

# ⑤ 無 farming_level → 農田產出 0（無田不產）
func _t5_no_farming_no_yield() -> void:
	print("--- ⑤ 無 farming_level 產 0 ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var tile := _mk_farm_tile(state, Vector2i(4,4), 0, 0)   # farming_level=0
	_mk_prod_team(state, 0, Vector2i(4,4), 6)
	LaborSystem.rebalance(state, tile)
	_ok(not tile.labor_alloc.has("farm"), "farming_level=0 → 無 farm 工位 demand")
	_ok(LaborSystem.labor_mult(tile, "farm") == 0.0, "farming_level=0 → farm labor=0 → 產出 0（無田不產）")
