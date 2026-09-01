extends SceneTree
# @observe-pure
# ★★★S1c：【封閉母體】＝ 全部 `const <NAME>: int = <裸字面量>`（排除 scripts/debug）。
#
# ★為什麼是這個母體（systems 裁定 2026-08-27）：
#   名字啟發式的母體是「名字看起來像時長的」⇒【開放式】，永遠不知道有沒有漏。
#   換成「全部裸字面量 int 常數」⇒ 有限、可枚舉、可被別人一秒重跑出同一個數。
#   ★★「掃完」= 這個母體【全部有處置】，不是「我想到的名字都掃了」。
#
# ★★★而「掃完」是【對當下母體的宣告】不是永久狀態：
#   新寫 code 會加新常數 ⇒ 母體往上長。★而那不破壞判準——
#   判的是 NEEDS_HUMAN == 0，不是「母體 = 120」（不能綁會隨 code 長大的量）。
#
# ★★★★而我另做的「使用處有沒有 tick 符號」自動判別【沒過陽性對照】：
#   把 MSG_TTL_SHORT 改回裸值 1680 ⇒ hits=0【漏掉】，因為它經由字典＋區域變數使用。
#   ⇒ 那支只能【排序】不能【結案】（見 .claude/hooks/const-time-sweep.sh 檔頭）。
#   本檔用的是【逐族規則 + 人判】，不依賴那個判別。

const EXCLUDE_DIRS: Array = ["res://scripts/debug"]

var _bare_re: RegEx
var _rules: Array = []

func _initialize() -> void:
	_run(); quit()

func _mk(re: String, disp: String, reason: String) -> Dictionary:
	var r := RegEx.new(); r.compile(re)
	return {"re": r, "disp": disp, "reason": reason, "src": re, "hits": 0}

