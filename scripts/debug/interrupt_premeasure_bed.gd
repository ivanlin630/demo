extends SceneTree
# @bed-kind: diagnostic
# 前置量測（HOW spec 2026-09-11-interrupt-not-replace §③ ＋ §⑦(2)）：★動 code 之前先答兩題，
#   ★★而它們【都可能讓那張票停下來】。
#
# ①★覓食 episode 的【起訖 food_days】與【長度】—— ★★若吃完 food_days 沒有明顯上升，
#   「插斷非取代」在這個世界裡【也會無限迴圈】（吃→還是餓→再吃）⇒ 回報 blueprint，不硬做。
# ②★★同窗【其他長程任務】的到場率 —— ★★★求居的驗收門檻要【綁這個基準】，
#   不綁一個拍出來的 30%；★而若基準本身就很低，那是【比本票更大的發現】。
#
# ★母體定義（跨表比較的前提是母體逐字相同）：
#   ·episode ＝ 同一隊在 `current_task` 上連續停留的一段（換 task／窗末 ＝ 結束）
#   ·長程 ＝ episode 開始時 `move_target` 與所在格的 hex 距離 ≥ LONG_TILES
#   ·到場 ＝ episode 結束時（或存續期間任一 tick）`tile_pos == move_target`
#   ·★被窗切掉的 episode 【單獨一類】，不算成功也不算失敗
# ★★純觀測：只讀欄位、零寫入、零 RNG。
# env：IP_TICKS（預設 43200 ＝ 30 天）／IP_SEED（預設 1337）／IP_CONFIG（預設 warring_states）

