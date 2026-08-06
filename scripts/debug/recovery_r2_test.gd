extends SceneTree

# 復甦路徑 Slice R2 TDD（spec 2026-08-06-recovery-path-HOW §1.1(2)/§2B）。
# 領主投資設施 lord-side dispatch（P3 material-delivery）：facility_roi survival-bounded（雙 survival bound）
# + material convoy deposit 入村公庫 + ★驗執行端（料到→村端建設真 fire→farming 真升）。
# 守零 god-view(facility_roi 純 est)/零死常數(真 ROI)/真成本(領主出料)/雙 survival bound。

var _fail: int = 0

func _initialize() -> void:
	_test_facility_roi_three_state()      # ①facility_roi 三態:森村轉正 roi>0 / 山地仍赤字 roi<0(survival-bounded、零 if-terrain)
	_test_facility_roi_survival_bounded() # ★survival-bound 機制:轉正村 full-horizon vs 仍赤字村 window→−cost(治 HORIZON 自打臉)
	_test_facility_roi_pure()             # ★god-view 結構防線:facility_roi 純 est 函式(不同 est→不同、無 state)
	_test_invest_forest_dispatch()        # 森村欠糧無 farming holding→roi>0→送料 convoy dispatch
	_test_invest_mountain_no_dispatch()   # ②山地村→roi<0→不投(三態湧現)
	_test_invest_lord_desperate_no()      # ★bound#2 領主端 source-floor:領主絕境→先自救不投(即使村 roi>0)
	_test_invest_deliver_deposits()       # ★material-delivery:invest convoy 抵村→料 deposit 入村 public_storage(非賣)
	_test_invest_full_pipeline()          # ★★★全 advance_tick pipeline:料到村→村建設真 fire→farming 0→1(驗執行端真路徑、非 hand-step)
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

const COST_VALUE_REP: float = 60.0   # 代表升級料價值（farming L1 material 30 × 領主 local_value≈2.0[material-rich]）

# ① facility_roi 三態（純 MarginalEconomy、REGEN 主導 sign、零 if-terrain）：
#   森村 pop5 farming L1 → net_after>=0（deficit→surplus）→ full-horizon → roi>0（投）。
#   山地 pop5 farming L1 → 仍遠赤字（net_after<0、food_est0→window0）→ roi=−cost<0（不投）。
func _test_facility_roi_three_state() -> void:
	print("--- ①facility_roi 三態 ---")
	var forest := VillageEstimate.make("forest", 1, 0, 5)     # REGEN3: inflow 3.0<need4.0(deficit)、farming L1→4.5>4.0(轉正)
	var mountain := VillageEstimate.make("mountain", 1, 0, 5)  # REGEN0.5: farming L1→0.75<<need4.0(永赤字)
	var rf := MarginalEconomy.facility_roi(forest, "farming", 1, COST_VALUE_REP)
	var rm := MarginalEconomy.facility_roi(mountain, "farming", 1, COST_VALUE_REP)
	_ok(rf > 0.0 and rm < 0.0,
		"森村 %.1f>0(投資轉正 deficit→surplus) / 山地 %.1f<0(投資後仍赤字→短窗→ROI 負自我區辨)＝三態(零 if-terrain)" % [rf, rm])

# ★survival-bounded 機制（治 HORIZON 自打臉）：轉正村 roi=Δinflow×90−cost（full horizon）；
#   仍赤字村（food_est0）roi=−cost（window 0）＝discrimination 非靠調 HORIZON、靠殘存活窗。
func _test_facility_roi_survival_bounded() -> void:
	print("--- ★survival-bounded 機制 ---")
	var mountain := VillageEstimate.make("mountain", 1, 0, 5)
	var rm := MarginalEconomy.facility_roi(mountain, "farming", 1, COST_VALUE_REP)
	# 山地 net_after<0 且 food_est=0 → effective_days=0 → roi = 0 − cost_value = −60（window-bound、非靠 HORIZON 大小）
	_ok(is_equal_approx(rm, -COST_VALUE_REP),
		"山地(仍赤字 food_est0)→window 0→roi=%.1f=−cost(治 HORIZON 自打臉:短窗定 sign 非調 HORIZON)" % rm)

