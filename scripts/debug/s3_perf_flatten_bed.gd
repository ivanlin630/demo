extends SceneTree
# ★★★S3 的 perf 主張要【量】不是宣稱（systems 定）：七支攤平之後，burst 是否真的變平。
#   ★既有證據形狀（cadence_stagger.gd 檔頭）：burst tick dt 中位 14.9M vs non-burst 4.2M = 3.5×
#   ⇒ ★★所以要看的是【分佈的尾巴】，不是平均 —— 攤平會讓 p99/中位 的比值下降。
#
# ★★★而跨 run 比絕對值會被 CPU contention 汙染（memory: HOB perf 協議）
#   ⇒ ★主指標用【比值】(p99 / median)，絕對值只當附註。
var _last_fire_n: int = 0

func _report(name: String, arr: Array) -> void:
	if arr.is_empty():
		print("  %-22s ★無樣本" % name); return
	var a: Array = arr.duplicate(); a.sort()
	var m: int = int(a[a.size() / 2])
	var p: int = int(a[mini(int(a.size() * 0.99), a.size() - 1)])
	var tot: int = 0
	for x in a: tot += int(x)
	print("  %-22s n=%-6d 中位 %8d us｜p99 %9d us｜平均 %8.0f us"
		% [name, a.size(), m, p, float(tot) / float(a.size())])

func _initialize() -> void:
	var days: int = int(OS.get_environment("PERF_DAYS")) if OS.has_environment("PERF_DAYS") else 8
	var cfg: String = OS.get_environment("PERF_CONFIG") if OS.has_environment("PERF_CONFIG") else "warring_states"
	seed(1337)
	var state := WorldState.new()
	GameSetup.setup(state, GameSetup.load_config("res://config/%s.json" % cfg))
	var stripped: bool = false
	if state.player_id != -1:
		stripped = true
		state.player_id = -1
		state.player_forced_event = {}
		state.player_forced_event_id = ""
		state.player_pending_targets = []
		state.player_hostile_teams = []
		state.player_pre_encounter = {}
		state.player_state = {}
	# ★★第一版用【全部 tick 的 p99/中位】—— 中位竟然是 14us：
	#   拆玩家後 near 集合空 ⇒ 絕大多數 tick 是 no-op ⇒ 那個比值量的是
	#   【多少 tick 是空的】不是【burst 有沒有被攝平】。
	#   ★★★改用既有證據的形狀：fire-tick vs non-fire-tick（靠 tier.fire tap 分類）。
	Probe.reset(); Probe.enabled = true
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var runner := SimRunner.new()
	var dts: Array = []
	var fire_dts: Array = []
	var idle_dts: Array = []
	var first_nonadv: int = -1
	for _t in range(ticks):
		var t0: int = Time.get_ticks_usec()
		var r: String = runner.advance_tick(state, Vector2i(-1, -1))
		var dt: int = Time.get_ticks_usec() - t0
		dts.append(dt)
		# ★靠 tier.fire 的累計筆數有沒有增加來分類這一 tick
		var now_n: int = (Probe.samples.get("tier.fire", []) as Array).size()
		if now_n > _last_fire_n:
			fire_dts.append(dt)
		else:
			idle_dts.append(dt)
		_last_fire_n = now_n
		if first_nonadv == -1 and (r == "game_over" or r == "awaiting_heir"):
			first_nonadv = state.world.current_tick
	var sorted_dt: Array = dts.duplicate()
	sorted_dt.sort()
	var med: int = int(sorted_dt[sorted_dt.size() / 2])
	var p99: int = int(sorted_dt[mini(int(sorted_dt.size() * 0.99), sorted_dt.size() - 1)])
	var mx: int = int(sorted_dt[sorted_dt.size() - 1])
	var total: int = 0
	for d in dts: total += int(d)
	print("=== s3_perf_flatten === cfg=%s days=%d ticks=%d teams_end=%d" % [cfg, days, ticks, state.teams.size()])
	print("  中位 dt = %d us｜p99 = %d us｜max = %d us｜總計 %.1f s" % [med, p99, mx, float(total) / 1e6])
	_report("fire-tick（有支線 fire）", fire_dts)
	_report("idle-tick（沒有）", idle_dts)
	print("  ★主指標（跨 run 可比）：p99/中位 = %.2f｜max/中位 = %.2f"
		% [float(p99) / maxf(float(med), 1.0), float(mx) / maxf(float(med), 1.0)])
	print("[BedSelfCheck] observer_guard=%s  first_nonadvance=%s  effective_window=%d/%d ticks"
		% ["stripped" if stripped else "none",
		   str(first_nonadv) if first_nonadv != -1 else "none",
		   (first_nonadv if first_nonadv != -1 else ticks), ticks])
	print("=== s3_perf_flatten DONE ===")
	quit()
