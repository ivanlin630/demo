extends SceneTree

# ② 重評頻率歸因：381次/90天(Team7 seed1337)由 _should_reeval 哪條件貢獻。
# Probe 分支計數(reeval.idle/stuck/crisis/directive/cadence)。純量測，不改邏輯。
# 也順帶記 established 數(①佐證)。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seed_val: int = 1337
	# ★同世界 specimen（blueprint 查證「第三種死法」跨世界假象 2026-07-14）：SPECIMEN_TEAM_ID 設則
	# 在**這支床產出全滅清單的同一世界**鎖該隊，讀真實 decision_count + 死因（軍備堆積餓死 vs 速死 decision_count=0）。
	var spec_id: int = int(OS.get_environment("SPECIMEN_TEAM_ID")) if OS.get_environment("SPECIMEN_TEAM_ID") != "" else -1
	print("=== reeval attribution: default.json seed=%d 3mo (specimen=%d) ===" % [seed_val, spec_id])
	Probe.enabled = true; Probe.reset()
	if spec_id != -1:
		SpecimenTracer.reset(); SpecimenTracer.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/default.json")
	if config.is_empty(): print("[FAIL] config"); return
	config["seed"] = seed_val
	GameSetup.setup(state, config)
	if spec_id != -1:
		state.specimen_team_ids = [spec_id]
	var no_player := Vector2i(-1, -1)
	var ticks: int = TimeScale.TICK_PER_DAY * 90
	# specimen 死因快照：每 tick 存最後已知狀態，消失即記死 tick + 死前家當
	var spec_last: Dictionary = {}
	var spec_death_tick: int = -1
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if spec_id != -1:
			if state.teams.has(spec_id):
				var t: TeamData = state.teams[spec_id]
				spec_last = {
					"tick": tick, "pop": t.population,
					"food": float(t.resources.get("food", 0)),
					"food_days": float(t.resources.get("food", 0)) / maxf(float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001),
					"weap": int(t.resources.get("weapon_melee_low",0)) + int(t.resources.get("weapon_melee_high",0)) + int(t.resources.get("weapon_ranged_low",0)) + int(t.resources.get("weapon_ranged_high",0)),
					"coin": float(t.resources.get("coin", 0)),
				}
			elif spec_death_tick == -1 and not spec_last.is_empty():
				spec_death_tick = tick
	# established 數
	var est: int = 0
	for fid in state.factions:
		if state.factions[fid].is_established: est += 1
	print("--- established = %d / %d factions ---" % [est, state.factions.size()])
	# reeval 分支計數
	print("--- _should_reeval 分支計數(全隊合計 %d 天) ---" % 90)
	var total: int = 0
	for k in ["reeval.idle", "reeval.stuck", "reeval.crisis", "reeval.directive", "reeval.cadence"]:
		var c: int = int(Probe.counts.get(k, 0))
		total += c
		print("  %-18s = %d" % [k, c])
	print("  %-18s = %d" % ["TOTAL true", total])
	# ★同世界 specimen 死因裁定
	if spec_id != -1:
		print("--- specimen Team%d 死因裁定（同世界）---" % spec_id)
		# ★decision_count = SpecimenTracer capture_decision tap ONLY——不含 [Order] 經濟決策路徑
		# → decision_count=0 ≠「AI 沒碰到」(tap-gap);死因看家當(weapons/food_days)+ grep [Order] 活動,非靠此數。
		print("  decision_count(SpecimenTracer tap,tap-gap警告) = %d" % SpecimenTracer.decision_count)
		print("  存活至尾 = %s；死 tick = %s" % [state.teams.has(spec_id), str(spec_death_tick)])
		if not spec_last.is_empty():
			print("  死前家當: pop=%d food=%.1f food_days=%.2f weapons=%d coin=%.0f" % [
				spec_last["pop"], spec_last["food"], spec_last["food_days"], spec_last["weap"], spec_last["coin"]])
		# 裁定看家當(非 decision_count):武器堆+糧盡=軍備餓死(tuning);無武器無錢=真赤貧;有錢無武器=別的
		if state.teams.has(spec_id):
			print("  ★裁定: 存活至尾(非死隊)")
		elif not spec_last.is_empty() and spec_last["weap"] > 5 and spec_last["food_days"] < 2.0:
			print("  ★裁定: 死前武器堆(%d)+糧盡 → 軍備堆積餓死型(層0/5 tuning,非架構絕症;★核 [Order] 確認有活躍買賣決策)" % spec_last["weap"])
		elif not spec_last.is_empty() and spec_last["coin"] < 1.0 and spec_last["weap"] <= 1:
			print("  ★裁定: 死前無錢無武器 → 真赤貧(可能本該死,非 bug)")
		else:
			print("  ★裁定: 死因非典型,見家當+grep [Order]/[Famine] 活動判(勿靠 decision_count)")
		SpecimenTracer.summary()
		SpecimenTracer.enabled = false
	Probe.enabled = false
	print("=== DONE ===")
