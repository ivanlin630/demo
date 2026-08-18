extends SceneTree
# labor-slice TDD — 食物工位邊際分配(T1) + 估算器 coherence(T2)。
# ①食物組 per-labor yield 比例分非 equal ②farm 高 level 拿多份治斷崖 ③cross-resource food-vs-material 比例不變
# ④未發展團 farming0 gather 照舊 ⑤_sustainable_inflow 移 farming_bonus 加 farm 貢獻含勞力飽和 ⑦estimator==allocation 同源。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _mk_tile(state: WorldState, farming: int, food_pool: float = 40.0, material_pool: float = 40.0) -> HexTileData:
	var t := HexTileData.new(); t.tile_id = 5005; t.tile_pos = Vector2i(5,5); t.terrain = "plains"
	t.outpost_owner = 0; t.outpost_level = 1; t.outpost_type = "civilian"
	t.farming_level = farming; t.harvest_factor = 1.0; t.productivity = 1.0
	t.resources = {"food": food_pool, "material": material_pool}; t.resource_cap = {"food": 200.0, "material": 200.0}
	state.world.tiles[5005] = t
	return t

func _mk_team(state: WorldState, pop: int) -> TeamData:
	var ldr := PersonData.new(); ldr.id = 1; ldr.skills = {"生產": 0.3}; state.persons[1] = ldr
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 1; team.tile_pos = Vector2i(5,5)
	team.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", maxi(pop-1, 0))
	state.teams[0] = team
	return team

func _init() -> void:
	print("=== labor-slice test ===")
	_t1_food_split_by_yield()
	_t2_farm_level_cliff()
	_t3_cross_resource_stable()
	_t4_no_farming_gather()
	_t5_estimator_coherence()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

# ① 食物組 per-labor yield 比例分（非 equal）
func _t1_food_split_by_yield() -> void:
	print("--- ① 食物組 yield 比例分 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := _mk_tile(state, 2)   # farming 2 → yield_f=2×FARM_UNIT_YIELD×1 >> yield_g=1×COLLECT_RATE
	_mk_team(state, 10)
	LaborSystem.rebalance(state, t)
	var gf: float = float(t.labor_alloc.get("gather:food", {}).get("share", 0.0))
	var fm: float = float(t.labor_alloc.get("farm", {}).get("share", 0.0))
	_ok(t.labor_alloc.has("farm") and t.labor_alloc.has("gather:food"), "食物組兩工位存在")
	_ok(fm > gf, "farm yield_f(高)>gather yield_g → farm 拿多份(farm %.2f > gather %.2f、非 equal)" % [fm, gf])

# ② farm level↑ → farm 產出↑（治斷崖=正相關）
func _t2_farm_level_cliff() -> void:
	print("--- ② farm level 治斷崖 ---")
	var prod1: float = _farm_output(1)
	var prod2: float = _farm_output(2)
	var prod3: float = _farm_output(3)
	_ok(prod3 > prod2 and prod2 > prod1, "farm level 1<2<3 產出遞增(正相關治斷崖、%.2f<%.2f<%.2f)" % [prod1, prod2, prod3])

func _farm_output(farming: int) -> float:
	var state := WorldState.new(); state.world = WorldData.new()
	var t := _mk_tile(state, farming)
	_mk_team(state, 10)
	LaborSystem.rebalance(state, t)
	# farm 產出 = farming × FARM_UNIT_YIELD × labor_mult(farm) × harvest
	return float(farming) * ResourceSystem.FARM_UNIT_YIELD * LaborSystem.labor_mult(t, "farm") * t.harvest_factor

# ③ cross-resource：食物組合併=food_need 單一 → material fill 不被食物雙倍擠壓
func _t3_cross_resource_stable() -> void:
	print("--- ③ cross-resource 不亂 ---")
	# 有農田 vs 無農田，material 工位 fill 應相近（食物組單一 need、非雙份擠 material）
	var s_farm := WorldState.new(); s_farm.world = WorldData.new()
	var t_farm := _mk_tile(s_farm, 2); _mk_team(s_farm, 10); LaborSystem.rebalance(s_farm, t_farm)
	var mat_farm: float = float(t_farm.labor_alloc.get("gather:material", {}).get("fill", 0.0))
	var s_nofarm := WorldState.new(); s_nofarm.world = WorldData.new()
	var t_nofarm := _mk_tile(s_nofarm, 0); _mk_team(s_nofarm, 10); LaborSystem.rebalance(s_nofarm, t_nofarm)
	var mat_nofarm: float = float(t_nofarm.labor_alloc.get("gather:material", {}).get("fill", 0.0))
	# 食物組單一 need_weight（非拆兩份）→ 加農田不額外雙倍擠 material（fill 差異僅來自 farm 佔池、非 need 雙計）
	_ok(t_farm.labor_alloc.has("gather:material"), "material 工位存在")
	_ok(abs(mat_farm - mat_nofarm) < 0.5, "material fill 加農田前後相近(%.2f≈%.2f、食物組單一 need 不雙擠)" % [mat_farm, mat_nofarm])

# ④ 未發展團 farming=0 → 無 farm 工位、gather:food 承全食物 need（照舊）
func _t4_no_farming_gather() -> void:
	print("--- ④ farming0 gather 照舊 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := _mk_tile(state, 0)
	_mk_team(state, 10)
	LaborSystem.rebalance(state, t)
	_ok(not t.labor_alloc.has("farm"), "farming0→無 farm 工位")
	_ok(float(t.labor_alloc.get("gather:food", {}).get("fill", 0.0)) > 0.0, "gather:food 承食物採集(照舊)")

# ⑤ estimator coherence：移 farming_bonus(乘性)、加 farm 貢獻(加項含勞力飽和)
func _t5_estimator_coherence() -> void:
	print("--- ⑤ estimator coherence ---")
	# food_flow._sustainable_inflow：farming 0 vs 2 → 差=加項(farm_contribution)非×2.5 乘性
	var state := WorldState.new(); state.world = WorldData.new()
	var t2 := _mk_tile(state, 2); _mk_team(state, 10); LaborSystem.rebalance(state, t2)
	var inflow_farm: float = FoodFlow._sustainable_inflow(state, state.teams[0])
	# 對照：同 tile farming=0
	var s0 := WorldState.new(); s0.world = WorldData.new()
	var t0 := _mk_tile(s0, 0); _mk_team(s0, 10); LaborSystem.rebalance(s0, t0)
	var inflow_nofarm: float = FoodFlow._sustainable_inflow(s0, s0.teams[0])
	_ok(inflow_farm > inflow_nofarm, "農田團 inflow > 無農田(farm 加項貢獻、%.2f>%.2f)" % [inflow_farm, inflow_nofarm])
	# MarginalEconomy._inflow_est：labor-starved(低 pop)farm ROI 誠實低 vs 足勞力
	var est_starved := VillageEstimate.make("plains", 1, 3, 1)   # farming3 但 pop1=labor-starved
	var est_staffed := VillageEstimate.make("plains", 1, 3, 30)  # farming3 pop30=足勞力
	_ok(MarginalEconomy._inflow_est(est_staffed) > MarginalEconomy._inflow_est(est_starved),
		"足勞力 farm ROI > labor-starved(誠實勞力飽和、%.2f>%.2f)" % [MarginalEconomy._inflow_est(est_staffed), MarginalEconomy._inflow_est(est_starved)])
