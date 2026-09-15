extends SceneTree

# @bed-kind: acceptance
# slice: 攻擊的【機會＋需要】項（HOW spec 2026-09-12-attack-opportunity-drive）
#
# ★母體與「一趟」的定義：
#   ·§A【成對對照】＝ **合成 ctx**（不跑世界）⇒ 方向性判準，零雜訊、零母體問題
#   ·§B【分布】＝ 一段短窗模擬裡**每一次攻擊 option 被評分**（`attack.util.*` 計數 ＋ 非零樣本）
# ★★而 §A 與 §B 是兩個母體：★★★方向性用合成、佔比與分布用世界 —— 不混。
# env：AO_TICKS（預設 4320 ＝ 3 天；★機器吃緊時縮窗，數字照樣可判方向）／AO_SEED（1337）

var _fails: int = 0

# ★校準曲線的母體地板：低於它一律印【不可判】——★理由是 systems 那句「不要用 2 筆畫一條曲線」。
const CALIB_MIN_N: int = 20

func _initialize() -> void:
	_run(); quit(0 if _fails == 0 else 1)

func _ok(c: bool, m: String) -> void:
	if c: print("  [OK] %s" % m)
	else:
		_fails += 1
		push_error("[FAIL] %s" % m)

func _mk(loot: float, food_days: float, odds: float, vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.attack_target_id = 7          # ★門已開（本票不動門）
	c.attack_loot_est = loot
	c.attack_win_odds = odds
	c.food_days = food_days
	c.desperation_entry_threshold = DecisionTerms.DESPERATION_DAYS
	c.leader_values = vals
	return c

func _run() -> void:
	print("=== 攻擊【機會＋需要】驗收 ===")
	var neutral: Dictionary = {"好戰": 0.5, "貪婪": 0.5, "慎重": 0.5}
	# ── §A 成對對照（★兩格都要跑：只驗一邊證明不了秤在讀資產）──
	var fat: float = DecisionTerms.eval("attack_opportunity", _mk(3.0, 20.0, 1.0, neutral), "攻擊")
	var poor: float = DecisionTerms.eval("attack_opportunity", _mk(0.0, 20.0, 1.0, neutral), "攻擊")
	print("★§A 方向性：肥而弱 util=%.3f｜窮而弱 util=%.3f" % [fat, poor])
	_ok(fat > poor, "③-a **肥的目標分數高於窮的**（秤真的在讀 belief 資產）")
	_ok(poor >= 0.0 and poor < fat, "③-b 窮的目標分數**不為負且更低**（★不是把所有目標都推高）")
	# ★★而「餓」那一半也要成對：同樣窮的目標，餓的隊應該更想搶
	var hungry: float = DecisionTerms.eval("attack_opportunity", _mk(0.0, 1.0, 1.0, neutral), "攻擊")
	print("★§A 需要：窮目標＋自己餓 util=%.3f（vs 吃飽 %.3f）" % [hungry, poor])
	_ok(hungry > poor, "③-c **自己餓時分數更高**（需要那一半有接上）")
	# ★★★無牙 ⇒ 整項 0（★「打不贏就別打」是既有接地，不是新規矩）
	var toothless: float = DecisionTerms.eval("attack_opportunity", _mk(3.0, 1.0, 0.0, neutral), "攻擊")
	_ok(absf(toothless) < 0.0005, "③-d **無牙（贏率 0）⇒ 整項 0**（不是壓低，是 0）")
	# ★人格 MODULATE：好戰高 ⇒ 更高；慎重高 ⇒ 更低（★同一個【真值】被調製，不是加常數）
	var martial: float = DecisionTerms.eval("attack_opportunity", _mk(3.0, 20.0, 1.0,
		{"好戰": 0.9, "貪婪": 0.5, "慎重": 0.5}), "攻擊")
	var cautious: float = DecisionTerms.eval("attack_opportunity", _mk(3.0, 20.0, 1.0,
		{"好戰": 0.5, "貪婪": 0.5, "慎重": 0.9}), "攻擊")
	print("★人格：好戰 0.9 ⇒ %.3f｜中性 ⇒ %.3f｜慎重 0.9 ⇒ %.3f" % [martial, fat, cautious])
	_ok(martial > fat and cautious < fat, "★人格 MODULATE 真值（好戰↑／慎重↓），非 boost 常數")

	# ── §B 世界側：佔比與分布 ──
	var ticks: int = int(OS.get_environment("AO_TICKS")) if OS.has_environment("AO_TICKS") else 4320
	var seed_val: int = int(OS.get_environment("AO_SEED")) if OS.has_environment("AO_SEED") else 1337
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	# ★★★【晚期窗】（systems 2026-09-15）：`bump_sample` 是 **first-N**
	#   ⇒ ★不管窗多長，樣本永遠來自【最早那一段】
	#   ⇒ ★★而「餓的隊都沒牙」**很可能正是早期的樣子**。
	#   ⇒ ★★★`AO_RESET_AT=<tick>` ⇒ 跑到那一刻把 Probe 清空，
	#     **於是整份報告都只來自【那一刻之後】** —— 不是混兩種窗。
	var reset_at: int = int(OS.get_environment("AO_RESET_AT")) if OS.has_environment("AO_RESET_AT") else -1
	for _t in range(ticks):
		if reset_at > 0 and _t == reset_at:
			Probe.reset()
			Probe.arm()
			print("★【晚期窗】tick %d 清空 Probe ⇒ **下面每一個數字都只含 tick %d–%d**" % [
				reset_at, reset_at, ticks])
			# ★★★兩種結局的【效力不對稱】（systems 2026-09-15，寫在結論旁邊不是信裏）：
			#   ★這一段是【這一趡的後段】，**不是【世界的晚期】**。
			#   ⇒ ★★**出現**某個現象 ⇒ **它就是會發生**（出現就是出現）
			#   ⇒ ★★★**仍然是 0** ⇒ **只能說「到這一刻為止仍是 0」** —— **不能證明它永遠不發生**。
			print("   ⇒ ★★★效力不對稱：**出現就是出現**；**仍是 0 只能說「到 tick %d 為止仍是 0」**" % ticks)
			print("      ★因為這一段是【這一趡的後段】，不是【世界的晚期】")
		runner.advance_tick(st, no_player)
	var z: int = int(Probe.counts.get("attack.cmp.zero_final", 0))
	var nz: int = int(Probe.counts.get("attack.cmp.nonzero_final", 0))
	print("")
	print("★①攻擊 util：零 %d／非零 %d（母體 %d ＝ 每一次攻擊被評分；窗 %d tick／seed %d）" % [
		z, nz, z + nz, ticks, seed_val])
	_ok(nz > 0, "①**非零不再是 0 次**（★病因是四項全授權 ⇒ 沒授權時恆 0）")
	# ②分布活著：非零值的變異不得為 0（★全部同一個數也叫非零，而那是另一個常數）
	var vals: Array = []
	for r in Probe.samples.get("attack.nonzero_util", []): vals.append(float(r["u"]))
	if vals.size() >= 2:
		var m: float = 0.0
		for v in vals: m += float(v)
		m /= float(vals.size())
		var varsum: float = 0.0
		for v in vals: varsum += (float(v) - m) * (float(v) - m)
		var sd: float = sqrt(varsum / float(vals.size()))
		print("★②非零 util 分布：n=%d mean=%.3f sd=%.3f min=%.3f max=%.3f" % [
			vals.size(), m, sd, vals.min(), vals.max()])
		_ok(sd > 0.0001, "②**分布活著（sd > 0）**★★『有非零值』不算過——全同一個數是另一個常數")
	else:
		print("★②非零樣本 %d 筆 ⇒ **不可判**（不是綠）" % vals.size())
	# ④授權群 vs 無授權群
	var ua_z: int = int(Probe.counts.get("attack.util.unauthed.zero", 0))
	var ua_nz: int = int(Probe.counts.get("attack.util.unauthed.nonzero", 0))
	var a_z: int = int(Probe.counts.get("attack.util.authed.zero", 0))
	var a_nz: int = int(Probe.counts.get("attack.util.authed.nonzero", 0))
	print("★④授權群 零%d／非零%d｜**無授權群 零%d／非零%d**" % [a_z, a_nz, ua_z, ua_nz])
	if ua_z + ua_nz == 0:
		print("   ★無授權群母體 0 ⇒ **不可判**（不是綠）")
	else:
		_ok(ua_nz > 0, "④**無授權群 util 不再全為 0**（★★否則『加成』偷偷變回『唯一來源』）")
	# ⑦tier 分桶（★觀察，不是目標；禁為了它好看而調權重）
	var t_row: Dictionary = {}
	for k in Probe.counts:
		var ks: String = String(k)
		if ks.begins_with("attack.util.tier") and ks.ends_with(".nonzero"):
			t_row[ks.replace("attack.util.", "").replace(".nonzero", "")] = int(Probe.counts[k])
	print("★⑦非零 util 的 belief tier 分桶：%s" % str(t_row))
	# ★★★驗收⑦ 的真判準：**同一 tier 內，util 有沒有跟著 loot 走**（★「tier2 比較多」證明不了這件事）
	print("★⑦-b 逐 tier × 逐 loot 桶的**平均 util**（母體各自標；★空桶印【不可判】不印 0）：")
	for _t in [-1, 0, 1, 2]:
		var _row: String = "   tier%d：" % _t
		for _lb in ["loot0", "lootLo", "lootHi"]:
			var _n: int = int(Probe.counts.get("attack.tier%d.%s.n" % [_t, _lb], 0))
			var _sum: float = Probe.amount("attack.tier%d.%s.usum" % [_t, _lb])
			_row += "%s=%s(n=%d) " % [_lb, ("不可判" if _n == 0 else "%.3f" % (_sum / float(_n))), _n]
		print(_row)
	print("   ★判準：**同一列裡 lootHi 的平均要高於 loot0**（跟著肥瘦走）；")
	print("     ★★而 tier2 那一列的【落差】應該比 tier0/1 大（知道得多 ⇒ 分得更開）——★★★這是觀察不是目標")
	# ★★剩下的零是什麼（systems：一半的母體沒有解釋我不收）
	var _zb: Dictionary = {}
	for _k in Probe.counts:
		var _ks: String = String(_k)
		if _ks.begins_with("attack.opp.zero_by."):
			_zb[_ks.replace("attack.opp.zero_by.", "")] = int(Probe.counts[_k])
	print("★①-b 那些零是什麼（機會項的零，逐因分類）：%s" % str(_zb))
	_ok(int(_zb.get("unexplained", 0)) == 0,
		"①-b **沒有「無法解釋」的零**（有就是我漏了一種來源）★第一趟這格是紅的：1 筆 ⇒ 逼出第五種【量級】")
	print("   ★五桶的語意不同：`no_teeth`／`poor_and_fed` 是**結構**（秤說沒理由）、")
	print("     `personality` 是**人格**、★★`too_small` 是**量級**（每個因子都非 0 而乘積小於門檻）")
	print("   ★★注意母體不同：這一格分類的是【機會項自己的零】，")
	print("     而『零 final』是【五項相加之後】的零 —— ★★★兩個數不可互相相減")
	print("   ★這一格是【觀察】不是【目標】——★★不准為了讓它好看而調 tier 權重（禁 crank）")
	# ── ★★★輸入營養稽核（三種形狀分開；★這一段全部是【分析欄】：讀了真值，不回頭餵秤）──
	var rows: Array = Probe.samples.get("appetite.input", [])
	print("")
	print("★★★輸入有沒有營養（★三種形狀的處置不同 ⇒ 分開量）")
	print("   母體 %d 次（樣本上限 400，實收 %d）" % [int(Probe.counts.get("appetite.n", 0)), rows.size()])
	if rows.is_empty():
		print("   ★母體 0 ⇒ **不可判**（★★而那與「輸入沒營養」是兩個結論）")
	else:
		var ests: Array = []
		var trues: Array = []
		var ratios: Array = []
		for r in rows:
			ests.append(float(r["est"]))
			trues.append(float(r["true"]))
			if float(r["true"]) > 0.001:
				ratios.append(float(r["est"]) / float(r["true"]))
		ests.sort(); trues.sort()
		var _sd: float = 0.0
		var _m: float = 0.0
		for v in ests: _m += float(v)
		_m /= float(ests.size())
		for v in ests: _sd += (float(v) - _m) * (float(v) - _m)
		_sd = sqrt(_sd / float(ests.size()))
		print("   ①系統性低估：估中位 %.3f｜真值中位 %.3f｜%s" % [
			ests[ests.size() / 2], trues[trues.size() / 2],
			("估／真 中位 %.3f" % [ratios[ratios.size() / 2]] if ratios.size() >= 2 else "★估／真 母體不足 ⇒ 不可判")])
		print("   ③值域壓縮：估的 mean %.3f｜sd %.3f｜min %.3f｜max %.3f" % [
			_m, _sd, ests[0], ests[ests.size() - 1]])
		print("      ★★『單調但很淺』正是這一形狀的症狀（tier2 的 0.000→0.003→0.099）")
	var _d: Dictionary = {}
	for k in Probe.counts:
		if String(k).begins_with("appetite.dir."):
			_d[String(k).replace("appetite.dir.", "")] = int(Probe.counts[k])
	print("   ②雜訊（同向率，★粗判：以「是否 > 1.0」二分；精確版要離線算）：%s" % str(_d))
	print("      ★ET/et ＝ 同向｜Et/eT ＝ 反向；★★同向率低 ⇒ 秤在讀噪音 ⇒ 方向性是假的")
	# ── ★②-a 贏率估 vs 實戰（★systems 指定：先報母體，母體不足就明說不可判）──
	var _fought: int = int(Probe.counts.get("combat.ended_n", 0))
	print("   ★②-a 贏率校準的母體＝本窗**真的打完的仗** %d 場" % _fought)
	if _fought < CALIB_MIN_N:
		print("      ⇒ ★**不可判**（母體 < %d）★★而『不可判』與『贏率估得不准』是兩個結論" % CALIB_MIN_N)
		print("      ⇒ ★★★逐場配對（開打時的 `attack_win_odds` ↔ 實際勝負）**本卷刻意沒接**：")
		print("         接了也只能拿 %d 筆畫校準曲線，而那條曲線會比沒有更誤導人。" % _fought)
		print("         母體真的上到 %d 場那天，配對接線才是下一張票。" % CALIB_MIN_N)
	else:
		print("      ⇒ ★母體夠了（≥ %d）⇒ **逐場配對接線是下一張票**，本卷只報母體" % CALIB_MIN_N)
	print("   ★★★而【風險項】在本實作裡**沒有獨立欄位**（風險折在贏率裡）")
	print("      ⇒ ★所以「風險恆大把胃口壓平」這一格 **不適用**，而不是 0 —— 我不編一個欄位來填表")
	# ── ★★★因子拆解（systems 2026-09-15）：哪一個因子把乘積壓扁 ──
	# ★★★【宣告式母體】（systems 2026-09-15）：**我要這個窗的 N 筆** ——
	#   ★拿不到那麼多 ⇒ **具名紅**，而不是拿幾筆算幾筆。
	#   ★★因為【樣本少】與【世界裡沒發生】在一個平均上長得一樣。
	var min_rows: int = int(OS.get_environment("AO_MIN_ROWS")) if OS.has_environment("AO_MIN_ROWS") else 150
	var frows: Array = Probe.samples.get("attack.opp.factors", [])
	if frows.size() < min_rows:
		print("★★★【紅】因子逐列只收到 %d 筆，而宣告的地板是 %d ⇒ **這一窗不可判**" % [
			frows.size(), min_rows])
		print("   ⇒ ★【樣本少】與【世界裡沒發生】是兩個結論，而平均數分不出來")
		_fails += 1
	print("")
	print("★★★乘積拆開：(0.6×loot + 0.4×need) × odds × person")
	print("   ★loot 與 need 是**相加**；本實作**沒有獨立風險項**（風險折在 odds 裡）")
	print("   母體 %d 次（樣本上限 400、實收 %d；★first-N 不是隨機）" % [
		int(Probe.counts.get("attack.opp.factors_n", 0)), frows.size()])
	if frows.is_empty():
		print("   ★母體 0 ⇒ **不可判**（★★而那與「因子都是 0」是兩個結論）")
	else:
		for k in ["est", "loot", "need", "odds", "person", "opp"]:
			var col: Array = []
			for r in frows: col.append(float(r[k]))
			col.sort()
			var med: float = col[col.size() / 2]
			var zero_n: int = 0
			for v in col: if absf(float(v)) < 0.0005: zero_n += 1
			print("   %-7s 中位 %.4f｜min %.4f｜max %.4f｜恰好 0 的 %d/%d" % [
				k, med, col[0], col[col.size() - 1], zero_n, col.size()])
		print("   ★★判法：**中位最靠近 0 的那一個因子，就是把乘積壓扁的那一個**")
		print("   ★★★而 `est` 與 `loot` 要一起看：`loot = clamp(est / %.1f, 0, 1)`" % DecisionTerms.ATTACK_LOOT_REF)
		print("      ⇒ ★若 est 中位遠小於參考值，**loot 就會在中位列近乎 0** ——")
		print("        而那時【分布不窄】與【中位列被壓扁】**同時成立**，它們不矛盾。")
	# ★★★【(a)/(b) 的分水嶺】—— 由床自己印，不靠我離線算（systems 2026-09-15）：
	#   ★要回答的是【筆數】不是【有沒有】—— **出現 1 筆與出現 100 筆是兩個答案**：
	#   ★★1 筆不是【早期窗假象】，是【罕見但存在】—— 兩者對絕境經濟的意義完全不同。
	if not frows.is_empty():
		var hungry_armed: int = 0
		var need_contrib: int = 0
		var hungry_n: int = 0
		var armed_n: int = 0
		for r in frows:
			var _nd: float = float(r["need"])
			var _od: float = float(r["odds"])
			if _nd >= 0.0005: hungry_n += 1
			if _od >= 0.0005: armed_n += 1
			if _nd >= 0.0005 and _od >= 0.0005:
				hungry_armed += 1
				if float(r["opp"]) > 0.0: need_contrib += 1
		print("")
		print("★★★【分水嶺】餓（need>0）且有牙（odds>0）的列：**%d / %d**（%.1f%%）" % [
			hungry_armed, frows.size(), 100.0 * float(hungry_armed) / float(frows.size())])
		print("   其中 `need` 真的進到 util 裡的（opp > 0）：**%d 筆**" % need_contrib)
		var ha_teams: Dictionary = {}
		for r in frows:
			if float(r["need"]) >= 0.0005 and float(r["odds"]) >= 0.0005:
				ha_teams[int(r.get("team", -9))] = true
		print("   ★★★而那些筆來自 **%d 支隊** —— **筆數 ≠ 隊數**（同一支隊連續 tick 會重複計）" % ha_teams.size())
		print("   兩邊的邊緣：餓的列 %d｜有牙的列 %d（★兩個數加起來超過母體才可能有交集）" % [
			hungry_n, armed_n])
		print("   ⇒ ★★報【筆數＋母體】，**分界不在這支床裡定** —— 它是裁決，不是量測。")
		print("      ★★★判法（systems 2026-09-15）：**這個判準能不能在【沒有人解釋】的情況下站得住？**")
		print("         能 ⇒ 進工具（實跑 N、母體地板、fp 逐字比）｜不能 ⇒ 留在人手上，而人要寫理由。")
	# ★★★【第②種】有目標、而攻擊輸給別人：**輸給誰、差多少**（systems 2026-09-15）
	#   ★這一格不畫門檻：**「贏率低」是裁決不是量測** ⇒ 只報分佈與輸給誰。
	var lost: Dictionary = {}
	var rankb: Dictionary = {}
	var gapb: Dictionary = {}
	for k in Probe.counts:
		var ks: String = String(k)
		if ks.begins_with("attack.lost_to."):
			lost[ks.replace("attack.lost_to.", "")] = int(Probe.counts[k])
		elif ks.begins_with("attack.rank.") and not ks.begins_with("attack.rank.of"):
			rankb[ks.replace("attack.rank.", "")] = int(Probe.counts[k])
		elif ks.begins_with("attack.gap."):
			gapb[ks.replace("attack.gap.", "")] = int(Probe.counts[k])
	print("")
	print("★★★攻擊的【名次】與【輸給誰】（★名次要配母體：第 5 名在 6 個候選裡＝墊底）")
	print("   名次分桶：%s" % str(rankb))
	print("   輸給誰：%s" % str(lost))
	print("   距第一名的差：%s（lt10pct ＝ 擦邊）" % str(gapb))
	# ★★★【紙上推演的限】（systems 2026-09-15，印在這一格旁邊）：
	#   ★拿 `gap` 算「權重推到上限會不會翻過贏家」，**假設了其他選項的 util 不變**。
	#   ★★而真的調下去，世界會變（更多攻擊 ⇒ 不同的後續狀態 ⇒ 別人的 util 也跟著動）。
	print("   ★★★紙上推演的限（★不對稱）：**紙上翻不過 ⇒ 結論強**（連最寬鬆的假設都翻不過＝形狀題）；")
	print("      **紙上翻得過 ⇒ 結論弱** —— 只能說「權重層可能夠」，**不能說「調下去就會這樣」**")
	print("      ★因為那個計算假設【其他選項的 util 不變】，而真的調下去世界會變")
	print("   ⇒ ★★【擦邊輸】與【輸很多】是兩種病：前者是權重，後者是那一項根本不夠格")
	# ★★★具名：那幾支【餓且有牙】的隊，它們的攻擊輸給誰（systems 2026-09-15）
	#   ★聚合說的是「通常輸給誰」；具名說的是「**一支該打而不打的隊在想什麼**」。
	var watch: Dictionary = {}
	for r in frows:
		if float(r["need"]) >= 0.0005 and float(r["odds"]) >= 0.0005:
			watch[int(r.get("team", -9))] = true
	var rows2: Array = Probe.samples.get("attack.rank_row", [])
	var hit: int = 0
	for r in rows2:
		if not watch.has(int(r.get("team", -9))): continue
		hit += 1
		if hit <= 15:
			print("   隊 %d @tick %d：攻擊排第 %d／%d｜attack_u=%.3f｜贏家 %s(%.3f)｜top3 %s" % [
				int(r.get("team", -9)), int(r.get("tick", -9)), int(r["rank"]), int(r["of"]),
				float(r["attack_u"]), String(r["winner"]), float(r["winner_u"]), str(r["top3"])])
	# ★★★【逐列紙上推演】（systems 2026-09-15 改寫判準）：
	#   ★舊：用【聚合 gap】算「推到上限會不會翻」⇒ **它假設那個差是穩定的，而它不是**。
	#   ★★新：**逐列** ⇒ 「在 N 次評分裡，有【幾次】推到上限就會翻」。
	#   ★★★而【合理上限】是**裁決**：`AO_WEIGHT_CEIL` 沒給 ⇒ **印不可判**，
	#     **床不自己挑一個數字** —— 否則那個數字三個月後會變成沒人記得為什麼的線。
	if hit > 0:
		if not OS.has_environment("AO_WEIGHT_CEIL"):
			print("   ★逐列紙上推演：**不可判**（未給 `AO_WEIGHT_CEIL`）—— ★★上限是裁決，床不挑")
		else:
			var ceil_w: float = float(OS.get_environment("AO_WEIGHT_CEIL"))
			var flip: int = 0
			var seen: int = 0
			for r in rows2:
				if not watch.has(int(r.get("team", -9))): continue
				seen += 1
				if float(r["attack_u"]) * ceil_w > float(r["winner_u"]): flip += 1
			print("   ★★★逐列紙上推演（上限 ×%.2f，由裁決給）：**%d / %d 次會翻**" % [
				ceil_w, flip, seen])
			print("      ★近似：把 `attack_u` 整個乘上限 —— **這是最寬鬆的假設**")
			print("      （因為只有機會項會被權重放大，而這裡假裝整個 util 都會）")
			print("      ⇒ ★★**0 次會翻 ⇒ 形狀題（這句很硬）**｜**多數會翻 ⇒ 平衡題**｜k 小 ⇒ 要講出 k／N")
	print("   ★具名列母體：盯的隊 %d 支｜`attack.rank_row` 樣本 %d 筆｜命中 %d 筆" % [
		watch.size(), rows2.size(), hit])
	if hit == 0:
		print("   ★★【命中 0】⇒ **這不是「它沒輸」，是【那支隊沒被 rank_row 取樣到】** ——")
		print("      `attack.rank_row` 上限 200 且是 first-N，**兩者在這行字上長得一樣**")
	# ★★★四格對帳（systems 2026-09-15）：沒目標／打不贏／秤上輸了／贏了卻沒派出去
	#   ★而①與④的 tap 在別處（ctx / engine）—— **它們有記，而床一直沒印**
	#   ⇒ ★★★又一次【裝好了沒接電】：**tap 在跑，而沒有人看得到它**。
	print("")
	print("★★★四格（餓而有牙卻沒搶）：")
	print("   ①沒有目標：%d 次（樣本 %d）—— ★genuine：**不是不想搶，是沒人可搶**" % [
		int(Probe.counts.get("hungry_armed.no_target", 0)),
		(Probe.samples.get("hungry_armed.no_target_rows", []) as Array).size()])
	var _wt: Array = Probe.samples.get("attack.won_task", [])
	var _already: int = 0
	for r in _wt:
		if String(r.get("task_before", "")) == TeamData.TASK_ATTACK: _already += 1
	print("   ④贏了的次數：%d（樣本 %d）｜其中當時 task 已經是攻擊的：%d" % [
		int(Probe.counts.get("attack.won_n", 0)), _wt.size(), _already])
	print("      ★★【贏了卻沒派出去】要看【贏之後】的 task，而這一行只看得到【當下】")
	print("      ⇒ ★★★所以這格是 **部分證據**，不是判決；要完整得在派工後再量一次")
	# ★★★【軌跡】餓且有牙的隊，它們的 need 隨時間怎麼走，有沒有真的去搶（systems 2026-09-15）
	if not frows.is_empty():
		var traj: Dictionary = {}
		for r in frows:
			if float(r["need"]) < 0.0005 or float(r["odds"]) < 0.0005:
				continue
			var _tm: int = int(r.get("team", -9))
			if not traj.has(_tm): traj[_tm] = []
			(traj[_tm] as Array).append([int(r.get("tick", -9)), float(r["need"])])
		var won: Dictionary = {}
		for w in Probe.samples.get("attack.won", []):
			won[int(w["team"])] = true
		if not traj.is_empty():
			print("")
			print("★★★餓且有牙的隊的【軌跡】（need 隨 tick），並標它有沒有真的搶")
			print("   ★【一路餓到死也沒搶】比【互斥】更難看：**有牙、很餓、而仍然不搶**")
			for tm in traj:
				var arr: Array = traj[tm]
				arr.sort_custom(func(a, b): return a[0] < b[0])
				print("   隊 %d：%d 筆｜tick %d→%d｜need %.3f→%.3f｜**%s**" % [
					tm, arr.size(), arr[0][0], arr[arr.size() - 1][0],
					arr[0][1], arr[arr.size() - 1][1],
					("曾經搶了" if won.has(tm) else "★從來沒搶")])
			print("   ★★母體邊界：`attack.won` 也是 first-N 樣本（實收 %d／累計 %d）" % [
				(Probe.samples.get("attack.won", []) as Array).size(),
				int(Probe.counts.get("attack.won_n", 0))])
			print("      ⇒ ★★★**「從來沒搶」可能是【搶了而沒被取樣】** —— 兩者在這行字上長得一樣")
	# ★★★因子逐列 TSV（systems 2026-09-15 問「淺」的來源）——
	#   ★聚合答不了逐桶平均：要算 tier2 的 loot 逐桶 util，必須有逐列值。
	print("")
	print("★因子逐列（TSV：est/loot/need/odds/person/opp/tier）")
	print("FACTORS_TSV	est	loot	need	odds	person	opp	tier	team	tick")
	for r in frows:
		print("FACTORS_TSV	%.3f	%.3f	%.3f	%.3f	%.3f	%.4f	%d	%d	%d" % [
			float(r["est"]), float(r["loot"]), float(r["need"]), float(r["odds"]),
			float(r["person"]), float(r["opp"]), int(r.get("tier", -9)),
			int(r.get("team", -9)), int(r.get("tick", -9))])
	# ── ★逐列原始樣本（讓等級相關可以離線算）──
	var arows: Array = Probe.samples.get("appetite.input", [])
	print("")
	print("★逐列樣本（TSV：估值、真值、tier、贏率）—— ★★因為上一卷的同向率二分法")
	print("   **沒有鑑別力**（門檻用絕對值 1.0，而兩個量尺度差兩個數量級），")
	print("   ⇒ ★★★要判雜訊必須用**等級相關**，而那需要逐列值——這就是那些值。")
	print("APPETITE_TSV	est	true	tier	odds")
	for r in arows:
		print("APPETITE_TSV	%.3f	%.3f	%d	%.3f" % [
			float(r["est"]), float(r["true"]), int(r["tier"]), float(r["odds"])])
	print("★fp = %s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=%d" % _fails)
	print("[TEST-SUITE-COMPLETE]")
