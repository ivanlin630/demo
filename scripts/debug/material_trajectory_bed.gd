extends SceneTree
# ★★★material 軌跡床（systems 派 2026-08-26 / slice material-trajectory）：
#   ★要答的唯一一件事：那些隊的 material 是【卡在一個平台】還是【緩慢單調上升】？
#     卡平台 ⇒ 有 sink 在吃掉它 ⇒ 治 sink
#     單調升 ⇒ 只是 30 天太短     ⇒ 加窗長，不是加供給
#   ★★兩者現在【印出來一模一樣】（都是 reject_cannot_afford），而修法完全相反。
#   ★★★而「只看那一刻的餘額」或「只看首尾差分」都分不出這兩個 —— 要的是【逐日軌跡】。
#
# ★零 production 改：存量直接讀 state（床本來就看得到），
#   ★per-team-per-day 的拒絕次數用【既有 per-team 累計 counter 的日差】算 ——
#   不新增 12×30 個 key（那是我們自己立過的「per-team 不逐日」那條）。
#
# ★私產與公庫【分開記】（systems 指定）：併起來就分不出「錢在誰手上」。
# ★母體＝`state.teams` 全隊名冊：沒有據點的隊照樣印一行，缺席要可讀不是留白。
#
# env：LW_CONFIG / PERF_SEED / ADHOC_DAYS / PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "30"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	var out_path: String = _env("PERF_OUT", "")
	print("=== material 軌跡：config=%s days=%d seed=%d ===" % [cfg, days, sd])
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
	var roster: Array = state.teams.keys(); roster.sort()

	# day → team → {priv, vault, rej_up, rej_wall}
	var hist: Array = []
	var prev_up: Dictionary = {}
	var prev_wall: Dictionary = {}
	var no_player := Vector2i(-1, -1)
	for day in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, no_player)
			if state.encounter_active and state.encounter_tick > 800:
				runner._encounter_system.resolve_encounter_end(state, "draw")
			if state.teams.is_empty(): break
		var row: Dictionary = {}
		for tid in roster:
			var t: TeamData = state.teams.get(tid)
			var priv: float = float(t.resources.get("material", 0)) if t != null else 0.0
			var vault: float = 0.0
			if t != null:
				for wid in state.world.tiles:
					var wt: HexTileData = state.world.tiles[wid]
					if wt.outpost_level > 0 and wt.outpost_owner == int(tid):
						vault += float(wt.public_storage.get("material", 0))
			# ★per-team-per-day 拒絕＝既有【累計】counter 的日差（★零新 key）
			var cu: int = int(Probe.counts.get("upgd.reject_cannot_afford.team.%d" % int(tid), 0))
			var cw: int = int(Probe.counts.get("wall.reject_cannot_afford.team.%d" % int(tid), 0))
			row[tid] = {"priv": priv, "vault": vault,
				"rej_up": cu - int(prev_up.get(tid, 0)), "rej_wall": cw - int(prev_wall.get(tid, 0)),
				"alive": t != null}
			prev_up[tid] = cu
			prev_wall[tid] = cw
		hist.append(row)
		if state.teams.is_empty(): break

	var lines: Array = []
	lines.append("[%s seed %d] 天數=%d｜★母體＝全隊名冊 %d 支（沒據點的照樣印）" % [cfg, sd, hist.size(), roster.size()])
	lines.append("★門檻對照（純讀 code，非量測）：facility material 30~100｜outpost L1→L2 = 150｜L2→L3 = 400")
	lines.append("")
	for tid2 in roster:
		var series: Array = []
		var rej_up_tot: int = 0
		var rej_wall_tot: int = 0
		for d in range(hist.size()):
			var cell: Dictionary = (hist[d] as Dictionary)[tid2]
			series.append(cell)
			rej_up_tot += int(cell["rej_up"])
			rej_wall_tot += int(cell["rej_wall"])
		var first: Dictionary = series[0]
		var last: Dictionary = series[series.size() - 1]
		var tot_first: float = float(first["priv"]) + float(first["vault"])
		var tot_last: float = float(last["priv"]) + float(last["vault"])
		# ★機械描述（★不下判斷）：最大值、是否單調不減、後段平台寬度
		var mx: float = 0.0
		var monotone: bool = true
		var prev_tot: float = -1.0
		for c in series:
			var tt: float = float(c["priv"]) + float(c["vault"])
			mx = maxf(mx, tt)
			if prev_tot >= 0.0 and tt < prev_tot - 0.001:
				monotone = false
			prev_tot = tt
		# 後段平台：最後 10 天的極差
		var tail_lo: float = 1e18
		var tail_hi: float = -1e18
		for k in range(maxi(0, series.size() - 10), series.size()):
			var c2: Dictionary = series[k]
			var t2v: float = float(c2["priv"]) + float(c2["vault"])
			tail_lo = minf(tail_lo, t2v); tail_hi = maxf(tail_hi, t2v)
		lines.append("── Team%d %s" % [int(tid2), "" if bool(last["alive"]) else "（★中途消失）"])
		lines.append("   總量 首日 %.0f → 末日 %.0f｜最大 %.0f｜單調不減 %s｜末 10 天極差 %.0f（%.0f〜%.0f）" % [
			tot_first, tot_last, mx, ("是" if monotone else "否"), tail_hi - tail_lo, tail_lo, tail_hi])
		lines.append("   拒絕合計：升級 %d｜設施牆 %d" % [rej_up_tot, rej_wall_tot])
		# ★★斜率與到門檻天數【由本床的序列算出】，★不手算也不手抄門檻：
		#   門檻讀 OutpostSystem.OUTPOST_COST（L1→L2）與 BuildAfford.MARGIN_NEUTRAL。
		# ★★★這是【照觀測斜率外推】，不是預測世界會維持線性 —— 只是把「還要多久」變成可比的數字。
		var n_days: int = series.size()
		var slope_all: float = (tot_last - tot_first) / maxf(float(n_days - 1), 1.0)
		# ★★★用【全窗斜率】算「還要多久」是錯的（我自己第一版踩到，訂正）：
		#   Team3/4/7 開局一次性花掉 310→160（蓋了兩座設施），之後【死平 25 天】。
		#   全窗斜率因此是 −5.19/日 ⇒ 會被讀成「有 sink 在把料吃掉」——★而那正好是相反的結論。
		#   ⇒ ★★問「卡平台還是緩慢上升」，要看的是【穩態】＝末段斜率，不是含開局那一刀的全窗。
		var tail_n: int = mini(10, n_days)
		var tail_first: Dictionary = series[n_days - tail_n]
		var tail_first_tot: float = float(tail_first["priv"]) + float(tail_first["vault"])
		var slope: float = (tot_last - tail_first_tot) / maxf(float(tail_n - 1), 1.0)
		var cost_up: float = float(OutpostSystem.OUTPOST_COST["civilian"][1].get("material", 0))
		var need_buf: float = cost_up * BuildAfford.MARGIN_NEUTRAL
		var s_phys: String = "已達" if tot_last >= cost_up else (
			"永不（斜率≤0）" if slope <= 0.0 else "%.0f 天" % ((cost_up - tot_last) / slope))
		var s_buf: String = "已達" if tot_last >= need_buf else (
			"永不（斜率≤0）" if slope <= 0.0 else "%.0f 天" % ((need_buf - tot_last) / slope))
		lines.append("   ★末段斜率(%d 天) %+.2f/日｜距【物理 %.0f】%s｜距【含緩衝 %.0f】%s" % [
			tail_n, slope, cost_up, s_phys, need_buf, s_buf])
		lines.append("      （參考：全窗斜率 %+.2f/日 —— ★含開局一次性支出，★★不可用來答「卡平台還是上升」）" % slope_all)
		var s_priv: Array = []
		var s_vault: Array = []
		var s_rej: Array = []
		for c3 in series:
			s_priv.append("%.0f" % float(c3["priv"]))
			s_vault.append("%.0f" % float(c3["vault"]))
			s_rej.append("%d" % (int(c3["rej_up"]) + int(c3["rej_wall"])))
		lines.append("   私產逐日：%s" % " ".join(PackedStringArray(s_priv)))
		lines.append("   公庫逐日：%s" % " ".join(PackedStringArray(s_vault)))
		lines.append("   當日拒絕：%s" % " ".join(PackedStringArray(s_rej)))
	# ═══ ★★★material 進帳的出口分類（systems 派 2026-08-26 / slice material-income-zero）═══
	#   ★四個出口互斥且窮盡，分母＝`matin.call`（該隊的採集迴圈走到 material 幾次）。
	#   ★★分母缺了就分不出「這隊沒收入」與「這隊根本沒被採集迴圈走到」。
	lines.append("")
	lines.append("═══ ★★material 進帳出口（分母＝matin.call；★零 ≠ 沒接上，看 call 本身）═══")
	lines.append("   team      call  pool_empty  carry_full  zero_other    gained      進帳量   載重/上限")
	var mv := MovementSystem.new()
	for tid3 in roster:
		var c_all: int = int(Probe.counts.get("matin.call.team.%d" % int(tid3), 0))
		var c_pe: int = int(Probe.counts.get("matin.pool_empty.team.%d" % int(tid3), 0))
		var c_cf: int = int(Probe.counts.get("matin.carry_full.team.%d" % int(tid3), 0))
		var c_zo: int = int(Probe.counts.get("matin.zero_gain_other.team.%d" % int(tid3), 0))
		var c_g: int = int(Probe.counts.get("matin.gained.team.%d" % int(tid3), 0))
		var amt: float = Probe.amount("matin.amount.team.%d" % int(tid3))
		var tt2: TeamData = state.teams.get(tid3)
		var wgt: String = "—"
		if tt2 != null:
			wgt = "%.0f/%.0f" % [mv.calc_total_weight(tt2), mv.get_carry_capacity(tt2)]
		var mark: String = ""
		if c_all > 0 and c_pe + c_cf + c_zo + c_g != c_all:
			mark = "   ❌四類加不回 call"
		elif c_all == 0:
			mark = "   ←★★採集迴圈【從沒走到 material】"
		lines.append("   %-6d %6d %11d %11d %11d %9d %11.1f %11s%s" % [
			int(tid3), c_all, c_pe, c_cf, c_zo, c_g, amt, wgt, mark])
	lines.append("  ★★★載重/上限：`carry_full` 只有在【上限被吃滿】時才成立 —— 兩欄要一起讀。")
	# ★需求端（買料）那條【是另一條鏈】：採集是被動的，買料才是被決策的
	lines.append("")
	lines.append("═══ ★需求端（買料）＝另一條鏈：採集是【被動】的，沒有 goal/argmax 這一段 ═══")
	lines.append("   resolver.resource_candidate.res.material = %d（★「為了取得 material 而提的 candidate」）" % 		int(Probe.counts.get("resolver.resource_candidate.res.material", 0)))
	lines.append("   ★systems 的 (a)(b)(c)(d) 四格【只適用這一條】——★★被動採集沒有「有沒有提出」這個問題。")
	lines.append("")
	lines.append("★★兩條線【對齊看】：存量爬升的那幾天，當日拒絕有沒有跟著減少。")
	lines.append("★★★判讀留給 systems —— 本床只給軌跡，不說是 sink 還是窗長。")
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== material 軌跡 DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
