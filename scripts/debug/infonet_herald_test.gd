extends SceneTree

# 資訊網 S-herald TDD（spec Part 2a 求援→TASK_HERALD）。
# 求援：有未滿足 need+知施助者(belief)→派信使子隊送 need 訊到施助者 team_known（修症1 領主學不到子民餓）。
# 守：applicable=need/knowledge-based 非死常數；util genuine(真 severity)+人格 MODULATE（傲vs務實分化）；感知鐵律(belief-pos)。

var _fail: int = 0

func _initialize() -> void:
	_test_ctx_help_fields()          # ①needy+知領主 belief→help_target/severity 設
	_test_util_pride_vs_pragmatic()  # ②genuine+人格:務實(求生欲)>傲(野心) 求援傾向分化
	_test_applicable_need_knowledge() # ③applicable=need+knowledge、非死常數;無對象/不需/子隊→false
	_test_deposit_need_to_helper()   # ④信使抵達 deposit 母隊食糧買單→施助者 team_known(症1 通例解)
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# ① ctx gather：needy resident(faction 0，非領主) + 領主 belief-pos 已知 → help_target_id=領主、severity>0。
func _test_ctx_help_fields() -> void:
	print("--- ①ctx help fields ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5,5); tile.terrain = "plains"
	tile.outpost_type = "civilian"; tile.outpost_level = 1; tile.outpost_owner = 2
	state.world.tiles[5*1000+5] = tile
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	# 領主 team1（在(9,9)）
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(9,9)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 20); state.teams[1] = lord
	# needy resident team2（food=0 瀕死）
	var r := TeamData.new(); r.team_id = 2; r.faction_id = 0; r.tile_pos = Vector2i(5,5)
	r.tags = [TeamData.TAG_PRODUCE]; AnonCohort.add(r.anon_cohorts, "平民", "healthy", 10)
	r.resources = {"food": 0.0}
	var lr := PersonData.new(); lr.id = 12; lr.values = {"求生欲": 0.6, "野心": 0.3, "義氣": 0.6}; state.persons[12] = lr; r.leader_id = 12
	state.teams[2] = r
	# resident 對領主的 belief-pos（親見 (9,9)）→ best_estimate 有 tile_pos
	BeliefSystem.record_claim(state, 2, 1, 2, "親見", {"tile_pos": Vector2i(9,9)}, 1.0, false)
	var ctx: DecisionContext = DecisionContext.gather(state, r)
	_ok(ctx.help_target_id == 1 and ctx.help_need_severity > 0.0 and ctx.help_target_pos == Vector2i(9,9),
		"needy+知領主 belief → help_target_id=1 severity=%.2f pos=%s" % [ctx.help_need_severity, str(ctx.help_target_pos)])

# ② genuine+人格 MODULATE：同 severity，務實(高求生欲低野心)求援傾向 > 傲(高野心低求生欲)。
func _test_util_pride_vs_pragmatic() -> void:
	print("--- ②util 傲vs務實分化 ---")
	var prag := DecisionContext.new(); prag.help_need_severity = 0.8
	prag.leader_values = {"求生欲": 1.0, "野心": 0.0, "義氣": 0.6}
	var proud := DecisionContext.new(); proud.help_need_severity = 0.8
	proud.leader_values = {"求生欲": 0.0, "野心": 1.0, "義氣": 0.6}
	var u_prag: float = DecisionTerms.eval("help_drive", prag, "求援")
	var u_proud: float = DecisionTerms.eval("help_drive", proud, "求援")
	_ok(u_prag > u_proud + 1e-6 and u_proud >= 0.0, "務實 help util %.3f > 傲 %.3f（人格真分化、base=真 severity 非 crank）" % [u_prag, u_proud])
	# opt≠求援 → 0（guardrail）
	_ok(DecisionTerms.eval("help_drive", prag, "建設") == 0.0, "help_drive 只加求援（其他 opt=0）")

# ③ applicable=need+knowledge-based（非死常數）。
func _test_applicable_need_knowledge() -> void:
	print("--- ③applicable need+knowledge ---")
	var appl: Callable = DecisionOptions.REGISTRY["求援"]["applicable"]
	var c1 := DecisionContext.new(); c1.is_subteam = false; c1.help_target_id = 1; c1.help_need_severity = 0.5
	_ok(appl.call(c1), "needy+知施助者 → applicable")
	var c2 := DecisionContext.new(); c2.is_subteam = false; c2.help_target_id = -1; c2.help_need_severity = 0.5
	_ok(not appl.call(c2), "不知施助者 → not applicable（無對象）")
	var c3 := DecisionContext.new(); c3.is_subteam = false; c3.help_target_id = 1; c3.help_need_severity = 0.0
	_ok(not appl.call(c3), "不缺（severity 0）→ not applicable（need-gated）")
	var c4 := DecisionContext.new(); c4.is_subteam = true; c4.help_target_id = 1; c4.help_need_severity = 0.5
	_ok(not appl.call(c4), "子隊 → not applicable（母團處理）")

# ④ _deposit_help_need：origin 有食糧買單 → 信使 deposit 進施助者 team_known（received_buy_orders 得見）。
func _test_deposit_need_to_helper() -> void:
	print("--- ④deposit need 到施助者 ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var origin := TeamData.new(); origin.team_id = 2; origin.faction_id = 0
	origin.active_orders = [{"order_id": 700, "kind": "buy", "res": "food", "qty_remaining": 50, "expire_tick": 99999}]
	origin.tile_pos = Vector2i(5,5); state.teams[2] = origin
	var helper := TeamData.new(); helper.team_id = 1; helper.faction_id = 0; helper.tile_pos = Vector2i(9,9); state.teams[1] = helper
	FactionAISystem.new()._deposit_help_need(state, 2, helper)
	var got: int = 0
	for m in state.team_known.get(1, []):
		if m.type == "order_buy" and String(m.params.get("res","")) == "food" and int(m.params.get("origin_team",-1)) == 2: got += 1
	_ok(got == 1, "信使 deposit origin food 買單 → 施助者 team_known（got %d）=領主學到子民 need（症1 通例解）" % got)
