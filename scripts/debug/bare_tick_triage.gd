extends SceneTree
# ★★★S1b：143 筆候選【逐顆結案】的分類器（★可重跑、可對帳，不靠人的印象）。
#
# ★對帳式（systems 定）：改 ＋ 延後 ＋ 白名單 ＝ 143，★一筆都不准無處置。
# ★★而我加了票上沒有的第四類，理由要講死：
#   **(d) 不是時間量** —— 掃描器是【同一行有 tick 符號就報】，
#   而同一行的整數常常根本不是 tick（取樣 cap、`== 0` 週期判、`-1` 哨兵、曆法單位 24/30/4…）。
#   ★★★把它們硬塞進 (a)/(b)/(c) 會讓白名單灌水成一份沒人讀的清單 ——
#     而白名單的價值全在「每一條都有人真的想過」。
#
# ★分類【保守】：只有形狀明確吻合才判 (d)；★★認不出來的一律丟 `NEEDS_HUMAN`，
#   ⇒ 漏判會表現成「要人看的變多」，★不會表現成「悄悄被歸類掉」。
#
# 輸入：SCAN_IN（S1a 的候選清單）　輸出：TRIAGE_OUT
# 欄位：disposition|reason|path|line|literal|symbol|source

var _rules: Array = []

func _initialize() -> void:
	_run(); quit()

func _mk(re: String, disp: String, reason: String, lit_bound: bool = false) -> Dictionary:
	var r := RegEx.new(); r.compile(re)
	return {"re": r, "disp": disp, "reason": reason, "src": re, "hits": 0, "lit_bound": lit_bound}

