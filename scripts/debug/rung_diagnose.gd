extends SceneTree

# rung2→3 立國卡點 measure（藍圖 2026-07-01「instrument T32 型,為何不進 rung3,別猜」）。
# rung3(STATE) target 需：food≥pop×2.4×7 + pop≥EXPAND_MIN_POP(8) + 在 faction 且 member_teams≥STATE_MIN(2) + ambition_cap≥3(野心≥0.55)。
# 立國(is_established) = 另一 gate(_update_goals)：是 faction leader + 未 est + 統領≥0.4 + 野心≥0.6 + readiness≥0.7 + members≥2。
# 量能人逐 component pass/fail，看哪個卡(rung 推進慢/faction<2/非 leader/cap...)。純量測。

func _initialize() -> void:
	_run(); quit()

func _is_capable(state: WorldState, team: TeamData) -> bool:
	var lp: PersonData = state.persons.get(team.leader_id)
	if lp == null: return false
	return float(lp.values.get("野心", 0.0)) >= 0.6 and float(lp.skills.get("統領", 0.0)) >= 0.4

func _diag(state: WorldState, tid: int) -> String:
	var t: TeamData = state.teams.get(tid)
	if t == null: return "T%d 死/併" % tid
	var lp: PersonData = state.persons.get(t.leader_id)
	var amb: float = float(lp.values.get("野心", 0.0)) if lp else 0.0
	var cmd: float = float(lp.skills.get("統領", 0.0)) if lp else 0.0
	var pop: int = t.population
	var food: float = ResourceSystem.effective_food(state, t)
	var surplus_need: float = float(pop) * 2.4 * 7.0
	var fteams: int = 0
	var is_leader: bool = false
	var est: bool = false
	if t.faction_id != -1 and state.factions.has(t.faction_id):
		var f = state.factions[t.faction_id]
		fteams = f.member_team_ids.size()
		is_leader = (f.leader_team_id == tid)
		est = f.is_established
	# rung3 target gate components
	var g_food: bool = food >= surplus_need
	var g_pop: bool = pop >= 8
	var g_fac: bool = t.faction_id != -1 and fteams >= 2
	var g_cap: bool = t.ambition_cap >= 3
	var rung3_block: String = ""
	if not g_food: rung3_block += "food(%.0f<%.0f) " % [food, surplus_need]
	if not g_pop: rung3_block += "pop(%d<8) " % pop
	if not g_fac: rung3_block += "faction(%d<2 fid=%d) " % [fteams, t.faction_id]
	if not g_cap: rung3_block += "cap(%d<3 amb=%.2f) " % [t.ambition_cap, amb]
	return "T%d rung=%d/cap=%d pop=%d food=%.0f/%.0f fac=%d(teams=%d leader=%s) est=%s | rung3_target=%s %s" % [
		tid, t.ambition_rung, t.ambition_cap, pop, food, surplus_need,
		t.faction_id, fteams, is_leader, est,
		"OK" if (g_food and g_pop and g_fac and g_cap) else "BLOCK", rung3_block]

func _run() -> void:
	print("=== rung2→3 立國卡點 measure ===")
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty(): print("[FAIL] config"); return
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var capable: Array = []
	for tid in state.teams:
		if _is_capable(state, state.teams[tid]): capable.append(tid)
	print("[rung] 能人 = %s" % str(capable))
	for month in range(10):
		for _t in range(240 * 30):
			runner.advance_tick(state, no_player)
			if state.encounter_active and state.encounter_tick > 800:
				runner._encounter_system.resolve_encounter_end(state, "draw")
		print("--- 月%d ---" % (month + 1))
		for tid in capable: print("  " + _diag(state, tid))
	print("\n[rung] 判讀:rung3_target=BLOCK 的 component 即卡點;rung<target 且 target=OK = 推進太慢;")
	print("[rung]   faction(teams<2) = 沒長出 faction 規模;非 leader = 不是立國決策者(成員不立國)。")
	print("=== rung diagnose DONE ===")
