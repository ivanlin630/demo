extends SceneTree

# [measurer持久fixture 2026-08-08] 規模經濟力底查 fair-fixture Tier1 驗證。
# ticket:docs/superpowers/handbacks/2026-08-08-systems-to-measurer-fixture-redesign.md
# CONCENTRATED_fair(1 lord+3 member 全co-located同tile,只lord持outpost) vs
# DISPERSED(既有infonet_scale_econ_dispersed.json,4隊各自outpost,人格/資源逐項對齊concentrated_fair)。
# ★驗:(1)公平fixture下dispersed是否仍瓦解(cohesion輸入已對齊,若仍瓦解=genuine經濟餓死鏈非結構artifact)
#      (2)sell_ownerless在無脫離的穩定fixture下是否仍fire(若仍fire=genuine convoy timing bug)
#      (3)gradient方向(econ聚合僅Tier1快看,乾淨帳留Tier2)
# 純觀測:inline SimRunner(同 convoy_t1_diag_bed pattern)、讀 Probe 全量、零 code 改、零額外 RNG。

const SEED: int = 8181
const MONTHS: int = 3
const CONC_CONFIG := "res://config/infonet_scale_econ_concentrated_fair.json"
const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const ORIG_TIDS: Array = [0, 1, 2, 3]
const OUT_PATH := "res://docs/measurements/2026-08-08-scale-econ-fair-fixture-tier1.json"

func _initialize() -> void:
	print("=== 規模經濟力底查 fair-fixture Tier1(seed=%d %d月) ===" % [SEED, MONTHS])
	var rc: Dictionary = _run("CONCENTRATED_fair", CONC_CONFIG)
	var rd: Dictionary = _run("DISPERSED", DISP_CONFIG)

	print("\n───────── gradient 對照 ─────────")
	for k in ["end_pop", "attrition_pct", "faction_dissolved_day", "secession_count",
			"convoy.dispatch", "convoy.deliver_settled", "convoy.deliver_bail_sell_ownerless",
			"manufacture.fired"]:
		print("  %s: concentrated=%s dispersed=%s" % [k, str(rc.get(k)), str(rd.get(k))])

	var dump: Dictionary = {"diagnostic": "fair-fixture Tier1(concentrated vs dispersed, cohesion輸入對齊)",
		"concentrated": rc, "dispersed": rd}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH)
	print("=== DONE ===")
	quit()

func _run(label: String, config_path: String) -> Dictionary:
	print("\n########## %s ##########" % label)
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(config_path)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_MONTH * MONTHS
	var start_pop: int = _total_pop(state)

	var faction_trace: Dictionary = {}   # tid → 逐日 faction_id(只記變化)
	var last_fid: Dictionary = {}
	for tid in ORIG_TIDS: last_fid[tid] = 1
	var faction_dissolved_day: int = -1
	var secession_count: int = 0

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			var day: int = state.world.current_tick / WorldState.TICKS_PER_DAY
			for tid in ORIG_TIDS:
				if not state.teams.has(tid): continue
				var fid: int = state.teams[tid].faction_id
				if fid != int(last_fid[tid]):
					secession_count += 1
					faction_trace[str(tid) + "@day" + str(day)] = "%d→%d" % [int(last_fid[tid]), fid]
					last_fid[tid] = fid
			if faction_dissolved_day == -1 and not state.factions.has(1):
				faction_dissolved_day = day
		if state.teams.is_empty(): break

	var end_pop: int = _total_pop(state)
	var bail_keys: Dictionary = {}
	for k in Probe.counts:
		if String(k).begins_with("convoy.deliver_bail_"): bail_keys[k] = int(Probe.counts[k])

	print("final: pop=%d attrition=%.1f%% faction_dissolved_day=%d secession_count=%d" % [
		end_pop, 0.0 if start_pop == 0 else 100.0 * (start_pop - end_pop) / float(start_pop),
		faction_dissolved_day, secession_count])
	print("convoy.dispatch=%d deliver=%d deliver_settled=%d bail=%s" % [
		int(Probe.counts.get("convoy.dispatch", 0)), int(Probe.counts.get("convoy.deliver", 0)),
		int(Probe.counts.get("convoy.deliver_settled", 0)), str(bail_keys)])
	print("manufacture.fired=%d construct.complete_upgrade_facility=%d" % [
		int(Probe.counts.get("manufacture.fired", 0)), int(Probe.counts.get("construct.complete_upgrade_facility", 0))])
	print("faction_trace=%s" % str(faction_trace))

	Probe.enabled = false
	return {
		"start_pop": start_pop, "end_pop": end_pop,
		"attrition_pct": 0.0 if start_pop == 0 else 100.0 * (start_pop - end_pop) / float(start_pop),
		"faction_dissolved_day": faction_dissolved_day, "secession_count": secession_count,
		"faction_trace": faction_trace,
		"convoy.dispatch": int(Probe.counts.get("convoy.dispatch", 0)),
		"convoy.deliver": int(Probe.counts.get("convoy.deliver", 0)),
		"convoy.deliver_settled": int(Probe.counts.get("convoy.deliver_settled", 0)),
		"convoy.deliver_bail_sell_ownerless": int(bail_keys.get("convoy.deliver_bail_sell_ownerless", 0)),
		"bail_reasons": bail_keys,
		"manufacture.fired": int(Probe.counts.get("manufacture.fired", 0)),
		"construct.complete_upgrade_facility": int(Probe.counts.get("construct.complete_upgrade_facility", 0)),
	}

func _total_pop(state: WorldState) -> int:
	var total: int = 0
	for tid in state.teams:
		total += state.teams[tid].population
	return total