# ★god-view 結構防線：facility_roi 純 est（不同 est→不同 roi、簽名不吃 state）。
func _test_facility_roi_pure() -> void:
	print("--- ★god-view:facility_roi 純函式 ---")
	var lowpop := VillageEstimate.make("plains", 1, 0, 2)
	var hipop := VillageEstimate.make("plains", 1, 0, 20)
	var r1 := MarginalEconomy.facility_roi(lowpop, "farming", 1, COST_VALUE_REP)
	var r2 := MarginalEconomy.facility_roi(hipop, "farming", 1, COST_VALUE_REP)
	_ok(r1 != r2, "facility_roi 純 est(pop2 roi=%.1f≠pop20 roi=%.1f)＝結果跟 est、簽名不吃 state 拿不到 live(結構防線)" % [r1, r2])

# 建 lord(faction leader、有料有糧有 advisor)+holding 村(terrain/belief pop_est 依參、farming_level 0)。
func _mk_lord_invest(terrain: String, pop_est: int, lord_food: float) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(0,0)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 10)
	lord.resources = {"food": lord_food, "material": 200.0}
	var ll := PersonData.new(); ll.id = 11; ll.values = {"義氣": 0.6, "求生欲": 0.6}; state.persons[11] = ll; lord.leader_id = 11
	var adv := PersonData.new(); adv.id = 12; adv.values = {"生產": 0.5}; state.persons[12] = adv   # ★非 leader 記名成員=advisor(convoy 需)
	lord.named_members = [11, 12]
	lord.dispatch_ledger.append({"kind": "holding", "subject_ref": 9, "is_team": true,
		"dispatched_tick": state.world.current_tick, "expected_return_tick": state.world.current_tick + 1000,
		"last_known_pos": Vector2i(5,5), "resolved": false})
	state.teams[1] = lord
	var village := TeamData.new(); village.team_id = 9; village.faction_id = 0; village.tile_pos = Vector2i(5,5)
	AnonCohort.add(village.anon_cohorts, "平民", "healthy", pop_est)
	state.teams[9] = village
	var vtile := HexTileData.new(); vtile.tile_pos = Vector2i(5,5); vtile.terrain = terrain
	vtile.outpost_level = 1; vtile.outpost_owner = 9; vtile.outpost_type = "civilian"; vtile.farming_level = 0
	state.world.tiles[5005] = vtile
	BeliefSystem.record_claim(state, 1, 9, 1, "親見", {"tile_pos": Vector2i(5,5), "population_est": pop_est}, 1.0, false)
	return [state, lord]

func _invest_fired(state: WorldState, lord: TeamData) -> int:
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._try_invest_side(state, lord)
	Probe.enabled = false
	return int(Probe.counts.get("invest.dispatched", 0))

# 森村欠糧無 farming holding→roi>0→送料 dispatch。
func _test_invest_forest_dispatch() -> void:
	print("--- 森村投資 dispatch ---")
	var a := _mk_lord_invest("forest", 5, 1000.0)
	_ok(_invest_fired(a[0], a[1]) == 1, "森村(deficit 無 farming)facility_roi>0→領主送料 convoy dispatch(邊際回收正成立)")

# ② 山地村→roi<0→不投。
func _test_invest_mountain_no_dispatch() -> void:
	print("--- ②山地村不投 ---")
	var a := _mk_lord_invest("mountain", 5, 1000.0)
	_ok(_invest_fired(a[0], a[1]) == 0, "山地村 facility_roi<0→不投(投資後仍赤字、料丟填不滿的洞=三態湧現)")

# ★bound#2 領主端 source-floor：領主絕境（食<DESPERATION）→先自救不投（即使村 roi>0）。
func _test_invest_lord_desperate_no() -> void:
	print("--- ★bound#2 領主絕境不投 ---")
	var a := _mk_lord_invest("forest", 5, 10.0)   # lord food 10 /(10×0.8)=1.25 天 < DESPERATION 3
	_ok(_invest_fired(a[0], a[1]) == 0, "領主絕境(food_days<DESPERATION)→先自救不投(雙 survival bound 之領主端 source-constraint)")