func _run() -> void:
	# ★規則順序即優先序；每條都要寫【為什麼它不是時間量】
	# ★★★規則順序即優先序：【專用 / 是時間量】的全部排在【寬規則】之前。
	#   ★血證（規則自審第一次跑就抓到，而這張票本來已經結案）：
	#     ① `TICKS_PER_DAY / 4`（sim_runner:294/340，註解「每 6 小時」）被 `% … == 0` 吃掉
	#     ② `current_tick - 1000`（player_trade_system:103）被 `get(k, 0)` 吃掉
	#        ★★而那一顆是【真的裸 tick】—— 我原本的結論「(a) = 0」因此是錯的。
	#   ⇒ ★★★寬規則排在前面會【安靜地】吐掉真答案，而它的症狀只有一個：
	#     專用規則命中 0。【那就是【印每條命中數】這條防線在抓的東西。】
	_rules = [
		# ── (a) 改：真裸 tick 字面量 ──
		_mk("current_tick\\s*-\\s*([0-9]{2,})", "a_change", "★真裸 tick：`current_tick - <字面量>` 沒有經過任何具名時間常數 ⇒ 根旋鈕一改它就静默偏移", true),
		# ── (b) 延後 ──
		# ★★(b) 的【第二種子形狀】（systems 裁定 2026-08-27）：
		#   ★S1b 的 (b)：【現制下無法精確表達】（2.4 小時，hours() 只吃整數小時）
		#   ★★這一顆：【改法本身依賴另一個未落地的改動】——
		#     BASE_ACTION_TICKS 意圖是「1/6 小時」，本質是 (a)；
		#     但舊根下 `TICKS_PER_HOUR / 6 = 10 // 6 = 1` ⇒ 整數除法把它壓成 1（快 10 倍）
		#     ⇒ ★必須與 S2 同時落地，否則改了比不改還糟。
		#   ★★★兩種都是「值不動、延後」，而理由不同 —— 分開寫，否則下一個人以為 (b) 只有一種。
		# ★而它只吃【裸值那一形】：= 後面直接接數字。
		#   已導出的寫法（= WorldState.TICKS_PER_HOUR / 6）不會命中，它走第一軸白名單。
		#   ★★所以在【本 branch】這條規則命中 0，規則自審會標它【已死】——
		#     那是【對的】：它是為【S2 尚未落地的 main】寫的，S2 一 merge 它就該死。
		_mk("const BASE_ACTION_TICKS[^=]*=\\s*[0-9]+", "b_defer", "★意圖是 1/6 小時（本質 (a)），但改法依賴 S2：舊根下 TICKS_PER_HOUR/6 = 10//6 = 1，整數除法把動作壓成 1 tick（快 10 倍、撞穿 >=10 地板）⇒ 必須與 S2 同時落地"),
		_mk("const TICKS_PER_TURN:", "b_defer", "24 tick ＝ 2.4 小時；hours() 只吃整數小時 ⇒ 無法精確表達 ⇒ 交 S2"),
		# ── ★第二軸（名字啟發式）新出現的候選 ──
		#   ★這一批的共同問題是【名字像時長，但軸不一定是世界時間】。
		_mk("const PRISONER_CHECK_INTERVAL", "c_whitelist", "★遭遇軸：比對的是 encounter_tick（:592 round_num %），不是 world tick ⇒ 不隨根旋鈕"),
		_mk("const BLOCK_WINDOW", "c_whitelist", "★遭遇軸：格持視窗以【動作】計，而動作 tick 數不變"),
		_mk("const ENCOUNTER_STUCK_TICKS", "c_whitelist", "★遭遇軸：observer_bridge:31 比對 state.encounter_tick"),
		_mk("const DECISION_CADENCE_MULT", "d_not_time", "multiplier：3 是【倍數】（×TICK_PER_DAY），本身不是時間量"),
		_mk("const [A-Z_]+_DAYS", "c_whitelist", "★單位就是【天】：使用端自己乘 TICKS_PER_DAY ⇒ 已隨根縮放，改成 tick 反而倒退"),
		_mk("const SURVIVAL_BUILD_MAX_TICKS", "c_whitelist", "★person-ticks 工量：與 cost[\"ticks\"] 同單位，每呼叫扣，不是世界時間"),
		_mk("const CAMP_BUILD_TICKS", "c_whitelist", "★person-ticks 工量（註解自述），同上"),
		_mk("const DUMP_CHUNK_TICKS", "d_not_time", "批次大小：observer dump 一塊跑幾 tick，是【分塊粒度】不是【時長】（UI 側，不影響世界）"),
		# ── 盲點修補後新出現的 "ticks" 族 ──
		_mk("[=!]=\\s*\"ticks\"", "d_not_time", "key_filter：`if k == \"ticks\"` 是【欄位名比對】，同行的數字不是時間量"),
		_mk("\"ticks\"\\s*:\\s*[0-9]+", "c_whitelist", "★person-ticks：建造成本是【工量】不是【時長】—— _tick_construction 每呼叫扣 maxi(pop,1)，而每日呼叫次數已由 TICKS_PER_DAY/NEAR_CADENCE 導出 ⇒ 不隨根旋鈕縮放"),
		_mk("cost\\.get\\(\"ticks\"", "c_whitelist", "★同上族：預設的建造工量（person-ticks）"),
		# ── (c) 白名單：S2 重錨引入的兩顆新形狀 ──
		_mk("const TICKS_PER_HOUR:", "c_whitelist", "★新的根常數本身（S2 把自由參數從 TICKS_PER_DAY 換成它）：其他時間量由它導出，改成 hours() 會循環定義"),
		_mk("TICKS_PER_HOUR / 6", "c_whitelist", "★單位結構：遭遇動作＝10 分鐘＝1/6 小時。★★這個 6 不隨小時縮放——根怎麼改，一小時永遠是六個十分鐘"),
		# ── (c) 白名單：根常數本身 ──
		_mk("const TICKS_PER_DAY:", "c_whitelist", "根常數本身：hours()/days() 由它導出，改成 hours() 會循環定義"),
		_mk("const TICKS_PER_SECOND:", "c_whitelist", "★播放速率：每【真實秒】渲染幾個 world tick —— 量的是現實時間，不隨小時縮放"),
		# ── (c) 白名單：曆法結構（是時間量，但不隨 tick 縮放）──
		_mk("TICKS_PER_DAY / 24", "c_whitelist", "曆法結構：24＝一天幾小時（改根時它必須維持 24）"),
		_mk("TICKS_PER_HOUR\\)\\s*%\\s*24", "c_whitelist", "曆法結構：24＝一天幾小時（顯示端）"),
		_mk("TICKS_PER_DAY\\)\\s*%\\s*30", "c_whitelist", "曆法結構：30＝一月幾天"),
		_mk("TICKS_PER_MONTH\\) % 12", "c_whitelist", "曆法結構：12＝一年幾月"),
		_mk("SEASON_LENGTH\\)\\s*%\\s*4", "c_whitelist", "曆法結構：4＝一年幾季"),
		# ── (c) 白名單：已由具名時間常數導出（★是時間量，但已隨根自動縮放）──
		#   ★這一組原本被我誤標成 (d)。它們確實是時間量（「每 50 小時」「2 天」），
		#   ★★只是不需要改 —— 而【不需要改】是 (c)，不是【不是時間量】。
		_mk("TICKS_PER_DAY\\s*/\\s*4", "c_whitelist", "已導出：/4＝一天四等分（每 6 小時），分母是 TICKS_PER_DAY ⇒ 已隨根縮放"),
		_mk("[0-9]+\\s*\\*\\s*(WorldState\\.)?TICKS_PER_", "c_whitelist", "已導出：`N * TICKS_PER_*`（例「每 50 小時」「2 天」）—— 是時間量，但已隨根縮放"),
		_mk("[A-Z_]{3,}\\s*\\*\\s*[0-9]+", "c_whitelist", "已導出：具名時間常數 × 倍數 ⇒ 已隨根縮放"),
		# ── (d) 不是時間量：★每條必須寫【為什麼它不是時間量】──
		_mk("base\\s*\\*\\s*31", "d_not_time", "hash_mult：31 是雜湊乘數"),
		_mk("\"speed\": 1", "d_not_time", "speed_mult：速度倍率，不是 tick"),
		_mk("maxi\\(1,", "d_not_time", "floor：`maxi(1, …)` 的 1 是下限保護"),
		_mk(", 1\\)$", "d_not_time", "floor：末位 1 是下限保護"),
		_mk("_next_tick = 0", "d_not_time", "sentinel：重設為「未排程」"),
		_mk("current_tick\\s*\\+=\\s*1", "d_not_time", "increment：tick 前進 1 步＝時間軸本身的定義"),
		_mk("< 0\\b", "d_not_time", "sentinel：`< 0` 是「從未發生」的哨兵比較"),
		_mk("\\}\\s*,\\s*[0-9]+\\s*\\)", "d_not_time", "sample_cap：字典後接的整數是 cap（★錨拿掉行尾 $：尾巴有註解時 $ 會沒命中，而那是【規則自己的盲點】不是新形狀）"),
		_mk("%[^=]*(==|!=)\\s*0", "d_not_time", "zero_compare：`% INTERVAL == 0` 的 0 是餘數判準"),
		_mk("get\\([^)]*,\\s*-?[0-9]+\\s*\\)", "d_not_time", "sentinel_default：`get(k, 0/-1)` 的預設值是哨兵"),
		_mk("^\\s*var\\s+\\w+:\\s*int\\s*=\\s*0", "d_not_time", "decl_init：`= 0` 是「尚未排程」的初值"),
		_mk("==\\s*0\\b", "d_not_time", "zero_compare：與 0 比較是「未排程」判斷"),
		_mk("\\+\\s*1\\b", "d_not_time", "increment：+1 是「下一個」不是一段時間"),
		_mk("-\\s*1\\b", "d_not_time", "sentinel：-1 是無效值哨兵"),
	]
	var in_path: String = _env("SCAN_IN", "docs/measurements/2026-08-27-bare-tick-candidates.txt")
	var out_path: String = _env("TRIAGE_OUT", "docs/measurements/2026-08-27-bare-tick-triage.txt")
	var f := FileAccess.open(in_path, FileAccess.READ)
	if f == null:
		print("[FAIL] 讀不到候選清單：%s" % in_path); return
	var rows: Array = []
	var tally: Dictionary = {}
	var total: int = 0
	while not f.eof_reached():
		var line: String = f.get_line()
		if line.strip_edges() == "" or line.begins_with("#"):
			continue
		var parts: PackedStringArray = line.split("|")
		if parts.size() < 6:
			continue
		total += 1
		var src: String = parts[5]
		var disp: String = "NEEDS_HUMAN"
		var reason: String = "★形狀認不出來 ⇒ 交人判（★保守：漏判表現成「要人看的變多」，不是悄悄歸類掉）"
		for r in _rules:
			var m: RegExMatch = (r["re"] as RegEx).search(src)
			if m == null:
				continue
			# ★規則是【逐行】比對，而列是【逐字面量】—— 同一行的別顆字面量會被沾到。
			#   ★★lit_bound 的規則要求【捕捉到的數字必須就是這一列的字面量】，
			#   否則 `current_tick - 1000` 那行的 `get(k, 0)` 的 0 也會被報成 (a)＝1 個站點虛胖成 2 列。
			if bool(r["lit_bound"]) and m.get_group_count() >= 1 and m.get_string(1) != parts[2]:
				continue
			disp = String(r["disp"]); reason = String(r["reason"])
			r["hits"] = int(r["hits"]) + 1
			break
		tally[disp] = int(tally.get(disp, 0)) + 1
		rows.append("%s|%s|%s|%s|%s|%s|%s" % [disp, reason, parts[0], parts[1], parts[2], parts[3], src])
	f.close()
	var head: Array = [
		"# ★S1b 分類（triage）：母體 ＝ S1a 的 %d 筆候選" % total,
		"# ★★對帳式：所有 disposition 相加必須 == 母體，★一筆都不准無處置。",
		"#",
		"# ★★★而我加了票上沒有的第四類 (d) 不是時間量 —— 理由：",
		"#   掃描器是【同一行有 tick 符號就報】，而同一行的整數常常根本不是 tick",
		"#   （取樣 cap／`% X == 0` 的 0／`get(k,-1)` 哨兵／曆法單位 24-30-4…）。",
		"#   ★把它們硬塞進 (a)/(b)/(c) 會讓白名單灌水成一份沒人讀的清單 ——",
		"#     而白名單的價值全在「每一條都有人真的想過」。",
		"#",
		"# ★分類保守：只有形狀明確吻合才判 (d)；認不出來一律 NEEDS_HUMAN。",
		"# 欄位：disposition|reason|path|line|literal|symbol|source",
		"#"]
	var tk: Array = tally.keys(); tk.sort()
	var sum: int = 0
	for k in tk:
		head.append("# %-14s = %d" % [String(k), int(tally[k])])
		sum += int(tally[k])
	head.append("# ★合計 %d vs 母體 %d ⇒ %s" % [sum, total, "一致" if sum == total else "★不一致"])
	head.append("#")
	# ★★★規則表自審（systems 2026-08-27 加的第三條防線）：每條規則印【它命中幾筆】。
	#   ★理由：規則會【腐爛】—— 一條為 `bump_sample(..., 200)` 寫的規則，
	#     日後可能命中一個【真的是時間量】的東西。
	#   ★★命中數異常大 ＝ 這條太寬；★★★命中 0 ＝ 這條已死（它守的形狀不在了，或從來沒對過）。
	#   ⇒ 這兩個訊號讓「規則表」本身可審計，而不必每次重新人工審全表。
	head.append("# ── 規則命中數（★太寬／已死 都在這欄看得見）──")
	var _wide: int = 0
	for r2 in _rules:
		var h: int = int(r2["hits"])
		var flag: String = ""
		if h == 0:
			flag = "   ★已死：命中 0 —— 它守的形狀不在了，或從來沒對過"
		elif h >= 20:
			flag = "   ★★太寬？命中 >=20，值得回頭看它有沒有吃到真的時間量"
		if h >= 20:
			_wide += 1
		head.append("#   %-12s %3d  %s%s" % [String(r2["disp"]), h, String(r2["src"]), flag])
	head.append("#")
	# ★★★機器可讀的逐規則命中數（閘要 parse 它）——
	#   ★上面那一塊是【給人看】的，而人看的格式會因為排版而變；
	#   ★★閘去 parse 人看的格式，就是把【排版】變成【契約】。
	#   ⇒ ★★★另開一行帶固定前綴的：欄位固定、不對齊、不加旗標文字。
	# ★★★★而它們必須以 `# ` 開頭：閘用 `grep -vc '^#'` 數【資料列】，
	#   不加 `# ` 會讓這幾行被當成候選⇒ 【候選 vs 分類筆數】那條對帳假紅。
	for r4 in _rules:
		head.append("# RULEHIT|%s|%d|%s" % [String(r4["disp"]), int(r4["hits"]), String(r4["src"])])
	# ★逐規則命中數合計 + NEEDS_HUMAN == 母體
	#   ★★因為比對迴圈命中就 break ⇒ 每筆候選【最多】命中一條規則，
	#   ★★★不平 = 有東西被靜默吐掉（而那在舊格式下看不見）。
	var _rh: int = 0
	for r5 in _rules:
		_rh += int(r5["hits"])
	var _nh: int = int(tally.get("NEEDS_HUMAN", 0))
	head.append("# RULEHITSUM|%d|%d|%d|%s" % [_rh, _nh, total,
		"OK" if _rh + _nh == total else "MISMATCH"])
	head.append("#")
	var of := FileAccess.open(out_path, FileAccess.WRITE)
	if of != null:
		of.store_string("\n".join(PackedStringArray(head)) + "\n" + "\n".join(PackedStringArray(rows)) + "\n")
		of.close()
	print("\n[S1b-triage] 母體 %d｜合計 %d｜%s" % [total, sum, "對帳一致" if sum == total else "★對帳不一致"])
	for k2 in tk:
		print("   %-14s = %d" % [String(k2), int(tally[k2])])
	print("   ── 規則自審（★太寬/已死）──")
	for r3 in _rules:
		var h3: int = int(r3["hits"])
		if h3 == 0 or h3 >= 20:
			print("   %s 命中 %d：%s" % ["★已死" if h3 == 0 else "★太寬?", h3, String(r3["src"])])
	print("[S1b-triage] 落地：%s" % out_path)
	print("=== bare_tick_triage DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
