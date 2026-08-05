extends SceneTree

# 復甦路徑 Slice R1 TDD（spec 2026-08-06-recovery-path-HOW §1/§2A）。
# MarginalEconomy 邊際計算層(命門① god-view 結構防線) + 移民 marginal-util dispatch(三態湧現、零 if-terrain)。
# 守零 god-view(est-not-live)/零死常數(真邊際)/真成本/來源不抽穿。

var _fail: int = 0

func _initialize() -> void:
	_test_marginal_three_state()   # ①migrant_marginal 三態 sign(plains 正/forest 負/mountain 負、REGEN 主導零 if-terrain)
	_test_inflow_est_pure()        # ★③god-view 結構防線:_inflow_est 純 est 函式(不同 est→不同結果、無 state 參照)
	_test_village_est_belief()     # ★③god-view:_village_est.pop=belief pop_est 非 live pop
	_test_migrant_forest_no_dispatch() # ②森林村→marginal<0→不派
	_test_migrant_plains_dispatch()    # 平原欠人村→marginal>0→派
	_test_source_not_drained()     # ④來源不抽穿:領主 anon 不足→不派
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# ① migrant_marginal 三態（純 MarginalEconomy、neutral defaults、REGEN 主導 sign、零 if-terrain）。
func _test_marginal_three_state() -> void:
	print("--- ①migrant_marginal 三態 ---")
	var plains := VillageEstimate.make("plains", 1, 0, 2)
	var forest := VillageEstimate.make("forest", 1, 0, 2)
	var mountain := VillageEstimate.make("mountain", 1, 0, 2)
	var mp := MarginalEconomy.migrant_marginal(plains, 3)
	var mf := MarginalEconomy.migrant_marginal(forest, 3)
	var mm := MarginalEconomy.migrant_marginal(mountain, 3)
	_ok(mp > 0.0 and mf < 0.0 and mm < 0.0,
		"plains %.2f>0(收) / forest %.2f<0(不收) / mountain %.2f<0(不收)＝三態 REGEN 主導湧現(零 if-terrain)" % [mp, mf, mm])

# ★③ _inflow_est 結構防線：純 est 函式（不同 est→不同結果、簽名無 state 拿不到 live）。
func _test_inflow_est_pure() -> void:
	print("--- ★③_inflow_est 純函式(結構防線) ---")
	var a := VillageEstimate.make("plains", 1, 0, 2)
	var b := VillageEstimate.make("plains", 1, 0, 5)
	var ia := MarginalEconomy._inflow_est(a)
	var ib := MarginalEconomy._inflow_est(b)
	_ok(ib > ia and ia > 0.0, "_inflow_est 純 est(pop2=%.2f<pop5=%.2f)＝結果跟 est、簽名不吃 state 拿不到 live target(結構防線)" % [ia, ib])

# ★③ _village_est.pop = belief pop_est 非 live pop（god-view leak 硬驗）。
func _test_village_est_belief() -> void:
	print("--- ★③_village_est 讀 belief 非 live ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(0,0); state.teams[1] = lord
	var village := TeamData.new(); village.team_id = 9; village.faction_id = 0; village.tile_pos = Vector2i(5,5)
	AnonCohort.add(village.anon_cohorts, "平民", "healthy", 50)   # ★live pop=50
	state.teams[9] = village
	var vtile := HexTileData.new(); vtile.tile_pos = Vector2i(5,5); vtile.terrain = "plains"; vtile.outpost_level = 1; vtile.outpost_owner = 9
	state.world.tiles[5005] = vtile
	BeliefSystem.record_claim(state, 1, 9, 1, "親見", {"tile_pos": Vector2i(5,5), "population_est": 2}, 1.0, false)   # ★belief pop_est=2
	var est: VillageEstimate = FactionAISystem.new()._village_est(state, lord, 9)
	_ok(est != null and est.pop == 2, "_village_est.pop=%d=belief pop_est(2) 非 live pop(50)＝零 god-view" % (est.pop if est != null else -1))

# 建 lord(faction leader)+holding 村(terrain 依參、belief pop_est=2)。
func _mk_lord_with_village(terrain: String, lord_anon: int) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(0,0)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", lord_anon)
	var ll := PersonData.new(); ll.id = 11; ll.values = {"義氣": 0.6, "求生欲": 0.6}; state.persons[11] = ll; lord.leader_id = 11
	lord.dispatch_ledger.append({"kind": "holding", "subject_ref": 9, "is_team": true,
		"dispatched_tick": state.world.current_tick, "expected_return_tick": state.world.current_tick + 1000,
		"last_known_pos": Vector2i(5,5), "resolved": false})
	state.teams[1] = lord
	var village := TeamData.new(); village.team_id = 9; village.faction_id = 0; village.tile_pos = Vector2i(5,5)
	AnonCohort.add(village.anon_cohorts, "平民", "healthy", 2)
	state.teams[9] = village
	var vtile := HexTileData.new(); vtile.tile_pos = Vector2i(5,5); vtile.terrain = terrain; vtile.outpost_level = 1; vtile.outpost_owner = 9
	state.world.tiles[5005] = vtile
	BeliefSystem.record_claim(state, 1, 9, 1, "親見", {"tile_pos": Vector2i(5,5), "population_est": 2}, 1.0, false)
	return [state, lord]

func _migrant_fired(state: WorldState, lord: TeamData) -> int:
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._try_migrant_side(state, lord)
	Probe.enabled = false
	return int(Probe.counts.get("migrant.dispatched", 0))

# ② 森林村→marginal<0→不派。
func _test_migrant_forest_no_dispatch() -> void:
	print("--- ②森林村不派 ---")
	var a := _mk_lord_with_village("forest", 10)
	_ok(_migrant_fired(a[0], a[1]) == 0, "森林村 migrant_marginal<0→不派移民(三態湧現、加人加速惡化)")

# 平原欠人村→marginal>0→派。
func _test_migrant_plains_dispatch() -> void:
	print("--- 平原欠人村派 ---")
	var a := _mk_lord_with_village("plains", 10)
	_ok(_migrant_fired(a[0], a[1]) == 1, "平原欠人村 migrant_marginal>0→派移民(人到=產能到僅邊際正成立)")

# ④ 來源不抽穿：領主 anon 不足(留守下限)→不派(即使 target 邊際正)。
func _test_source_not_drained() -> void:
	print("--- ④來源不抽穿 ---")
	var a := _mk_lord_with_village("plains", 3)   # 領主 anon 僅 3(<BATCH3+2)→不掏穿
	_ok(_migrant_fired(a[0], a[1]) == 0, "領主 anon 不足留守下限→不派(不拆東牆補西牆、即使平原 target 邊際正)")
