extends SceneTree

# 復甦路徑 Slice R3 TDD（spec 2026-08-06-recovery-path-HOW §2C/§3）。
# 遷村令：relocate_value(邊際前景−沉沒) + 領主令(letter)/村自願遷 + ★★村遷村執行端(compound:棄據點→mobile→抵→establish) + 從抗人格秤。
# 守零 god-view(relocate_value belief est)/零死常數(從抗/relocate util 真值)/真成本(棄據點沉沒+路程)。

var _fail: int = 0

func _initialize() -> void:
	_test_relocate_value_three_state()   # ①relocate_value 三態:爛地村→好地大正遷 / 好地村→爛地負不遷 / 原地沉沒不遷
	_test_relocate_value_pure()          # ★god-view 結構防線:relocate_value 純 est(不同→不同、無 state)
	_test_begin_relocate_abandons()      # ★_begin_village_relocate:棄據點 set_owner(-1)+TASK_MIGRATE reason=relocate+move_target
	_test_relocate_order_letter()        # ★領主下遷村令:爛地 holding 村+有更優已知領土→_try_relocate_order dispatch relocate letter
	_test_order_god_view_clean()         # ★fix:領主令領主自己視角(不讀村戀土 god-view)→傲村(會抗命)照令=兩層對抗 alive
	_test_order_passive_lord_no()        # ★anti-crank:放任領主→不下令(genuine 領主分化非被迫)
	_test_comply_resist()                # ★從抗人格秤:忠village→從+帶怨 unrest / 傲village→抗命(genuine 人格非死門檻)
	_test_self_relocate()                # ★村自願遷:村秤自身 relocate_value>閾→自發遷
	_test_relocate_full_pipeline()       # ★★★全 advance_tick pipeline:村棄爛地→travel→抵空好地→establish 落腳(真完成遷、非只決策)
	_test_relocate_natural_pipeline()    # ★★★自然觸發:advance_tick 中決策層(領主令/自願)真觸發→執行完成(②驗執行端、非 hand-call)
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# ① relocate_value 三態（純、REGEN 主導、零 if-terrain）。
func _test_relocate_value_three_state() -> void:
	print("--- ①relocate_value 三態 ---")
	var mtn := VillageEstimate.make("mountain", 1, 0, 5)   # 爛地 current（REGEN0.5、永赤字）
	var pln := VillageEstimate.make("plains", 1, 0, 5)      # 好地（REGEN8）
	var v_bad_to_good := MarginalEconomy.relocate_value(mtn, pln, 1.0)   # 爛→好、沉沒小 → 大正
	var v_good_to_bad := MarginalEconomy.relocate_value(pln, mtn, 1.0)   # 好→爛 → 負
	var v_stay := MarginalEconomy.relocate_value(pln, pln, 1.0)          # 原地(same)−沉沒 → 負
	_ok(v_bad_to_good > 0.0 and v_good_to_bad < 0.0 and v_stay < 0.0,
		"爛地→好地 %.1f>0(遷) / 好地→爛地 %.1f<0(不遷) / 原地-沉沒 %.1f<0(不遷)＝三態(REGEN 主導、零 if-terrain)" % [v_bad_to_good, v_good_to_bad, v_stay])

# ★god-view 結構防線：relocate_value 純 est（不同 est→不同、簽名不吃 state）。
func _test_relocate_value_pure() -> void:
	print("--- ★god-view:relocate_value 純函式 ---")
	var a := VillageEstimate.make("mountain", 1, 0, 5)
	var b := VillageEstimate.make("plains", 1, 0, 5)
	var c := VillageEstimate.make("forest", 1, 0, 5)
	var rab := MarginalEconomy.relocate_value(a, b, 0.0)
	var rac := MarginalEconomy.relocate_value(a, c, 0.0)
	_ok(rab != rac and rab > rac, "relocate_value 純 est(→plains %.1f > →forest %.1f、跟 target est)＝簽名不吃 state(結構防線)" % [rab, rac])

