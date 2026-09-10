extends SceneTree
# @bed-kind: acceptance
# slice: 每小時全隊一起想 ⇒ 錯開（選項 A：到期檢查移出 60-tick 全域閘，改每 tick 檢查）
#
# ★★★這張票的核心不是「用了 CadenceStagger」，是【檢查頻率】：
#   只在 60 的倍數檢查 ⇒ offset≥1 就跳過一個檢查點 ⇒ 間隔 120 ⇒ 98.3% 的隊思考頻率砍半。
#   ⇒ ★所以驗收⑧（實際間隔分布）是必跑的：**不得只憑「用了工具」就假設分布正常**。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 6
const CAD: int = 60

func _initialize() -> void:
	print("=== solo think 錯開床 ===")
	_test_interval_distribution()
	_test_throughput()
	_test_spike_paired()
	_test_t0_not_delayed()
	_test_no_one_reads_phase()
	_test_cost_model()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _mk(cfg: String) -> WorldState:
	seed(4242)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/%s.json" % cfg))
	st.player_id = -1
	return st

# ── ⑧ 實際間隔分布（★R² 明文要求：不得假設它正常）────────────────────
func _test_interval_distribution() -> void:
	print("-- ⑧ 實際間隔分布（中位數 ≒60、min ≥ MIN_GAP=%d）--" % CadenceStagger.min_gap_of(CAD))
	var st := _mk("world_sim")
	var runner := SimRunner.new()
	var last: Dictionary = {}
	var last_sched: Dictionary = {}
	var gaps: Array = []
	var counts: Dictionary = {}
	var first: Dictionary = {}
	var woke_gaps: Array = []
	for i in range(600):
		# ★★分辨【排程到期】與【事件喚醒】：兩者的間隔語意不同 ——
		#   MIN_GAP 夾的是【排程】那條，事件喚醒【本來就該】比它短（護欄①要的正是這件事）
		#   ⇒ ★★★把兩者混在同一個分布裡，MIN_GAP 那一格會被事件喚醒判紅（床第一次跑就是這樣）。
		var due_before: Dictionary = {}
		for tid0 in st.teams:
			due_before[tid0] = (st.teams[tid0] as TeamData).solo_think_next_tick
		runner.advance_tick(st, Vector2i(-1, -1))
		for tid in st.teams:
			var t: TeamData = st.teams[tid]
			if t.solo_think_last_tick == 0:
				continue
			if int(last.get(tid, -1)) == t.solo_think_last_tick:
				continue
			var was_scheduled: bool = t.solo_think_last_tick >= int(due_before.get(tid, 0))
			if was_scheduled:
				# ★MIN_GAP 夾的是【排程與排程之間】—— 而事件喚醒可以插在中間，
				#   ★★所以基準要用【上一次排程】而不是【上一次思考】（床第一次跑就被這個判紅）。
				if last_sched.has(tid):
					gaps.append(t.solo_think_last_tick - int(last_sched[tid]))
				else:
					first[tid] = t.solo_think_last_tick
				last_sched[tid] = t.solo_think_last_tick
			elif last.has(tid):
				woke_gaps.append(t.solo_think_last_tick - int(last[tid]))
			last[tid] = t.solo_think_last_tick
			if was_scheduled:
				counts[tid] = int(counts.get(tid, 0)) + 1
	gaps.sort()
	if gaps.is_empty():
		_ok(false, "⑧★一個間隔都沒收集到 ⇒ 這一格【沒有測到】（母體地板）")
		_sections += 1
		return
	var med: int = int(gaps[gaps.size() / 2])
	print("    【排程】間隔 n=%d｜min=%d 中位=%d max=%d｜想過的隊 %d" % [
		gaps.size(), int(gaps[0]), med, int(gaps[-1]), counts.size()])
	print("    【事件喚醒】另外 %d 次（★它們本來就不受 MIN_GAP 夾 —— 護欄①要的就是這個）" % woke_gaps.size())
	_ok(abs(med - CAD) <= 5, "⑧中位間隔 %d ≒ %d（★若砍半會是 ~120，這一格就是那個 bug 的守衛）" % [med, CAD])
	_ok(int(gaps[0]) >= CadenceStagger.min_gap_of(CAD),
		"⑧min 間隔 %d ≥ MIN_GAP %d（wrap 那一次被夾住）" % [int(gaps[0]), CadenceStagger.min_gap_of(CAD)])
	# ⑥ 公平性：次數與首次 tick 不得與 team_id 單調相關
	var ids: Array = counts.keys()
	ids.sort()
	var mono_first: bool = true
	for i in range(1, ids.size()):
		if int(first.get(ids[i], 0)) < int(first.get(ids[i - 1], 0)):
			mono_first = false
			break
	var fl: Array = []
	for k in ids:
		fl.append("%s@%s" % [str(k), str(first.get(k, -1))])
	print("    首次【排程】思考 tick（按 team_id 排序）：%s" % str(fl))
	_ok(not mono_first, "⑥首次思考 tick 與 team_id 【不】單調相關（★輪轉層失效的話這格會紅）")
	var cmin: int = 999999
	var cmax: int = 0
	for k in counts:
		cmin = mini(cmin, int(counts[k]))
		cmax = maxi(cmax, int(counts[k]))
	print("    每隊思考次數：min=%d max=%d（600 tick／cadence 60 ⇒ 期望 ~10）" % [cmin, cmax])
	_ok(cmax - cmin <= 2, "⑥各隊【排程】次數差 %d ≤2（沒有人被系統性餓到）" % (cmax - cmin))
	_sections += 1

