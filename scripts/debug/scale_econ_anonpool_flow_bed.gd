extends SceneTree

# [measurer持久fixture 2026-08-08] anon-pool exhaustion收支診斷:LEAK(recall沒完成merge)vs
# GENUINE scarcity(僧多粥少,returned≈dispatched但pool仍空)。
# ticket:docs/superpowers/handbacks/2026-08-08-systems-to-measurer-anonpool-flow-diagnose.md
# seed8181 dispersed 45天,lord Team0 anon池逐日+各dispatch型出入帳。
# 純觀測:inline SimRunner、既有Probe tap+1個temp tap(subteam_system.gd try_merge_back,
# env ANONFLOW_TAP=1 gate,merge_back時記task_reason breakdown,測完git checkout --revert)。

const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const LORD: int = 0
const DAYS: int = 45
const SEED: int = 8181

func _initialize() -> void:
	print("=== anon-pool 收支診斷(seed=%d %d天,lord=Team%d) ===" % [SEED, DAYS, LORD])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(DISP_CONFIG)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS

	var out_keys: Array = ["help.letter_dispatched", "care.scout_dispatched", "distribute.dispatch",
		"migrant.dispatched", "invest.dispatched", "relocate.ordered", "relocate.self"]
	var prev: Dictionary = {}
	for k in out_keys: prev[k] = 0
	var totals: Dictionary = {}
	for k in out_keys: totals[k] = 0
	var prev_convoy_return: int = 0
	var total_convoy_return: int = 0
	var prev_anonflow: Dictionary = {}   # 動態key(anonflow.return_*)delta追蹤

	var daily_log: Array = []
	var lord_anon_min: int = 999; var lord_anon_max: int = -1
	var lord_anon_zero_since_day: int = -1
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			var day: int = state.world.current_tick / WorldState.TICKS_PER_DAY
			var entry: Dictionary = {"day": day}
			for k in out_keys:
				var cur: int = int(Probe.counts.get(k, 0))
				var d: int = cur - int(prev[k])
				entry[k] = d; prev[k] = cur; totals[k] = int(totals[k]) + d
			var cr_cur: int = int(Probe.counts.get("convoy.return", 0))
			entry["convoy.return"] = cr_cur - prev_convoy_return
			prev_convoy_return = cr_cur; total_convoy_return += entry["convoy.return"]
			# 動態掃 anonflow.return_* key
			var anonflow_delta: Dictionary = {}
			for k in Probe.counts:
				if String(k).begins_with("anonflow.return_"):
					var cur2: int = int(Probe.counts[k])
					var d2: int = cur2 - int(prev_anonflow.get(k, 0))
					if d2 > 0: anonflow_delta[k] = d2
					prev_anonflow[k] = cur2
			entry["anonflow_returns"] = anonflow_delta

			var lord_anon: int = -1
			if state.teams.has(LORD):
				lord_anon = AnonTierSystem.total_pop(state.teams[LORD])
				entry["lord_pop"] = state.teams[LORD].population
			entry["lord_anon"] = lord_anon
			if lord_anon >= 0:
				lord_anon_min = mini(lord_anon_min, lord_anon)
				lord_anon_max = maxi(lord_anon_max, lord_anon)
				if lord_anon == 0 and lord_anon_zero_since_day == -1: lord_anon_zero_since_day = day
				elif lord_anon > 0: lord_anon_zero_since_day = -1   # 有回補就清旗標(非永久)
			daily_log.append(entry)
			if day <= 15 or day % 5 == 0 or not anonflow_delta.is_empty():
				print("  day%d: lord_anon=%d lord_pop=%s | OUT herald+=%d scout+=%d distribute+=%d migrant+=%d invest+=%d relocate_order+=%d relocate_self+=%d | IN convoy.return+=%d anonflow_returns=%s" % [
					day, lord_anon, str(entry.get("lord_pop")),
					int(entry["help.letter_dispatched"]), int(entry["care.scout_dispatched"]), int(entry["distribute.dispatch"]),
					int(entry["migrant.dispatched"]), int(entry["invest.dispatched"]), int(entry["relocate.ordered"]), int(entry["relocate.self"]),
					int(entry["convoy.return"]), str(anonflow_delta)])

	print("\n───── 45天總帳 ─────")
	print("  OUT totals: %s" % str(totals))
	print("  IN  convoy.return total=%d" % total_convoy_return)
	var anonflow_totals: Dictionary = {}
	for k in Probe.counts:
		if String(k).begins_with("anonflow.return_"): anonflow_totals[k] = int(Probe.counts[k])
	print("  IN  anonflow.return_* totals: %s" % str(anonflow_totals))
	print("  lord_anon: min=%d max=%d zero_since_day=%d(-1=從未卡0或有回補)" % [lord_anon_min, lord_anon_max, lord_anon_zero_since_day])

	var out_sum: int = 0
	for k in totals: out_sum += int(totals[k])
	var in_sum: int = total_convoy_return
	for k in anonflow_totals: in_sum += int(anonflow_totals[k])
	print("  ★收支比: OUT總=%d(含herald/migrant永久性drain) IN總(merge_back真回池)=%d" % [out_sum, in_sum])

	var dump: Dictionary = {"seed": SEED, "days": DAYS, "out_totals": totals, "convoy_return_total": total_convoy_return,
		"anonflow_return_totals": anonflow_totals, "lord_anon_min": lord_anon_min, "lord_anon_max": lord_anon_max,
		"lord_anon_zero_since_day": lord_anon_zero_since_day, "daily_log": daily_log}
	var f := FileAccess.open("res://docs/measurements/2026-08-08-scale-econ-anonpool-flow.json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-08-scale-econ-anonpool-flow.json")
	print("=== DONE ===")
	quit()
