extends SceneTree
# ★`unified.rank.call_us` 的 dump（systems 派 2026-08-27 / slice perf-spike-per-call-distribution）：
#   ★要答：那 0.22 秒／次是【均攤地慢】還是【少數幾次極貴把中位數拉起來】？
#     ★★兩者要鑽的地方完全不同——若 top-1 就佔一半以上，要找的不是「決策很慢」，
#       是【那一兩個特定的決策】。
#
# ★★★母體與取樣偏差【寫死在輸出裡】（systems 要求）：
#   `bump_sample` 是 **first-N** ⇒ 樣本不是隨機的，是【最早的 N 筆】。
#   ⇒ ★沒有「母體 vs 樣本」與「樣本涵蓋哪段 tick」，「top-1 佔 X%」會被讀成母體的 X%，
#     而它其實是【樣本內】的 X%，且樣本偏向開局。
#
# ★★前提：本 sample 依賴 `SimRunner.phase_timing`（單次耗時取自既有那對計時）。
#   ⇒ 只開 `Probe.enabled` 而沒開 phase_timing 會拿到【空樣本】——★那不是「沒有慢的呼叫」。
#   本床兩個旗標都開，並把這個前提印在輸出第一行。
# env：LW_CONFIG / PERF_SEED / ADHOC_DAYS / PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "10"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	SimRunner.phase_timing = true   # ★本 sample 的前提；關掉會拿到空樣本
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break

	var lines: Array = []
	lines.append("[%s seed %d days %d] ★前提：SimRunner.phase_timing = true（本 sample 的單次耗時取自既有那對計時；" % [cfg, sd, days])
	lines.append("   ★只開 Probe.enabled 而沒開 phase_timing 會拿到【空樣本】—— 那不是「沒有慢的呼叫」。）")
	var pop: int = int(Probe.counts.get("unified.rank.calls", 0))
	var arr: Array = (Probe.samples["unified.rank.call_us"] as Array) \
		if Probe.samples.has("unified.rank.call_us") else []
	lines.append("")
	lines.append("★★母體（unified.rank.calls）= %d｜★樣本 = %d｜cap = 200" % [pop, arr.size()])
	if arr.is_empty():
		lines.append("★零樣本 —— ★★分不出「沒發生」與「旗標沒開」：母體 %d 就是分辨用的那個數字。" % pop)
		_out(lines)
		return
	# ★樣本涵蓋哪段 tick —— ★這是 first-N 偏差最銳利的陳述
	var t_lo: int = 1 << 30
	var t_hi: int = -1
	var us: Array = []
	var per_team: Dictionary = {}
	for s in arr:
		var tk: int = int(s.get("tick", -1))
		t_lo = mini(t_lo, tk); t_hi = maxi(t_hi, tk)
		var u: int = int(s.get("us", 0))
		us.append(u)
		var tm: int = int(s.get("team", -1))
		per_team[tm] = int(per_team.get(tm, 0)) + u
	if arr.size() < pop:
		lines.append("★★★樣本 < 母體 ⇒ **以下比例僅【樣本內】**，而樣本是 first-N ⇒ 偏向最早那幾個 tick。")
	lines.append("   ★樣本涵蓋 tick %d〜%d（全程 %d tick）" % [t_lo, t_hi, days * WorldState.TICKS_PER_DAY])
	us.sort()
	var total: int = 0
	for u2 in us: total += int(u2)
	var n: int = us.size()
	lines.append("")
	lines.append("★單次耗時分布（μs，樣本內）：")
	lines.append("   min %d｜p50 %d｜p90 %d｜max %d｜合計 %d" % [
		int(us[0]), int(us[n / 2]), int(us[mini(n - 1, int(n * 0.9))]), int(us[n - 1]), total])
	# ★均攤地慢 vs 少數極貴：top-1 / top-5 佔比
	var top1: float = 100.0 * float(us[n - 1]) / maxf(float(total), 1.0)
	var top5: int = 0
	for k in range(maxi(0, n - 5), n): top5 += int(us[k])
	lines.append("   ★★top-1 佔樣本總耗時 %.1f%%｜top-5 佔 %.1f%%" % [
		top1, 100.0 * float(top5) / maxf(float(total), 1.0)])
	lines.append("   ★★★讀法：top-1 過半 ⇒ 要找的是【那一兩個特定決策】；分布平坦 ⇒ 是【均攤地慢】。")
	lines.append("   ★我不替 systems 選 —— 兩個數字都在上面。")
	var tks: Array = per_team.keys(); tks.sort()
	lines.append("")
	lines.append("★逐隊耗時合計（樣本內）：")
	for tk2 in tks:
		lines.append("   Team%-4d %8d μs" % [int(tk2), int(per_team[tk2])])
	_out(lines)

func _out(lines: Array) -> void:
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	var out_path: String = OS.get_environment("PERF_OUT")
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== unified.rank.call_us dump DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
