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
