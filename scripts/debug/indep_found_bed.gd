extends SceneTree

# 獨立戰略層 bed（plan Task2 Step3）：野心獨立隊建國 → established 1→多 / CONQUER 0→小正 / 不 over-found。
# warring_states config（多獨立隊），跑數月，量：
#   - established 數隨時間（獨立能人建國 → 漲，非卡 1）
#   - 獨立隊 fid -1→正 數（建國事件，indep.found_* probe）
#   - faction 意圖 CONQUER 數（更多 established → commander-v2 征服候選）
#   - 不 over-found：建國隊數遠少於獨立隊總數（門檻稀有）
# 純量測。輕量（月數可調）。

func _initialize() -> void:
	_run(); quit()

func _established_count(state: WorldState) -> int:
	var n: int = 0
	for fid in state.factions:
		if state.factions[fid].is_established: n += 1
	return n

func _conquer_count(state: WorldState) -> int:
	var n: int = 0
	for fid in state.factions:
		var f = state.factions[fid]
		if f.intent is Dictionary and f.intent.get("type", "") == "征服": n += 1
	return n

func _indep_count(state: WorldState) -> int:
	var n: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.faction_id == -1 and t.parent_team_id == -1: n += 1
	return n

func _run() -> void:
	print("=== 獨立戰略層 bed：建國→established 1→多 / CONQUER 0→小正 / 不 over-found ===")
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty(): print("[FAIL] config"); Probe.enabled = false; return
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var indep0: int = _indep_count(state)
	var fac0: int = state.factions.size()
	var est0: int = _established_count(state)
	print("[bed] init teams=%d factions=%d established=%d 獨立隊=%d" % [
		state.teams.size(), fac0, est0, indep0])
	var months: int = 4   # 整環：建國→成 faction→爬 established（commander-v2 gate 需時間；長跑接 warring full）
	for month in range(months):
		for _t in range(240 * 30):
			runner.advance_tick(state, no_player)
			if state.encounter_active and state.encounter_tick > 800:
				runner._encounter_system.resolve_encounter_end(state, "draw")
		print("[bed] 月%d teams=%d factions=%d established=%d CONQUER意圖=%d 獨立隊=%d | found_ally=%d found_subj=%d g2.faction_found=%d" % [
			month + 1, state.teams.size(), state.factions.size(),
			_established_count(state), _conquer_count(state), _indep_count(state),
			int(Probe.counts.get("indep.found_ally", 0)),
			int(Probe.counts.get("indep.found_subjugate", 0)),
			int(Probe.counts.get("g2.faction_found", 0))])
	var found_total: int = int(Probe.counts.get("indep.found_ally", 0)) + int(Probe.counts.get("indep.found_subjugate", 0))
	print("\n[bed] === 收尾 ===")
	print("[bed] established %d→%d | CONQUER意圖=%d | 建國 dispatch 總=%d(ally=%d subj=%d) | faction %d→%d" % [
		est0, _established_count(state), _conquer_count(state), found_total,
		int(Probe.counts.get("indep.found_ally", 0)), int(Probe.counts.get("indep.found_subjugate", 0)),
		fac0, state.factions.size()])
	print("[bed] 判讀：established 漲=獨立建國通；CONQUER>0=征服候選湧現；")
	print("[bed]   建國 dispatch 總 << 獨立隊數=稀有(非建國潮 over-found)。")
	print("[bed] funnel: ambitious=%d → fail[pop=%d food=%d busy=%d nopath=%d] → path_ok=%d → dispatch=%d" % [
		int(Probe.counts.get("indep.gate_ambitious", 0)),
		int(Probe.counts.get("indep.gate_fail_pop", 0)),
		int(Probe.counts.get("indep.gate_fail_food", 0)),
		int(Probe.counts.get("indep.gate_fail_busy", 0)),
		int(Probe.counts.get("indep.gate_fail_nopath", 0)),
		int(Probe.counts.get("indep.gate_path_ok", 0)),
		found_total])
	Probe.enabled = false
	print("=== indep found bed DONE ===")