# ★_begin_village_relocate：棄據點(set_owner -1)+轉 TASK_MIGRATE reason=relocate+move_target=target。
func _test_begin_relocate_abandons() -> void:
	print("--- ★_begin_village_relocate 棄據點 ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var v := TeamData.new(); v.team_id = 9; v.faction_id = 0; v.tile_pos = Vector2i(5,5)
	AnonCohort.add(v.anon_cohorts, "平民", "healthy", 5)
	var ll := PersonData.new(); ll.id = 91; ll.values = {"求生欲": 0.6}; state.persons[91] = ll; v.leader_id = 91
	state.add_tag(v, TeamData.TAG_PRODUCE, "test")
	state.teams[9] = v
	var t := HexTileData.new(); t.tile_pos = Vector2i(5,5); t.terrain = "mountain"; t.outpost_level = 1; t.outpost_owner = 9; t.outpost_type = "civilian"
	state.world.tiles[5005] = t
	Probe.reset(); Probe.enabled = true
	var ok: bool = FactionAISystem.new()._begin_village_relocate(state, v, Vector2i(8,8))
	Probe.enabled = false
	_ok(ok and t.outpost_owner == -1 and v.current_task == TeamData.TASK_MIGRATE and v.task_reason == "relocate" and v.move_target == Vector2i(8,8),
		"_begin_relocate:棄據點 owner→-1 + TASK_MIGRATE reason=relocate + move_target=(8,8)(mobile 隨隊、真成本沉沒)")

# 建 lord(faction leader)+爛地 holding 村(mountain)+更優已知領土(plains own outpost)。lord/村人格依參。
func _mk_lord_relocate(lord_vals: Dictionary = {"慎重": 0.5, "義氣": 0.6, "野心": 0.5}, village_vals: Dictionary = {"義氣": 0.7, "野心": 0.2}) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(0,0)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 10)
	var ll := PersonData.new(); ll.id = 11; ll.values = lord_vals; state.persons[11] = ll; lord.leader_id = 11
	lord.dispatch_ledger.append({"kind": "holding", "subject_ref": 9, "is_team": true,
		"dispatched_tick": state.world.current_tick, "expected_return_tick": state.world.current_tick + 1000,
		"last_known_pos": Vector2i(5,5), "resolved": false})
	state.teams[1] = lord
	# 爛地 mountain 村（遷主）
	var v := TeamData.new(); v.team_id = 9; v.faction_id = 0; v.tile_pos = Vector2i(5,5)
	AnonCohort.add(v.anon_cohorts, "平民", "healthy", 5)
	var vl := PersonData.new(); vl.id = 91; vl.values = village_vals; state.persons[91] = vl; v.leader_id = 91
	state.add_tag(v, TeamData.TAG_PRODUCE, "test"); state.teams[9] = v
	var vt := HexTileData.new(); vt.tile_pos = Vector2i(5,5); vt.terrain = "mountain"; vt.outpost_level = 1; vt.outpost_owner = 9; vt.outpost_type = "civilian"
	state.world.tiles[5005] = vt
	# 更優 plains own-faction outpost（遷往地；team 8 佔）
	var g := TeamData.new(); g.team_id = 8; g.faction_id = 0; g.tile_pos = Vector2i(6,6); state.teams[8] = g
	var gt := HexTileData.new(); gt.tile_pos = Vector2i(6,6); gt.terrain = "plains"; gt.outpost_level = 1; gt.outpost_owner = 8; gt.outpost_type = "civilian"
	state.world.tiles[6006] = gt
	BeliefSystem.record_claim(state, 1, 9, 1, "親見", {"tile_pos": Vector2i(5,5), "population_est": 5}, 1.0, false)
	return [state, lord, v]

func _test_relocate_order_letter() -> void:
	print("--- ★領主下遷村令 ---")
	var a := _mk_lord_relocate()
	var state: WorldState = a[0]
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._try_relocate_order(state, a[1])
	Probe.enabled = false
	var ordered: int = int(Probe.counts.get("relocate.ordered", 0))
	var has_letter: bool = false
	for l in state.in_transit_letters:
		if String(l.get("kind","")) == "relocate" and int(l.get("target_lord_id",-1)) == 9 and l.get("relocate_to") == Vector2i(6,6):
			has_letter = true
	_ok(ordered == 1 and has_letter, "領主 relocate_value>閾→下遷村令 letter(kind=relocate、target 村9、遷往已知領土 plains(6,6)、真送達非瞬間)")

