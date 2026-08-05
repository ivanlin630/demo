extends SceneTree

# 領主主動照護 loop TDD（spec 2026-08-05-lord-care-loop-HOW）。
# ①holding ledger 持久監看(refresh-keep) ②care/ignore competing util ③★(a)firsthand 觀察 write(inline co-location、傲村不 post 也讀出缺口) ④觀察→distribute。
# 守零 god-view(holding 自我記憶/firsthand co-location 物理在場)/零死常數(人格秤)/真成本(scout)/程度界線。

var _fail: int = 0

func _initialize() -> void:
	_test_care_reaction_argmax()     # ②責任→care / 疏忽→ignore（competing util 非 if/elif）
	_test_holding_refresh_keep()     # ①holding 逾時→反應後 refresh-keep(不 resolved-drop、持久監看續留)
	_test_firsthand_proud_village()  # ★③(a) scout 抵傲村(無 post 買單)→firsthand 讀出缺口→distress belief 寫
	_test_firsthand_to_distribute()  # ④firsthand distress→_distribute_candidates fire(端到端)
	_test_firsthand_needs_colocation() # ⑤零 god-view：firsthand 只在 co-location(scout 在村)才寫、非全知
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# ② care/ignore competing util。
func _test_care_reaction_argmax() -> void:
	print("--- ②care/ignore 人格分化 ---")
	var fai := FactionAISystem.new()
	var kind_lord: String = fai._pick_care_reaction(2.0, {"義氣": 1.0, "統領": 0.5, "野心": 0.0})
	var neglect_lord: String = fai._pick_care_reaction(2.0, {"義氣": 0.0, "統領": 0.0, "野心": 1.0})
	_ok(kind_lord == "care" and neglect_lord == "ignore",
		"責任/仁厚→care(%s) / 野心疏忽→ignore(%s)＝competing util 分化(非 if/elif 死一條)" % [kind_lord, neglect_lord])

