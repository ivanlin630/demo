extends SceneTree

# 單一代表隊 3mo 逐次 task/option 決策時間軸（純觀測，SpecimenTracer 零改決策）。
# 用戶要親眼看行為連貫性（非聚合數字）：pass1 無 tracer 跑一輪找候選代表隊
# （非 owner、活到 3mo 尾、population 有起伏=經歷波折），pass2 同 seed 從頭
# 對該 team_id 開 tracer 全程記錄。

func _initialize() -> void:
	var world_seed: int = int(OS.get_environment("TRACE_SEED")) if OS.get_environment("TRACE_SEED") != "" else 1337
	var months: int = int(OS.get_environment("TRACE_MONTHS")) if OS.get_environment("TRACE_MONTHS") != "" else 3
	var cfg_path: String = OS.get_environment("TRACE_CONFIG") if OS.get_environment("TRACE_CONFIG") != "" else "res://config/default.json"
	var ticks: int = months * WorldState.TICKS_PER_MONTH

	# ── pass1：找候選代表隊（非owner、活到尾、population 有起伏）──
	seed(world_seed)
	var state1 := WorldState.new()
	var runner1 := SimRunner.new()
	var config1: Dictionary = GameSetup.load_config(cfg_path)
	config1["seed"] = world_seed
	GameSetup.setup(state1, config1)
	var pop_history: Dictionary = {}   # team_id -> Array[pop per month]
	for tid in state1.teams:
		pop_history[tid] = [state1.teams[tid].population]
	var no_player := Vector2i(-1, -1)
	for tick in range(ticks):
		runner1.advance_tick(state1, no_player)
		if state1.encounter_active and state1.encounter_tick > 800:
			runner1._encounter_system.resolve_encounter_end(state1, "draw")
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			for tid in pop_history.keys():
				if state1.teams.has(tid):
					pop_history[tid].append(state1.teams[tid].population)
				else:
					pop_history[tid].append(0)   # 死了

	var scored_candidates: Array = []
	for tid in pop_history.keys():
		if not state1.teams.has(tid): continue   # 沒活到尾
		var t: TeamData = state1.teams[tid]
		if t.faction_id != -1 and t.parent_team_id == -1:
			var f = state1.factions.get(t.faction_id)
			if f != null and f.leader_team_id == tid: continue   # skip faction owner/leader
		var hist: Array = pop_history[tid]
		var mn: float = 999999.0; var mx: float = 0.0
		for v in hist:
			mn = min(mn, float(v)); mx = max(mx, float(v))
		var swing: float = mx - mn   # 波折幅度
		var final_pop: float = float(hist[hist.size() - 1])
		# 選「有故事但存活」= 波折大(有威脅/危機經歷) + 最終存活(non-zero)優先，非純穩定也非全滅
		var story_score: float = swing + final_pop * 0.5
		scored_candidates.append({"tid": tid, "swing": swing, "score": story_score})
	scored_candidates.sort_custom(func(a, b): return a["score"] > b["score"])
	if scored_candidates.is_empty():
		print("[FAIL] 無候選代表隊（全滅或全穩定無波折）"); quit(); return

	# ── pass2：逐候選試跑（同 seed 從頭），選第一個 decision_count>0 者
	#   （純survival-override全程隊不觸 tracer capture tap，跳過另試下一位）──
	for cand in scored_candidates:
		var candidate_id: int = cand["tid"]
		seed(world_seed)
		var state2 := WorldState.new()
		var runner2 := SimRunner.new()
		var config2: Dictionary = GameSetup.load_config(cfg_path)
		config2["seed"] = world_seed
		GameSetup.setup(state2, config2)
		state2.specimen_team_ids = [candidate_id]
		SpecimenTracer.reset()
		SpecimenTracer.enabled = true
		for tick in range(ticks):
			runner2.advance_tick(state2, no_player)
			if state2.encounter_active and state2.encounter_tick > 800:
				runner2._encounter_system.resolve_encounter_end(state2, "draw")
		if SpecimenTracer.decision_count > 0:
			print("[bed] 選定代表隊 = Team%d，population 軌跡=%s（波折幅度=%.0f，decision_count=%d）" % [
				candidate_id, str(pop_history[candidate_id]), cand["swing"], SpecimenTracer.decision_count])
			SpecimenTracer.flush()
			SpecimenTracer.summary()
			SpecimenTracer.reset()
			quit()
			return
		else:
			print("[bed] Team%d decision_count=0（全程 survival-override 未觸 tracer tap）→ 跳過試下一候選" % candidate_id)
			SpecimenTracer.reset()
	print("[FAIL] 所有候選皆 decision_count=0")
	quit()
