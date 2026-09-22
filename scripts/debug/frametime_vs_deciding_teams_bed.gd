extends SceneTree
# @bed-kind: diagnostic
# slice: 幀時是不是由【本 tick 有幾隊在決策】解釋（★純量測，不動行為）
#
# ★★★不每 tick 印：12 天 ＝ 17280 tick × 2 seed，★I/O 會變成被量的成本本身
#   ⇒ 累積在 `SimRunner.ft_samples`（交錯存 teams, dt），結尾一次 dump。
# ★★母體衛生：桶 n < 30 標【不可判】—— ★不要印一個漂亮的中位數在 5 個樣本上。
# ★主判準是【比值】（凍結幀 vs 非凍結幀的決策隊數中位數）⇒ 不受樁成本影響，只受樁失真影響
#   ⇒ 失真由 FT_OFF=1 的對照跑證（gather 呼叫數、圈數必須逐字相同）。
#
# env：FT_DAYS（預設 12）／FT_SEED（預設 1337）／FT_CONFIG（預設 warring_states）／FT_OFF=1（關樁）

const FREEZE_US: int = 2000000   # ★凍結幀定義：dt > 2s（用戶包絡，與 FRAME_BUDGET 同源語意）

func _initialize() -> void:
	var days: int = int(OS.get_environment("FT_DAYS")) if OS.has_environment("FT_DAYS") else 12
	var sd: int = int(OS.get_environment("FT_SEED")) if OS.has_environment("FT_SEED") else 1337
	var cfg: String = OS.get_environment("FT_CONFIG") if OS.has_environment("FT_CONFIG") else "warring_states"
	var off: bool = OS.get_environment("FT_OFF") == "1"
	print("=== 幀時 vs 決策隊數（days=%d seed=%d config=%s FT_OFF=%s）===" % [days, sd, cfg, str(off)])

	seed(sd)
	Probe.reset(); Probe.arm()
	SimRunner.ft_samples = PackedInt32Array()
	SimRunner.ft_teams_this_tick.clear()
	SimRunner.ft_on = not off
	DecisionContext._mc_reset()
	DecisionContext._mc_on = true   # ★對照欄需要它;★★兩臂(FT_OFF 開/關)都開 ⇒ 對照本身同配置
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var n_ticks: int = days * WorldState.TICKS_PER_DAY
	for _t in range(n_ticks):
		runner.advance_tick(st, Vector2i(-1, -1))

	# ★對照欄（樁失真用）：這兩個數在 FT_OFF=1 與 FT_OFF=0 之間必須逐字相同
	print("[FT] ★對照欄：gather 呼叫=%d｜attack_scan 圈數=%d｜最後隊數=%d｜tick=%d" % [
		int(DecisionContext._mc_calls), int(Probe.counts.get("gseg.scan.attack.iter", 0)),
		st.teams.size(), st.world.current_tick])
	if off:
		print("=== frametime_vs_deciding_teams DONE（FT_OFF：只出對照欄）===")
		quit(0)
		return

	var s: PackedInt32Array = SimRunner.ft_samples
	var n: int = s.size() / 2
	print("[FT] ★母體：取樣 tick 數=%d（跑了 %d tick）" % [n, n_ticks])
	if n < 100:
		push_error("[FT][不可判] 取樣 tick 只有 %d ⇒ 母體塌陷（樁沒接上，不是世界很短）" % n)
		quit(2)
		return

	# ── 分桶 ──
	var edges: Array = [0, 1, 3, 6, 11]   # 桶：0｜1-2｜3-5｜6-10｜11+
	var names: Array = ["0", "1-2", "3-5", "6-10", "11+"]
	var buckets: Array = []
	for _i in range(names.size()): buckets.append([])
	var all_dt: Array = []
	var frozen_teams: Array = []
	var normal_teams: Array = []
	for i in range(n):
		var teams: int = s[i * 2]
		var dt: int = s[i * 2 + 1]
		all_dt.append(dt)
		var bi: int = 0
		for e in range(edges.size()):
			if teams >= int(edges[e]): bi = e
		buckets[bi].append(dt)
		if dt > FREEZE_US: frozen_teams.append(teams)
		else: normal_teams.append(teams)

	print("\n[FT] 分桶（★n<30 標【不可判】，不印中位數）")
	print("[FT] %-7s %8s %10s %10s %10s %10s %8s" % ["桶", "n", "median", "p90", "p99", "max", "凍結率"])
	for b in range(names.size()):
		var arr: Array = buckets[b]
		if arr.size() < 30:
			print("[FT] %-7s %8d %10s ← ★不可判（n<30）" % [String(names[b]), arr.size(), "—"])
			continue
		arr.sort()
		var frz: int = 0
		for v in arr:
			if int(v) > FREEZE_US: frz += 1
		print("[FT] %-7s %8d %10d %10d %10d %10d %7.2f%%" % [
			String(names[b]), arr.size(), _q(arr, 0.5), _q(arr, 0.9), _q(arr, 0.99),
			int(arr[arr.size() - 1]), 100.0 * float(frz) / float(arr.size())])

	all_dt.sort()
	print("\n[FT] ★全體 dt（普通 tick 的基準）：median=%d p90=%d p99=%d max=%d us｜n=%d" % [
		_q(all_dt, 0.5), _q(all_dt, 0.9), _q(all_dt, 0.99), int(all_dt[all_dt.size() - 1]), all_dt.size()])

	# ── ★主判準：凍結幀 vs 非凍結幀的【決策隊數】中位數比 ──
	print("\n[FT] ★★★主判準（預註冊）：凍結幀 vs 非凍結幀的決策隊數中位數比")
	print("[FT]   凍結幀 n=%d｜非凍結 n=%d" % [frozen_teams.size(), normal_teams.size()])
	if frozen_teams.size() < 30 or normal_teams.size() < 30:
		push_error("[FT][不可判] 凍結 n=%d／非凍結 n=%d，任一 <30 ⇒ 母體太小，不得下判" % [
			frozen_teams.size(), normal_teams.size()])
	else:
		frozen_teams.sort()
		normal_teams.sort()
		var mf: int = _q(frozen_teams, 0.5)
		var mn: int = _q(normal_teams, 0.5)
		print("[FT]   凍結幀 median 決策隊數=%d｜非凍結 median=%d" % [mf, mn])
		if mn == 0:
			push_error("[FT][不可判] 非凍結 median ＝ 0 ⇒ 比值算不出來")
		else:
			var ratio: float = float(mf) / float(mn)
			print("[FT]   ★比值 = %.2f（★預註冊：≥2 ⇒ 母體控制｜<1.5 ⇒ 回到單價｜1.5~2.5 ⇒ 不可判）" % ratio)
			print("[FT]   ★★而【相關 ≠ 因果】：這只說「大 tick 伴隨多隊決策」，不說「多隊決策造成大 tick」")
	# ── ★週期性：11+ tick 之間的間距分佈（★結尾一次算，仍然不每 tick 印）──
	#   ★對齊（排程）⇒ 間距會集中在固定值；★★叢集（天然）⇒ 間距不規則。
	#   ★★★而我先前【沒有把序列寫出來】⇒ 這一格從舊 raw 答不出來,只能補跑一輪。
	var hot: Array = []
	for i2 in range(n):
		if s[i2 * 2] >= 11: hot.append(i2)
	print("
[FT] ★★週期性：11+ 決策隊的 tick 共 %d 個" % hot.size())
	if hot.size() < 30:
		push_error("[FT][不可判] 11+ tick 只有 %d 個 ⇒ 間距母體太小" % hot.size())
	else:
		var gaps: Dictionary = {}
		for i3 in range(1, hot.size()):
			var g: int = int(hot[i3]) - int(hot[i3 - 1])
			gaps[g] = int(gaps.get(g, 0)) + 1
		var gk: Array = gaps.keys()
		gk.sort_custom(func(a, b): return int(gaps[a]) > int(gaps[b]))
		var tot: int = hot.size() - 1
		print("[FT]   間距分佈（前 8，母體 %d 個間距）：" % tot)
		var top1: float = 0.0
		for j in range(mini(8, gk.size())):
			var c: int = int(gaps[gk[j]])
			if j == 0: top1 = 100.0 * float(c) / float(tot)
			print("[FT]     間距 %-6d ×%-5d（%.1f%%）" % [int(gk[j]), c, 100.0 * float(c) / float(tot)])
		print("[FT]   ★相異間距值 %d 種｜top-1 佔 %.1f%%" % [gk.size(), top1])
		print("[FT]   ★★判讀提示（不是判決）：top-1 佔比高且間距值少 ⇒ 偏【排程對齊】；反之偏【天然叢集】")
	# ── ★n_deciders 分佈（WHAT 指出：「11+」是桶的【下緣】,我們不知道尖峰多大）──
	var nd: Array = []
	var alive: Array = []
	var ser: PackedInt32Array = SimRunner.ft_series
	for k in range(ser.size() / 3):
		nd.append(ser[k * 3 + 1])
		alive.append(ser[k * 3 + 2])
	nd.sort()
	var nd_max: int = int(nd[nd.size() - 1])
	var alive_last: int = int(alive[alive.size() - 1])
	print("\n[FT] ★★n_deciders 分佈：median=%d p90=%d p99=%d ★max=%d｜最後存活隊數=%d" % [
		_q(nd, 0.5), _q(nd, 0.9), _q(nd, 0.99), nd_max, alive_last])
	print("[FT]   ★尖峰佔存活隊數 = %.1f%%（max %d ／ 存活 %d）——★母體同印" % [
		100.0 * float(nd_max) / float(maxi(alive_last, 1)), nd_max, alive_last])
	# ── ★歸因：尖峰 tick 上,哪些 cadence 欄位到期 ──
	var dh: Dictionary = SimRunner.ft_due_hits
	var dk: Array = dh.keys()
	dk.sort_custom(func(a, b): return int(dh[a]) > int(dh[b]))
	print("[FT] ★★★尖峰歸因（欄位清單掃 get_property_list,不手抄）：相異欄位 %d 個" % dk.size())
	var dsum: int = 0
	for v in dh.values(): dsum += int(v)
	for j in range(mini(8, dk.size())):
		print("[FT]   %-32s %8d 次（%.1f%%）" % [String(dk[j]), int(dh[dk[j]]),
			100.0 * float(dh[dk[j]]) / float(maxi(dsum, 1))])
	if dk.size() > 0:
		print("[FT]   ★top-1 佔 %.1f%%（★單一層佔多數 ⇒ 那條路就是要改的;多層疊加 ⇒ 要改的是 cadence 之間的關係）" % [
			100.0 * float(dh[dk[0]]) / float(maxi(dsum, 1))])
	# ── ★序列 dump 成檔（不進 repo）──
	var outp: String = OS.get_environment("FT_SERIES_OUT") if OS.has_environment("FT_SERIES_OUT") else ""
	if outp != "":
		var f := FileAccess.open(outp, FileAccess.WRITE)
		if f != null:
			f.store_line("tick,n_deciders,alive")
			for k2 in range(ser.size() / 3):
				f.store_line("%d,%d,%d" % [ser[k2 * 3], ser[k2 * 3 + 1], ser[k2 * 3 + 2]])
			f.close()
			print("[FT] ★逐 tick 序列已寫出：%s（%d 行）" % [outp, ser.size() / 3])
	print("=== frametime_vs_deciding_teams DONE ===")
	quit(0)

func _q(sorted_arr: Array, q: float) -> int:
	var idx: int = int(floor(q * float(sorted_arr.size() - 1)))
	return int(sorted_arr[clampi(idx, 0, sorted_arr.size() - 1)])
