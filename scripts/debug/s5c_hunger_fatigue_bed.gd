extends SceneTree
# @observe-pure
# ★★★S5c 驗收②：飢餓／疲勞事件的【發生時點分佈】——★不是單點，是分佈（票寫死）。
#
# ★為什麼純觀測不動 production：本票只准改那四顆常數（票的 ④ 誠實限），
#   ★★而「首次達到 1.0 的 tick」逐 tick 掃 state 就讀得到，不需要在 production 插 tap。
#   ★★★這也讓 before/after 兩跑用【同一支床】，比較不會被儀器差異汙染。
#
# ★★同 seed 前後比在本票【可用】：S5c 純數值、不動 RNG（票的 ② 講的順序理由）。
#   ⇒ 而 S5a（刪 randf_range）之後就不能這樣比了 —— 所以這一票要趁現在做。
#
# ★★★★「沒有人餓死」與「沒有人達到 hunger=1.0」是兩件事，分開印：
#   前者是世界事實（可能糧食夠），後者是這一票直接改的量。
#   ★把它們混成一句「沒事發生」會讓這一票變成不可驗。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var ticks: int = days * WorldState.TICKS_PER_DAY
	seed(1337)
	var state := WorldState.new()
	GameSetup.setup(state, GameSetup.load_config("res://config/%s.json" % cfg))
	var guard: String = "none"
	if state.player_id != -1:
		guard = "stripped"
		state.player_id = -1
		state.player_forced_event = {}
		state.player_forced_event_id = ""
		state.player_pending_targets = []
		state.player_hostile_teams = []
		state.player_pre_encounter = {}
		state.player_state = {}
	Probe.reset(); Probe.enabled = true
	var runner := SimRunner.new()

	var hunger_full: Dictionary = {}   # person_id -> 首次 hunger >= 1.0 的 tick
	var fatigue_full: Dictionary = {}  # team_id   -> 首次 fatigue >= 1.0 的 tick
	var hunger_peak: float = 0.0
	var fatigue_peak: float = 0.0
	var stopped_at: int = -1
	var stop_reason: String = ""
	for _t in range(ticks):
		var r: String = runner.advance_tick(state, Vector2i(-1, -1))
		if stopped_at == -1 and (r == "game_over" or r == "awaiting_heir"):
			stopped_at = state.world.current_tick; stop_reason = r
		var now: int = state.world.current_tick
		for pid in state.persons:
			var p: PersonData = state.persons[pid]
			if p.is_dead:
				continue
			hunger_peak = maxf(hunger_peak, p.hunger)
			if p.hunger >= 1.0 and not hunger_full.has(pid):
				hunger_full[pid] = now
		for tid in state.teams:
			var tm: TeamData = state.teams[tid]
			fatigue_peak = maxf(fatigue_peak, tm.fatigue)
			if tm.fatigue >= 1.0 and not fatigue_full.has(tid):
				fatigue_full[tid] = now
	var eff: int = stopped_at if stopped_at != -1 else ticks

	var out: Array = []
	out.append("# S5c 飢餓/疲勞時點分佈｜cfg=%s days=%d ticks=%d 有效窗=%d" % [cfg, days, ticks, eff])
	out.append("# 常數現值：HUNGER_GAIN=%s HUNGER_RECOVER=%s FATIGUE=%s FATIGUE_RECOVERY=%s"
		% [str(ResourceSystem.HUNGER_GAIN_PER_DAY), str(ResourceSystem.HUNGER_RECOVER_PER_DAY),
		   str(SimRunner.FATIGUE_PER_DAY), str(SimRunner.FATIGUE_RECOVERY_PER_DAY)])
	print("\n=== s5c_hunger_fatigue ｜cfg=%s days=%d ===" % [cfg, days])
	print("常數：HUNGER_GAIN=%s HUNGER_RECOVER=%s FATIGUE=%s FATIGUE_RECOVERY=%s"
		% [str(ResourceSystem.HUNGER_GAIN_PER_DAY), str(ResourceSystem.HUNGER_RECOVER_PER_DAY),
		   str(SimRunner.FATIGUE_PER_DAY), str(SimRunner.FATIGUE_RECOVERY_PER_DAY)])

	_dist("飢餓滿（hunger >= 1.0）", hunger_full, state.persons.size(), hunger_peak, out)
	_dist("疲勞滿（fatigue >= 1.0）", fatigue_full, state.teams.size(), fatigue_peak, out)

	# ★餓死是另一件事，分開印（世界事實 vs 本票直接改的量）
	var starve_keys: Array = []
	for ck in Probe.counts.keys():
		var cs: String = String(ck)
		if cs.find("starv") != -1 or cs.find("famine") != -1:
			starve_keys.append(cs)
	starve_keys.sort()
	print("\n餓死/糧荒相關 tap（★與上面兩張分佈是【不同】的量）：")
	out.append("#")
	out.append("## 餓死/糧荒 tap（與時點分佈是不同的量）")
	if starve_keys.is_empty():
		print("   ★key 全部不存在，而 Probe 是 ON ⇒ 這一輪沒發生（不是沒儀器）")
		out.append("# ★key 不存在且 Probe ON ⇒ 沒發生（不是沒儀器）")
	for sk in starve_keys:
		print("   %-36s %d" % [sk, int(Probe.counts[sk])])
		out.append("starve|%s|%d" % [sk, int(Probe.counts[sk])])

	print("\n[BedSelfCheck] observer_guard=%s  first_nonadvance=%s  effective_window=%d/%d ticks"
		% [guard, ("%d(%s)" % [stopped_at, stop_reason]) if stopped_at != -1 else "none", eff, ticks])
	out.append("# [BedSelfCheck] observer_guard=%s first_nonadvance=%s effective_window=%d/%d"
		% [guard, ("%d(%s)" % [stopped_at, stop_reason]) if stopped_at != -1 else "none", eff, ticks])
	var path: String = OS.get_environment("S5C_OUT") if OS.has_environment("S5C_OUT") \
		else "docs/measurements/2026-09-01-s5c-%s.txt" % cfg
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(PackedStringArray(out)) + "\n"); f.close()
		print("\n落地：%s" % path)
	print("=== s5c_hunger_fatigue DONE ===")