# ① holding 逾時→反應後 refresh-keep（entry 續留 ledger、非一次性 drop）。
func _test_holding_refresh_keep() -> void:
	print("--- ①holding refresh-keep ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(0,0)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 10)
	var ll := PersonData.new(); ll.id = 11; ll.values = {"義氣": 1.0, "統領": 0.5, "野心": 0.0}; state.persons[11] = ll; lord.leader_id = 11
	state.teams[1] = lord
	# holding entry（村 subject=9、久無音訊：dispatched 久前、expected 早過、無 belief→dispatch elapsed 兜底）
	lord.dispatch_ledger.append({"kind": "holding", "subject_ref": 9, "is_team": true,
		"dispatched_tick": state.world.current_tick - WorldState.TICKS_PER_DAY * 30,
		"expected_return_tick": state.world.current_tick - WorldState.TICKS_PER_DAY * 20,
		"last_known_pos": Vector2i(5,5), "resolved": false})
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._step_contact_ledger(state, lord)
	Probe.enabled = false
	var still_there: bool = false
	for e in lord.dispatch_ledger:
		if String(e.get("kind","")) == "holding" and int(e.get("subject_ref",-1)) == 9 and not bool(e.get("resolved",false)): still_there = true
	_ok(still_there and int(Probe.counts.get("contact.overdue",0)) == 1,
		"holding 逾時 fire 反應後 refresh-keep(entry 續留 ledger、非 resolved-drop、持久監看)")

# ★③ (a) firsthand：scout 抵傲村(food 低+無 post 買單)→firsthand 讀出缺口→distress 入領主 team_known。
func _test_firsthand_proud_village() -> void:
	print("--- ★③(a) firsthand 傲村 ---")
	var s: Array = _mk_scout_at_village(2.0, [])   # 村 food 低、active_orders 空(傲村不 post)
	var state: WorldState = s[0]; var scout: TeamData = s[1]
	FactionAISystem.new()._tick_info_scout(state, scout, [])
	var got: bool = false
	for m in state.team_known.get(1, []):
		if m.type == "order_buy" and int(m.params.get("origin_team",-1)) == 9 and int(m.params.get("order_id",-1)) >= 2000000000: got = true
	_ok(got, "scout 抵傲村(無 post 買單)→firsthand 讀 food 缺口→synth distress 入領主 team_known(傲村不開口也看得見)")

# ④ firsthand distress→_distribute_candidates fire（端到端）。
func _test_firsthand_to_distribute() -> void:
	print("--- ④觀察→賑濟端到端 ---")
	var s: Array = _mk_scout_at_village(2.0, [])
	var state: WorldState = s[0]; var scout: TeamData = s[1]
	FactionAISystem.new()._tick_info_scout(state, scout, [])   # firsthand write
	# 領主有餘糧 → _distribute_candidates 應讀到 firsthand distress fire
	var lord: TeamData = state.teams[1]
	ResourceBank.set_amt(lord, "food", 500.0, "t")
	var ctx: DecisionContext = DecisionContext.gather(state, lord)
	var lv: Dictionary = TradeValuation.leader_vals(state, lord)
	var cands: Array = GoalResolver._distribute_candidates(state, lord, ctx, lv)
	var fired: bool = false
	for c in cands:
		if String(c.get("label","")) == "distribute_food" and int(c["to_task"].get("terminus_team_id",-1)) == 9: fired = true
	_ok(fired, "firsthand distress→_distribute_candidates fire(terminus=傲村9)＝觀察→preemptive 賑濟端到端(reuse 既有 distribute、無新機制)")

# ⑤ 零 god-view：scout 不在村(非 co-location)→不 firsthand 讀寫。
func _test_firsthand_needs_colocation() -> void:
	print("--- ⑤零 god-view(需 co-location) ---")
	var s: Array = _mk_scout_at_village(2.0, [])
	var state: WorldState = s[0]; var scout: TeamData = s[1]
	scout.tile_pos = Vector2i(0,0)   # scout 不在村(9@ (5,5))→非 co-location
	FactionAISystem.new()._tick_info_scout(state, scout, [])
	var got: bool = false
	for m in state.team_known.get(1, []):
		if m.type == "order_buy" and int(m.params.get("order_id",-1)) >= 2000000000: got = true
	_ok(not got, "scout 非 co-location→不 firsthand 讀寫村缺口(零 god-view、物理在場才知)")

# scout(parent=領主1、target=村9 food 低)、co-located@(5,5)。village_orders=村 active_orders。
func _mk_scout_at_village(village_food: float, village_orders: Array) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(0,0)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 10); ResourceBank.set_amt(lord, "food", 500.0, "t")
	var ll := PersonData.new(); ll.id = 11; ll.values = {"義氣": 0.6, "貪婪": 0.4}; state.persons[11] = ll; lord.leader_id = 11
	state.teams[1] = lord
	var village := TeamData.new(); village.team_id = 9; village.faction_id = 0; village.tile_pos = Vector2i(5,5)
	village.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(village.anon_cohorts, "平民", "healthy", 8); village.resources = {"food": village_food}
	village.active_orders = village_orders
	state.teams[9] = village
	var vtile := HexTileData.new(); vtile.tile_pos = Vector2i(5,5); vtile.outpost_level = 1; vtile.outpost_owner = 9
	state.world.tiles[5*1000+5] = vtile
	var scout := TeamData.new(); scout.team_id = 20; scout.faction_id = 0; scout.parent_team_id = 1
	scout.tile_pos = Vector2i(5,5); scout.order_target_id = 9; scout.task_reason = "info_scout"
	scout.current_task = TeamData.TASK_SCOUT; scout.task_start_tick = state.world.current_tick
	scout.task_extra_data = {"scout_mother": 1, "timeout": 99999}
	AnonCohort.add(scout.anon_cohorts, "平民", "healthy", 1); state.teams[20] = scout
	return [state, scout]
