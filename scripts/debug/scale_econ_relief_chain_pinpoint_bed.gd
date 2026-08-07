extends SceneTree

# [measurer持久fixture 2026-08-08] 規模經濟力底查 relief/info鏈斷點pinpoint。
# ticket:docs/superpowers/handbacks/2026-08-08-systems-to-measurer-relief-chain-pinpoint.md
# 目的:精確定位DISPERSED Team2(famine受害隊)的求援/scout/看板鏈哪一站斷,分類(a)never-attempt
#      (b)attempt-fail-deliver(c)circular。cheap re-run(同seed8181 dispersed,45天窗涵蓋day1-45危機全程)。
# 純觀測:inline SimRunner、daily讀Probe.counts delta(help.*/scout.*/care.*)+Team2 faction_id/food_days逐日、
#         零code改零額外RNG(Probe本身既有tap,只是我這輪才dump)。

const SEED: int = 8181
const DAYS: int = 45
const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const T2: int = 2
const OUT_PATH := "res://docs/measurements/2026-08-08-scale-econ-relief-chain-pinpoint.json"

func _initialize() -> void:
	print("=== relief/info鏈斷點pinpoint(seed=%d %d天,Team2focus) ===" % [SEED, DAYS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(DISP_CONFIG)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	if OS.get_environment("CARE_TAP") == "1" and OS.get_environment("ANCHOR_LORD") == "1":
		no_player = state.teams[0].tile_pos   # ★established fix pattern:lord自己tile_pos當anchor→強制near-tier cadence,測belief blocker是否LOD-anchor artifact
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS

	var prev_counts: Dictionary = {}
	var watch_keys: Array = ["help.severity_positive", "help.target_unresolved", "help.target_resolved",
		"help.letter_dispatched", "scout.mini_util_positive", "care.scout_dispatched",
		"g1.market_arrive", "distribute.dispatch",
		"contact.overdue", "contact.care_check", "contact.care_ignore", "contact.ledger_add"]
	for k in watch_keys: prev_counts[k] = 0

	var daily_log: Array = []
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			var day: int = state.world.current_tick / WorldState.TICKS_PER_DAY
			var entry: Dictionary = {"day": day}
			# 全域 Probe delta（本fixture此窗口內主要活動來源=Team2危機，供粗略歸因；非嚴格per-team）
			for k in watch_keys:
				var cur: int = int(Probe.counts.get(k, 0))
				entry[k] = cur - int(prev_counts[k])
				prev_counts[k] = cur
			if state.teams.has(T2):
				var t2: TeamData = state.teams[T2]
				var food_days: float = ResourceSystem.effective_food(state, t2) / maxf(float(t2.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
				entry["t2_faction_id"] = t2.faction_id
				entry["t2_food_days"] = snappedf(food_days, 0.01)
				entry["t2_severity"] = snappedf(clampf((DecisionTerms.DESPERATION_DAYS - food_days) / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0), 0.01)
				entry["t2_pop"] = t2.population
				entry["t2_task"] = t2.current_task
				# applicable 直接複寫 _resolve_help_target 的第一道 gate（faction_id==-1→無解）：純讀複製判斷式,零改production
				entry["t2_help_applicable_gate"] = "OK" if t2.faction_id != -1 else "DEAD(faction_id=-1)"
			else:
				entry["t2_faction_id"] = null
			daily_log.append(entry)
			if day <= 30 or entry.get("help.letter_dispatched", 0) > 0 or entry.get("help.severity_positive", 0) > 0:
				print("  day%d: t2_faction=%s food_days=%.2f severity=%.2f pop=%s task=%s | help_sev+=%d target_ok+=%d target_dead+=%d letter+=%d scout_dispatch+=%d | ledger_add+=%d overdue+=%d care_check+=%d care_ignore+=%d" % [
					day, str(entry.get("t2_faction_id")), float(entry.get("t2_food_days", -1)), float(entry.get("t2_severity", -1)),
					str(entry.get("t2_pop")), str(entry.get("t2_task")),
					int(entry.get("help.severity_positive", 0)), int(entry.get("help.target_resolved", 0)),
					int(entry.get("help.target_unresolved", 0)), int(entry.get("help.letter_dispatched", 0)),
					int(entry.get("care.scout_dispatched", 0)),
					int(entry.get("contact.ledger_add", 0)), int(entry.get("contact.overdue", 0)),
					int(entry.get("contact.care_check", 0)), int(entry.get("contact.care_ignore", 0))])

	var dump: Dictionary = {"diagnostic": "relief/info鏈斷點pinpoint(Team2 focus)", "daily_log": daily_log}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH)
	print("=== DONE ===")
	quit()
