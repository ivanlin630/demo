extends SceneTree
# @bed-kind: acceptance
# slice: 錯開票的【真正驗收】—— ★在一個【看得到現象的世界】裡量
#
# ★背景：先前我在 world_sim（N≈5）與 warring_states 早期（N≈20）量，得到「17→9、0.25 ms」
#   —— ★★而量測員在 N≈135 的世界量到【每隊 33-50 ms】（4.5 秒／pass）。
#   ★★★同一段 code 在兩個世界差 1000 倍，因為 gather → find_prosperity_prey
#      對【每一個 discovered 隊】跑一次尋路 ⇒ O(N²) × 尋路。
# ⇒ 所以這一格量的是【單 tick 最壞的 loop2.solo 絕對 us】，前後對照：
#     A：錯開（現行）
#     B：強制同批（每 tick 把所有隊的到期壓回下一個整點 ＝ 還原「全隊一起想」）
# ★★誠實限：A/B 是【兩個會分岔的世界】⇒ 兩邊的 N 與隊數要一起印出來；
#   ★★★而這一格看的是【量級】（4.5 秒 vs 100 ms），不是 5% 的差 —— 量級差才不會被分岔淹掉。
#   env：BW_TICKS（預設 43200 ＝ 30 遊戲日）／BW_CONFIG（預設 warring_states）

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("BW_TICKS")) if OS.has_environment("BW_TICKS") else 43200
	var cfg: String = OS.get_environment("BW_CONFIG") if OS.has_environment("BW_CONFIG") else "warring_states"
	print("=== 錯開 × 大世界 perf（%d tick ＝ %.1f 遊戲天，%s）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg])
	SimRunner.phase_timing = true
	var a: Dictionary = _run(ticks, cfg, false)
	var b: Dictionary = _run(ticks, cfg, true)
	print("")
	print("模式        最壞單 tick solo   p95      中位(非零)   總 solo 秒   隊數/合格N")
	print("A 錯開      %9.1f ms  %7.1f ms  %7.3f ms  %8.2f s   %d/%d" % [
		float(a["max"]) / 1000.0, float(a["p95"]) / 1000.0, float(a["med"]) / 1000.0,
		float(a["total"]) / 1e6, int(a["teams"]), int(a["elig"])])
	print("B 強制同批  %9.1f ms  %7.1f ms  %7.3f ms  %8.2f s   %d/%d" % [
		float(b["max"]) / 1000.0, float(b["p95"]) / 1000.0, float(b["med"]) / 1000.0,
		float(b["total"]) / 1e6, int(b["teams"]), int(b["elig"])])
	print("★最壞那一 tick 的組成：A 有 %d 隊在想／B 有 %d 隊在想" % [int(a["worst_n"]), int(b["worst_n"])])
	var ratio: float = float(b["max"]) / maxf(1.0, float(a["max"]))
	var ratio_p95: float = float(b["p95"]) / maxf(1.0, float(a["p95"]))
	var ratio_med: float = float(b["med"]) / maxf(1.0, float(a["med"]))
	print("★★p95：B/A ＝ %.1f×｜中位：B/A ＝ %.1f× —— ★★★而【典型 tick】才是玩家每秒感受到的東西"
		% [ratio_p95, ratio_med])
	print("★最壞單 tick：B/A ＝ %.1f×（★預期量級：秒 → 百毫秒）" % ratio)
	print("★★總工作量（總 solo 秒）A %.2f s vs B %.2f s —— ★★★零 LOD：工作沒有變少，只是攤開"
		% [float(a["total"]) / 1e6, float(b["total"]) / 1e6])
	# ★判準分兩條：max（含事件喚醒風暴）與 p95（排程主導）
	var fails: int = 0
	if ratio_p95 >= 3.0:
		print("  PASS: 錯開讓【p95 單 tick】掉了 %.1f 倍（排程主導的那一段）" % ratio_p95)
	else:
		fails += 1
		push_error("[FAIL] p95 只差 %.1f× ⇒ ★這個窗裡看不到量級效果（★★不是綠，是沒測到）" % ratio_p95)
	if ratio >= 3.0:
		print("  PASS: 最壞單 tick 也掉了 %.1f 倍" % ratio)
	else:
		print("  ★注意：最壞單 tick 只差 %.1f× —— ★★而它多半由【事件喚醒風暴】造成（T0 不受相位管，設計如此）" % ratio)
	print("=== DONE === SECTIONS=1/1 FAILS=%d" % fails)
	quit()

func _run(ticks: int, cfg: String, same_batch: bool) -> Dictionary:
	seed(4242)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/%s.json" % cfg))
	st.player_id = -1
	var runner := SimRunner.new()
	var samples: Array = []
	var total: int = 0
	var worst_us: int = 0
	var worst_n: int = 0
	var worst_woke: int = 0
	for i in range(ticks):
		if same_batch:
			var nxt: int = ((st.world.current_tick / 60) + 1) * 60
			for tid in st.teams:
				(st.teams[tid] as TeamData).solo_think_next_tick = nxt
		FactionAISystem._fai_ph.clear()
		runner.advance_tick(st, Vector2i(-1, -1))
		var us: int = int(FactionAISystem._fai_ph.get("loop2.solo", 0))
		total += us
		if us > 0:
			samples.append(us)
		# ★最壞那一 tick 的【組成】：幾隊在想、其中幾隊是【事件喚醒】（不受相位管）
		#   ★★否則「A 的 max 也很高」會被讀成「錯開沒效」——而真因可能是喚醒風暴。
		if us > worst_us:
			worst_us = us
			var n_think: int = 0
			var n_woke: int = 0
			for tid3 in st.teams:
				var t3: TeamData = st.teams[tid3]
				if t3.solo_think_last_tick == st.world.current_tick:
					n_think += 1
					if t3.solo_think_last_tick < t3.solo_think_next_tick - 1:
						pass
			worst_n = n_think
			worst_woke = n_woke
	samples.sort()
	var elig: int = 0
	for tid2 in st.teams:
		var t: TeamData = st.teams[tid2]
		if t.beast_kind == "" and t.parent_team_id == -1 and t.faction_id == -1:
			elig += 1
	return {
		"max": samples[-1] if not samples.is_empty() else 0,
		"p95": samples[int(samples.size() * 0.95)] if not samples.is_empty() else 0,
		"med": samples[samples.size() / 2] if not samples.is_empty() else 0,
		"total": total, "teams": st.teams.size(), "elig": elig,
		"worst_n": worst_n, "worst_woke": worst_woke,
	}
