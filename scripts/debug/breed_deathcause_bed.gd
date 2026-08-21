extends SceneTree
# ★systems票(2026-08-21 breed-verify-and-deathcause)②:同一輪報死因分佈+『掉到pop=1』隊的軌跡。
# 基於breed_anon_measure_bed.gd(gate①)擴充：加death.*/defection.*逐10日桶＋團崩潰(pop>=2→<=1)偵測+trailing history。
# 純觀測,零sim改(health_system.gd額外补的death.starve_named_hunger/bleed tap另計L3聲明,非本檔改動)。
# env：LW_CONFIG(peaceful_economy)、ADHOC_DAYS(90)、PERF_SEED(1337)、PERF_OUT、SPECIMEN_TEAM_ID/SPECIMEN_SAMPLE_N/SPECIMEN_OUT

var _team_hist: Dictionary = {}   # tid → Array[{day,pop,minor,named_n,famine_days,task,food_flow_avg,tags}]（bound 10筆）
var _last_pop: Dictionary = {}    # tid → 上次記錄的population(偵測>=2→<=1)
var _collapse_log: Array = []     # 逐筆{team_id,day,tick,tags,task,famine_days,food_flow_avg,named_n,minor_before,trail}
var _death_buckets: Array = []    # 逐10日{day, <key>: delta...}
var _last_counts: Dictionary = {}

func _initialize() -> void:
	_run(); quit()

func _snap_team(t: TeamData, day: int) -> Dictionary:
	return {"day": day, "pop": t.population, "minor": t.minor_population,
		"named_n": t.named_members.size(), "famine_days": t.famine_days,
		"task": t.current_task, "food_flow_avg": t.food_flow_avg, "tags": t.tags.duplicate()}

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 90
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== breed-deathcause 量測：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true; Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty(): print("[FAIL] config"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	SpecimenDumpHelper.setup_from_env(state)
	var pop0: int = _pop_total(state)
	var no_player := Vector2i(-1, -1)
	var DEATH_KEYS: Array = ["death.starve_minor", "death.starve_anon", "death.starve_named_hunger",
		"death.starve_named_bleed", "death.combat_pop", "death.combat_named", "death.defect_leave",
		"extinct.starve", "extinct.combat", "extinct.other", "defection.independent"]
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % WorldState.TICKS_PER_DAY == 0:
			var day: int = int((tick + 1) / WorldState.TICKS_PER_DAY)
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				if t.beast_kind != "" or t.parent_team_id != -1: continue
				var h: Array = _team_hist.get(tid, [])
				h.append(_snap_team(t, day))
				if h.size() > 10: h.pop_front()
				_team_hist[tid] = h
				var prev: int = int(_last_pop.get(tid, t.population))
				if prev >= 2 and t.population <= 1 and _collapse_log.size() < 4:
					_collapse_log.append({"team_id": tid, "day": day, "tick": tick + 1,
						"tags": t.tags.duplicate(), "task": t.current_task, "famine_days": t.famine_days,
						"food_flow_avg": t.food_flow_avg, "named_n": t.named_members.size(),
						"minor_before": t.minor_population,
						"trail": (h as Array).duplicate(true)})
				_last_pop[tid] = t.population
			if day % 10 == 0:
				var row: Dictionary = {"day": day}
				for k in DEATH_KEYS:
					var now_v: int = int(Probe.counts.get(k, 0))
					row[k] = now_v - int(_last_counts.get(k, 0))
					_last_counts[k] = now_v
				_death_buckets.append(row)
		if state.teams.is_empty():
			print("[bed] 全滅 @tick=%d" % tick); break
	var lines: Array = []
	lines.append("[%s day %d seed %d] teams=%d" % [cfg, days, sd, state.teams.size()])
	lines.append("  pop_total %d → %d｜named %d｜minors %d" % [
		pop0, _pop_total(state), state.persons.size(), _minors(state)])
	for k in ["breed.born", "breed.eligible_named", "breed.eligible_anon"]:
		lines.append("  %-24s = %d" % [k, int(Probe.counts.get(k, 0))])
	if Probe.peaks.has("breed.safety_proxy"):
		lines.append("  breed.safety_proxy(peak) = %.3f" % float(Probe.peaks["breed.safety_proxy"]))
	lines.append("  ★★死因分佈(合計,累加不分桶)：")
	for k in DEATH_KEYS:
		var tot: int = int(Probe.counts.get(k, 0))
		if tot > 0: lines.append("    %-30s = %d" % [k, tot])
	lines.append("  ★★死因逐10日桶(day, key=delta，只列非全0的桶)：")
	for row in _death_buckets:
		var nonzero: Dictionary = {}
		for k in DEATH_KEYS:
			if int(row.get(k, 0)) > 0: nonzero[k] = row[k]
		if not nonzero.is_empty():
			lines.append("    day=%3d %s" % [int(row["day"]), str(nonzero)])
	lines.append("  ★★崩潰隊(pop>=2→<=1)逐筆+trailing history(最近10日快照)：")
	for c in _collapse_log:
		lines.append("    ---- team=%d day=%d famine_days=%.1f named_n=%d minor_before=%d task=%s tags=%s ----" % [
			int(c["team_id"]), int(c["day"]), float(c["famine_days"]), int(c["named_n"]),
			int(c["minor_before"]), str(c["task"]), str(c["tags"])])
		for hh in c["trail"]:
			lines.append("      %s" % str(hh))
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null: f.store_string(text + "\n"); f.close()
	var spec_path: String = OS.get_environment("SPECIMEN_OUT")
	if spec_path != "":
		SpecimenDumpHelper.dump(state, spec_path)
	Probe.enabled = false
	print("=== breed-deathcause 量測 DONE ===")

func _pop_total(state: WorldState) -> int:
	var n: int = 0
	for tid in state.teams: n += (state.teams[tid] as TeamData).population
	return n

func _minors(state: WorldState) -> int:
	var n: int = 0
	for tid in state.teams: n += (state.teams[tid] as TeamData).minor_population
	return n