# ── ② 總吞吐：不是用少做事換不卡 ─────────────────────────────────────
func _test_throughput() -> void:
	print("-- ② 總吞吐（★新 tap：只在真的往下跑思考時 bump）--")
	Probe.arm()
	var st := _mk("world_sim")
	var runner := SimRunner.new()
	for i in range(600):
		runner.advance_tick(st, Vector2i(-1, -1))
	var total: int = 0
	var per_team: Array = []
	for tid in st.teams:
		var c: int = int(Probe.counts.get("solo.think.byteam.%04d" % int(tid), 0))
		if c > 0:
			per_team.append(c)
			total += c
	per_team.sort()
	print("    新 tap 逐隊次數：n=%d min=%d max=%d 總計 %d（期望每隊 ~%d）" % [
		per_team.size(), int(per_team[0]) if per_team.size() > 0 else -1,
		int(per_team[-1]) if per_team.size() > 0 else -1, total, 600 / CAD])
	_ok(per_team.size() > 0, "②★母體地板：真的有隊在走這條路（否則下面兩格沒有鑑別力）")
	_ok(int(per_team[0]) >= (600 / CAD) - 2,
		"②最少的那一隊也想了 %d 次 ≥ 期望-2 ⇒ ★沒有人被錯開【換成少做事】" % int(per_team[0]))
	_sections += 1

# ── ①③ 集中度：★★★而【牆鐘時間】那條路我走過了，它不可比（見下方註解）──────
func _test_spike_paired() -> void:
	print("-- ①③ 每 tick 有幾隊在想（★集中度：錯開 vs 強制同批）--")
	# ★★為什麼不比牆鐘 max：兩種模式下【世界會分岔】（思考次序變了 ⇒ 隊數/事件都不同）
	#   ⇒ 我實測過：錯開 max=8205ms／同批 8063ms、整點中位 1419 vs 1041ms
	#   ★★★那個差【不是排程造成的，是兩個不同的世界】—— 拿它當證據是把 confound 讀成效果。
	#   ⇒ 改量【機制本身】：同一個 tick 裡有幾隊在想。這個量不受世界分岔影響到同樣程度，
	#     而它正是 spike 的成因（26 秒那一下＝全世界擠在同一 tick）。
	var a: Dictionary = _concentration(false)
	var b: Dictionary = _concentration(true)
	print("    錯開      每 tick 最多 %d 隊在想｜有人想的 tick 佔 %.1f%%" % [int(a["max"]), float(a["busy_pct"])])
	print("    強制同批  每 tick 最多 %d 隊在想｜有人想的 tick 佔 %.1f%%" % [int(b["max"]), float(b["busy_pct"])])
	_ok(int(a["max"]) < int(b["max"]),
		"①③錯開之後【單 tick 最多幾隊一起想】從 %d 降到 %d ⇒ spike 的成因被打散了"
			% [int(b["max"]), int(a["max"])])
	_ok(float(a["busy_pct"]) > float(b["busy_pct"]),
		"③★另一半：錯開之後【有人在想的 tick】變多（%.1f%% > %.1f%%）—— 工作沒有消失，只是攤開了"
			% [float(a["busy_pct"]), float(b["busy_pct"])])
	_sections += 1

