extends SceneTree
# ★★★cadence 錯峰驗收床（spec 2026-08-27 cadence-stagger）。
#   ①「單一 tick 過閘 ≥100 隊」的 tick 數 → 應為 0
#   ②burst / non-burst 的 per-tick dt 中位數比值（改動前 3.5×）→ 應趨近 1
#   ⑥同隊相鄰思考的最小間隔 ≥ `CadenceStagger.min_gap_of(cadence)`，★無 1~2 tick 連思
#
# ★★per-tick dt 是【同一次跑內】的相對比較（burst vs non-burst），
#   ★不是「改動前後的 wall-clock 加速」—— spec 明令禁用全局 wall-clock 宣稱加速（雜訊 ±4~8% > 效果）。
#
# ★★★MIN_GAP 讀 `CadenceStagger.min_gap_of()`，★不自己再抄一份 `cadence / 2`
#   —— 兩份會各自漂，而漂掉的那次不會有症狀。
# env：LW_CONFIG / PERF_SEED / ADHOC_DAYS / PERF_OUT

const BURST_THRESHOLD: int = 100   # ★spec ①的定義：單一 tick 過閘 ≥ 此隊數 ＝ burst

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "10"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var dt_by_tick: Dictionary = {}
	var total: int = days * WorldState.TICKS_PER_DAY
	for _t in range(total):
		var tk: int = state.world.current_tick
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(state, no_player)
		dt_by_tick[tk] = Time.get_ticks_usec() - t0
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break

	var lines: Array = []
	lines.append("[%s seed %d days %d] 跑了 %d tick" % [cfg, sd, days, dt_by_tick.size()])
	var arr: Array = (Probe.samples["stagger.fired"] as Array) if Probe.samples.has("stagger.fired") else []
	lines.append("★母體/樣本：stagger.fired 樣本 = %d（cap 20000）%s" % [
		arr.size(), "★★樣本已達 cap ⇒ 以下同批峰值是【下界】" if arr.size() >= 20000 else ""])
	if arr.is_empty():
		lines.append("★零樣本 —— 分不出「沒發生」與「tap 沒接上」；★而 Probe.enabled 本床已開，所以是前者。")
		_out(lines); return

	# ── ①每個 tick 有幾隊過閘 ──
	var per_tick: Dictionary = {}
	var per_team_ticks: Dictionary = {}
	for s in arr:
		var tk2: int = int(s.get("tick", -1))
		var tm: int = int(s.get("team", -1))
		var kd: String = String(s.get("kind", ""))
		var key: String = "%d|%s" % [tk2, kd]
		per_tick[key] = int(per_tick.get(key, 0)) + 1
		var pk: String = "%d|%s" % [tm, kd]
		var lst: Array = per_team_ticks.get(pk, [])
		lst.append(tk2)
		per_team_ticks[pk] = lst
	var burst_ticks: Dictionary = {}   # tick → true（任一 kind 超標）
	var max_batch: int = 0
	var n_over: int = 0
	for k in per_tick:
		var c: int = int(per_tick[k])
		if c > max_batch: max_batch = c
		if c >= BURST_THRESHOLD:
			n_over += 1
			burst_ticks[int(String(k).split("|")[0])] = true
	lines.append("")
	lines.append("★★①單一 tick 過閘 ≥%d 隊的 tick 數 = %d（★最大同批 = %d 隊）" % [
		BURST_THRESHOLD, n_over, max_batch])

	# ── ②burst vs non-burst 的 per-tick dt 中位數 ──
	var b: Array = []
	var nb: Array = []
	for tk3 in dt_by_tick:
		if burst_ticks.has(int(tk3)): b.append(int(dt_by_tick[tk3]))
		else: nb.append(int(dt_by_tick[tk3]))
	lines.append("")
	if b.is_empty():
		lines.append("★★②沒有任何 burst tick（依 ①的定義）⇒ ★比值無法計算 —— 而那正是①要的結果，不是缺資料。")
		lines.append("   ★所以本欄改印【最大同批那個 tick】的 dt 與整體中位數對照：")
		var mx_tick: int = -1
		var mx_c: int = -1
		for k2 in per_tick:
			if int(per_tick[k2]) > mx_c:
				mx_c = int(per_tick[k2]); mx_tick = int(String(k2).split("|")[0])
		nb.sort()
		if not nb.is_empty():
			# ★哨兵值不外洩：該 tick 可能不在 dt 取樣範圍（最後一筆樣本落在迴圈結束後的 tick）
			var _dts: String = ("%d" % int(dt_by_tick[mx_tick])) if dt_by_tick.has(mx_tick) else "（該 tick 不在 dt 取樣範圍內）"
			lines.append("      最大同批 tick %d（%d 隊）dt = %s μs｜全體中位數 dt = %d μs" % [
				mx_tick, mx_c, _dts, int(nb[nb.size() / 2])])
	else:
		b.sort(); nb.sort()
		var mb: int = int(b[b.size() / 2])
		var mn: int = int(nb[nb.size() / 2]) if not nb.is_empty() else 0
		lines.append("★★②burst tick %d 個 中位數 dt = %d μs｜non-burst %d 個 中位數 = %d μs｜★比值 %.2f×" % [
			b.size(), mb, nb.size(), mn, float(mb) / maxf(float(mn), 1.0)])
	lines.append("   ★這是【同一次跑內】burst vs non-burst 的相對比較，★★不是改動前後的 wall-clock 加速宣稱。")

	# ── ⑥同隊相鄰思考的最小間隔 ──
	lines.append("")
	lines.append("★★★⑥同隊相鄰思考間隔（★MIN_GAP 讀 CadenceStagger.min_gap_of，不自己抄 cadence/2）：")
	var cadences: Dictionary = {
		"ambition": AmbitionLadder.LADDER_EVAL_CADENCE,
		"order": OrderSystem.ORDER_POST_CADENCE}
	for kind in cadences:
		var cad: int = int(cadences[kind])
		var gap_min_req: int = CadenceStagger.min_gap_of(cad)
		var worst: int = 1 << 30
		var worst_team: int = -1
		var n_violate: int = 0
		var n_pairs: int = 0
		for pk2 in per_team_ticks:
			if not String(pk2).ends_with("|" + String(kind)): continue
			var ts: Array = per_team_ticks[pk2]
			ts.sort()
			for i in range(1, ts.size()):
				var g: int = int(ts[i]) - int(ts[i - 1])
				n_pairs += 1
				if g < worst:
					worst = g; worst_team = int(String(pk2).split("|")[0])
				if g < gap_min_req: n_violate += 1
		if n_pairs == 0:
			lines.append("   %-9s ★零組相鄰樣本（該 kind 在本窗只 fire 過 ≤1 次／隊）" % kind)
			continue
		lines.append("   %-9s cadence %4d｜MIN_GAP %4d｜★最小實測間隔 %d（Team%d）｜違規 %d / %d 組%s" % [
			kind, cad, gap_min_req, worst, worst_team, n_violate, n_pairs,
			"   ←★★違規＞0：wrap clamp 沒擋住" if n_violate > 0 else "   ✅"])
	# ── ★★★④offset 分桶【原始資料】落地給 measurer（systems 2026-08-27 急件訂正）──
	#   ★驗收 4 改了：★★【不送 QA 判分佈】—— 跨隊分佈命題不是單一 story 的形狀。
	#   ⇒ 我只產【原始列】，★★★不算「有沒有系統性優勢」那個判決（那是 measurer 的統計）。
	#   ★措辭紀律（QA 立的）：禁寫「證明沒有系統性優勢」；只能寫「樣本窗內未見，而窗有多大」。
	lines.append("")
	lines.append("═══ ★★④offset 分桶原始資料（★給 measurer 做統計；★★本床不下判決）═══")
	lines.append("   ★窗 = %d tick（%d 天）｜隊數 = %d" % [dt_by_tick.size(), days, state.teams.size()])
	lines.append("   ★★offset 逐 cycle 輪轉 ⇒ 下面印的是【末 tick 那個 cycle】的相位，不是終身相位。")
	var last_tick: int = state.world.current_tick
	var roster: Array = state.teams.keys(); roster.sort()
	lines.append("   ★★★行為面欄位（存活／資源／據點數）【已移除】——systems 2026-08-27 定案：",)
	lines.append("      measurer 判那個量不出來（16 天內 team 101→202，戰鬥／飢荒／立國／分裂的量級遠大於 offset），")
	lines.append("      ★而這題的雜訊與效應是【同一條通道】⇒ 不能靠控制事件降噪，只能靠樣本量，而樣本量沒有底。")
	lines.append("      ⇒ ★本床只落地 offset；印出行為面數字只會邀請一個判不了的比較。")
	lines.append("   team   offset(ambition)   offset(order)")
	for tid in roster:
		if state.teams.get(tid) == null: continue
		var off_a: int = CadenceStagger.next_tick(last_tick, last_tick, int(tid),
			AmbitionLadder.LADDER_EVAL_CADENCE) % AmbitionLadder.LADDER_EVAL_CADENCE
		var off_o: int = CadenceStagger.next_tick(last_tick, last_tick, int(tid),
			OrderSystem.ORDER_POST_CADENCE) % OrderSystem.ORDER_POST_CADENCE
		lines.append("   %-6d %15d %15d" % [int(tid), off_a, off_o])
	_out(lines)

func _out(lines: Array) -> void:
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	var out_path: String = OS.get_environment("PERF_OUT")
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== cadence_stagger_bed DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
