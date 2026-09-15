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
	# ★★★窗長（systems REDO 2026-09-15）：**預設 30 天，與體檢卷可比**
	#   ★舊值 1440 ＝ **1 個遊戲天** ⇒ 起始糧還在 ⇒ `maintain_food` 全 satisfied
	#   ⇒ ★★那不是【機制不通】，是【動詞還沒機會 fire】。
	var _ticks: int = int(OS.get_environment("CP_TICKS")) if OS.has_environment("CP_TICKS") else 43200
	print("★窗：%d tick ＝ %.1f 天（★與體檢卷的 30 天可比）" % [_ticks, float(_ticks) / 1440.0])
	for _t in range(_ticks):
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

	# ══ ★★★【宣告式母體】：該缺錢的那些隊（systems DISPATCH 2026-09-15）══
	#   ★我上一卷報的「中位 0.190」是**發現式母體**（誰走到就算誰）
	#   ⇒ ★★**「他們不缺錢」與「他們根本沒被問」在一個中位數上長得一模一樣**。
	#   ★★★三個格子的順序不能換：①母體多大 → ②其中幾支真的走進買路 → ③分布。
	print("")
	print("★★★【宣告式母體】該缺錢的隊（★謂詞不得放寬：一鬆，母體就會長成我想要的形狀）")
	var setA: Dictionary = {}
	var noOutpost: int = 0
	var plainsOutpost: int = 0
	var setB: Dictionary = {}
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if t == null: continue
		# (A) 買糧壓力：自家據點所在格 terrain != "plains"
		#     ★依據 `outpost_system.gd:105` farming 的 `required_terrain: "plains"`
		#     ★★而謂詞看【據點格地形】，**不是「有沒有農田」**（規則只擋建址）
		# ★★★(A) ＝ 0 有兩種：【據點在平原】與【根本沒有據點】
		#   ⇒ ★不拆就會把「這把刀砍不到人」讀成「大家都住平原」。
		# ★★★謂詞訂正（2026-09-15）：(A) 改用【擁有】`own_outpost_tile()`，
		#   ★而不是【登記】`work_outpost` —— **因為登記需要 PRODUCE tag，而全世界 PRODUCE 隊 ＝ 0**
		#   ⇒ ★★用登記當謂詞，量到的是【沒人登記】，**不是【沒人住非平原】**。
		var _ot0 = st.own_outpost_tile(int(tid))
		if _ot0 == null:
			noOutpost += 1
		else:
			if str(_ot0.terrain) != "plains":
				setA[int(tid)] = str(_ot0.terrain)
			else:
				plainsOutpost += 1
		# (B) 薪資壓力：既有的真實量（不是手抄）
		if SalarySystem.estimated_payroll(st, t) > 0.0:
			setB[int(tid)] = true
	var interAB: Array = []
	for k in setA:
		if setB.has(k): interAB.append(k)
	# ★★★全 tile 掃描【拿掉】：`world.tiles` 太大，實測在那一步被超時殺掉兩趠
	#   ⇒ ★而【被殺】與【數出來是 0】在日誌上差很多 —— 前者根本沒有結果。
	#   ⇒ ★★改用逐隊 `own_outpost_tile()`（63 次，**有界**）—— 而那本來就是 systems 問的謂詞。
	var produce_n: int = 0
	var reg_n: int = 0   # ★真正的【登記】數（work_outpost 非空）—— ★★不得由【擁有】導出
	var own_n: int = 0
	var own_terr: Dictionary = {}
	var both_n: int = 0
	for tid2 in st.teams:
		var t2: TeamData = st.teams[tid2]
		if t2 == null: continue
		if t2.tags.has(TeamData.TAG_PRODUCE): produce_n += 1
		if t2.work_outpost != Vector2i(-1, -1): reg_n += 1
		var ot = st.own_outpost_tile(int(tid2))
		if ot != null:
			own_n += 1
			own_terr[str(ot.terrain)] = int(own_terr.get(str(ot.terrain), 0)) + 1
			if t2.work_outpost != Vector2i(-1, -1): both_n += 1
	print("   ★★★三個數一起報（不先挑一個講）：")
	print("      (a) PRODUCE 隊 **%d 支**｜(b) 【擁有】據點 **%d 支**（地形 %s）｜【登記】**%d 支**｜交集 **%d 支**" % [
		produce_n, own_n, str(own_terr), reg_n, both_n])
	# ★★★兩個收口的數（systems 2026-09-15）：
	#   ①那 18 個據點的 `outpost_type`（★civilian 才給 PRODUCE，否則給 MILITARY）
	#   ②那幾支沒被問的隊，`maintain_food` 是 satisfied 還是 active
	var otype: Dictionary = {}
	for tid3 in st.teams:
		var ot3 = st.own_outpost_tile(int(tid3))
		if ot3 == null: continue
		otype[str(ot3.outpost_type)] = int(otype.get(str(ot3.outpost_type), 0)) + 1
	# ★★★那些 civilian 據點是【起始預置】還是【蓋出來】（systems 必答）：
	#   ★若是 genesis 預置 ⇒ **沒有「完工安頓」那個動詞可以給 PRODUCE 身分**
	#   ⇒ ★★而那就不是「寫入點沒跑」，是「那條路從來沒被走過」。
	print("   ★③ 完工安頓動詞本窗 fire 次數：`outpost.settle_builder` %d｜`outpost.built` %d" % [
		int(Probe.counts.get("outpost.settle_builder", 0)), int(Probe.counts.get("outpost.built", 0))])
	print("      ⇒ ★若兩者都是 0 而據點有 18 個 ⇒ **它們是起始預置的**")
	print("   ★①那 %d 個據點的 outpost_type：%s" % [own_n, str(otype)])
	print("      ⇒ ★★`civilian` 才給 PRODUCE tag（`outpost_system.gd:545`）⇒ 其餘型別給 MILITARY")
	var st_cnt: Dictionary = {}
	var asked: Dictionary = {}
	for k2 in setA:
		asked[int(k2)] = int(Probe.counts.get("buy.byteam.t%d" % int(k2), 0)) > 0
	for k2 in setA:
		var t4: TeamData = st.teams.get(int(k2))
		if t4 == null: continue
		var found: String = "(沒有這個 goal)"
		for g4 in t4.goal_state:
			if String((g4 as Dictionary).get("goal_type", "")) == "maintain_food":
				found = String((g4 as Dictionary).get("status", "?"))
				break
		var key4: String = ("被問過/" if asked.get(int(k2), false) else "沒被問/") + found
		st_cnt[key4] = int(st_cnt.get(key4, 0)) + 1
	print("   ★★★②那 %d 支（A 母體）的 `maintain_food` 狀態 × 有沒有被問：%s" % [
		setA.size(), str(st_cnt)])
	print("      ⇒ ★**satisfied ⇒ 它不缺糧**（沒走進買路是合理的）")
	print("      ⇒ ★★**active 而沒被問 ⇒ 那才是【斷點在買之前】**（而它會是一個新問題）")
	print("      ⇒ ★【登記】與【擁有】是兩個謂詞，它們不一致是既有 known issue —— **這裡只報數，不解釋**")
	print("   ★(A) 拆開（【擁有】謂詞）：**根本沒有據點 %d 支**｜**據點在平原 %d 支**" % [noOutpost, plainsOutpost])
	print("   ①母體：(A) 非平原據點 **%d 支**｜(B) 有薪資壓力 **%d 支**｜A∩B **%d 支**（全世界 %d 支）" % [
		setA.size(), setB.size(), interAB.size(), st.teams.size()])
	if setA.is_empty() and setB.is_empty():
		print("   ★★★母體 ＝ 0 ⇒ **整件事不可判** —— 而那本身就是答案：")
		print("      **這個世界目前沒有【該缺錢】的隊** ⇒ 不往下算")
	else:
		var inA: int = 0
		var inB: int = 0
		for k in setA:
			if int(Probe.counts.get("buy.byteam.t%d" % int(k), 0)) > 0: inA += 1
		for k in setB:
			if int(Probe.counts.get("buy.byteam.t%d" % int(k), 0)) > 0: inB += 1
		print("   ②其中【真的走進買路】：A 裡 **%d/%d**｜B 裡 **%d/%d**" % [
			inA, setA.size(), inB, setB.size()])
		if inA == 0 and inB == 0:
			print("      ★★★**② ＝ 0** ⇒ 下面的分布**不得被引用** ——")
			print("         **「預算／現金從不過 1」是【沒量到】，不是【不缺錢】**")
			print("         ★而【該缺糧的隊沒有去買糧】本身就是一個發現（它比本票大）")
		else:
			var over1: int = 0
			var ratios: Array = []
			for r in Probe.samples.get("buy.budget", []):
				var _tm: int = int(r["team"])
				if not (setA.has(_tm) or setB.has(_tm)): continue
				var _rt: float = float(r["budget"]) / maxf(float(r["coin"]), 0.01)
				ratios.append(_rt)
				if _rt > 1.0: over1 += 1
			ratios.sort()
			if ratios.is_empty():
				print("      ★母體裡的隊有走買路，**而樣本裡一筆都沒抓到**（`buy.budget` 是 first-N 上限 300）")
				print("         ⇒ ★★**這不是分布，是取樣窗口** ⇒ 不可判")
			else:
				# ★★★【這個分布不可引用來回答「有沒有人過 1」】：
				#   ★`buy.budget` 是 **first-N 上限 300** ⇒ 它只蓋到【最早那一段】
				#   ⇒ ★★實測：計數說預算過 1 有上千次，**而這個樣本裡一筆都沒有**
				#   ⇒ ★★★**要回答「有沒有人過 1」請讀計數（`buy_short`），不要讀這一行**。
				print("      ③分布（n=%d，★first-N 早期窗）：min %.3f｜中位 %.3f｜max %.3f｜樣本裡過 1 的 %d 筆" % [
					ratios.size(), ratios[0], ratios[ratios.size() / 2],
					ratios[ratios.size() - 1], over1])
				print("         ★★而【全窗計數】才是答案：預算 > 手上的錢 **%d 次** / 買路走到 %d 次" % [
					int(Probe.counts.get("goal.res_prereq.buy_short", 0)),
					int(Probe.counts.get("goal.res_prereq.buy_seen", 0))])
	var _lst: Array = []
	for k in setA: _lst.append("t%d(%s)" % [int(k), str(setA[k])])
	print("   (A) 逐支：%s" % str(_lst.slice(0, 12)))
	print("★fp = %s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=%d" % _fails)
	print("[TEST-SUITE-COMPLETE]")
	quit()
