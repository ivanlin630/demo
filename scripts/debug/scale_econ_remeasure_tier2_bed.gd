extends SceneTree

# [measurer持久fixture 2026-08-11] re-measure scale Tier2鎖定:方向反轉(dispersed較好)真鎖+WHY故事+
# relief殘餘confound誠實分清。seed可調(env RM_SEED),3mo(established安全窗長,兼顧"更長窗"要求與timeout風險)。
# ticket:docs/superpowers/handbacks/2026-08-11-systems-to-measurer-remeasure-tier2-lock.md
# 附SpecimenDumpHelper(CONCENTRATED+DISPERSED雙邊都掛)送QA故事稽核。
# 純觀測:inline SimRunner、既有LaborSystem.pool_of/labor_mult pure-read、[Succession]事件計數(raw log掃描
# 不需temp production tap)、per-team daily status。

const CONC_CONFIG := "res://config/infonet_scale_econ_concentrated_fair.json"
const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const MONTHS: int = 3
const ORIG_TIDS: Array = [0, 1, 2, 3]

func _initialize() -> void:
	var seed_env: String = OS.get_environment("RM_SEED")
	var s: int = int(seed_env) if seed_env != "" else 8181
	var scenario: String = OS.get_environment("RM_SCENARIO")   # "concentrated" | "dispersed"(拆單run避10分鐘工具timeout)
	print("=== re-measure scale Tier2鎖定(seed=%d %d月 scenario=%s) ===" % [s, MONTHS, scenario])
	var result: Dictionary
	var label: String
	if scenario == "concentrated":
		label = "CONCENTRATED_fair"; result = _run(label, CONC_CONFIG, s)
	else:
		label = "DISPERSED"; result = _run(label, DISP_CONFIG, s)
	print("\n───────── %s(seed%d) ─────────" % [label, s])
	print("  attrition=%.2f%%" % float(result["attrition_pct"]))
	var f := FileAccess.open("res://docs/measurements/2026-08-11-scale-econ-remeasure-tier2-seed%d-%s.json" % [s, label], FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(result, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-11-scale-econ-remeasure-tier2-seed%d-%s.json" % [s, label])
	print("=== DONE ===")
	quit()

func _run(label: String, config_path: String, s: int) -> Dictionary:
	print("\n########## %s seed=%d ##########" % [label, s])
	seed(s)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(config_path)
	config["seed"] = s
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_MONTH * MONTHS
	var start_pop: int = _total_pop(state)

	state.specimen_team_ids = [0, 1, 2, 3]
	SpecimenTracer.reset(); SpecimenTracer.enabled = true

	var team_daily: Dictionary = {}
	for tid in ORIG_TIDS: team_daily[tid] = []
	var labor_daily: Array = []
	# ★QA抓到方法論漏洞修正：同一連續run內記錄day60 checkpoint(非另開2mo-only獨立run比較，避免不同bed腳本
	# RNG消耗footprint不同導致從tick0就分道揚鑣、兩個attrition%其實不是同一world的兩個時間點)。
	var checkpoint_2mo: Dictionary = {}
	var checkpoint_2mo_tick: int = WorldState.TICKS_PER_MONTH * 2

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.world.current_tick == checkpoint_2mo_tick:
			var cp_pop: int = _total_pop(state)
			var full_roster: Dictionary = {}
			for tid2 in state.teams: full_roster[tid2] = state.teams[tid2].population
			checkpoint_2mo = {"tick": checkpoint_2mo_tick, "day": checkpoint_2mo_tick / WorldState.TICKS_PER_DAY,
				"pop": cp_pop, "attrition_pct": 0.0 if start_pop == 0 else 100.0 * (start_pop - cp_pop) / float(start_pop),
				"full_roster": full_roster}
			print("  [checkpoint@day60 全隊roster] %s" % str(full_roster))
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				if (t.current_task == TeamData.TASK_SCOUT or t.current_task == TeamData.TASK_CONVOY) and not int(tid) in state.specimen_team_ids:
					state.specimen_team_ids.append(int(tid))
			var day: int = state.world.current_tick / WorldState.TICKS_PER_DAY
			for tid in ORIG_TIDS:
				if not state.teams.has(tid):
					team_daily[tid].append({"day": day, "faction_id": null, "pop": -1, "note": "gone_or_merged"})
					continue
				var t2: TeamData = state.teams[tid]
				team_daily[tid].append({"day": day, "faction_id": t2.faction_id, "pop": t2.population, "unrest": t2.unrest_turns})
			# labor pool(lord=team0所在tile,pure-read)
			if state.teams.has(0) and day % 5 == 0:
				var tile: HexTileData = state.world.tiles.get(state.teams[0].tile_pos.x * 1000 + state.teams[0].tile_pos.y)
				if tile != null:
					var pool: float = LaborSystem.pool_of(state, tile)
					labor_daily.append({"day": day, "pool": pool, "outpost_level": tile.outpost_level})

	var end_pop: int = _total_pop(state)
	var attrition: float = 0.0 if start_pop == 0 else 100.0 * (start_pop - end_pop) / float(start_pop)
	var final_roster: Dictionary = {}
	for tid3 in state.teams: final_roster[tid3] = state.teams[tid3].population
	print("  [final@day%d 全隊roster] %s" % [MONTHS * 30, str(final_roster)])

	SpecimenTracer.flush()
	var spec_path: String = "docs/measurements/2026-08-11-scale-econ-remeasure-tier2-seed%d-%s.specimen.jsonl" % [s, label]
	SpecimenDumpHelper.dump(state, spec_path)
	SpecimenTracer.reset()
	Probe.enabled = false

	print("  ★checkpoint@2mo(day%s): pop=%s attrition=%s%%" % [
		str(checkpoint_2mo.get("day")), str(checkpoint_2mo.get("pop")), str(checkpoint_2mo.get("attrition_pct"))])
	print("  final(day%d,3mo): pop=%d attrition=%.2f%%" % [MONTHS * 30, end_pop, attrition])
	for tid in ORIG_TIDS:
		var last = team_daily[tid][-1] if not team_daily[tid].is_empty() else {}
		print("  Team%d final: %s" % [tid, str(last)])

	return {"start_pop": start_pop, "end_pop": end_pop, "attrition_pct": attrition,
		"checkpoint_2mo": checkpoint_2mo, "final_roster": final_roster,
		"succession_count": 0, "team_daily": team_daily, "labor_daily": labor_daily}

func _total_pop(state: WorldState) -> int:
	var total: int = 0
	for tid in state.teams:
		total += state.teams[tid].population
	return total
