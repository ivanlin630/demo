extends SceneTree

# [measurer持久fixture 2026-08-12] ③長期故事驗證 first-pass story-audit(整系統believability)。
# ticket:docs/superpowers/handbacks/2026-08-12-systems-to-measurer-phase3-longterm-story-audit.md
# ★中性觀察禁預設,產中性長局敘事+top incoherences ranked。
# vehicle:複製WarringHarness.run()同款tick迴圈+config(seed1337,warring_states.json),疊加近期系統
# (promote/migrant/invest/relocate/mobilize)逐月delta,既有欄位(teams/factions/established/pop/intent/
# food_econ)沿用WarringHarness._snapshot同款靜態helper直呼(避免碰established infra、零sim邏輯變)。

const WORLD_SEED: int = 1337
const CONFIG_PATH := "res://config/warring_states.json"

func _initialize() -> void:
	var months: int = int(OS.get_environment("LW_MONTHS")) if OS.has_environment("LW_MONTHS") else 12
	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	print("=== ③長期故事驗證(seed=%d %d月 ticks=%d) ===" % [WORLD_SEED, months, total_ticks])

	seed(WORLD_SEED)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = WORLD_SEED
	GameSetup.setup(state, config)
	SpecimenDumpHelper.setup_from_env(state)

	var new_keys: Array = ["promote.fired", "promote.field_desperate",
		"migrant.dispatched", "migrant.arrived", "invest.dispatched",
		"relocate.ordered", "relocate.comply", "relocate.resist", "relocate.started",
		"relocate.abandoned", "relocate.arrived", "relocate.resettled",
		"reaction.N3_defect", "g2.ambition_promote", "g2.ambition_demote",
		"g2.faction_found", "death.combat_pop", "death.starve_anon"]
	var prev_new: Dictionary = {}
	for k in new_keys: prev_new[k] = 0
	var mobilize_peak_prev: float = 0.0

	var curve: Array = []
	var start_pop: int = _total_pop(state)
	var no_player := Vector2i(-1, -1)
	var extinct_tick: int = -1

	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			var month: int = (tick + 1) / WorldState.TICKS_PER_MONTH
			var snap: Dictionary = {
				"month": month, "teams": state.teams.size(), "factions": state.factions.size(),
				"established": WarringHarness._established_count(state), "pop": _total_pop(state),
				"intent": WarringHarness._intent_histogram(state)}
			var new_delta: Dictionary = {}
			for k in new_keys:
				var cur: int = int(Probe.counts.get(k, 0))
				new_delta[k] = cur - int(prev_new[k])
				prev_new[k] = cur
			snap["new_delta"] = new_delta
			snap["mobilize_fraction_peak"] = float(Probe.peaks.get("mobilize.fraction", 0.0))
			curve.append(snap)
			print("[月%d] team=%d faction=%d established=%d pop=%d intent=%s newdelta=%s mobilize_peak=%.3f" % [
				month, snap["teams"], snap["factions"], snap["established"], snap["pop"],
				str(snap["intent"]), str(new_delta), snap["mobilize_fraction_peak"]])
		if state.teams.is_empty():
			extinct_tick = tick
			print("[EXTINCT] 全滅於 tick=%d" % tick)
			break

	var end_pop: int = _total_pop(state)
	print("\n───── 終態總結 ─────")
	print("  start_pop=%d end_pop=%d attrition=%.1f%% extinct_tick=%d" % [
		start_pop, end_pop, (0.0 if start_pop == 0 else 100.0 * (start_pop - end_pop) / float(start_pop)), extinct_tick])
	print("  final: teams=%d factions=%d established=%d" % [
		state.teams.size(), state.factions.size(), WarringHarness._established_count(state)])
	print("  final intent histogram: %s" % str(WarringHarness._intent_histogram(state)))
	for k in new_keys:
		print("  %s 累計=%d" % [k, int(Probe.counts.get(k, 0))])
	print("  mobilize.fraction 全程峰值=%.3f" % float(Probe.peaks.get("mobilize.fraction", 0.0)))

	var dump: Dictionary = {"seed": WORLD_SEED, "months": months, "curve": curve,
		"start_pop": start_pop, "end_pop": end_pop, "extinct_tick": extinct_tick,
		"final": {"teams": state.teams.size(), "factions": state.factions.size(),
			"established": WarringHarness._established_count(state)},
		"final_intent": WarringHarness._intent_histogram(state),
		"new_keys_total": {}, "mobilize_fraction_peak_final": float(Probe.peaks.get("mobilize.fraction", 0.0))}
	for k in new_keys: dump["new_keys_total"][k] = int(Probe.counts.get(k, 0))
	Probe.enabled = false
	var f := FileAccess.open("res://docs/measurements/2026-08-12-phase3-story-audit-seed%d-%dmo.json" % [WORLD_SEED, months], FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-12-phase3-story-audit-seed%d-%dmo.json" % [WORLD_SEED, months])
	SpecimenDumpHelper.dump(state, "res://docs/measurements/2026-08-12-phase3-story-audit-seed%d-%dmo.specimen.jsonl" % [WORLD_SEED, months])
	print("=== DONE ===")
	quit()

func _total_pop(state: WorldState) -> int:
	var total: int = 0
	for tid in state.teams: total += state.teams[tid].population
	return total