# ★fix god-view clean + 兩層對抗：領主令用領主自己視角(economics+領主人格)、不讀村戀土 → 傲村(會抗命)領主照樣下令。
func _test_order_god_view_clean() -> void:
	print("--- ★領主令 god-view clean(不讀村戀土) ---")
	# 傲村(野心0.9 慎重0.8=高戀土會抗命)——舊 code 用村 persist 會少令、fix 後領主自己視角照令。
	var a := _mk_lord_relocate({"慎重": 0.6, "義氣": 0.6, "野心": 0.5}, {"義氣": 0.2, "野心": 0.9, "慎重": 0.8, "好戰": 0.8})
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._try_relocate_order(a[0], a[1])
	Probe.enabled = false
	_ok(int(Probe.counts.get("relocate.ordered",0)) == 1, "傲村(高戀土會抗命)領主照樣下令(領主自己視角 economics、不讀村內在戀土=god-view 清、兩層對抗 alive)")

# ★anti-crank：放任領主(低慎重/義氣/野心)→lord_pmult 低→order_util<閾→不下令(genuine 領主分化、非被迫全序)。
func _test_order_passive_lord_no() -> void:
	print("--- ★anti-crank 放任領主不下令 ---")
	var a := _mk_lord_relocate({"慎重": 0.05, "義氣": 0.05, "野心": 0.05}, {"義氣": 0.7, "野心": 0.2})
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._try_relocate_order(a[0], a[1])
	Probe.enabled = false
	_ok(int(Probe.counts.get("relocate.ordered",0)) == 0, "放任領主(低人格)→lord_pmult 低→不下令(genuine 領主分化=被動領主不下、非被迫全序)")

# ★從抗人格秤：忠村(義氣 high 野心 low)→從+帶怨；傲村(野心 high)→抗命。genuine 人格非死門檻。
func _test_comply_resist() -> void:
	print("--- ★從抗人格秤 ---")
	# 忠村 → 從
	var s1 := WorldState.new(); s1.world = WorldData.new(); s1.world.current_tick = 100000
	var v1 := TeamData.new(); v1.team_id = 9; v1.faction_id = 0; v1.tile_pos = Vector2i(5,5)
	AnonCohort.add(v1.anon_cohorts, "平民", "healthy", 5)
	var l1 := PersonData.new(); l1.id = 91; l1.values = {"義氣": 0.9, "野心": 0.1, "好戰": 0.2, "慎重": 0.2}; s1.persons[91] = l1; v1.leader_id = 91
	s1.add_tag(v1, TeamData.TAG_PRODUCE, "test"); s1.teams[9] = v1
	var t1 := HexTileData.new(); t1.tile_pos = Vector2i(5,5); t1.terrain = "mountain"; t1.outpost_level = 1; t1.outpost_owner = 9; t1.outpost_type = "civilian"
	s1.world.tiles[5005] = t1
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._deliver_relocate_order(s1, {"target_lord_id": 9, "relocate_to": Vector2i(8,8)})
	Probe.enabled = false
	var complied: bool = int(Probe.counts.get("relocate.comply",0)) == 1 and v1.task_reason == "relocate" and int(Probe.counts.get("relocate.unrest_added",0)) == 1
	# 傲村 → 抗
	var s2 := WorldState.new(); s2.world = WorldData.new(); s2.world.current_tick = 100000
	var v2 := TeamData.new(); v2.team_id = 9; v2.faction_id = 0; v2.tile_pos = Vector2i(5,5)
	AnonCohort.add(v2.anon_cohorts, "平民", "healthy", 5)
	var l2 := PersonData.new(); l2.id = 92; l2.values = {"義氣": 0.2, "野心": 0.9, "好戰": 0.8, "慎重": 0.8}; s2.persons[92] = l2; v2.leader_id = 92
	s2.add_tag(v2, TeamData.TAG_PRODUCE, "test"); s2.teams[9] = v2
	var t2 := HexTileData.new(); t2.tile_pos = Vector2i(5,5); t2.terrain = "mountain"; t2.outpost_level = 1; t2.outpost_owner = 9; t2.outpost_type = "civilian"
	s2.world.tiles[5005] = t2
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._deliver_relocate_order(s2, {"target_lord_id": 9, "relocate_to": Vector2i(8,8)})
	Probe.enabled = false
	var resisted: bool = int(Probe.counts.get("relocate.resist",0)) == 1 and v2.task_reason != "relocate"
	_ok(complied and resisted, "忠村(義氣0.9)→從令遷+帶怨 unrest / 傲村(野心0.9戀土)→抗命不遷(genuine 人格秤、非死門檻)")

