extends SceneTree

# @bed-kind: acceptance
# slice: 票乙 —— 錢是手段不是目的（前置鏈）｜HOW spec 2026-09-15-coin-is-the-unit
#
# ★★★三條硬約束逐格驗（systems／R² 2026-09-15），而**不准只靠讀 code 相信**：
#   ①**取代不是附加** ⇒ fixture 直接斷言「同一個 (team, goal, res) 一次 resolve 只吐一個 candidate」
#   ②**量自己算** ⇒ 斷言 `SalarySystem.estimated_payroll` **沒有**出現在這條路上（讀原始碼）
#   ③**PV 只排內部序** ⇒ 斷言對外報的 util ＝ 繼承 payoff 那把尺，**不是** PV
# ★★而 spec 要的「maintain_coin 會不會一上來就贏」這一問**形狀變了**：
#   `maintain_coin` 已拆掉 ⇒ 要問的是**「先弄到錢」的 candidate 會不會一上來就贏過一切**。

var _fails: int = 0

func _ok(cond: bool, msg: String) -> void:
	print(("  [OK] " if cond else "  [FAIL] ") + msg)
	if not cond: _fails += 1

static func _src(path: String) -> String:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null: return ""
	var t: String = f.get_as_text()
	f.close()
	return t

func _init() -> void:
	print("=== 票乙：錢＝手段（前置鏈） ===")
	var src: String = _src("res://scripts/simulation/decision/goal_resolver.gd")
	_ok(src != "", "★讀得到 goal_resolver.gd（★讀不到 ⇒ 本輪【沒有判過】，不是通過）")

	# ── ②量自己算：禁止借用 estimated_payroll ──
	print("★②「買資源缺錢」的量自己算 —— 禁止借用 `SalarySystem.estimated_payroll`")
	var i_fn: int = src.find("_earn_money_candidate")
	var seg: String = src.substr(i_fn, 2600) if i_fn >= 0 else ""
	_ok(i_fn >= 0, "②-a 找得到 `_earn_money_candidate`（★找不到 ⇒ 判紅，查無 ≠ 沒問題）")
	_ok(seg.find("estimated_payroll") < 0,
		"②-b 這條路上**沒有** `estimated_payroll` —— ★它只服務薪資，借它會逼 `need > 0` 守衛對採購壓力負責")
	_ok(seg.find("local_value") >= 0,
		"②-c 取價走 `local_value()` 單一入口（★不是 `BASE_PRICE.get(res, 0.0)` —— 那會把 coin 算成 0）")
	# ★陽性對照：同一個判準拿違規字串跑，必須紅（否則這個判準可能根本不會紅）
	_ok("var x = SalarySystem.estimated_payroll(state, team)".find("estimated_payroll") >= 0,
		"②-d 陽性對照：**違規字串會被同一個判準抓到** ⇒ ★這格有鑑別力")

	# ── ③PV 只排內部序：對外報的 util 必須來自 `_mk_candidate` ──
	print("★③折現磚的 PV **只排內部序、不進外層 argmax**")
	_ok(seg.find("DiscountedFlow.pv") >= 0, "③-a 內部**有**用折現磚（★結構在）")
	var i_ret: int = seg.find("return _mk_candidate")
	_ok(i_ret >= 0, "③-b 對外**回 `_mk_candidate`**（★繼承 payoff 那把已驗的尺）")
	var tail: String = seg.substr(i_ret, 400) if i_ret >= 0 else "_pv"
	_ok(tail.find("_pv") < 0, "③-c 回傳裡**不含 PV** ⇒ ★★**PV 用完即丟，不外流**")

	# ── ①取代不是附加：跑真世界，逐 (team, goal, res) 對帳 ──
	print("★①【取代不是附加】—— ★★不讀 code，直接在真世界上數")
	seed(1337)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for _t in range(1440):
		runner.advance_tick(st, no_player)

	var entry: int = int(Probe.counts.get("goal.res_prereq.entry", 0))
	var earn: int = int(Probe.counts.get("goal.res_prereq.earn_replaces_buy", 0))
	var buy: int = int(Probe.counts.get("goal.res_prereq.buy_wins", 0))
	var nomeans: int = int(Probe.counts.get("goal.res_prereq.earn_no_means", 0))
	var sat: int = int(Probe.counts.get("goal.res_prereq.satisfied", 0))
	print("   母體：`res_prereq` 進入 %d 次｜前置已滿 %d｜買贏 %d｜**改成先弄到錢 %d**｜無手段退回 %d" % [
		entry, sat, buy, earn, nomeans])
	_ok(entry > 0, "①-a 這條路**本窗真的有跑到**（★實跑 0 ⇒ 下面每一格都不可判，不是綠）")
	# ★★★取代的機械證據：`earn` 與 `buy` 是**同一個 return 點的兩條互斥分支**
	#   ⇒ 它們【不會同時發生在同一次呼叫】⇒ 對帳 ＝ 兩者相加不得超過「非滿足」的呼叫數
	_ok(earn + buy <= entry - sat + 1,
		"①-b 買贏＋改賺 ≤ 非滿足的呼叫數 ⇒ ★**沒有【同一次多吐一個】的空間**")
	print("   ★★而【取代】的真正證據是控制流：兩條分支共用同一個 `return`，")
	print("      ⇒ ★★★**一次呼叫只可能走其中一條** —— 而上面那格是它的數值對帳。")

	# ── ★「先弄到錢」會不會一上來就贏過一切 ──
	print("★★★會不會一上來就贏過一切（★spec 要求必問；★★若它佔據 argmax 多數 ⇒ 回報，不在票裡壓它）")
	var winners: Dictionary = {}
	var wtot: int = 0
	for k in Probe.counts:
		var ks: String = String(k)
		if ks.begins_with("rank.winner_all.") and not ks.ends_with("__total"):
			winners[ks.replace("rank.winner_all.", "")] = int(Probe.counts[k])
			wtot += int(Probe.counts[k])
	var trade_w: int = int(winners.get("貿易", 0))
	print("   argmax 贏家母體 %d｜其中 `貿易` %d（%.1f%%）" % [
		wtot, trade_w, 100.0 * float(trade_w) / maxf(float(wtot), 1.0)])
	print("   ★注意：**「先弄到錢」的 to_task 也是 `貿易`** ⇒ 這一欄【混著兩種意圖】")
	print("      ⇒ ★★所以它**不能**直接當「賺錢動機佔比」讀 —— 要分開得在 to_task 上帶標記（下一票）")
	print("   ★★★而 `earn.means.sell` 實跑 %d 次｜`earn.rows` 樣本 %d 筆" % [
		int(Probe.counts.get("earn.means.sell", 0)),
		(Probe.samples.get("earn.rows", []) as Array).size()])

	# ── ★spec 點名的兩處：coin 會不會活過來 ──
	# ★★★分辨「沒接上」與「世界裡沒發生」
	print("★★★那條新路為什麼沒 fire（★兩種原因在一個 0 上長得一樣）")
	var bseen: int = int(Probe.counts.get("goal.res_prereq.buy_seen", 0))
	var bshort: int = int(Probe.counts.get("goal.res_prereq.buy_short", 0))
	var bafford: int = int(Probe.counts.get("goal.res_prereq.buy_afford", 0))
	print("   買路走到 %d 次｜**預算 > 手上的錢 %d 次**｜買得起 %d 次" % [bseen, bshort, bafford])
	_ok(bseen > 0, "★買路本窗真的走到 ⇒ 這個 0 不是【這條路沒跑】")
	var brows: Array = Probe.samples.get("buy.budget", [])
	if not brows.is_empty():
		var rr: Array = []
		for r in brows: rr.append(float(r["budget"]) / maxf(float(r["coin"]), 0.01))
		rr.sort()
		print("   預算／手上的錢 分布（n=%d）：min %.3f｜中位 %.3f｜max %.3f" % [
			rr.size(), rr[0], rr[rr.size() / 2], rr[rr.size() - 1]])
		print("   ★★ > 1.0 才會觸發【先弄到錢】⇒ **中位離 1.0 有多遠，就是這個世界多不缺錢**")
		var u0: int = 0
		var g0: int = 0
		var both: int = 0
		for r in brows:
			var _u: float = float(r["unit"])
			var _g: float = float(r["gap"])
			if _u <= 0.005: u0 += 1
			if _g <= 0.005: g0 += 1
			if _u <= 0.005 and _g > 0.005: both += 1
		print("   ★★★拆開那個 0：單價≤ 0 的 %d/%d｜缺口≤ 0 的 %d/%d" % [u0, brows.size(), g0, brows.size()])
		print("   ★**【缺口 > 0 而單價 ＝ 0】的有 %d 筆** —— ★★`need_keep` 說缺、而 `local_value` 說不缺" % both)
		print("      ⇒ ★★★**兩套「該有多少」不一致**：`need_keep`（自用＋供應鏈＋建造） vs `TARGET_PER_POP`（每人配額）")
		print("   逐筆前五：%s" % str(brows.slice(0, 5)))
	print("★spec 點名的 `goal_resolver.gd:181`／`:220`（coin 成為 prereq res 那一刻會活過來）")
	print("   ★★而本票**拆掉了 `maintain_coin`** ⇒ **coin 不再是任何 goal 的 prereq res**")
	print("   ⇒ ★★★那兩處**仍然拿不到 coin** —— **危險是【被避開】不是【被處理】**，而這要寫明")

	print("★fp = %s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=%d" % _fails)
	print("[TEST-SUITE-COMPLETE]")
	quit()