const LONG_TILES: int = 3

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("IP_TICKS")) if OS.has_environment("IP_TICKS") else 43200
	var seed_val: int = int(OS.get_environment("IP_SEED")) if OS.has_environment("IP_SEED") else 1337
	var cfg: String = OS.get_environment("IP_CONFIG") if OS.has_environment("IP_CONFIG") else "warring_states"
	print("=== 插斷非取代｜前置量測（%d tick ＝ %.1f 遊戲天，%s，seed=%d，★預設 config 未改）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg, seed_val])
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	var live: Dictionary = {}        # team_id → {task, target, start, start_fd, start_dist, arrived}
	var forage_rows: Array = []      # ①逐筆
	var ep_start: Dictionary = {}    # task → 長程 episode 起算數
	var ep_arrive: Dictionary = {}   # task → 其中到場數
	var ep_cut: Dictionary = {}      # task → 被窗切掉
	var ep_len: Dictionary = {}      # task → 長度合計（tick）

	for tick in range(ticks):
		runner.advance_tick(st, no_player)
		for tid in st.teams:
			var t: TeamData = st.teams[tid]
			var cur: String = t.current_task
			var prev: Dictionary = live.get(tid, {})
			if prev.is_empty() or String(prev["task"]) != cur or Vector2i(prev["target"]) != t.move_target:
				if not prev.is_empty():
					_close(prev, st, t, ep_start, ep_arrive, ep_len, forage_rows, false)
				live[tid] = {"task": cur, "target": t.move_target, "start": st.world.current_tick,
					"start_fd": _food_days(st, t), "team": tid,
					"start_dist": FactionAISystem._hex_dist(t.tile_pos, t.move_target) if t.move_target != Vector2i(-1, -1) else -1,
					"arrived": false}
			else:
				if t.move_target != Vector2i(-1, -1) and t.tile_pos == t.move_target:
					live[tid]["arrived"] = true
	# ★窗末仍在進行中的 episode 自成一類（★它不是失敗，是窗太短）
	for tid2 in live:
		var t2: TeamData = st.teams.get(tid2)
		if t2 == null: continue
		var k2: String = String(live[tid2]["task"])
		if int(live[tid2]["start_dist"]) >= LONG_TILES:
			ep_cut[k2] = int(ep_cut.get(k2, 0)) + 1
		_close(live[tid2], st, t2, ep_start, ep_arrive, ep_len, forage_rows, true)

	# ── ① 覓食 episode：起訖 food_days ──
	print("")
	print("★①覓食 episode（母體＝所有覓食 episode，★含被窗切掉的）")
	print("   母體 = %d 段（其中被窗切掉 %d 段）" % [forage_n, forage_cut_n])
	if forage_deltas.is_empty():
		print("   ★★完整結束的 episode = 0 ⇒ 【不可判】（★★★「沒人覓食」與「覓食沒效果」是兩個結論）")
	else:
		var ds: Array = forage_deltas.duplicate(); ds.sort()
		var ls: Array = forage_lens.duplicate(); ls.sort()
		var up: int = 0
		for d in ds:
			if float(d) > 0.5: up += 1
		print("   完整結束 %d 段｜Δfood_days：min=%.2f 中位=%.2f max=%.2f ｜ ★上升 >0.5 天 = %d (%.1f%%)" % [
			ds.size(), float(ds[0]), float(ds[ds.size() / 2]), float(ds[ds.size() - 1]),
			up, 100.0 * float(up) / float(ds.size())])
		print("   episode 長度（tick）：min=%d 中位=%d max=%d ｜ 中位 = %.2f 遊戲天" % [
			int(ls[0]), int(ls[ls.size() / 2]), int(ls[ls.size() - 1]),
			float(int(ls[ls.size() / 2])) / float(WorldState.TICKS_PER_DAY)])
	print("   ★逐筆前 %d 筆（★★前 N 筆、不是隨機樣本）：" % forage_rows.size())
	for r2 in forage_rows:
		print("     team=%d 起 tick=%d 訖 tick=%d 長=%d tick food_days %.2f → %.2f (Δ%+.2f)%s" % [
			int(r2["team"]), int(r2["start"]), int(r2["end"]), int(r2["len"]),
			float(r2["start_fd"]), float(r2["end_fd"]),
			float(r2["end_fd"]) - float(r2["start_fd"]), "　★被窗切掉" if bool(r2["cut"]) else ""])

	# ── ② 長程任務到場率（基準） ──
	print("")
	print("★②長程任務到場率（母體＝episode 開始時目標距離 ≥ %d 格的 episode；★被窗切掉的單獨列、不進分母）" % LONG_TILES)
	var keys: Array = ep_start.keys()
	keys.sort()
	var base_start: int = 0
	var base_arr: int = 0
	print("   %-8s %8s %8s %10s %10s %12s" % ["task", "起算", "到場", "到場率", "窗末未完", "中位長(天)"])
	for k in keys:
		var s0: int = int(ep_start[k])
		var a0: int = int(ep_arrive.get(k, 0))
		var c0: int = int(ep_cut.get(k, 0))
		var rate: String = "不可判(母體0)" if s0 == 0 else ("%.1f%%" % (100.0 * float(a0) / float(s0)))
		var avgd: String = "-" if s0 == 0 else ("%.2f" % (float(int(ep_len.get(k, 0))) / float(s0) / float(WorldState.TICKS_PER_DAY)))
		print("   %-8s %8d %8d %10s %10d %12s" % [String(k), s0, a0, rate, c0, avgd])
		if String(k) != TeamData.TASK_SEEK_HOME:
			base_start += s0
			base_arr += a0
	print("")
	if base_start == 0:
		print("   ★★★基準【不可判】：其他長程任務的 episode 母體 = 0（★不是「基準是 0%%」）")
	else:
		print("   ★★★基準（★不含求居）：到場 %d / 起算 %d = **%.1f%%**" % [
			base_arr, base_start, 100.0 * float(base_arr) / float(base_start)])
		var sk_s: int = int(ep_start.get(TeamData.TASK_SEEK_HOME, 0))
		var sk_a: int = int(ep_arrive.get(TeamData.TASK_SEEK_HOME, 0))
		if sk_s == 0:
			print("   ★求居：母體 0 ⇒ 不可判（★而這本身就是那 42 次沒上路的後果）")
		else:
			print("   ★求居：到場 %d / 起算 %d = %.1f%%（★★門檻 ＝ 基準，不是拍出來的 30%%）" % [
				sk_a, sk_s, 100.0 * float(sk_a) / float(sk_s)])
	# ── ③ 驗收欄（這一刀的副作用守衛）：★餓死率不得上升、★★無登記隊數不得歸零 ──
	#   ★兩個數字都是【跟同窗對照】用的：本片只負責把它們印出來，
	#   ★★而【上升沒上升】只有兩趨相減才答得出來。
	var _starve_team: int = int(Probe.counts.get("extinct.starve", 0))
	var _starve_person: int = int(Probe.counts.get("death.starve_named_hunger", 0))
	var _homeless: int = 0
	var _registered: int = 0
	for tid3 in st.teams:
		var t3: TeamData = st.teams[tid3]
		if st.own_outpost_tile(t3.team_id) != null: continue
		if t3.work_outpost == Vector2i(-1, -1): _homeless += 1
		else: _registered += 1
	print("")
	print("★③副作用守衛：隊滅絕於餓 %d｜有名角色餓死 %d｜窗末無自家據點的隊：未登記 %d ・已登記寄居 %d" % [
		_starve_team, _starve_person, _homeless, _registered])
	print("   ★未登記歸零＝消滅遊商階層（blueprint 明文禁）⇒ 這一欄应該保持非 0"
		+ ("　★★本窗＝0，要當成紅看" if _homeless == 0 else ""))
	print("★>2 秒幀數 = %d / %d" % [SimRunner.frames_over_budget, SimRunner.frames_total])
	print("★fp = %s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=0")
	print("[TEST-SUITE-COMPLETE]")
	quit(0)

var forage_n: int = 0
var forage_cut_n: int = 0
var forage_deltas: Array = []
var forage_lens: Array = []

func _close(ep: Dictionary, st: WorldState, t: TeamData, ep_start: Dictionary, ep_arrive: Dictionary,
		ep_len: Dictionary, forage_rows: Array, cut: bool) -> void:
	var k: String = String(ep["task"])
	var length: int = st.world.current_tick - int(ep["start"])
	if int(ep["start_dist"]) >= LONG_TILES:
		ep_start[k] = int(ep_start.get(k, 0)) + 1
		ep_len[k] = int(ep_len.get(k, 0)) + length
		if bool(ep["arrived"]) or t.tile_pos == Vector2i(ep["target"]):
			ep_arrive[k] = int(ep_arrive.get(k, 0)) + 1
	if k == TeamData.TASK_FORAGE:
		# ★記憶體：完整結束的只留【兩個數】，逐筆只留前 20 筆
		#   （★★上一趨被 OS 當低記憶體殺掉，而那會讓整個窗白跑）
		forage_n += 1
		if cut:
			forage_cut_n += 1
		else:
			forage_deltas.append(_food_days(st, t) - float(ep["start_fd"]))
			forage_lens.append(length)
		if forage_rows.size() < 20:
			forage_rows.append({"team": int(ep["team"]), "start": int(ep["start"]),
				"end": st.world.current_tick, "len": length, "start_fd": float(ep["start_fd"]),
				"end_fd": _food_days(st, t), "cut": cut})

func _food_days(st: WorldState, t: TeamData) -> float:
	var need: float = maxf(float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
	return ResourceSystem.effective_food(st, t) / need
