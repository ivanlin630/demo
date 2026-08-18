extends SceneTree
# labor-slice v2 TDD — 食物真邊際分配(T1) + ★farm production 解耦 level-cancellation(T2 核心) + 估算器(T3)。
# ★核心 ③：alloc 固定、level 升 → farm production 真升（治 level-cancellation、v1 FAIL 此項）。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _init() -> void:
	print("=== labor v2 test ===")
	_t3_production_rises_with_level_FIXED_alloc()
	_t1_food_split()
	_t4_magnitude()
	_t5_estimator_coherence()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

# ★③ 核心：FIXED alloc share、level 1→2→3 → farm production 真升（治 level-cancellation）。
func _t3_production_rises_with_level_FIXED_alloc() -> void:
	print("--- ③★ production 隨 level 升(FIXED alloc、治 cancellation) ---")
	var t := HexTileData.new(); t.tile_pos = Vector2i(0,0); t.harvest_factor = 1.0
	var prods: Array = []
	var flabors: Array = []
	for level in [1, 2, 3]:
		t.farming_level = level
		# ★FIXED share=5（同一實配勞力）；demand=level×K_FARM(僅 cap、不進 production 除式)
		t.labor_alloc = {"farm": {"share": 5.0, "demand": float(level) * LaborSystem.K_FARM, "fill": 5.0 / (float(level) * LaborSystem.K_FARM)}}
		var flabor: float = LaborSystem.farm_labor(t)   # =share/K_FARM×SCALE=level-independent(不隨 level 縮)
		flabors.append(flabor)
		var prod: float = float(level) * ResourceSystem.FARM_UNIT_YIELD * t.harvest_factor * flabor
		prods.append(prod)
	_ok(abs(flabors[0] - flabors[1]) < 1e-6 and abs(flabors[1] - flabors[2]) < 1e-6,
		"farm_labor level-independent(FIXED share→同 %.3f、非 fill 隨 level 縮)" % flabors[0])
	_ok(prods[0] < prods[1] and prods[1] < prods[2],
		"★production 隨 level 真升(FIXED alloc: L1 %.2f < L2 %.2f < L3 %.2f)=治 cancellation" % [prods[0], prods[1], prods[2]])
	# 對照舊 fill 式(level 相消驗)：old_prod=level×FUY×(share/(level×K_FARM))=share×FUY/K_FARM=level-independent
	var old1: float = 1.0 * ResourceSystem.FARM_UNIT_YIELD * (5.0 / (1.0 * LaborSystem.K_FARM))
	var old3: float = 3.0 * ResourceSystem.FARM_UNIT_YIELD * (5.0 / (3.0 * LaborSystem.K_FARM))
	_ok(abs(old1 - old3) < 1e-6, "對照:舊 fill 式 level 相消(old L1 %.2f==L3 %.2f=v1 FAIL 根)" % [old1, old3])

# ① 食物組 per-labor yield 比例分（farm 高 yield_f 拿多）
func _t1_food_split() -> void:
	print("--- ① 食物組 yield 比例分 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := HexTileData.new(); t.tile_id = 5005; t.tile_pos = Vector2i(5,5); t.terrain = "plains"
	t.outpost_owner = 0; t.outpost_level = 1; t.outpost_type = "civilian"
	t.farming_level = 2; t.harvest_factor = 1.0; t.productivity = 1.0
	t.resources = {"food": 40.0, "material": 40.0}; t.resource_cap = {"food": 200.0, "material": 200.0}
	state.world.tiles[5005] = t
	var ldr := PersonData.new(); ldr.id = 1; ldr.skills = {"生產": 0.3}; state.persons[1] = ldr
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 1; team.tile_pos = Vector2i(5,5); team.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 9); state.teams[0] = team
	LaborSystem.rebalance(state, t)
	var gf: float = float(t.labor_alloc.get("gather:food", {}).get("share", 0.0))
	var fm: float = float(t.labor_alloc.get("farm", {}).get("share", 0.0))
	_ok(fm > gf, "farm yield_f>gather yield_g → farm 拿多份(farm %.2f > gather %.2f)" % [fm, gf])

# ④ magnitude 守 FUY 2.0 不爆（full-staff level3 production bounded）
func _t4_magnitude() -> void:
	print("--- ④ magnitude 守 ---")
	var t := HexTileData.new(); t.tile_pos = Vector2i(0,0); t.harvest_factor = 1.0; t.farming_level = 3
	# full-staff：share=demand=level×K_FARM
	var full_share: float = 3.0 * LaborSystem.K_FARM
	t.labor_alloc = {"farm": {"share": full_share, "demand": full_share, "fill": 1.0}}
	var prod: float = 3.0 * ResourceSystem.FARM_UNIT_YIELD * t.harvest_factor * LaborSystem.farm_labor(t)
	_ok(prod <= 3.0 * 3.0 * ResourceSystem.FARM_UNIT_YIELD + 0.01, "full-staff L3 production=%.1f bounded(≤level²×FUY=%.1f、無爆)" % [prod, 9.0 * ResourceSystem.FARM_UNIT_YIELD])

# ⑤ 估算器 == production 同源（level 生效 + 勞力飽和誠實）
func _t5_estimator_coherence() -> void:
	print("--- ⑤ estimator==production 同源 ---")
	# MarginalEconomy est-based：farming 高 level inflow 升(level 生效)、labor-starved<staffed(誠實)
	var starved := VillageEstimate.make("plains", 1, 3, 2)    # farming3 pop2=labor-starved
	var staffed := VillageEstimate.make("plains", 1, 3, 30)   # farming3 pop30=足勞力
	var lo := MarginalEconomy._inflow_est(starved)
	var hi := MarginalEconomy._inflow_est(staffed)
	_ok(hi > lo, "足勞力 inflow > labor-starved(勞力飽和誠實、%.2f>%.2f)" % [hi, lo])
	# level 生效：同 pop 足勞力、farming 1 vs 3 → inflow 升
	var f1 := VillageEstimate.make("plains", 1, 1, 30)
	var f3 := VillageEstimate.make("plains", 1, 3, 30)
	_ok(MarginalEconomy._inflow_est(f3) > MarginalEconomy._inflow_est(f1), "farming level↑→est inflow↑(level 生效)")
