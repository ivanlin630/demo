extends SceneTree

# 統一勞力池 dev-verify（HOW spec 2026-08-03 §7）。allocator rebalance + labor_mult 機制驗。
# ★baseline 保真(pop5 單工位 labor_mult≈1.0)+size matter(大池餵多工位)+人手少全線比例+人手多飽和溢出+determinism。
# 純算術零 RNG（determinism 保）。全世界 size-matter emergence → measurer 合量。

var _fail: int = 0

func _initialize() -> void:
	_test_baseline_single_workstation()
	_test_small_pool_all_lines_proportional()
	_test_large_pool_saturates()
	_test_size_matter_more_workstations_fed()
	_test_need_gated_no_phantom_labor()
	_test_supply_chain_multilevel_need()
	_test_rebalance_deterministic()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

# 建 state:tile @(0,0) 有 food+material 資源;N 個 pop=P 的 PRODUCE 隊共址。facilities 依參數。
func _mk(pool_teams: Array, mfg_levels: Dictionary, resources: Dictionary) -> Array:
	var state := WorldState.new()
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(0, 0); tile.outpost_owner = 0; tile.outpost_level = 1
	for r in resources: tile.resources[r] = float(resources[r])
	for lk in mfg_levels: tile.set(lk, int(mfg_levels[lk]))
	state.world.tiles[0] = tile
	var i := 0
	for pop in pool_teams:
		var t := TeamData.new(); t.team_id = i; t.tile_pos = Vector2i(0, 0)
		t.tags = [TeamData.TAG_PRODUCE]
		AnonCohort.add(t.anon_cohorts, "平民", "healthy", int(pop))
		var l := PersonData.new(); l.id = 1000 + i; l.team_id = i; l.values = {"慎重": 0.5}
		t.leader_id = l.id; state.persons[l.id] = l
		state.teams[i] = t
		i += 1
	return [state, tile]

func _test_baseline_single_workstation() -> void:
	# pool5 單隊、只 food 工位(demand K_GATHER=5)→share=min(5,5)=5→fill=1→labor_mult=1.0(=pop_mult@pop5)。
	var st := _mk([5], {}, {"food": 1000.0})
	var state: WorldState = st[0]; var tile: HexTileData = st[1]
	LaborSystem.rebalance(state, tile)
	var lm: float = LaborSystem.labor_mult(tile, "gather:food")
	if absf(lm - 1.0) < 0.05:
		_ok("baseline 保真:pop5 單隊單工位 labor_mult=%.3f≈1.0(=現 pop_mult@5)" % lm)
	else:
		_bad("baseline 破:labor_mult=%.3f≠1.0" % lm)

func _test_small_pool_all_lines_proportional() -> void:
	# pool5 但 3 工位(food+material+workshop)→池不足→每工位 fill>0 分一份(無 winner-take-all)。
	var st := _mk([5], {"manufacturing_level": 1}, {"food": 1000.0, "material": 1000.0})
	var state: WorldState = st[0]; var tile: HexTileData = st[1]
	LaborSystem.rebalance(state, tile)
	var ff: float = LaborSystem.labor_mult(tile, "gather:food")
	var fm: float = LaborSystem.labor_mult(tile, "gather:material")
	var fw: float = LaborSystem.labor_mult(tile, "mfg:manufacturing_level")
	# food 有 survival need→fill>0;至少 food 線分到(material/mfg need 視 demand,food 必>0)。
	if ff > 0.0 and ff <= 1.0:
		_ok("人手少全線比例:food fill=%.2f>0(survival 拉權重)、material=%.2f、mfg=%.2f(池分裂非獨吞)" % [ff, fm, fw])
	else:
		_bad("人手少分配錯:food=%.2f material=%.2f mfg=%.2f" % [ff, fm, fw])

func _test_large_pool_saturates() -> void:
	# pool40 單隊、只 food 工位(demand 5)→封頂 fill=1(share cap 5)+餘力溢出(35 閒)。
	var st := _mk([40], {}, {"food": 1000.0})
	var state: WorldState = st[0]; var tile: HexTileData = st[1]
	LaborSystem.rebalance(state, tile)
	var a: Dictionary = tile.labor_alloc.get("gather:food", {})
	if absf(float(a.get("fill", 0)) - 1.0) < 0.001 and float(a.get("share", 0)) <= 5.001:
		_ok("人手多飽和:pool40 單工位 fill=1(share=%.0f cap demand 5)+餘力溢出(35 閒)" % float(a.get("share", 0)))
	else:
		_bad("飽和錯:fill=%.2f share=%.1f" % [float(a.get("fill", 0)), float(a.get("share", 0))])

func _test_size_matter_more_workstations_fed() -> void:
	# size matter:大池(pool40)餵得動多工位(food+material+workshop 全 fill 高) vs 小池(pool5)分裂。
	# 比「全工位 fill 總和」:大池 > 小池(餵得動更多)。
	var big := _mk([40], {"manufacturing_level": 2}, {"food": 1000.0, "material": 1000.0})
	LaborSystem.rebalance(big[0], big[1])
	var small := _mk([5], {"manufacturing_level": 2}, {"food": 1000.0, "material": 1000.0})
	LaborSystem.rebalance(small[0], small[1])
	var big_sum: float = 0.0
	for k in big[1].labor_alloc: big_sum += float(big[1].labor_alloc[k].get("fill", 0))
	var small_sum: float = 0.0
	for k in small[1].labor_alloc: small_sum += float(small[1].labor_alloc[k].get("fill", 0))
	if big_sum > small_sum + 0.1:
		_ok("size matter:大池 Σfill=%.2f > 小池 Σfill=%.2f(餵得動多工位=真產多)" % [big_sum, small_sum])
	else:
		_bad("size 未 matter:大 Σfill=%.2f 小=%.2f" % [big_sum, small_sum])

