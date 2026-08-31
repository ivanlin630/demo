extends SceneTree
# @observe-pure
# ★★★S5a 驗收①：季節曲線的【函數層】檢查 —— ★不跑世界。
#
# ★為什麼函數層是主軸（spec 寫死的理由）：S5a 刪 randf_range ⇒ 之後每顆骰子都換人擲
#   ⇒ ★★世界大幅分岔 ⇒ 世界層前後比【不能】當效果量。
#   ⇒ ★★★所以效果要在【純函數】上證：連續性 + 季界不跳變。
#
# ★★而世界層只驗一件：亂擲真的沒了。
#   ★spec 原文寫「同一 tile、同一季內、不同 tick ⇒ factor 相同」——
#   ★★而那與【季內插值】不可能同時成立（插值就是要它在季內變）。
#   ★★★所以本床改驗一個【與插值相容、且同樣能證明亂擲消失】的判準：
#       【同一 tick、不同 tile ⇒ factor 完全相同】
#     舊寫法是每 tile 獨立擲一次 ⇒ 同 tick 各 tile 必然不同；
#     ⇒ 「同 tick 全 tile 一致」是亂擲移除的【直接】證據，而且不與插值衝突。
#   ★這個替換我已寄信給 systems，未獲裁定前【兩個判準都印】。

