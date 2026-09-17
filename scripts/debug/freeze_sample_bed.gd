extends SceneTree
# @bed-kind: diagnostic
# slice: 凍結終線 —— ★【取樣，不修任何東西】（blueprint 裁 (a) 2026-09-18）
#
# ★★★這支床回答一個問題，而且只回答這一個：
#   **「>2 秒的那些幀，時間花在哪一個【淨值】相位上？」**
#   ⇒ ★它**不優化**、**不改 production**、**不猜目標** ——
#     理由是 spec §⑥ 自己記著的那件事：**連續四張票每一版都先挑了一個看起來最大的去優化，
#     而前三個診斷後來都被推翻，只有讀既有 log 的那一版一次就對。**
#
# ★★母體與判準（★兩個都印，缺一不可）：
#   母體 ＝ 跑過的總幀數（`SimRunner.frames_total`）
#   命中 ＝ `dt > FRAME_BUDGET_US`（2 秒）的幀數（`SimRunner.frames_over_budget`）
#   ⇒ ★★★**若命中 ＝ 0 ⇒ 本次【不可判】**（不是「沒有凍結」——是這個窗口沒跑到，要拉長）
#
# ★誠實限：
#   ①`self_us` 的父子表是**手抄**的（`PHASE_PARENT`）⇒ 登記成錯誤的父親它不會紅（spec §⑤）
#   ②被標 `*multi` 的相位**不參與淨值減法**、單獨列出 ⇒ ★**它們的時間不會出現在任何父親的 self 裡**
#   ③本床**只看 FactionAI 的相位表** —— 一幀裡不屬於 FactionAI 的時間（渲染／其他系統）**不在這張表上**
#
# env：FS_DAYS（預設 12）／FS_SEED（預設 1337）／FS_CONFIG（預設 warring_states）／FS_TOP（預設 8）

var _fails: int = 0
var _undec: int = 0

func _initialize() -> void:
	_run()
	print("-- 量測完成；[FAIL] 數 ＝ %d｜[不可判] 數 ＝ %d --" % [_fails, _undec])
	print("[TEST-SUITE-COMPLETE]")
	quit(1 if _fails > 0 else 0)

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fails += 1
		push_error("[FAIL] %s" % msg)

