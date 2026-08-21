extends SceneTree
# §3 常數重錨的【先量再定】床：P_ref ＝ peaceful 世界的中位隊伍規模。
# ★跨多個 snapshot 取中位數（R² 建議）：單一快照的中位數本身也是抽樣值，
#   拿它當常數的錨會把抽樣雜訊烙進世界。
# 量三件：中位 population／中位「適齡數」（healthy anon + needs 達標 named）／每隊 named 數。
# 純觀測、零 sim 改。env：PREF_SEEDS（逗號，預設 1337,42,8181）、PREF_DAYS（逗號，預設 30,60,90）

func _initialize() -> void:
	_run(); quit()

func _median(a: Array) -> float:
	if a.is_empty(): return 0.0
	var b: Array = a.duplicate(); b.sort()
	var n: int = b.size()
	return float(b[n / 2]) if n % 2 == 1 else (float(b[n / 2 - 1]) + float(b[n / 2])) / 2.0

func lines_print(hist: Dictionary, singles: Array) -> void:
	print("    分佈: %s" % str(hist))
	for x in singles:
		print("    [pop<=1] %s" % str(x))

func _run() -> void:
	var seeds_s: String = OS.get_environment("PREF_SEEDS") if OS.get_environment("PREF_SEEDS") != "" else "1337,42,8181"
	var days_s: String = OS.get_environment("PREF_DAYS") if OS.get_environment("PREF_DAYS") != "" else "30,60,90"
	var seeds: Array = []
	for x in seeds_s.split(","): seeds.append(int(x))
	var days: Array = []
	for x in days_s.split(","): days.append(int(x))
	days.sort()
	print("=== P_ref 量測：seeds=%s snapshots(day)=%s config=peaceful_economy ===" % [str(seeds), str(days)])

	var pop_medians: Array = []
	var pop_h_medians: Array = []
	var fit_h_medians: Array = []
	var fit_medians: Array = []
	var named_per_team: Array = []
	for sd in seeds:
		seed(int(sd))
		FactionAISystem._a2b_remote_tribute_payers.clear()
		var state := WorldState.new()
		var runner := SimRunner.new()
		var config: Dictionary = GameSetup.load_config("res://config/peaceful_economy.json")
		if config.is_empty():
			print("[FAIL] config"); return
		config["seed"] = int(sd)
		GameSetup.setup(state, config)
		var no_player := Vector2i(-1, -1)
		var next_i: int = 0
		var max_tick: int = int(days[days.size() - 1]) * WorldState.TICKS_PER_DAY
		for tick in range(max_tick):
			runner.advance_tick(state, no_player)
			if state.encounter_active and state.encounter_tick > 800:
				runner._encounter_system.resolve_encounter_end(state, "draw")
			if next_i < days.size() and (tick + 1) == int(days[next_i]) * WorldState.TICKS_PER_DAY:
				var pops: Array = []
				var pops_healthy: Array = []   # ★排除縮到剩 1 人的崩潰隊（母體要是「村」，不是殘骸）
				var fits: Array = []
				var fits_healthy: Array = []
				var nameds: Array = []
				for tid in state.teams:
					var t: TeamData = state.teams[tid]
					if t.beast_kind != "" or t.parent_team_id != -1:
						continue   # 只看常駐主隊（子隊/野獸不是「村」）
					pops.append(t.population)
					if t.population >= 2:
						pops_healthy.append(t.population)
					var anon_fit: int = AnonCohort.by_health(t.anon_cohorts, "healthy")
					var named_fit: int = 0
					var named_n: int = 0
					for pid in state.persons:
						var p: PersonData = state.persons[pid]
						if p.team_id != t.team_id: continue
						named_n += 1
						if float(p.needs.get("safety", 1.0)) > 0.7 and float(p.needs.get("food", 1.0)) > 0.7:
							named_fit += 1
					fits.append(anon_fit + named_fit)
					if t.population >= 2:
						fits_healthy.append(anon_fit + named_fit)
					nameds.append(named_n)
				# ★中位數被 pop=1 隊淹沒時要看得見分佈（否則會把雜訊烙進常數）
				var hist: Dictionary = {}
				var singles: Array = []
				for tid2 in state.teams:
					var t2: TeamData = state.teams[tid2]
					if t2.beast_kind != "" or t2.parent_team_id != -1: continue
					var b: String = "1" if t2.population <= 1 else ("2-3" if t2.population <= 3 else ("4-7" if t2.population <= 7 else "8+"))
					hist[b] = int(hist.get(b, 0)) + 1
					if t2.population <= 1 and singles.size() < 6:
						singles.append({"id": t2.team_id, "task": t2.current_task, "tags": t2.tags,
							"fac": t2.faction_id, "was_convoy": (t2.task_extra_data as Dictionary).has("convoy_phase")})
				lines_print(hist, singles)
				var mp: float = _median(pops)
				var mf: float = _median(fits)
				var mn: float = _median(nameds)
				pop_medians.append(mp); fit_medians.append(mf); named_per_team.append(mn)
				pop_h_medians.append(_median(pops_healthy)); fit_h_medians.append(_median(fits_healthy))
				print("    ★pop>=2 子母體：n=%d 中位pop=%.1f 中位適齡=%.1f" % [
					pops_healthy.size(), _median(pops_healthy), _median(fits_healthy)])
				print("  seed=%d day=%d  teams=%d  中位pop=%.1f  中位適齡=%.1f  中位named=%.1f" % [
					int(sd), int(days[next_i]), pops.size(), mp, mf, mn])
				next_i += 1
			if state.teams.is_empty(): break

	var P_ref: float = _median(pop_medians)
	var fit_ref: float = _median(fit_medians)
	print("\n★跨 %d 個 snapshot：P_ref(中位的中位)=%.2f｜適齡數(P_ref)=%.2f｜中位 named/隊=%.2f" % [
		pop_medians.size(), P_ref, fit_ref, _median(named_per_team)])
	var P_h: float = _median(pop_h_medians)
	var fit_h: float = _median(fit_h_medians)
	print("★【pop>=2 子母體】P_ref=%.2f｜適齡數=%.2f｜BASE=(1/30)/(0.5×適齡)=%.5f" % [
		P_h, fit_h, (1.0 / 30.0) / maxf(0.5 * fit_h, 0.001)])
	if fit_ref > 0.0:
		var base: float = (1.0 / 30.0) / (0.5 * fit_ref)
		print("★BASE = (1/30) / (0.5 × 適齡數) = %.5f（現行 %.4f）" % [base, ReactionSystem.BREED_BASE_RATE])
	else:
		print("★適齡數 = 0 → 無法定錨（要先問為什麼沒有適齡者）")