func _test_self_relocate() -> void:
	print("--- ★村自願遷 ---")
	var a := _mk_lord_relocate()
	var state: WorldState = a[0]; var v: TeamData = a[2]
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._try_self_relocate(state, v)
	Probe.enabled = false
	_ok(int(Probe.counts.get("relocate.self",0)) == 1 and v.task_reason == "relocate" and v.move_target == Vector2i(6,6),
		"爛地村秤自身 relocate_value>閾→自發遷向已知更優領土 plains(6,6)(村自主、非領主令)")

# ★★★全 advance_tick pipeline（驗執行端、非只決策 fire）：mountain 村棄爛地→travel→抵空 plains 地→establish 落腳。
func _test_relocate_full_pipeline() -> void:
	print("--- ★★★全 pipeline 村真完成遷 ---")
	seed(4242)
	var config: Dictionary = {
		"seed": 4242, "mode": "explicit", "max_ticks": 50000,
		"map": {"radius": 20, "resource_richness": 5},
		"teams": [
			{"id": 0, "name": "Lord", "tile_pos": [14,14], "population": 16, "tags": ["統領","生產"],
				"faction_id": 1, "is_faction_leader": true, "anon_tiers": {"平民": 14},
				"resources": {"food": 5000.0, "coin": 200.0},
				"leader": {"name": "L", "skills": {"統領": 0.7}, "values": {"統領": 0.7, "義氣": 0.7, "求生欲": 0.6}},
				"outpost": {"type": "civilian", "level": 1, "terrain": "plains", "tile_food_init": 5000}},
			{"id": 1, "name": "MtnVillage", "tile_pos": [16,14], "population": 5, "tags": ["生產"],
				"faction_id": 1, "is_faction_leader": false, "anon_tiers": {"平民": 4},
				"resources": {"food": 200.0},
				"leader": {"name": "V", "skills": {"生產": 0.4}, "values": {"求生欲": 0.7}},
				"outpost": {"type": "civilian", "level": 1, "terrain": "mountain", "tile_food_init": 200}},
		],
	}
	var state := WorldState.new()
	var runner := SimRunner.new()
	GameSetup.setup(state, config)
	var v: TeamData = state.teams[1]
	var origin_tile: HexTileData = state.world.tiles.get(16 * 1000 + 14)
	var target := Vector2i(18, 14)   # 空 plains 好地（establish_crude_camp founding）
	# 保 target 為空可 settle plains（world_gen 可能非 plains → 強制設）
	var tt := HexTileData.new(); tt.tile_pos = target; tt.terrain = "plains"; tt.outpost_level = 0; tt.outpost_owner = -1
	state.world.tiles[18 * 1000 + 14] = tt
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._begin_village_relocate(state, v, target)   # 觸發遷村（lord-order/self 後續 slice；此測執行端 compound）
	var anchor: Vector2i = (state.teams[0] as TeamData).tile_pos
	for _t in range(600):
		runner.advance_tick(state, anchor)
	Probe.enabled = false
	var abandoned: int = int(Probe.counts.get("relocate.abandoned", 0))
	var resettled: int = int(Probe.counts.get("relocate.resettled", 0))
	var v_now: TeamData = state.teams.get(1)
	var at_target: bool = v_now != null and v_now.tile_pos == target
	# ★S2a：establish_crude_camp 現建 L0（camp_level=1、不 set_owner）；L1 owned 據點=S2b 工期後。
	# 落腳 landing 判準改 camp_level（resettle 抵好地立 L0 營地=真完成遷；L1 領土宣稱 S2b 恢復）。
	var new_camp: bool = tt.camp_level == 1
	_ok(abandoned > 0 and resettled > 0 and at_target and new_camp and origin_tile.outpost_owner == -1,
		"★全 pipeline：棄爛地(abandoned=%d、原 owner→-1)→travel 抵好地(at_target=%s)→establish 落腳 L0(resettled=%d、camp_level=1)＝真完成遷(非只決策 fire；L1=S2b)" % [abandoned, str(at_target), resettled])

