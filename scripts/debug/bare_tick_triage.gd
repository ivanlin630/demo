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

func _mk(re: String, disp: String, reason: String) -> Dictionary:
	var r := RegEx.new(); r.compile(re)
	return {"re": r, "disp": disp, "reason": reason}

func _run() -> void:
	# ★規則順序即優先序；每條都要寫【為什麼它不是時間量】
	_rules = [
		_mk("Probe\\.(bump_sample|note)\\(", "d_not_time", "sample_cap：bump_sample 末位是【樣本上限】不是 tick"),
		# ── ★(b)/(c) 逐筆釘死（★file:line 當錨，理由寫在這裡也寫在 code 註記裡）──
		_mk("const TICKS_PER_DAY:", "c_whitelist", "根常數本身：hours()/days() 由它導出，改成 hours() 會循環定義"),
		_mk("TICKS_PER_DAY / 24", "c_whitelist", "曆法結構：24＝一天幾小時，不隨 tick 縮放（改根時它必須維持 24）"),
		_mk("TICKS_PER_MONTH\\) % 12", "c_whitelist", "曆法結構：12＝一年幾月"),
		_mk("const TICKS_PER_SECOND:", "c_whitelist", "★播放速率：每【真實秒】渲染幾個 world tick —— 不是世界時間，不隨小時縮放"),
		_mk("const TICKS_PER_TURN:", "b_defer", "24 tick ＝ 2.4 小時；hours() 只吃整數小時 ⇒ 無法精確表達 ⇒ 交 S2"),
		# ── ★分類器缺口（第一版沒涵蓋的機械形狀，實測 11 筆待人判時發現）──
		_mk("< 0\\b", "d_not_time", "sentinel：`< 0` 是「從未發生」的哨兵比較"),
		_mk("maxi\\(1,", "d_not_time", "floor：`maxi(1, …)` 的 1 是下限保護，不是一段時間"),
		_mk(", 1\\)$", "d_not_time", "floor：末位 1 是下限保護"),
		_mk("\"speed\": 1", "d_not_time", "speed_mult：速度倍率，不是 tick"),
		_mk("_next_tick = 0", "d_not_time", "sentinel：重設為「未排程」"),
		_mk("\\}\\s*,\\s*[0-9]+\\s*\\)\\s*$", "d_not_time", "sample_cap：字典後接的整數是 cap"),
		_mk("%[^=]*(==|!=)\\s*0", "d_not_time", "zero_compare：`% INTERVAL == 0` 的 0 是餘數判準，不是時間量"),
		_mk("get\\([^)]*,\\s*-?[0-9]+\\s*\\)", "d_not_time", "sentinel_default：`get(k, 0/-1)` 的預設值是哨兵"),
		_mk("current_tick\\s*\\+=\\s*1", "d_not_time", "increment：tick 前進 1 步＝時間軸本身的定義"),
		_mk("TICKS_PER_HOUR\\)\\s*%\\s*24", "c_whitelist", "曆法結構：24＝一天幾小時 —— ★是時間量，但不隨 tick 縮放（根改了它仍須是 24）"),
		_mk("TICKS_PER_DAY\\)\\s*%\\s*30", "c_whitelist", "曆法結構：30＝一月幾天 —— ★是時間量，但不隨 tick 縮放"),
		_mk("SEASON_LENGTH\\)\\s*%\\s*4", "c_whitelist", "曆法結構：4＝一年幾季 —— ★是時間量，但不隨 tick 縮放"),
		_mk("TICKS_PER_DAY\\s*/\\s*4", "c_whitelist", "曆法結構：/4＝一天四等分 —— ★分母是 TICKS_PER_DAY，已隨根自動縮放，改寫成 hours() 只是換寫法"),
		_mk("base\\s*\\*\\s*31", "d_not_time", "hash_mult：31 是雜湊乘數"),
		_mk("^\\s*var\\s+\\w+:\\s*int\\s*=\\s*0", "d_not_time", "decl_init：`= 0` 是「尚未排程」的初值，不是一段時間"),
		_mk("==\\s*0\\b", "d_not_time", "zero_compare：與 0 比較是「未排程」判斷"),
		_mk("[A-Z_]{3,}\\s*\\*\\s*[0-9]+", "d_not_time", "derived_mult：已由具名時間常數導出，倍數不是裸 tick"),
		_mk("[0-9]+\\s*\\*\\s*(WorldState\\.)?TICKS_PER_", "d_not_time", "derived_mult：`N * TICKS_PER_*` 已隨根縮放"),
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
			if (r["re"] as RegEx).search(src) != null:
				disp = String(r["disp"]); reason = String(r["reason"]); break
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
	var of := FileAccess.open(out_path, FileAccess.WRITE)
	if of != null:
		of.store_string("\n".join(PackedStringArray(head)) + "\n" + "\n".join(PackedStringArray(rows)) + "\n")
		of.close()
	print("\n[S1b-triage] 母體 %d｜合計 %d｜%s" % [total, sum, "對帳一致" if sum == total else "★對帳不一致"])
	for k2 in tk:
		print("   %-14s = %d" % [String(k2), int(tally[k2])])
	print("[S1b-triage] 落地：%s" % out_path)
	print("=== bare_tick_triage DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
