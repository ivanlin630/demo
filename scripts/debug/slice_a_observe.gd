extends SceneTree

# Slice A 觀測（非 gate）：① 層0 boost 觸發頻率(健康指標,measurer 要) ② Fix3c coinless+武器 barter 真 fire。

func _initialize() -> void:
	_observe_layer0_boost_freq()
	_observe_fix3c_barter()
	print("=== DONE ===")
	quit()

func _observe_layer0_boost_freq() -> void:
	print("=== 層0 boost 觸發頻率 (seed1337 default 3mo) ===")
	Probe.enabled = true; Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/default.json")
	if config.is_empty(): print("[FAIL] config"); return
	config["seed"] = 1337
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = TimeScale.TICK_PER_DAY * 90
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
	var boost: int = int(Probe.counts.get("survival.boost_fire", 0))
	var coeff_n: int = int(Probe.counts.get("decision.coeff_applied_n", 0))
	print("  survival.boost_fire = %d （分母 decision.coeff_applied_n = %d）" % [boost, coeff_n])
	print("  boost 佔決策比 = %.4f%%（健康鐵律：低=安全網有效；常觸發=安全網失職）" % \
		(100.0 * float(boost) / maxf(float(coeff_n), 1.0)))
	Probe.enabled = false

func _observe_fix3c_barter() -> void:
	print("=== Fix3c coinless+武器 has_specie + barter fire ===")
	var state := WorldState.new(); state.world = WorldData.new()
	# 武備隊：cash/ore 盡、滿手武器、糧跌破。leader 中性。
	var t := TeamData.new(); t.team_id = 0; t.leader_id = 100; t.tile_pos = Vector2i(5, 5)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 10)
	t.resources = {"food": 5.0, "coin": 0.0, "weapon_melee_low": 30.0}   # 武器遠超留底(TARGET_PER_POP 1.0×10=10)
	var ldr := PersonData.new(); ldr.id = 100; ldr.values = {"慎重": 0.5, "野心": 0.5}
	state.persons[100] = ldr; state.teams[0] = t
	var ctx: DecisionContext = DecisionContext.gather(state, t)
	print("  武備隊 has_specie = %s （Fix3c 前=false 機械餓死；後應 true）" % ctx.has_specie)
	print("  weapon reserve(10pop) = %.1f，持有 30 → 超留底 %.1f 可變現" % \
		[TradeValuation.reserve(t, "weapon_melee_low"), 30.0 - TradeValuation.reserve(t, "weapon_melee_low")])
	# barter：對手糧多缺武器
	var b := TeamData.new(); b.team_id = 1; b.leader_id = 101; b.tile_pos = Vector2i(5, 5)
	AnonCohort.add(b.anon_cohorts, "平民", "healthy", 10)
	b.resources = {"food": 500.0, "coin": 0.0}
	var ldr2 := PersonData.new(); ldr2.id = 101; ldr2.values = {"慎重": 0.5, "野心": 0.5}
	state.persons[101] = ldr2; state.teams[1] = b
	var isys := InteractionSystem.new()
	var food_before: float = float(t.resources.get("food", 0))
	var wpn_before: float = float(t.resources.get("weapon_melee_low", 0))
	isys._attempt_barter(state, t, b)
	var food_after: float = float(t.resources.get("food", 0))
	var wpn_after: float = float(t.resources.get("weapon_melee_low", 0))
	print("  barter：武備隊 food %.0f→%.0f, weapon %.0f→%.0f" % [food_before, food_after, wpn_before, wpn_after])
	print("  barter fired = %s（武器換糧成交=Fix3c 存活路徑真通）" % (food_after > food_before and wpn_after < wpn_before))