# ★material-delivery：invest convoy 抵村（co-located）→_tick_convoy DELIVER deposit 料入村 public_storage（非賣）。
func _test_invest_deliver_deposits() -> void:
	print("--- ★material-delivery deposit ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var vtile := HexTileData.new(); vtile.tile_pos = Vector2i(5,5); vtile.terrain = "forest"
	vtile.outpost_level = 1; vtile.outpost_owner = 9; vtile.outpost_type = "civilian"
	state.world.tiles[5005] = vtile
	var sub := TeamData.new(); sub.team_id = 30; sub.faction_id = 0; sub.parent_team_id = 1
	sub.tile_pos = Vector2i(5,5); sub.move_target = Vector2i(-1,-1)   # ★抵村
	sub.current_task = TeamData.TASK_CONVOY; sub.resources = {"material": 45.0}
	sub.task_extra_data = {"convoy_phase": "OUTBOUND", "convoy_kind": "invest", "cargo_res": "material",
		"market_pos": Vector2i(5,5), "home_pos": Vector2i(0,0)}
	state.teams[30] = sub
	var mat_before: float = float(vtile.public_storage.get("material", 0))
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._tick_convoy(state, sub, [])
	Probe.enabled = false
	var mat_after: float = float(vtile.public_storage.get("material", 0))
	_ok(mat_after >= mat_before + 44.0 and float(sub.resources.get("material",0)) < 1.0 \
			and String(sub.task_extra_data.get("convoy_phase")) == "RETURN",
		"invest convoy 抵村→料入村 public_storage %.0f→%.0f(deposit 非賣)+porter 卸空+轉 RETURN(reuse convoy 生命週期)" % [mat_before, mat_after])

# ★★★全 advance_tick pipeline（驗執行端、非 hand-step）：lord(有料)+森村欠糧無 farming holding
#   → 領主 facility_roi>0 送料 convoy → 料 deposit 入村公庫 → 村端 _pick_facility(飢餓 urgency)選 farming
#   → _can_afford(公庫有料)過 → build 真 fire → farming_level 0→1（reviewer ⑥ 硬要求:走真 precondition gate）。
func _test_invest_full_pipeline() -> void:
	print("--- ★★★全 pipeline 料到村真蓋 ---")
	seed(4242)
	var config: Dictionary = {
		"seed": 4242, "mode": "explicit", "max_ticks": 50000,
		"map": {"radius": 20, "resource_richness": 5},
		"teams": [
			{"id": 0, "name": "Lord", "tile_pos": [14,14], "population": 16, "tags": ["統領","生產"],
				"faction_id": 1, "is_faction_leader": true, "anon_tiers": {"平民": 14},
				"resources": {"food": 5000.0, "coin": 200.0, "material": 500.0},
				"leader": {"name": "L", "skills": {"統領": 0.7}, "values": {"統領": 0.7, "義氣": 0.7, "求生欲": 0.6, "野心": 0.2}},
				"outpost": {"type": "civilian", "level": 1, "terrain": "plains", "tile_food_init": 5000}},
			{"id": 1, "name": "Village", "tile_pos": [15,14], "population": 3, "tags": ["生產"],
				"faction_id": 1, "is_faction_leader": false, "anon_tiers": {"平民": 2},
				"resources": {"food": 12.0},
				"leader": {"name": "V", "skills": {"生產": 0.4}, "values": {"求生欲": 0.7}},
				"outpost": {"type": "civilian", "level": 1, "terrain": "forest", "tile_food_init": 2}},
		],
	}
	var state := WorldState.new()
	var runner := SimRunner.new()
	GameSetup.setup(state, config)
	# 確保領主對村有 belief pop_est（同 faction 創世 discovery；補記保 invest 早 fire）
	if state.teams.has(0) and state.teams.has(1):
		BeliefSystem.record_claim(state, 0, 1, 0, "親見", {"tile_pos": state.teams[1].tile_pos, "population_est": 3}, 1.0, false)
	var vtile0: HexTileData = state.world.tiles.get(15 * 1000 + 14)
	var farm0: int = int(vtile0.farming_level) if vtile0 != null else -1
	Probe.reset(); Probe.enabled = true
	var anchor: Vector2i = (state.teams[0] as TeamData).tile_pos   # anchor=lord tile（teams near→info_dispatch 收到）
	for _t in range(600):
		runner.advance_tick(state, anchor)
	Probe.enabled = false
	var disp: int = int(Probe.counts.get("invest.dispatched", 0))
	var delivered: float = float(Probe.amounts.get("invest.material_delivered", 0.0))
	var built: int = int(Probe.counts.get("village.build_fired", 0))
	var vtile1: HexTileData = state.world.tiles.get(15 * 1000 + 14)
	var farm1: int = int(vtile1.farming_level) if vtile1 != null else -1
	# ★真路徑（reviewer ⑥）：dispatched(決策)+material_delivered(料到村公庫)+build_fired(村端真 precondition gate 過)+farming 0→1(facility 真升)。
	_ok(disp > 0 and delivered > 0.0 and built > 0 and farm1 > farm0,
		"★全 pipeline：dispatched=%d + 料到村 %.0f + build_fired=%d + farming %d→%d 真升(料到→村建設走真 _can_afford gate 真蓋、非 hand-step)" % [disp, delivered, built, farm0, farm1])
