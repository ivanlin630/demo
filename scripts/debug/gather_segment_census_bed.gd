extends SceneTree
# @bed-kind: diagnostic
# slice: 等價剪枝 §1 量測（★取證，不含設計選擇）——**同一次 `gather` 之內，時間花在哪一段**
#
# ★★★這支床【只量不改】：spec §1 明寫「先知道做了什麼事，才談少做什麼」，
#   而判準表是 systems **寫在量之前**的 ⇒ ★量完照表走，**不准挑一個好看的方向**。
#
# ★量法：`SimRunner.phase_timing` 打開 ⇒ `FactionAISystem._fai_ph` 每 tick 帶著那一 tick 的分段耗時，
#   而它**每 tick 會被清一次** ⇒ ★★所以本床**每 tick 累加一次**，跑完才有整段期間的總額。
#   `DecisionContext._mc_on` 打開 ⇒ 拿到 `gather` 的**呼叫次數**（母體）。
#
# ★★必報三欄（spec §1）：
#   ①母體：gather 被呼叫幾次（★每段的【執行次數】見下面的誠實限②）
#   ②占比：★**不是絕對秒數** —— 單輪排行不可依，那是 WHAT 立過的規矩
#   ③「算了但沒人讀」：★**本床報這一欄**（構造式：算過幾次 vs 被讀過幾次）——
#     ★★而「讀」要分成【決策讀】與【診斷讀】兩欄，理由見下面那一段。
#     ★★★而「段內掃描實際跑幾圈」這一輪也量了（母體那一塊）。
#
# ★誠實限：
#   ①`phase_timing` 打開本身有成本 ⇒ **絕對秒數不可跨「開／關」比較**；本床只用它算【占比】。
#   ②`gather.*` 這 8 個檢查點是**順序執行**的計時樁 ⇒ 它們的「執行次數」≈ gather 呼叫次數，
#     ★**真正有意義的是【段內那些 O(隊數) 掃描實際跑了幾圈】，而那需要在掃描裡加計數器**
#     ⇒ ★這一輪【量了】：見輸出的「母體：四段各自掃了幾圈」那一塊。
#   ③本床只看 FactionAI 的相位表 —— 一次 gather 裡不屬於這張表的時間不在上面。
#
# env：GS_DAYS（預設 8）／GS_SEED（預設 1337）／GS_CONFIG（預設 warring_states）

var _undec: int = 0

func _initialize() -> void:
	_run()
	print("-- 分段普查結束；[不可判] ＝ %d --" % _undec)
	quit(2 if _undec > 0 else 0)

func _bed_self_check_tree() -> void:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short", "HEAD"], out)
	var sha: String = (out[0] as String).strip_edges() if not out.is_empty() else "UNKNOWN"
	out.clear()
	OS.execute("git", ["status", "--porcelain", "--", "scripts/"], out)
	var dirty: int = 0
	if not out.is_empty():
		for l in (out[0] as String).split("\n"):
			if l.strip_edges() != "": dirty += 1
	print("[TREE] HEAD=%s scripts-dirty=%d（%s）" % [sha, dirty, "clean" if dirty == 0 else "★dirty"])