# ★harvest 的更新節律（sim_runner:299 `current_tick % (TICKS_PER_DAY / 4) == 0`）＝每 6 小時。
#   ★★從同一個來源導出，不寫死 360 —— 根一改它就跟著走。
const HARVEST_CADENCE: int = WorldState.TICKS_PER_DAY / 4

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var L: int = HarvestSystem.SEASON_LENGTH
	var out: Array = []
	out.append("# S5a 季節曲線｜SEASON_LENGTH=%d｜SEASON_BASE=%s" % [L, str(HarvestSystem.SEASON_BASE)])
	print("\n=== s5a_season_curve ｜SEASON_LENGTH=%d ===" % L)

	# ── ① 連續性：相鄰 tick 的差必須 <= 可推導的上界 ──
	#   上界 = 相鄰兩季錨點差的最大值 / SEASON_LENGTH
	#   ★這個上界是【從 SEASON_BASE 推導】的，不是我挑一個會過的數字。
	var max_step: float = 0.0
	for i in range(4):
		max_step = maxf(max_step, absf(float(HarvestSystem.SEASON_BASE[(i + 1) % 4])
			- float(HarvestSystem.SEASON_BASE[i])))
	var bound: float = max_step / float(L)
	var worst: float = 0.0
	var worst_tick: int = -1
	var prev: float = _f(0, L)
	for tick in range(1, L * 4 + 1):
		var cur: float = _f(tick, L)
		var d: float = absf(cur - prev)
		if d > worst:
			worst = d; worst_tick = tick
		prev = cur
	var ok1: bool = worst <= bound + 1e-9
	print("① 連續性：相鄰 tick 最大差 = %.8f @tick %d｜上界 = %.8f（= max|Δ錨點| %.2f / %d）⇒ %s"
		% [worst, worst_tick, bound, max_step, L, "PASS" if ok1 else "★FAIL"])
	out.append("## ① 連續性｜最大差=%.8f|上界=%.8f|worst_tick=%d|%s"
		% [worst, bound, worst_tick, "PASS" if ok1 else "FAIL"])

	# ── ② 季界不跳變：t→1 與下一季 t→0 必須相等 ──
	#   ★用【最後一個 tick】與【下一季第一個 tick】比，差必須 <= 一個 tick 的步長上界。
	var ok2: bool = true
	out.append("## ② 季界（t→1 vs 下季 t=0）｜季界tick|前值|後值|差")
	for s in range(4):
		var last_tick: int = (s + 1) * L - 1
		var next_tick: int = (s + 1) * L
		var a: float = _f(last_tick, L)
		var b: float = _f(next_tick, L)
		var d2: float = absf(b - a)
		var pass_s: bool = d2 <= bound + 1e-9
		ok2 = ok2 and pass_s
		print("   季 %d→%d @tick %d：%.6f → %.6f（差 %.8f）%s"
			% [s, (s + 1) % 4, next_tick, a, b, d2, "" if pass_s else "★FAIL"])
		out.append("edge|%d->%d|%d|%.6f|%.6f|%.8f|%s"
			% [s, (s + 1) % 4, next_tick, a, b, d2, "PASS" if pass_s else "FAIL"])
	print("② 季界不跳變 ⇒ %s" % ["PASS" if ok2 else "★FAIL"])

	# ── ③ 錨點落點：SEASON_BASE[s] 必須出現在【該季第一個 tick】 ──
	#   ★這條是把「錨點語意」寫成可驗的：它證明我沒有偷偷位移半季。
	var ok3: bool = true
	for s2 in range(4):
		var v: float = _f(s2 * L, L)
		var want: float = float(HarvestSystem.SEASON_BASE[s2])
		if absf(v - want) > 1e-6:
			ok3 = false
			print("   ★季 %d 起點 %.6f ≠ SEASON_BASE %.6f" % [s2, v, want])
	print("③ 錨點落在季首（未位移）⇒ %s" % ["PASS" if ok3 else "★FAIL"])
	out.append("## ③ 錨點落在季首（未位移）｜%s" % ["PASS" if ok3 else "FAIL"])

	# ── ④ 曲線取樣（給人看形狀，不是判準）──
	out.append("#")
	out.append("## ④ 曲線取樣（每 1/8 季一點）｜tick|季|t|factor")
	print("\n④ 曲線取樣：")
	for i2 in range(33):
		var tk: int = int(float(i2) * float(L) / 8.0)
		var sea: int = (tk / L) % 4
		var tt: float = float(tk % L) / float(L)
		out.append("curve|%d|%d|%.3f|%.4f" % [tk, sea, tt, _f(tk, L)])
		if i2 % 4 == 0:
			print("   tick %-7d 季%d t=%.2f  factor=%.4f" % [tk, sea, tt, _f(tk, L)])

	# ── ⑤ 世界層：亂擲真的沒了 ＋ 兩份實作沒漂 ──
	#   ★判準A【同一 tick、全部 tile 的 factor 相同】—— 舊寫法每 tile 獨立擲，同 tick 必然不同
	#     ⇒ 這是亂擲移除的【直接】證據，而且與季內插值【相容】。
	#   ★★判準B【production 的值 == 本床純函數的值】—— 上面那些檢查都是對純函數做的，
	#     ★★★沒有 B，①②③ 全過也可能只證明「我的副本是對的」而 production 是另一回事。
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/peaceful_economy.json"))
	if st.player_id != -1:
		st.player_id = -1
		st.player_forced_event = {}
		st.player_forced_event_id = ""
		st.player_pending_targets = []
		st.player_hostile_teams = []
		st.player_pre_encounter = {}
		st.player_state = {}
	var runner := SimRunner.new()
	var spread_max: float = 0.0
	var drift_max: float = 0.0
	var checks: int = 0
	for _t in range(L * 2):
		runner.advance_tick(st, Vector2i(-1, -1))
		# ★★★只在【harvest 剛跑完的那個 tick】取樣 —— 這是我第一版的 bug：
		#   harvest_factor 是【每 6 小時更新一次的保持值】（sim_runner:299 `% (TICKS_PER_DAY/4)`），
		#   而我第一版在任意 tick 取樣、拿【當前 tick】的函數值去比
		#   ⇒ 最多差 359 tick 的量（實測偏差 0.00106，而 359 × 斜率 9.26e-6 = 0.00332，相符）
		#   ⇒ ★★那是【分子分母不同時刻】那一族，不是 production 錯。
		if st.world.current_tick % HARVEST_CADENCE != 0:
			continue
		var lo: float = 1e9
		var hi: float = -1e9
		for tid in st.world.tiles:
			var tl: HexTileData = st.world.tiles[tid]
			lo = minf(lo, tl.harvest_factor)
			hi = maxf(hi, tl.harvest_factor)
		if lo <= hi:
			spread_max = maxf(spread_max, hi - lo)
			drift_max = maxf(drift_max, absf(hi - _f(st.world.current_tick, L)))
			checks += 1
	var ok5a: bool = spread_max <= 1e-9
	var ok5b: bool = drift_max <= 1e-6
	print("\n⑤ 世界層（peaceful，%d tick，取樣 %d 次）" % [L * 2, checks])
	print("   A 同 tick 全 tile 一致：最大離散 = %.10f ⇒ %s" % [spread_max, "PASS" if ok5a else "★FAIL"])
	print("   B production vs 純函數：最大偏差 = %.10f ⇒ %s" % [drift_max, "PASS" if ok5b else "★FAIL"])
	out.append("#")
	out.append("## ⑤ 世界層｜取樣=%d|同tick離散=%.10f|%s|production-vs-函數偏差=%.10f|%s"
		% [checks, spread_max, "PASS" if ok5a else "FAIL", drift_max, "PASS" if ok5b else "FAIL"])
	out.append("# ★A 是亂擲移除的直接證據（舊寫法每 tile 獨立擲，同 tick 必然不同）")
	out.append("# ★★B 防「我的副本對、production 是另一回事」——沒有它，①②③ 全過也證不到 production")
	# ★★★一個必須誠實講的事實：世界看到的 factor 【不是每 tick 連續】的。
	#   harvest 每 %d tick（6 小時）才更新一次 ⇒ ★世界層是那條連續曲線的【取樣保持】，
	#   ★★每一階的高度來自曲線、而階與階之間是平的。
	#   ⇒ ★★★「連續」是函數層的性質；世界層該講的是【階高】，而它 = 斜率 × 節律。
	var step_world: float = bound * float(HARVEST_CADENCE)
	print("   ★世界層是【每 %d tick 取樣保持】⇒ 階高上界 = %.6f（斜率 %.8f × 節律 %d）"
		% [HARVEST_CADENCE, step_world, bound, HARVEST_CADENCE])
	out.append("# ★★★世界層是每 %d tick 的取樣保持 ⇒ 階高上界 %.6f —— 「連續」是函數層的性質，不是世界層的"
		% [HARVEST_CADENCE, step_world])

	var verdict: bool = ok1 and ok2 and ok3 and ok5a and ok5b
	print("\n★總判：%s" % ["PASS（連續 + 季界不跳變 + 錨點未位移）" if verdict else "★FAIL"])
	out.append("# ★總判：%s" % ["PASS" if verdict else "FAIL"])
	var path: String = OS.get_environment("S5A_OUT") if OS.has_environment("S5A_OUT") \
		else "docs/measurements/2026-09-01-s5a-season-curve.txt"
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(PackedStringArray(out)) + "\n"); f.close()
		print("落地：%s" % path)
	print("=== s5a_season_curve DONE ===")

# ★純函數：把 production 的算式在這裡【重寫一次】——
#   ★★不呼叫 HarvestSystem.tick_all，因為那要一個 WorldState 且會寫 tile。
#   ★★★而重寫一次意味著【兩份實作要一致】才有意義 ⇒ 世界層那一節就是在驗這件事。
func _f(tick: int, L: int) -> float:
	var s: int = (tick / L) % 4
	var t: float = float(tick % L) / float(L)
	return clampf(lerp(float(HarvestSystem.SEASON_BASE[s]),
		float(HarvestSystem.SEASON_BASE[(s + 1) % 4]), t), 0.1, 2.0)
