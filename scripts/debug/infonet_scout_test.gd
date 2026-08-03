extends SceneTree

# 資訊網 S-scout TDD（spec Part 2b 偵察→TASK_SCOUT）。
# 偵察：領主對子民 belief 陳舊 → 派斥候查、帶 fresh need 回領主 team_known（active 版症1 解）。
# 守：applicable=info-gap+在乎 非死常數；util genuine(真 staleness)+人格 MODULATE（統領↑野心↓分化）。

var _fail: int = 0

func _initialize() -> void:
	_test_util_command_vs_ambition()   # ①genuine+人格:統領(關切)>野心(疏忽) 偵察傾向
	_test_applicable_infogap()         # ②applicable=info-gap+在乎、非死常數
	_test_ctx_scout_fields()           # ③領主 gather:子民 belief 陳舊→scout_target/staleness
	_test_scout_returns_need()         # ④斥候 co-loc 子民→帶 need 回領主 team_known+刷新 belief
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# ① util genuine + 人格：同 staleness，統領(關切)高 > 野心(疏忽內政)高。
func _test_util_command_vs_ambition() -> void:
	print("--- ①util 統領vs野心分化 ---")
	var care := DecisionContext.new(); care.scout_staleness = 0.8
	care.leader_values = {"統領": 1.0, "野心": 0.0}
	var amb := DecisionContext.new(); amb.scout_staleness = 0.8
	amb.leader_values = {"統領": 0.0, "野心": 1.0}
	var u_care: float = DecisionTerms.eval("scout_drive", care, "偵察")
	var u_amb: float = DecisionTerms.eval("scout_drive", amb, "偵察")
	_ok(u_care > u_amb + 1e-6 and u_amb >= 0.0, "關切(統領)偵察 util %.3f > 野心 %.3f（人格真分化、base=真 staleness）" % [u_care, u_amb])
	_ok(DecisionTerms.eval("scout_drive", care, "建設") == 0.0, "scout_drive 只加偵察")

# ② applicable=info-gap+在乎（非死常數）。
func _test_applicable_infogap() -> void:
	print("--- ②applicable info-gap ---")
	var appl: Callable = DecisionOptions.REGISTRY["偵察"]["applicable"]
	var c1 := DecisionContext.new(); c1.is_subteam = false; c1.scout_target_id = 5; c1.scout_staleness = 0.5
	_ok(appl.call(c1), "有 info-gap+知位 → applicable")
	var c2 := DecisionContext.new(); c2.is_subteam = false; c2.scout_target_id = -1; c2.scout_staleness = 0.5
	_ok(not appl.call(c2), "無待查對象 → not applicable")
	var c3 := DecisionContext.new(); c3.is_subteam = false; c3.scout_target_id = 5; c3.scout_staleness = 0.0
	_ok(not appl.call(c3), "belief 不陳舊(staleness 0)→ not applicable")
	var c4 := DecisionContext.new(); c4.is_subteam = true; c4.scout_target_id = 5; c4.scout_staleness = 0.5
	_ok(not appl.call(c4), "子隊 → not applicable")

# ③ ctx gather：領主對子民 belief 陳舊 → scout_target 設、staleness>0。
func _test_ctx_scout_fields() -> void:
	print("--- ③ctx scout fields ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(5,5)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 20)
	var ll := PersonData.new(); ll.id = 11; ll.values = {"統領": 0.7, "野心": 0.3}; state.persons[11] = ll; lord.leader_id = 11
	state.teams[1] = lord
	var sub := TeamData.new(); sub.team_id = 2; sub.faction_id = 0; sub.tile_pos = Vector2i(8,8)
	AnonCohort.add(sub.anon_cohorts, "平民", "healthy", 10); state.teams[2] = sub
	# 領主對子民舊 belief（last_tick 遠早於 now → 陳舊）
	BeliefSystem.record_claim(state, 1, 2, 1, "轉述", {"tile_pos": Vector2i(8,8), "last_tick": 100}, 0.8, false)
	var ctx: DecisionContext = DecisionContext.gather(state, lord)
	_ok(ctx.scout_target_id == 2 and ctx.scout_staleness > 0.0, "領主 gather:子民 belief 陳舊→scout_target=2 staleness=%.2f" % ctx.scout_staleness)

# ④ 斥候 co-loc 子民 → 帶 need 回領主 team_known + 刷新 belief。
func _test_scout_returns_need() -> void:
	print("--- ④斥候帶 need 回領主 ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(5,5); state.teams[1] = lord
	var sub := TeamData.new(); sub.team_id = 2; sub.faction_id = 0; sub.tile_pos = Vector2i(8,8)
	sub.active_orders = [{"order_id": 700, "kind": "buy", "res": "food", "qty_remaining": 50, "expire_tick": 99999}]
	state.teams[2] = sub
	# 斥候子隊：mother=1、order_target=2、co-located 子民 @(8,8)
	var scout := TeamData.new(); scout.team_id = 3; scout.faction_id = 0; scout.parent_team_id = 1
	scout.current_task = TeamData.TASK_SCOUT; scout.task_reason = "info_scout"
	scout.order_target_id = 2; scout.tile_pos = Vector2i(8,8)
	scout.task_start_tick = 1000; scout.task_extra_data = {"scout_mother": 1, "timeout": 99999}
	var sl := PersonData.new(); sl.id = 33; state.persons[33] = sl; scout.leader_id = 33
	state.teams[3] = scout
	FactionAISystem.new()._tick_info_scout(state, scout, [])
	var got: int = 0
	for m in state.team_known.get(1, []):
		if m.type == "order_buy" and int(m.params.get("origin_team",-1)) == 2: got += 1
	_ok(got == 1, "斥候 co-loc 子民 → 子民 food 買單回領主 team_known（got %d）=active 症1 解" % got)