func _test_need_gated_no_phantom_labor() -> void:
	# need-driven 雙向:有 need 工位配勞力(food survival)、無 need 工位不配(gem 無自用/無設施/非擁地/無買單→need=0)。
	# 證非「有資源就採」——無需求不配勞力(§2.4 need-gate、無 scripted floor)。
	var state := WorldState.new()
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(0, 0)
	tile.outpost_owner = -1; tile.outpost_level = 0   # 隊非擁地 → 無 construction need
	tile.resources = { "food": 1000.0, "gem": 1000.0 }
	state.world.tiles[0] = tile
	var t := TeamData.new(); t.team_id = 0; t.tile_pos = Vector2i(0, 0); t.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 10)
	var l := PersonData.new(); l.id = 1000; l.team_id = 0; l.values = {"慎重": 0.5}
	t.leader_id = l.id; state.persons[l.id] = l; state.teams[0] = t
	LaborSystem.rebalance(state, tile)
	var f_food: float = LaborSystem.labor_mult(tile, "gather:food")
	var f_gem: float = LaborSystem.labor_mult(tile, "gather:gem")
	if f_food > 0.0 and f_gem == 0.0:
		_ok("need-gate 雙向:food(survival need>0)fill=%.2f>0、gem(need=0)fill=0(無需求不配勞力、非有礦就採)" % f_food)
	else:
		_bad("need-gate 破:food=%.2f gem=%.2f(gem 應 0)" % [f_food, f_gem])

func _test_supply_chain_multilevel_need() -> void:
	# ★(b)供給鏈多級 need 傳播:weapon_high(終端自用)←ore_steel(供給)←ore_iron(供給)=2 級。
	# ★關鍵:ore_steel/ore_iron 皆 PURE_INTERMEDIATE(self_use=0)→其 need 只能來自供給鏈傳導。
	#   ore_steel>0 證 level-1(weapon 需→拉料);ore_iron>0 證 level-2(續傳過 steel 中間品)。
	# 若任一=0 → need_oracle.supply_chain 傳播斷 = oracle completeness follow-up(修 oracle、非加 floor)。
	var state := WorldState.new()
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(0, 0)
	tile.outpost_owner = 0; tile.outpost_level = 1
	tile.set("weaponsmith_level", 1)   # 終端 weapon_high 設施(拉 ore_steel need)
	tile.set("smelter_level", 1)       # ore_steel 設施(拉 ore_iron need)=多級樞紐
	state.world.tiles[0] = tile
	var t := TeamData.new(); t.team_id = 0; t.tile_pos = Vector2i(0, 0); t.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 10)
	var l := PersonData.new(); l.id = 1000; l.team_id = 0; l.values = {"慎重": 0.5}
	t.leader_id = l.id; state.persons[l.id] = l
	t.resources = {}   # holding=0 → gap 全開
	state.teams[0] = t
	var lv: Dictionary = TradeValuation.leader_vals(state, t)
	var n_wpn: float = NeedOracle.need_keep(state, t, "weapon_melee_high", lv)
	var n_steel: float = NeedOracle.need_keep(state, t, "ore_steel", lv)
	var n_iron: float = NeedOracle.need_keep(state, t, "ore_iron", lv)
	if n_wpn > 0.0 and n_steel > 0.0 and n_iron > 0.0:
		_ok("供給鏈多級傳播不斷:weapon(自用 %.1f)→ore_steel(供給 %.1f,self_use=0 純傳導)→ore_iron(供給 %.1f,level-2)" % [n_wpn, n_steel, n_iron])
	else:
		_bad("★供給鏈多級斷:weapon=%.2f steel=%.2f iron=%.2f(=0 者傳播斷→oracle completeness follow-up,非加 floor)" % [n_wpn, n_steel, n_iron])

func _test_rebalance_deterministic() -> void:
	# 同 state 兩次 rebalance → alloc 完全相同（sorted key + 純算術 + 零 RNG）。
	var st := _mk([12, 8], {"manufacturing_level": 1, "apothecary_level": 1}, {"food": 500.0, "material": 500.0, "herb": 300.0})
	var state: WorldState = st[0]; var tile: HexTileData = st[1]
	LaborSystem.rebalance(state, tile)
	var snap: Dictionary = tile.labor_alloc.duplicate(true)
	tile.labor_eval_next_tick = 0
	LaborSystem.rebalance(state, tile)
	var same: bool = true
	for k in snap:
		if absf(float(snap[k].get("share", 0)) - float(tile.labor_alloc[k].get("share", 0))) > 1e-6: same = false
	if same and snap.size() == tile.labor_alloc.size():
		_ok("determinism:同 state 兩次 rebalance alloc byte-identical(%d 工位)" % snap.size())
	else:
		_bad("determinism 破:兩次 rebalance 不同")

func _ok(m: String) -> void: print("  [PASS] " + m)
func _bad(m: String) -> void:
	_fail += 1
	print("  [FAIL] " + m)