func _run() -> void:
	_bare_re = RegEx.new()
	_bare_re.compile("^\\s*const\\s+([A-Z_][A-Z0-9_]*)\\s*:\\s*int\\s*=\\s*(-?[0-9]+)\\s*$")

	# ★規則順序即優先序：專用在前、家族在後。每條都要寫【為什麼】。
	_rules = [
		# ── (c) 是時間量，但不該改（各有不同理由）──
		_mk("^TICKS_PER_HOUR$", "c_whitelist", "★根常數本身：其他時間量由它導出，改成 hours() 會循環定義"),
		_mk("^TICKS_PER_SECOND$", "c_whitelist", "★播放速率：量的是【現實時間】（每真實秒渲染幾 tick），不隨世界小時縮放"),
		_mk("^TURN_MINUTES$", "c_whitelist", "★時間宣告用【分鐘】：2.4 小時整數小時表達不了，而分鐘可以"),
		_mk("[A-Z_]*_DAYS$", "c_whitelist", "★單位就是【天】：使用端自己乘 TICKS_PER_DAY ⇒ 已隨根縮放，改成 tick 反而倒退"),
		_mk("^(CAMP_BUILD_PERSON_HOURS|SURVIVAL_BUILD_MAX_TICKS)$", "c_whitelist", "★person-hours【工量】非【時長】：每小時扣一次，而每日呼叫數由 TICKS_PER_DAY/NEAR_CADENCE 導出"),
		_mk("^(PRISONER_CHECK_INTERVAL|BLOCK_WINDOW|ENCOUNTER_STUCK_TICKS)$", "c_whitelist", "★遭遇軸：比對 encounter_tick 不是 world tick ⇒ 不隨根旋鈕變"),
		# ── (b) 延後：改法依賴未落地的改動 ──
		_mk("^BASE_ACTION_TICKS$", "b_defer", "★意圖是 1/6 小時（本質 (a)），但舊根下 TICKS_PER_HOUR/6 = 10//6 = 1 ⇒ 必須與 S2 同時落地"),
		# ── (d) 不是時間量：★每條寫【它是什麼量】──
		_mk("^DUMP_CHUNK_TICKS$", "d_not_time", "批次大小：observer 一塊跑幾 tick，是【分塊粒度】不是【時長】"),
		_mk("^DECISION_CADENCE_MULT$", "d_not_time", "倍數：×TICK_PER_DAY 的乘數，本身不是時間量"),
		_mk("^(LOD_|L_|RUNG_|FAC_|MAP_RADIUS)", "d_not_time", "列舉／層級索引／地圖尺度，非時間"),
		_mk("[A-Z_]*_(POP|POP_MIN|POP_MAX)$", "d_not_time", "人數"),
		_mk("[A-Z_]*(DIST|DISTANCE|RANGE|RADIUS)[A-Z_]*$", "d_not_time", "距離／半徑（格數）"),
		_mk("[A-Z_]*(THRESHOLD|LIMIT|PENALTY|COST|WIDTH|STEP|RETRY|SHARE|SIGNAL|BAND)[A-Z_]*$", "d_not_time", "門檻／代價／版面／步數等純量，非時間"),
		_mk("[A-Z_]*(CAP|MAX|MIN|COUNT|ENTRIES|MESSAGES|SLOTS|SIZE|LEVEL|TIER|REDUNDANCY|DIVISOR|K)$", "d_not_time", "上下限／數量／層級，非時間"),
		# ── ★第一輪 NEEDS_HUMAN 16 顆的逐族判決（每條寫【它是什麼量】）──
		_mk("^PRIO_", "d_not_time", "任務優先序分數（TaskArbiter 比大小用），與時間無關"),
		_mk("^N_LAYERS$", "d_not_time", "需求層級的層數（結構尺寸）"),
		_mk("^(MIGRANT_BATCH|OVERFLOW_ITERS|UNITS_PER_EQUIP)$", "d_not_time", "批量大小／迭代次數／配裝比，都是【次數】不是【時長】"),
		_mk("^NAMED_WEIGHT$", "d_not_time", "負重（named 成員算幾單位重量）"),
		_mk("^PROMOTE_DESPERATE_SPARE$", "d_not_time", "晉升時保留的人數額度"),
		_mk("^STATE_MIN_FACTION_TEAMS$", "d_not_time", "隊數門檻（立國最低團數）"),
		_mk("^WILD_HORSE_TILE_CAP_RICH$", "d_not_time", "單格野馬上限（數量）"),
		_mk("^(MAX|MIN|ANON|ENVOY|CONVOY|ESCORT|HORSE|FLOOR|BREAKOUT|ENCIRCLE|FLEE|DEFECT|GOVERN|CREATION|INVITE|CONSOLIDATE|DISPATCH|EXPAND|HEGEMON|FORAGE|FACILITY|ARROW|COL|BOARD|AI)_", "d_not_time", "同族純量（數量／距離／門檻），非時間"),
	]

	var rows: Array = []
	var tally: Dictionary = {}
	var total: int = 0
	_walk("res://scripts", rows)
	for row in rows:
		total += 1
		tally[row["disp"]] = int(tally.get(row["disp"], 0)) + 1
	rows.sort_custom(func(a, b): return String(a["name"]) < String(b["name"]))

	var keys: Array = tally.keys(); keys.sort()
	var sum: int = 0
	print("\n[S1c-const] 母體 %d" % total)
	for k in keys:
		print("   %-16s = %d" % [String(k), int(tally[k])])
		sum += int(tally[k])
	print("   %-16s = %d ⇒ %s" % ["合計", sum, "對帳一致" if sum == total else "★對帳不一致"])
	var nh: int = int(tally.get("NEEDS_HUMAN", 0))
	print("[S1c-const] %s" % ("★PASS：NEEDS_HUMAN=0 ⇒ 當下母體【掃完】" if nh == 0 else "★FAIL：%d 顆沒人判過" % nh))

	var out: Array = [
		"# S1c 封閉母體分類：全部 `const <NAME>: int = <裸字面量>`（排除 scripts/debug）",
		"# ★枚舉指令（別人重跑得出同一個數）：",
		"#   grep -rnE '^[[:space:]]*const [A-Z_][A-Z0-9_]*[[:space:]]*:[[:space:]]*int[[:space:]]*=[[:space:]]*-?[0-9]+[[:space:]]*(#.*)?$' \\",
		"#     --include=*.gd scripts/ | grep -v '^scripts/debug/' | wc -l",
		"# ★★『掃完』是【對當下母體的宣告】，不是永久狀態：新 code 會讓母體長大，",
		"#   而判準是 NEEDS_HUMAN == 0（不綁會隨 code 長大的量）。",
		"# 欄位：disposition|reason|name|value|path:line"]
	for k2 in keys:
		out.append("# %-16s = %d" % [String(k2), int(tally[k2])])
	out.append("# %-16s = %d" % ["母體", total])
	out.append("#")
	for row in rows:
		out.append("%s|%s|%s|%s|%s" % [row["disp"], row["reason"], row["name"], row["value"], row["site"]])
	var path: String = _env("CONST_OUT", "docs/measurements/2026-08-27-s1c-const-population.txt")
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(PackedStringArray(out)) + "\n"); f.close()
		print("[S1c-const] 落地：%s" % path)
	print("=== const_time_triage DONE ===")

func _walk(dir_path: String, rows: Array) -> void:
	for ex in EXCLUDE_DIRS:
		if dir_path == String(ex):
			return
	var d := DirAccess.open(dir_path)
	if d == null:
		return
	d.list_dir_begin()
	var n: String = d.get_next()
	while n != "":
		var full: String = dir_path + "/" + n
		if d.current_is_dir():
			if not n.begins_with("."):
				_walk(full, rows)
		elif n.ends_with(".gd"):
			_scan(full, rows)
		n = d.get_next()
	d.list_dir_end()

func _scan(path: String, rows: Array) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var ln: int = 0
	while not f.eof_reached():
		var s: String = f.get_line(); ln += 1
		var code: String = s
		var h: int = code.find("#")
		if h != -1:
			code = code.substr(0, h)
		var m := _bare_re.search(code)
		if m == null:
			continue
		var nm: String = m.get_string(1)
		var disp: String = "NEEDS_HUMAN"
		var reason: String = "★形狀認不出來 ⇒ 交人判（保守：漏判表現成「要人看的變多」）"
		for r in _rules:
			if (r["re"] as RegEx).search(nm) != null:
				disp = String(r["disp"]); reason = String(r["reason"])
				r["hits"] = int(r["hits"]) + 1
				break
		rows.append({"disp": disp, "reason": reason, "name": nm, "value": m.get_string(2),
			"site": "%s:%d" % [path.replace("res://", ""), ln]})
	f.close()

func _env(k: String, d: String) -> String:
	var v: String = OS.get_environment(k)
	return v if v != "" else d