# ★★★自然觸發全 pipeline（②驗執行端、非 hand-call _begin）：advance_tick 中決策層(領主令/村自願)真觸發遷村→執行完成。
func _test_relocate_natural_pipeline() -> void:
	print("--- ★★★自然觸發全 pipeline 決策→執行 ---")
	seed(4242)
	var config: Dictionary = {
		"seed": 4242, "mode": "explicit", "max_ticks": 50000,
		"map": {"radius": 20, "resource_richness": 5},
		"teams": [
			{"id": 0, "name": "Lord", "tile_pos": [14,14], "population": 16, "tags": ["統領","生產"],
				"faction_id": 1, "is_faction_leader": true, "anon_tiers": {"平民": 14},
				"resources": {"food": 5000.0, "coin": 200.0},
				"leader": {"name": "L", "skills": {"統領": 0.7}, "values": {"統領": 0.7, "慎重": 0.7, "義氣": 0.7, "野心": 0.6, "求生欲": 0.6}},
				"outpost": {"type": "civilian", "level": 1, "terrain": "plains", "tile_food_init": 5000}},
			{"id": 1, "name": "MtnVillage", "tile_pos": [16,14], "population": 5, "tags": ["生產"],
				"faction_id": 1, "is_faction_leader": false, "anon_tiers": {"平民": 4},
				"resources": {"food": 300.0},
				"leader": {"name": "V", "skills": {"生產": 0.4}, "values": {"義氣": 0.7, "求生欲": 0.7}},
				"outpost": {"type": "civilian", "level": 1, "terrain": "mountain", "tile_food_init": 300}},
		],
	}
	var state := WorldState.new()
	var runner := SimRunner.new()
	GameSetup.setup(state, config)
	if state.teams.has(0) and state.teams.has(1):
		BeliefSystem.record_claim(state, 0, 1, 0, "親見", {"tile_pos": state.teams[1].tile_pos, "population_est": 5}, 1.0, false)
	var mtn_tile: HexTileData = state.world.tiles.get(16 * 1000 + 14)
	Probe.reset(); Probe.enabled = true
	var anchor: Vector2i = (state.teams[0] as TeamData).tile_pos
	for _t in range(700):
		runner.advance_tick(state, anchor)
	Probe.enabled = false
	var ordered: int = int(Probe.counts.get("relocate.ordered", 0))
	var self_r: int = int(Probe.counts.get("relocate.self", 0))
	var abandoned: int = int(Probe.counts.get("relocate.abandoned", 0))
	var resettled: int = int(Probe.counts.get("relocate.resettled", 0))
	var v_now: TeamData = state.teams.get(1)
	var left_mtn: bool = mtn_tile.outpost_owner != 1   # 棄爛地(mountain 不再屬村)
	# ★決策層(領主令 或 村自願)真觸發 → 執行真完成(棄地+落腳)＝非只決策、非 hand-call。
	_ok((ordered > 0 or self_r > 0) and abandoned > 0 and resettled > 0 and left_mtn,
		"★自然全 pipeline：決策層真觸發(ordered=%d/self=%d)→棄爛地(abandoned=%d、mtn 脫手=%s)→落腳(resettled=%d)＝advance_tick 中決策→執行真完成" % [ordered, self_r, abandoned, str(left_mtn), resettled])