func _run() -> void:
	var days: int = int(OS.get_environment("GS_DAYS")) if OS.has_environment("GS_DAYS") else 8
	var seed_val: int = int(OS.get_environment("GS_SEED")) if OS.has_environment("GS_SEED") else 1337
	var cfg: String = OS.get_environment("GS_CONFIG") if OS.has_environment("GS_CONFIG") else "warring_states"
	print("=== `gather` 分段普查（config=%s days=%d seed=%d）★只量不改 ===" % [cfg, days, seed_val])
	_bed_self_check_tree()

	# ★A2／A5：用環境變數關掉 memo（★關的是 memo，不是 tap）
	if OS.has_environment("MEMO_OFF") and OS.get_environment("MEMO_OFF") == "1":
		PathSystem.catchmemo_enabled = false
		print("[MEMO] ★★本輪 memo 關閉（A5 陽性對照）")
	seed(seed_val)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	SimRunner.phase_timing = true
	DecisionContext._mc_reset()
	DecisionContext._mc_on = true
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var total: Dictionary = {}       # 相位名 → 累計 us
	for _i in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, no_player)
		# ★每 tick 累加：`_fai_ph` 每 tick 被清一次，不累加就只剩最後一 tick
		for k in FactionAISystem._fai_ph:
			total[k] = int(total.get(k, 0)) + int(FactionAISystem._fai_ph[k])
	DecisionContext._mc_on = false
	SimRunner.phase_timing = false

	var calls: int = DecisionContext._mc_calls
	var gather_us: int = 0
	var rows: Array = []
	for k in total:
		if String(k).begins_with("gather."):
			gather_us += int(total[k])
			rows.append({"n": k, "us": int(total[k])})
	rows.sort_custom(func(a, b): return int(a["us"]) > int(b["us"]))

	# ── A3/A4/A5 的讀數（★Probe 開之下才有） ──
	var _h: int = int(Probe.counts.get("catchmemo.hit", 0))
	var _m: int = int(Probe.counts.get("catchmemo.miss", 0))
	print("[MEMO] hit=%d miss=%d ⇒ hit率=%.4f（A3：應 ≈ D7 0.69；差很多 ⇒ 鑰匙錯了,別調門檻）" % [
		_h, _m, float(_h) / float(maxi(_h + _m, 1))])
	print("[MEMO] A4 母體：estimate_catch_up 總呼叫=%d（hit+miss；★應與 912861 同量級）" % [_h + _m])
	print("[MEMO] size_max=%.0f｜memo_enabled=%s" % [
		float(Probe.peaks.get("catchmemo.size_max", 0.0)), str(PathSystem.catchmemo_enabled)])

	print("\n[母體] gather 被呼叫 %d 次｜最後隊數 %d｜跑了 %d 天" % [calls, st.teams.size(), days])
	if calls == 0 or gather_us == 0:
		_undec += 1
		push_error("[不可判] 母體為 0（呼叫 %d 次／分段總額 %d us）⇒ 這一輪什麼都沒量到" % [
			calls, gather_us])
		return

	print("\n[★分段占比]（★占比是主欄；絕對秒數只作參考，因為 phase_timing 本身有成本）")
	print("   %-28s %10s %8s %12s" % ["段", "總額(s)", "占比", "每次呼叫(ms)"])
	for r in rows:
		var us: int = int(r["us"])
		print("   %-28s %10.3f %7.1f%% %12.3f" % [
			String(r["n"]), float(us) / 1e6, 100.0 * float(us) / float(gather_us),
			float(us) / float(maxi(calls, 1)) / 1000.0])
	print("   %-28s %10.3f %7.1f%%" % ["＝ gather.* 合計", float(gather_us) / 1e6, 100.0])

	# ── ★★★第三欄：算過幾次 vs 被讀過幾次（構造式，不是清單）──
	var n_compute: int = int(Probe.counts.get("gseg.compute.attack_scan", 0))
	var n_read: int = int(Probe.counts.get("gseg.read.decision.attack", 0))
	var n_diag: int = int(Probe.counts.get("gseg.read.diag.attack", 0))
	print()
	print("[★★★第三欄：attack_scan（gather.readiness_prey 段裡最貴的那個掃描）]")
	print("   算過 %d 次｜★決策讀 %d 次｜★★診斷讀 %d 次" % [n_compute, n_read, n_diag])
	if n_compute == 0:
		_undec += 1
		push_error("[不可判] attack_scan 這一輪算過 0 次 ⇒ 母體為 0，比值沒有意義")
	else:
		print("   ⇒ 決策讀／算過 ＝ %.2f" % [float(n_read) / float(n_compute)])
		print("   ★比值 ≪ 1 ⇒ 大量【算了沒人讀】⇒ 照判準表【先做誰讀誰算】；")
		print("   ★★比值 ≥ 1 ⇒ 每次算完都有決策在讀 ⇒ 這一段不是那一格，要走等價剪枝那一列。")
	print("   ★★★【診斷讀】單獨一欄的理由：decision_engine.gd:404-416 讀 ctx.attack_* 的那一塊")
	print("      全部餵給 Probe ⇒ 那是【觀測】不是【決策】。把它算進「有人讀」，會讓一個")
	print("      沒有任何決策在用的欄位看起來是必要的 —— ★量「讀」這個方法本身有這個坑。")

	print()
	# ── ★★★母體那一格（systems 裁 2026-09-18：先問事實，不先挑判準列）──
	#   問題：那幾段是不是【各自重跑同一個母體】的掃描？
	#   ⇒ 若是 ⇒ 真正的頭是「掃描本身」⇒ 形狀＝掃一次多段共用（★輸入相同輸出相同，等價，免證上界）
	#   ⇒ 若母體各不相同 ⇒ 回到原表（有可證上界則剪枝，否則結案）
	var it_attack: int = int(Probe.counts.get("gseg.scan.attack.iter", 0))
	var it_prey: int = int(Probe.counts.get("gseg.scan.prey.iter", 0))
	var it_threat: int = int(Probe.counts.get("gseg.scan.threat.iter", 0))
	var it_thr2: int = int(Probe.counts.get("gseg.scan.threat_inline.iter", 0))
	var it_home: int = int(Probe.counts.get("gseg.scan.home_food.iter", 0))
	var sub_be: int = int(Probe.counts.get("gseg.sub.best_estimate", 0))
	var mt_scored: int = int(Probe.counts.get("gseg.maxthreat.scored", 0))
	print()
	print("[★★★母體：四段各自掃了幾圈]（每次 gather 平均）")
	print("   readiness_prey(attack_scan)  %10d 圈｜每次 %.2f" % [it_attack, float(it_attack) / float(maxi(calls, 1))])
	print("   weak_prey(_find_weakest_prey)%10d 圈｜每次 %.2f" % [it_prey, float(it_prey) / float(maxi(calls, 1))])
	print("   threat(_max_threat)          %10d 圈｜每次 %.2f" % [it_threat, float(it_threat) / float(maxi(calls, 1))])
	print("   threat(★行內那條 :634)          %10d 圈｜每次 %.2f  ★★§0 漏數的第四條" % [it_thr2, float(it_thr2) / float(maxi(calls, 1))])

	print("   home_food(scout 迴圈)        %10d 圈｜每次 %.2f  ★母體不同（state.teams）" % [it_home, float(it_home) / float(maxi(calls, 1))])
	print("   共用子呼叫 best_estimate      %10d 次｜每次 %.2f" % [sub_be, float(sub_be) / float(maxi(calls, 1))])
	var same3: bool = (it_attack == it_prey and it_prey == it_threat and it_threat == it_thr2)
	print("   ⇒ ★【四條】走訪的圈數是否逐字相同：%s" % ("★是 ⇒ 同一個母體被掃了四次" if same3 else "否"))
	print("   ★★★_max_threat 過濾後真的算 score 的元素 ＝ %d／%d 圈（p ＝ %.3f）" % [
		mt_scored, it_threat, float(mt_scored) / float(maxi(it_threat, 1))])
	print("      ⇒ 合併共用後 threat.score_n 的預期比值 ＝ 1／(1+p) ＝ %.3f（★不是 0.5）" % [
		1.0 / (1.0 + float(mt_scored) / float(maxi(it_threat, 1)))])
	if it_attack == 0 or it_prey == 0 or it_threat == 0:
		_undec += 1
		push_error("[不可判] 有掃描的圈數是 0 ⇒ 母體為 0，上面的比較沒有意義")

	print("   ★註：上面「每次呼叫」是【段】的平均；【圈】的成本見上面那一塊。")
