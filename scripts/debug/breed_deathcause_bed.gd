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
var _survivor_snapshots: Dictionary = {}   # day(60/90) → Array[{team_id,pop,famine_days,food_flow_avg}]
var _ever_zero_famine: Dictionary = {}     # team_id → bool（famine_days 是否曾經在任一日快照歸零＝真正止過血）
# ★systems訂正票(2026-08-21 URGENT-wrong-metric+correction-not-a-bug)：food_flow_avg判『該不該成長』(刻意保守)非
# 『還在不在流血』——後者要用effective_food(真實庫存)。加：逐日effective_food全history+knife-edge偵測(高峰後崩到近零算1次)。
var _ef_hist: Dictionary = {}              # tid → Array[{day,ef}]（不bound，全程存，供knife-edge/day60→90對照）
var _ef_was_high: Dictionary = {}          # tid → bool（曾超過KNIFE_HIGH，供偵測下一次崩到近零算1次knife-edge cycle）
var _knife_cycles: Dictionary = {}         # tid → int（knife-edge週期次數）
const KNIFE_HIGH: float = 50.0
const KNIFE_LOW: float = 5.0

func _median_f(a: Array) -> float:
	if a.is_empty(): return 0.0
	var b: Array = a.duplicate(); b.sort()
	var n: int = b.size()
	return float(b[n / 2]) if n % 2 == 1 else (float(b[n / 2 - 1]) + float(b[n / 2])) / 2.0

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
				if t.famine_days <= 0.001: _ever_zero_famine[tid] = true
				var ef: float = ResourceSystem.effective_food(state, t)
				var efh: Array = _ef_hist.get(tid, [])
				efh.append({"day": day, "ef": ef})
				_ef_hist[tid] = efh
				if ef >= KNIFE_HIGH: _ef_was_high[tid] = true
				elif ef <= KNIFE_LOW and bool(_ef_was_high.get(tid, false)):
					_knife_cycles[tid] = int(_knife_cycles.get(tid, 0)) + 1
					_ef_was_high[tid] = false
				var prev: int = int(_last_pop.get(tid, t.population))
				if prev >= 2 and t.population <= 1 and _collapse_log.size() < 4:
					_collapse_log.append({"team_id": tid, "day": day, "tick": tick + 1,
						"tags": t.tags.duplicate(), "task": t.current_task, "famine_days": t.famine_days,
						"food_flow_avg": t.food_flow_avg, "named_n": t.named_members.size(),
						"minor_before": t.minor_population,
						"trail": (h as Array).duplicate(true)})
				_last_pop[tid] = t.population
			if day == 60 or day == 90:
				var snap: Array = []
				for tid2 in state.teams:
					var t2: TeamData = state.teams[tid2]
					if t2.beast_kind != "" or t2.parent_team_id != -1: continue
					snap.append({"team_id": tid2, "pop": t2.population,
						"famine_days": t2.famine_days, "food_flow_avg": t2.food_flow_avg})
				_survivor_snapshots[day] = snap
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
	lines.append("  ★★存活隊 effective_food(真實庫存)趨勢 day60→90(中位數+正成長佔比)：")
	var ef60: Dictionary = {}; var ef90: Dictionary = {}
	for tid3 in _ef_hist:
		for e in (_ef_hist[tid3] as Array):
			if int(e["day"]) == 60: ef60[tid3] = float(e["ef"])
			if int(e["day"]) == 90: ef90[tid3] = float(e["ef"])
	var deltas: Array = []
	var growth_pos: int = 0
	var n_both: int = 0
	for tid3 in ef90:
		if not ef60.has(tid3): continue
		n_both += 1
		var d: float = float(ef90[tid3]) - float(ef60[tid3])
		deltas.append(d)
		if d > 0.0: growth_pos += 1
	lines.append("    n(day60且day90都存活)=%d 中位Δeffective_food=%.2f 正成長佔比=%d/%d(%.0f%%)" % [
		n_both, _median_f(deltas), growth_pos, n_both, (100.0 * growth_pos / maxf(n_both, 1))])
	for tid3 in ef90:
		if not ef60.has(tid3): continue
		lines.append("      team=%d ef(day60)=%.1f ef(day90)=%.1f Δ=%.1f knife_cycles=%d" % [
			int(tid3), float(ef60[tid3]), float(ef90[tid3]), float(ef90[tid3]) - float(ef60[tid3]),
			int(_knife_cycles.get(tid3, 0))])
	lines.append("  ★★knife-edge(高峰>=%.0f後崩到<=%.0f算1次週期)週期數統計：" % [KNIFE_HIGH, KNIFE_LOW])
	var knife_teams: Array = []
	for tid3 in _knife_cycles:
		if int(_knife_cycles[tid3]) > 0: knife_teams.append([tid3, _knife_cycles[tid3]])
	lines.append("    有knife-edge週期的隊數=%d/%d：%s" % [knife_teams.size(), _ef_hist.size(), str(knife_teams)])
	lines.append("  ★★地形/可及資源快照(存活隊,day90當下state)：")
	for tid3 in state.teams:
		var t3: TeamData = state.teams[tid3]
		if t3.beast_kind != "" or t3.parent_team_id != -1: continue
		var terrain_s: String = "?"
		var tile_food: float = -1.0
		var tile_cap: float = -1.0
		for tid_key in state.world.tiles:
			var tt: HexTileData = state.world.tiles[tid_key]
			if tt.tile_pos == t3.tile_pos:
				terrain_s = tt.terrain
				tile_food = float(tt.resources.get("food", 0))
				tile_cap = float(tt.resource_cap.get("food", -1))
				break
		var g2: HexTileData = ResourceSystem.own_granary_tile(state, t3)
		var granary_food: float = float(g2.public_storage.get("food", 0)) if g2 != null else -1.0
		lines.append("    team=%d pos=%s terrain=%s tile_food=%.1f tile_food_cap=%.1f granary_food=%s coin=%.0f" % [
			int(tid3), str(t3.tile_pos), terrain_s, tile_food, tile_cap,
			(str(granary_food) if g2 != null else "無自家糧倉"), float(t3.resources.get("coin", 0))])
	lines.append("  ★★存活隊 food_flow_avg 分佈(day60/90，含famine_days是否曾歸零)：")
	for sday in [60, 90]:
		if not _survivor_snapshots.has(sday): continue
		var rows2: Array = _survivor_snapshots[sday]
		var flows: Array = []
		var pos_n: int = 0
		var zero_n: int = 0
		for r2 in rows2:
			flows.append(float(r2["food_flow_avg"]))
			if float(r2["food_flow_avg"]) > 0.0: pos_n += 1
			if bool(_ever_zero_famine.get(int(r2["team_id"]), false)): zero_n += 1
		lines.append("    day=%d n=%d 中位food_flow_avg=%.3f 正值佔比=%d/%d(%.0f%%) famine曾歸零=%d/%d(%.0f%%)" % [
			sday, rows2.size(), _median_f(flows), pos_n, rows2.size(),
			(100.0 * pos_n / maxf(rows2.size(), 1)), zero_n, rows2.size(),
			(100.0 * zero_n / maxf(rows2.size(), 1))])
		for r2 in rows2:
			lines.append("      team=%d pop=%d famine_days=%.2f food_flow_avg=%.3f ever_zero_famine=%s" % [
				int(r2["team_id"]), int(r2["pop"]), float(r2["famine_days"]), float(r2["food_flow_avg"]),
				str(_ever_zero_famine.get(int(r2["team_id"]), false))])
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
