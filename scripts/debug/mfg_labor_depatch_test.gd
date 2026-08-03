extends SceneTree

# manufacturing per-labor-allocation de-patch TDD（spec 2026-08-03-mfg-labor-integration-depatch-HOW）。
# 移除 mfg:67 `current_task != TASK_MANUFACTURE → skip` 補丁閘 → PRODUCE 隊在自家 outpost 就跑（如 gather 對稱）。
# ★所有 fixture current_task=IDLE（≠MANUFACTURE）→ 證 de-patch（移閘前全 skip 產 0）。
# blast-radius：①de-patch 生效 ②need/stock 滿足不過度生產 ③materials-gated ④position-gated ⑤PRODUCE-gated（軍隊排除）。
# 純算術/讀 belief 零 RNG。

var _fail: int = 0

func _initialize() -> void:
	_test_depatch_runs_when_idle()   # ①移閘後 IDLE 隊在 outpost 就產（was skip）
	_test_satisfied_no_overproduce() # ②stock 滿足→不產（不過度生產）
	_test_materials_gated()          # ③需求在但無材料→不產
	_test_position_gated()           # ④非自家 outpost→不產
	_test_produce_gated()            # ⑤無 PRODUCE 居民（軍隊）→不產
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

# tile@(5,5) civilian outpost lvl1 + workshop(manufacturing_level=1)。team PRODUCE(可選)、current_task=IDLE、
# own(owner=自己 或 99)、material 庫存、tools/goods/arrows/wagons 起始 hold、可選親聞 tools 買單。
func _mk(produce_tag: bool, own: bool, material: float, tools_hold: float, tools_demand: int) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5, 5); tile.terrain = "plains"
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	tile.outpost_owner = (1 if own else 99)
	tile.set("manufacturing_level", 1)
	state.world.tiles[5 * 1000 + 5] = tile
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	team.current_task = TeamData.TASK_IDLE   # ★≠MANUFACTURE：移閘前必 skip
	if produce_tag: team.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 10)
	team.resources["food"] = 5000.0
	team.resources["material"] = material
	# goods/arrows/wagons 灌高 hold → 其 out satisfied（stock≥target）只留 tools 為變因。
	team.resources["goods"] = 99999.0; team.resources["arrows"] = 99999.0; team.resources["wagons"] = 99999.0
	team.resources["tools"] = tools_hold
	var l := PersonData.new(); l.id = 10; l.values = {"慎重": 0.5}; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	if tools_demand > 0:
		var m := MessageData.new(); m.type = "order_buy"
		m.params = {"res": "tools", "origin_team": 99, "expire_tick": 99999, "qty": tools_demand}
		state.team_known[1] = [m]
	return [state, team, tile]

func _tools_made(team: TeamData, tile: HexTileData) -> float:
	return float(team.resources.get("tools", 0)) + float(tile.public_storage.get("tools", 0))

# ① de-patch 生效：PRODUCE 隊在自家 outpost、current_task=IDLE、有需求(demand)+材料 → 產 tools（移閘前=0）
func _test_depatch_runs_when_idle() -> void:
	print("--- ①de-patch:IDLE 隊在 outpost 就產 ---")
	var a: Array = _mk(true, true, 1000.0, 0.0, 500)   # tools hold 0、大 demand → need>0
	var before: float = _tools_made(a[1], a[2])
	ManufacturingSystem.new().tick_all(a[0], [1])
	var after: float = _tools_made(a[1], a[2])
	_ok(after > before, "current_task=IDLE + PRODUCE+outpost+need+材料 → 產 tools %.3f（移閘前=0，de-patch 生效）" % (after - before))

# ② stock 滿足 → 不過度生產（satisfied 經濟不亂產）
func _test_satisfied_no_overproduce() -> void:
	print("--- ②satisfied→不產 ---")
	# tools hold 灌爆 + 無 demand → 全 out stock≥target → 不產。
	var a: Array = _mk(true, true, 1000.0, 99999.0, 0)
	var before: float = _tools_made(a[1], a[2])
	ManufacturingSystem.new().tick_all(a[0], [1])
	var after: float = _tools_made(a[1], a[2])
	_ok(absf(after - before) < 0.001, "stock 滿足+無 demand → 不產（不過度生產；Δtools=%.3f）" % (after - before))

# ③ materials-gated：需求在但無材料 → 不產
func _test_materials_gated() -> void:
	print("--- ③materials-gated ---")
	var a: Array = _mk(true, true, 0.0, 0.0, 500)   # need>0（demand）但 material=0
	var before: float = _tools_made(a[1], a[2])
	ManufacturingSystem.new().tick_all(a[0], [1])
	var after: float = _tools_made(a[1], a[2])
	_ok(absf(after - before) < 0.001, "有需求但無材料 → 不產（materials-gated；Δtools=%.3f）" % (after - before))

# ④ position-gated：非自家 outpost → 不產
func _test_position_gated() -> void:
	print("--- ④position-gated ---")
	var a: Array = _mk(true, false, 1000.0, 0.0, 500)   # owner=99≠team → _team_works_tile false
	var before: float = _tools_made(a[1], a[2])
	ManufacturingSystem.new().tick_all(a[0], [1])
	var after: float = _tools_made(a[1], a[2])
	_ok(absf(after - before) < 0.001, "非自家 outpost → 不產（position-gated；Δtools=%.3f）" % (after - before))

# ⑤ PRODUCE-gated：無 PRODUCE 居民（軍隊型）→ 不產
func _test_produce_gated() -> void:
	print("--- ⑤PRODUCE-gated（軍隊排除）---")
	var a: Array = _mk(false, true, 1000.0, 0.0, 500)   # 無 TAG_PRODUCE → _has_resident_on_tile false
	var before: float = _tools_made(a[1], a[2])
	ManufacturingSystem.new().tick_all(a[0], [1])
	var after: float = _tools_made(a[1], a[2])
	_ok(absf(after - before) < 0.001, "無 PRODUCE 居民 → 不產（PRODUCE-gated、軍隊不算；Δtools=%.3f）" % (after - before))