# ★分佈而不是單點：首次 / Q1 / 中位 / Q3 / 最後，＋【母體 vs 達到的人數】。
#   ★★沒達到的那些【不算成大數字】也不算成 0 —— 它們是「窗內沒到」，獨立一欄。
func _dist(title: String, hit: Dictionary, pop: int, peak: float, out: Array) -> void:
	var ts: Array = hit.values()
	ts.sort()
	print("\n%s｜母體 %d ／ ★達到 %d ／ 窗內未達到 %d ／ 峰值 %.3f"
		% [title, pop, ts.size(), pop - ts.size(), peak])
	out.append("#")
	out.append("## %s｜母體=%d|達到=%d|未達到=%d|峰值=%.3f" % [title, pop, ts.size(), pop - ts.size(), peak])
	if ts.is_empty():
		print("   ★窗內【無人達到】—— 而峰值 %.3f 才是這一票在這張床上的可比量" % peak)
		out.append("# ★窗內無人達到；★★峰值 %.3f 是可比量（比「0 件事發生」有資訊）" % peak)
		return
	var q1: int = int(ts[ts.size() / 4])
	var med: int = int(ts[ts.size() / 2])
	var q3: int = int(ts[(ts.size() * 3) / 4])
	print("   首次 %d ／ Q1 %d ／ 中位 %d ／ Q3 %d ／ 最後 %d tick（%d tick = 1 日）"
		% [int(ts[0]), q1, med, q3, int(ts[-1]), WorldState.TICKS_PER_DAY])
	out.append("dist|%s|first=%d|q1=%d|median=%d|q3=%d|last=%d"
		% [title, int(ts[0]), q1, med, q3, int(ts[-1])])