func _concentration(same_batch: bool) -> Dictionary:
	var st := _mk("warring_states")
	var runner := SimRunner.new()
	var worst: int = 0
	var busy: int = 0
	var ticks: int = 600
	for i in range(ticks):
		if same_batch:
			var nxt: int = ((st.world.current_tick / CAD) + 1) * CAD
			for tid in st.teams:
				(st.teams[tid] as TeamData).solo_think_next_tick = nxt
		runner.advance_tick(st, Vector2i(-1, -1))
		var n: int = 0
		for tid2 in st.teams:
			if (st.teams[tid2] as TeamData).solo_think_last_tick == st.world.current_tick:
				n += 1
		worst = maxi(worst, n)
		if n > 0:
			busy += 1
	return {"max": worst, "busy_pct": 100.0 * float(busy) / float(ticks)}

# ── ④ T0：事件喚醒不等相位 ───────────────────────────────────────────
func _test_t0_not_delayed() -> void:
	print("-- ④ T0：事件喚醒的隊【不等自己的相位】--")
	var st := _mk("world_sim")
	var runner := SimRunner.new()
	for i in range(120):
		runner.advance_tick(st, Vector2i(-1, -1))
	# 挑一支【相位還很遠】的隊
	var pick: int = -1
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if t.faction_id == -1 and t.parent_team_id == -1 and t.beast_kind == "" \
				and t.solo_think_next_tick - st.world.current_tick > 20:
			pick = int(tid)
			break
	if pick == -1:
		_ok(false, "④★找不到相位還遠的隊 ⇒ 這一格【沒有測到】")
		_sections += 1
		return
	var team: TeamData = st.teams[pick]
	var before: int = team.solo_think_last_tick
	var gap_to_phase: int = team.solo_think_next_tick - st.world.current_tick
	WorldEvents.emit(st, "labor_crisis", [pick])
	runner.advance_tick(st, Vector2i(-1, -1))
	print("    隊 %d 距離自己的相位還有 %d tick｜事件後 last_tick %d → %d" % [
		pick, gap_to_phase, before, team.solo_think_last_tick])
	_ok(team.solo_think_last_tick > before,
		"④事件喚醒的隊【當 tick】就想了，沒等那 %d tick 的相位" % gap_to_phase)
	_sections += 1

# ── ⑤ 沒有人讀相位 ───────────────────────────────────────────────────
func _test_no_one_reads_phase() -> void:
	print("-- ⑤ 相位是中性事實：排程器以外不得有人讀它 --")
	var hits: Array = []
	for d in ["res://scripts/simulation", "res://scripts/data"]:
		_scan(String(d), hits)
	print("    solo_think_next_tick 的出現處：%s" % str(hits))
	# 合法：team_data 宣告 ＋ faction_ai 的排程器本身
	var illegal: Array = []
	for h in hits:
		var s: String = String(h)
		if s.contains("team_data.gd") or s.contains("faction_ai_system.gd"):
			continue
		illegal.append(s)
	_ok(illegal.is_empty(), "⑤排程器以外零消費者（★否則相位會變成一個新的 god-view）")
	_ok(hits.size() >= 2, "⑤★母體地板：真的掃到 %d 處（空母體不得判綠）" % hits.size())
	_sections += 1

func _scan(dir_path: String, hits: Array) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		var full: String = dir_path + "/" + name
		if dir.current_is_dir():
			_scan(full, hits)
		elif name.ends_with(".gd"):
			var f := FileAccess.open(full, FileAccess.READ)
			if f != null:
				var i: int = 0
				for l in f.get_as_text().split("\n"):
					i += 1
					var line: String = String(l)
					var h: int = line.find("#")
					if h >= 0:
						line = line.substr(0, h)
					if line.contains("solo_think_next_tick"):
						hits.append("%s:%d" % [name, i])
				f.close()
		name = dir.get_next()
	dir.list_dir_end()