func _undecidable(claim: String, why: String, how: String) -> void:
	_undec += 1
	push_error("[不可判] %s" % claim)
	print("  [不可判] %s\n       為什麼：%s\n       怎麼補：%s" % [claim, why, how])

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
	var days: int = int(OS.get_environment("FS_DAYS")) if OS.has_environment("FS_DAYS") else 12
	var seed_val: int = int(OS.get_environment("FS_SEED")) if OS.has_environment("FS_SEED") else 1337
	var cfg: String = OS.get_environment("FS_CONFIG") if OS.has_environment("FS_CONFIG") else "warring_states"
	var topn: int = int(OS.get_environment("FS_TOP")) if OS.has_environment("FS_TOP") else 8
	print("=== 凍結取樣（config=%s days=%d seed=%d）★只取樣，不修任何東西 ===" % [cfg, days, seed_val])
	_bed_self_check_tree()
	print("[判準] 母體 ＝ 跑過的幀數｜命中 ＝ 單幀 > %.1f 秒（★用戶包絡）" % [
		float(SimRunner.FRAME_BUDGET_US) / 1e6])

	seed(seed_val)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	SimRunner.phase_timing = true          # ★opt-in：只為量測，不改行為（zero cost when off）
	SimRunner.frames_total = 0
	SimRunner.frames_over_budget = 0
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	# ★每一個 >2s 的幀，把【它自己那一幀】的相位表抓下來（`_fai_ph` 由 runner 每 tick 清一次）
	var freeze_rows: Array = []            # [{tick, dt_us, teams, phases:{name:us}}]
	var self_sum: Dictionary = {}          # 相位名 → 跨凍結幀的 self_us 加總
	var tot_sum: Dictionary = {}
	var multi_sum: Dictionary = {}
	var ticks: int = days * WorldState.TICKS_PER_DAY
	for i in range(ticks):
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(st, no_player)
		var dt: int = Time.get_ticks_usec() - t0
		if dt <= SimRunner.FRAME_BUDGET_US:
			continue
		var ph: Dictionary = FactionAISystem._fai_ph.duplicate(true)
		freeze_rows.append({"tick": st.world.current_tick, "dt": dt, "teams": st.teams.size(), "n_ph": ph.size()})
		# ★淨值：與 production 同一支函式的口徑（★不要在床裡自己算一份會 drift 的）
		var selfs: Dictionary = _self_us(ph)
		for k in selfs:
			if String(FactionAISystem.PHASE_PARENT.get(k, "")) == "*multi":
				multi_sum[k] = int(multi_sum.get(k, 0)) + int(ph[k])
			else:
				self_sum[k] = int(self_sum.get(k, 0)) + int(selfs[k])
			tot_sum[k] = int(tot_sum.get(k, 0)) + int(ph[k])

	print("\n[母體] 跑過 %d 幀（%d 天）｜★>2 秒的幀 ＝ %d 幀（%.2f%%）｜最後隊數 %d" % [
		SimRunner.frames_total, days, SimRunner.frames_over_budget,
		100.0 * float(SimRunner.frames_over_budget) / float(maxi(SimRunner.frames_total, 1)),
		st.teams.size()])
	if freeze_rows.is_empty():
		_undecidable("「>2 秒的幀，時間花在哪個淨值相位上」",
			"這個窗口【一幀都沒有超過 2 秒】⇒ 沒有母體可看（★不是『沒有凍結問題』，是這一輪沒跑到）",
			"拉長 FS_DAYS（隊數會長大，凍結通常出現在隊數起來之後）或換 seed")
		return

	print("\n[凍結幀逐筆]（最多印 12 筆）")
	for r in freeze_rows.slice(0, mini(12, freeze_rows.size())):
		print("   tick=%d dt=%.2fs teams=%d phases=%d" % [
			int(r["tick"]), float(r["dt"]) / 1e6, int(r["teams"]), int(r["n_ph"])])

	print("\n[★self_us 排行（只含凍結幀；★★這是【淨值】不是總計）] 前 %d 名" % topn)
	var rows: Array = []
	for k in self_sum:
		rows.append({"n": k, "self": int(self_sum[k]), "tot": int(tot_sum.get(k, 0))})
	rows.sort_custom(func(a, b): return int(a["self"]) > int(b["self"]))
	var shown: int = 0
	for r in rows:
		if shown >= topn: break
		print("   %-34s self=%8.3fs  total=%8.3fs" % [
			String(r["n"]), float(r["self"]) / 1e6, float(r["tot"]) / 1e6])
		shown += 1
	if not multi_sum.is_empty():
		print("\n[★multi 列：不參與淨值減法，單獨列出]（它們的時間【不在】任何父親的 self 裡）")
		var mrows: Array = []
		var multi_total: int = 0
		for k in multi_sum:
			mrows.append({"n": k, "tot": int(multi_sum[k])})
			multi_total += int(multi_sum[k])
		mrows.sort_custom(func(a, b): return int(a["tot"]) > int(b["tot"]))
		# ★★★【全部印，不截斷】（blueprint 裁 2026-09-18）——兩輪要【逐列對照】，
		#   截斷會讓對照在第 7 列以後變成「兩邊都沒有資料」而不是「兩邊都穩」。
		for r in mrows:
			print("   %-34s total=%8.3fs" % [String(r["n"]), float(r["tot"]) / 1e6])
		# ★★★【`*multi` 必須進候選對比】（blueprint 裁 2026-09-18）——
		#   ★理由是本床誠實限②【我自己標的】：multi 不參與減法 ⇒ **它的時間不在任何父親的 self 裡**
		#   ⇒ ★★它天生【站在排行外面】：只看排行去挑優化目標，就會漏掉一塊可能比第一名還大的時間。
		#   ★★★所以這裡把它做成一行【可比的數】，而不是一段要人自己去加總的附註。
		var top_self: int = int(rows[0]["self"]) if not rows.is_empty() else 0
		var top_name: String = String(rows[0]["n"]) if not rows.is_empty() else "—"
		print("\n[★★候選對比] 排行第一 %s self=%.3fs　vs　★`*multi` 合計=%.3fs（%d 列）⇒ multi／第一 ＝ %.2f×" % [
			top_name, float(top_self) / 1e6,
			float(multi_total) / 1e6, mrows.size(),
			float(multi_total) / float(maxi(top_self, 1))])
		print("     ★這一行存在的理由：`*multi` 不會出現在排行裡，而它可能比排行第一【大】。")

	# ★★★可判性：只有「有凍結幀」才算量到；★而本床不判「該修誰」——那是下一票
	_ok(SimRunner.frames_over_budget > 0,
		"★母體非 0：這一輪真的有 >2 秒的幀（%d／%d）" % [
			SimRunner.frames_over_budget, SimRunner.frames_total])
	_ok(not rows.is_empty(),
		"★★凍結幀裡真的有 FactionAI 的相位資料（%d 個相位名）" % rows.size()
		+ "｜★為 0 ⇒ 那些幀的時間不在這張表上（渲染／其他系統）⇒ 這張表回答不了那一幀")

# ★與 production `phase_report` 同口徑的淨值：self ＝ total − Σ(直接子)；`*multi` 不參與減法
func _self_us(ph: Dictionary) -> Dictionary:
	var selfs: Dictionary = {}
	for k in ph:
		selfs[k] = int(ph[k])
	for k in ph:
		var parent: String = String(FactionAISystem.PHASE_PARENT.get(k, ""))
		if parent == "" or parent == "*multi":
			continue
		if selfs.has(parent):
			selfs[parent] = int(selfs[parent]) - int(ph[k])
	return selfs
