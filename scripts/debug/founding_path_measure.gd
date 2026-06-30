extends SceneTree

# 獨立 founding 路徑可達性 measure（藍圖 2026-07-01「measure 哪條 create_faction 路徑最順 wire，別猜」）。
# 3 路徑：結盟(interaction 兩獨立聯盟)/吞併(npc_combat subjugate 戰勝)/宣告(solo 招生 member≥2)。
# 量 T32 型獨立能人(野心≥0.6+統領≥0.4+fid=-1)：鄰可結盟獨立數 / 可打贏弱鄰數(吞併) / 自身 pop(宣告基)。
# 純量測。

func _initialize() -> void:
	_run(); quit()

func _is_cap_indep(state: WorldState, t: TeamData) -> bool:
	if t.faction_id != -1: return false
	var lp: PersonData = state.persons.get(t.leader_id)
	if lp == null: return false
	return float(lp.values.get("野心", 0.0)) >= 0.6 and float(lp.skills.get("統領", 0.0)) >= 0.4

func _diag(state: WorldState, tid: int) -> String:
	var t: TeamData = state.teams.get(tid)
	if t == null: return "T%d 死/併" % tid
	var fa := FactionAISystem.new()
	# 結盟候選：discovered 中的獨立隊(fid=-1)
	var ally_cand: int = 0
	# 吞併候選：discovered 中可達 + belief 看似弱(pop<我)
	var subj_cand: int = 0
	for did in state.team_discovered.get(tid, []):
		var dt: TeamData = state.teams.get(did)
		if dt == null or did == tid: continue
		if dt.faction_id == -1: ally_cand += 1
		var snap: Dictionary = BeliefSystem.best_estimate(state, tid, did)
		var pop_est: float = float(snap.get("population_est", 999))
		if pop_est < float(t.population) and PathSystem.estimate_catch_up(state, t, did).reachable:
			subj_cand += 1
	return "T%d pop=%d 野心領袖 | 結盟候選(獨立鄰)=%d 吞併候選(弱可達)=%d 宣告基(pop)=%d discovered=%d" % [
		tid, t.population, ally_cand, subj_cand, t.population, state.team_discovered.get(tid, []).size()]

func _run() -> void:
	print("=== 獨立 founding 路徑可達性 measure ===")
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty(): print("[FAIL] config"); return
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	# 跑 2 月讓 discovered/belief 鋪開
	for _t in range(240 * 60):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
	var caps: Array = []
	for tid in state.teams:
		if _is_cap_indep(state, state.teams[tid]): caps.append(tid)
	print("[found] 獨立能人(野心≥0.6+統領≥0.4+fid=-1) = %d" % caps.size())
	for tid in caps: print("  " + _diag(state, tid))
	print("\n[found] 判讀:結盟候選>0=結盟路可走;吞併候選>0=吞併可走;pop≥若干=宣告可走。")
	print("[found]   哪路候選多=最順 wire(means-end 仍秤 viability 選,此量 grounding)。")
	print("=== founding path measure DONE ===")