# ── ★★★成本模型（systems 要的那一格）：★在【同一跑之內】，不跨模式 ────────
#   用戶的問題是「還會不會卡 5-10 秒」，而集中度只答「有沒有攤開」。
#   ⇒ 這一格把集中度【翻譯成秒數】：逐 tick 記 (x=幾隊在想, y=tick wall-time)
#     ⇒ 印出 y 對 x 的關係 ⇒ 把 x=9（錯開後）與 x=17（同批）代進去。
#   ★而它不需要兩個世界：A 與 B 都來自同一個分布。
func _test_cost_model() -> void:
	print("-- ★成本模型（同一跑內）：x=幾隊在想 → y=tick 花多久 --")
	var st := _mk("warring_states")
	var runner := SimRunner.new()
	var by_x: Dictionary = {}          # x → [y…]（★只收【非整點】tick：整點還扛著別的每小時工作）
	var hour_us: Array = []
	var eligible: int = 0
	var offsets: Array = []
	for i in range(600):
		var is_hour: bool = (st.world.current_tick + 1) % CAD == 0
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(st, Vector2i(-1, -1))
		var dt: int = Time.get_ticks_usec() - t0
		var x: int = 0
		eligible = 0
		for tid in st.teams:
			var t: TeamData = st.teams[tid]
			if t.beast_kind == "" and t.parent_team_id == -1 and t.faction_id == -1:
				eligible += 1
				if i == 300:
					offsets.append(t.solo_think_next_tick % CAD)
			if t.solo_think_last_tick == st.world.current_tick:
				x += 1
		if is_hour:
			hour_us.append(dt)
			continue
		if not by_x.has(x):
			by_x[x] = []
		(by_x[x] as Array).append(dt)
	var xs: Array = by_x.keys()
	xs.sort()
	var pts: Array = []
	for x in xs:
		var arr: Array = by_x[x]
		arr.sort()
		pts.append([int(x), int(arr[arr.size() / 2]), arr.size()])
		print("    x=%2d 隊在想 ⇒ y 中位 %8.3f ms（n=%d）" % [int(x), float(arr[arr.size() / 2]) / 1000.0, arr.size()])
	hour_us.sort()
	print("    ★整點 tick（還扛著其餘每小時工作）中位 %.1f ms／max %.1f ms" % [
		float(hour_us[hour_us.size() / 2]) / 1000.0, float(hour_us[-1]) / 1000.0])
	# ★線性外推：★★只用【樣本夠多】的 x 點 —— 床第一次跑時 x=3 只有 1 筆（139 ms），
	#   而那一筆讓斜率變成 46 ms/隊 ⇒ ★★★單樣本點會把整條模型帶走，這種外推是假的。
	var solid: Array = []
	for pt in pts:
		if int(pt[2]) >= 10:
			solid.append(pt)
	if solid.size() < 2:
		print("    ★樣本夠多（n≥10）的 x 點只有 %d 個 ⇒ 【算不出可信的斜率】，不外推。" % solid.size())
		_ok(false, "★成本模型【不可判】：可信 x 點不足（這不是綠，是沒測到）")
		_sections += 1
		return
	var lo = solid[0]
	var hi = solid[-1]
	var k: float = 0.0
	if int(hi[0]) != int(lo[0]):
		k = float(int(hi[1]) - int(lo[1])) / float(int(hi[0]) - int(lo[0]))
	var base: float = float(int(lo[1])) - k * float(int(lo[0]))
	print("    ⇒ 成本模型（只用 n≥10 的點：x=%d 與 x=%d）y ≒ %.3f ＋ %.3f·x ms" % [
		int(lo[0]), int(hi[0]), base / 1000.0, k / 1000.0])
	print("    ⇒ 代入 x=9（錯開後 max）＝%.3f ms｜x=17（強制同批 max）＝%.3f ms" % [
		(base + k * 9.0) / 1000.0, (base + k * 17.0) / 1000.0])
	print("    ★★★而這一跑【沒有重現 26 秒】：整點 tick 中位 %.1f ms 由【其餘每小時工作】扛著，"
		% (float(hour_us[hour_us.size() / 2]) / 1000.0))
	print("       不是 solo 思考（solo 每隊只要 %.3f ms）⇒ 用戶感受得到的秒數要量測員在真 run 上量。"
		% (k / 1000.0))
	_ok(solid.size() >= 2, "★成本模型用了 %d 個樣本夠多的 x 點" % solid.size())
	# ★★systems §③：N 與 offset 分布 —— 9 到底是不是理論極限
	print("    ★★這一跑真正走這條路的隊 N=%d ⇒ 理論期望 x ≒ N/%d = %.2f" % [eligible, CAD, float(eligible) / float(CAD)])
	var hist: Dictionary = {}
	for o in offsets:
		var b: int = int(o) / 10
		hist[b] = int(hist.get(b, 0)) + 1
	var hl: Array = []
	for b in range(6):
		hl.append("%d-%d:%d" % [b * 10, b * 10 + 9, int(hist.get(b, 0))])
	print("    ★offset 直方圖（tick 300 當下，%d 隊）：%s" % [offsets.size(), " ".join(PackedStringArray(hl))])
	_ok(eligible > 0, "★母體地板：真的有 %d 隊走這條路（否則上面兩行沒有意義）" % eligible)
	_sections += 1
