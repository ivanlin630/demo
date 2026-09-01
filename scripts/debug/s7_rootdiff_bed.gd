extends SceneTree

# ★★★S7換根微分試驗量測床(measurer側,純觀測,零production改動)。
#   讀573ef498插的rootdiff.*既有tap，算每個候選常數的【套用次數 per person-day】。
#   本床本身在root60/root120兩個commit上跑法完全一樣——只有checkout的commit不同，
#   跑法本身不碰TICKS_PER_HOUR。
#
# 用法：BED_CONFIG=warring_states BED_DAYS=30 godot --script scripts/debug/s7_rootdiff_bed.gd

func _initialize() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	seed(1337)
	# ★修setup期間盲區(systems記進known_issues那條)：arm Probe在GameSetup.setup()之前，
	#   否則world_generator等setup階段套用的rootdiff.*常數(如TERRAIN_WEIGHTS)會被結構性漏記，
	#   在報表上長得跟「沒發生」一模一樣。
	Probe.reset()
	Probe.enabled = true
	var state := WorldState.new()
	GameSetup.setup(state, GameSetup.load_config("res://config/%s.json" % cfg))
	var _stripped: bool = false
	if state.player_id != -1:
		_stripped = true
		state.player_id = -1
		state.player_forced_event = {}
		state.player_forced_event_id = ""
		state.player_pending_targets = []
		state.player_hostile_teams = []
		state.player_pre_encounter = {}
		state.player_state = {}
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var runner := SimRunner.new()
	# ★person-day分母：day-boundary取樣persons.size()累加(跟qty_tap_bed的team-days同精神，改用person)
	var person_days: float = 0.0
	var _first_nonadv: int = -1
	var _nonadv_reason: String = ""
	for t in range(ticks):
		var r: String = runner.advance_tick(state, Vector2i(-1, -1))
		if _first_nonadv == -1 and (r == "game_over" or r == "awaiting_heir"):
			_first_nonadv = state.world.current_tick; _nonadv_reason = r
		if (t + 1) % WorldState.TICKS_PER_DAY == 0:
			person_days += float(state.persons.size())

	print("=== s7_rootdiff_bed === config=%s days=%d ticks=%d TICKS_PER_HOUR=%d TICKS_PER_DAY=%d"
		% [cfg, days, ticks, WorldState.TICKS_PER_HOUR, WorldState.TICKS_PER_DAY])
	print("母體：結束時隊數=%d｜結束時人口(named)=%d｜person_days(day-boundary累加)=%.1f"
		% [state.teams.size(), state.persons.size(), person_days])
	print("[BedSelfCheck] observer_guard=%s  first_nonadvance=%s  effective_window=%d/%d ticks"
		% ["stripped" if _stripped else "none",
		   ("%d(%s)" % [_first_nonadv, _nonadv_reason]) if _first_nonadv != -1 else "none",
		   (_first_nonadv if _first_nonadv != -1 else ticks), ticks])

	print("
── rootdiff候選 套用次數/person-day ──")
	var keys: Array = []
	for k in Probe.counts:
		var ks: String = String(k)
		if ks.begins_with("rootdiff."):
			keys.append(ks.substr("rootdiff.".length()))
	keys.sort()
	if person_days <= 0.0:
		print("  ★person_days=0，無法算率——照印總數")
	for name in keys:
		var total: int = int(Probe.counts.get("rootdiff." + name, 0))
		var per_pd: float = float(total) / person_days if person_days > 0.0 else 0.0
		print("  %-28s 總數=%-8d per_person_day=%.6f" % [name, total, per_pd])
	print("=== s7_rootdiff_bed DONE ===")
	quit()
