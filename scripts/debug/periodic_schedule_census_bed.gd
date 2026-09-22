extends SceneTree
# @bed-kind: diagnostic
# slice: 60-tick 尖峰歸因 —— 第 0 步：★把全庫【所有週期性排程的週期值】原樣列出來
#
# ★★★這一格【不是】去找「哪個常數等於 60」——是「列出全部 X」。
#   60 若在裡面，它會自己掉出來；★★若不在，那是更重要的答案：**尖峰的來源不是 *_next_tick**。
# ★掃的是【形狀】不是【名字】：週期性在 tick 迴圈裡只有兩個來源 ——
#   ①`tick % X == 0` 型的模閘（★涵蓋 LOD／小時邊界／結算這些不叫 cadence 的東西）
#   ②`*_next_tick` 型的排程欄位（純加法 `+ X`，或 `CadenceStagger.next_tick(..., X)`）
# ★★★而我的偵測器只認得【我想得到的形狀】⇒ 所以有第三欄：**殘渣**
#   ——「這一行同時出現 tick 與 %，但沒有任何形狀接住它」⇒ 那才是我看不見的那格。
#   ★沒有殘渣欄，這份普查只證明我的 regex 認得自己。
#
# env：PC_ROOT（預設 res://scripts）

func _initialize() -> void:
	var root: String = OS.get_environment("PC_ROOT") if OS.has_environment("PC_ROOT") else "res://scripts"
	print("=== 週期性排程普查（root=%s）===" % root)
	var fail: int = 0
	var cells: int = 0

	var files: Array = []
	_walk(root, files)
	print("[PC] 掃到 .gd 檔 %d 支" % files.size())
	if files.size() < 50:
		push_error("[PC][不可判] 只掃到 %d 支 .gd ⇒ 母體塌陷（走訪器壞了，不是庫只有這麼多）" % files.size())
		quit(2)
		return

	# ── ① const 值表（給解析週期值用；★同名不同值 ⇒ 標歧義，不挑一個）──
	var re_const := RegEx.create_from_string("^const\\s+([A-Z][A-Z_0-9]*)\\s*(?::\\s*int\\s*)?:?=\\s*([^#]+)")
	var re_mod := RegEx.create_from_string("([A-Za-z_][A-Za-z_0-9.]*)\\s*%\\s*([A-Za-z_0-9.]+)\\s*==\\s*0")
	var re_add := RegEx.create_from_string("([a-z_][a-z_0-9]*_next_tick)\\s*=\\s*[^=#]*?\\+\\s*([A-Za-z_0-9.]+)")
	var re_stag := RegEx.create_from_string("CadenceStagger\\.next_tick\\(([^)]*)\\)")
	var re_resid := RegEx.create_from_string("%")

	var consts: Dictionary = {}     # 短名 → {值字串: [來源]}
	var srcs: Dictionary = {}       # 路徑 → 去註解後的行陣列
	for p in files:
		var raw: String = FileAccess.get_file_as_string(p)
		var lines: Array = []
		for ln in raw.split("\n"):
			var s: String = String(ln)
			var hi: int = s.find("#")
			if hi >= 0: s = s.substr(0, hi)
			# ★剝雙引號字串字面值：`"%-16s"` 這種格式字串會讓殘渣欄被 %d 淹掉
			s = _strip_strings(s)
			lines.append(s)
		# ★★★跨行合併：庫裡的 `CadenceStagger.next_tick(` 有一半是【換行寫】的,
		#   而逐行 regex 對它們【靜默零命中】—— 普查照樣印得很漂亮。
		#   ⇒ 括號未閉合的行吸收後續行,行號記【起始行】。
		var joined: Array = []
		var k: int = 0
		while k < lines.size():
			var cur: String = String(lines[k])
			var bal: int = cur.count("(") - cur.count(")")
			var k2: int = k
			while bal > 0 and k2 + 1 < lines.size():
				k2 += 1
				var nx: String = String(lines[k2])
				cur += " " + nx.strip_edges()
				bal += nx.count("(") - nx.count(")")
			joined.append(cur)
			for _pad in range(k2 - k): joined.append("")
			k = k2 + 1
		lines = joined
		srcs[p] = lines   # ★已跨行合併
		for ln2 in lines:
			var m := re_const.search(String(ln2))
			if m == null: continue
			var nm: String = m.get_string(1)
			var val: String = m.get_string(2).strip_edges()
			if not consts.has(nm): consts[nm] = {}
			var d: Dictionary = consts[nm]
			if not d.has(val): d[val] = []
			d[val].append(p)
	print("[PC] const 值表：相異常數名 %d 個" % consts.size())
	cells += 1

	# ── ② 三種形狀掃描 ──
	var hits: Array = []            # [週期表達式, 形狀, 來源]
	var residue: Array = []
	for p2 in files:
		var lines3: Array = srcs[p2]
		for i in range(lines3.size()):
			var s3: String = String(lines3[i])
			if s3.strip_edges() == "": continue
			var got: bool = false
			var mm := re_mod.search(s3)
			if mm != null:
				hits.append([mm.get_string(2), "①模閘 %s %% X == 0" % mm.get_string(1), "%s:%d" % [p2, i + 1]])
				got = true
			var ma := re_add.search(s3)
			if ma != null:
				hits.append([ma.get_string(2), "②純加法 %s += X" % ma.get_string(1), "%s:%d" % [p2, i + 1]])
				got = true
			var ms := re_stag.search(s3)
			if ms != null:
				var args: PackedStringArray = ms.get_string(1).split(",")
				if args.size() >= 4:
					hits.append([String(args[3]).strip_edges(), "③CadenceStagger", "%s:%d" % [p2, i + 1]])
					got = true
			# ★殘渣：有 % 又有 tick，卻沒被任何形狀接住
			if not got and re_resid.search(s3) != null and s3.to_lower().find("tick") >= 0:
				residue.append("%s:%d｜%s" % [p2, i + 1, s3.strip_edges()])
	print("[PC] 形狀命中 %d 處｜★殘渣（有 %% 又有 tick 但沒被接住）%d 行" % [hits.size(), residue.size()])
	cells += 1

	# ── ③ 解析成數值並彙總（★不過濾任何值）──
	var by_val: Dictionary = {}
	var unresolved: Dictionary = {}
	for h in hits:
		var expr: String = String(h[0])
		var v: int = _resolve(expr, consts)
		if v < 0:
			if not unresolved.has(expr): unresolved[expr] = []
			unresolved[expr].append(String(h[2]))
			continue
		if not by_val.has(v): by_val[v] = []
		by_val[v].append("%s ← %s" % [String(h[1]), String(h[2])])
	var vals: Array = by_val.keys()
	vals.sort()
	print("\n[PC] ★★★全部週期值（升冪，★沒有過濾、沒有挑）：相異值 %d 個" % vals.size())
	for v2 in vals:
		var lst: Array = by_val[v2]
		# ★★拆【生產】vs【床】：尖峰是跑世界時發生的 ⇒ 只有生產那一欄能解釋它,
		#   但 debug 那一欄【也要印】—— 不印就看不出「這個值只是床在用」。
		var prod: Array = []
		for e in lst:
			if String(e).find("/debug/") < 0: prod.append(e)
		var d2: float = float(v2) / float(WorldState.TICKS_PER_DAY)
		print("[PC] ★週期 %-8d（%.3f 天 ／ %.2f 小時）共 %d 處｜★生產 %d 處｜床 %d 處" % [
			int(v2), d2, float(v2) / float(WorldState.TICKS_PER_HOUR), lst.size(),
			prod.size(), lst.size() - prod.size()])
		for j in range(mini(6, prod.size())):
			print("[PC]      [生產] %s" % String(prod[j]))
		if prod.size() > 6: print("[PC]      [生產] …其餘 %d 處" % (prod.size() - 6))
	cells += 1

	print("\n[PC] ★未解析的週期表達式 %d 種（★它們【也是】母體的一部分，不可當作不存在）" % unresolved.size())
	var uk: Array = unresolved.keys()
	uk.sort()
	for u in uk:
		var ul: Array = unresolved[u]
		print("[PC]   %-34s ×%d 處｜例：%s" % [String(u), ul.size(), String(ul[0])])
	cells += 1

	var res_prod: Array = []
	for r in residue:
		if String(r).find("/debug/") < 0: res_prod.append(r)
	print("[PC] ★★殘渣（形狀沒接住、剝掉字串字面值後仍同時有 %% 與 tick）：共 %d 行｜★生產 %d 行" % [
		residue.size(), res_prod.size()])
	print("[PC]   ★★★這一欄才是「我的偵測器認不得的那格」")
	for k3 in range(mini(40, res_prod.size())):
		print("[PC]   [生產] %s" % String(res_prod[k3]))
	if res_prod.size() > 40: print("[PC]   [生產] …其餘 %d 行" % (res_prod.size() - 40))
	cells += 1

	# ── ★陽性對照：三種形狀各餵一條【已知會命中】的合成行 ──
	#   ★★它只證明「偵測器認得自己的形狀」——★★★所以上面的【殘渣欄】才是真正的防線，
	#   這一格擋的是另一種病：regex 打錯字 ⇒ 整個形狀靜默零命中而普查照樣印得很漂亮。
	var probes: Array = [
		["state.world.current_tick % 1440 == 0", re_mod, "①"],
		["team.foo_next_tick = state.world.current_tick + 4320", re_add, "②"],
		["x = CadenceStagger.next_tick(a, b, c, 999)", re_stag, "③"],
	]
	var ctrl_ok: int = 0
	for pr in probes:
		var rr: RegEx = pr[1]
		var hit: bool = rr.search(String(pr[0])) != null
		print("[對照] 形狀%s：%s ⇒ %s" % [String(pr[2]), String(pr[0]), "命中 ✔" if hit else "★零命中 ✘"])
		if hit: ctrl_ok += 1
	if ctrl_ok != probes.size():
		push_error("[對照][FAIL] %d／%d 形狀沒命中自己的合成行 ⇒ regex 壞了，普查數字無效" % [
			ctrl_ok, probes.size()])
		fail += 1
	cells += 1

	print("\n[誠實限] ①剝註解是用 find(\"#\")，字串裡的 # 會被誤剝 ⇒ 少數行可能被截短")
	print("[誠實限] ②只解析 `const NAME = 字面值／單一常數參照`，算式型的進【未解析】欄，不進值表")
	print("[誠實限] ③本床答的是「庫裡有哪些週期」，★不答「哪個週期造成尖峰」——那要逐 tick 歸因")
	print("=== periodic_schedule_census DONE（fail=%d｜到場點名 %d／6）===" % [fail, cells])
	if cells != 6:
		push_error("[FAIL] 到場點名 %d／6 ⇒ 有格沒跑到" % cells)
		fail += 1
	quit(1 if fail > 0 else 0)

func _resolve(expr: String, consts: Dictionary) -> int:
	var e: String = expr.strip_edges()
	if e.is_valid_int(): return int(e)
	var short: String = e.get_slice(".", e.get_slice_count(".") - 1)
	if not consts.has(short): return -1
	var d: Dictionary = consts[short]
	if d.size() != 1: return -1          # ★同名不同值 ⇒ 歧義，不挑一個
	var val: String = String(d.keys()[0]).strip_edges()
	if val.is_valid_int(): return int(val)
	if val == e: return -1
	return _resolve(val, consts)

func _walk(dir: String, out: Array) -> void:
	var d := DirAccess.open(dir)
	if d == null: return
	d.list_dir_begin()
	var n: String = d.get_next()
	while n != "":
		if d.current_is_dir():
			if not n.begins_with("."): _walk(dir + "/" + n, out)
		elif n.ends_with(".gd"):
			# ★★★排除本床自身：它裡面有【合成對照行】,不排除會把 999／4320 這種
			#   我自己寫的假週期印進普查 ⇒ 普查會說庫裡有一個不存在的週期。
			if not n.begins_with("periodic_schedule_census"):
				out.append(dir + "/" + n)
		n = d.get_next()
	d.list_dir_end()

func _strip_strings(s: String) -> String:
	# ★只剝雙引號字串（GDScript 也允許單引號,但庫裡幾乎全用雙引號 ⇒ 誠實限已註明）
	var out: String = ""
	var inq: bool = false
	for i in range(s.length()):
		var ch: String = s[i]
		if ch == "\"":
			inq = not inq
			continue
		if not inq: out += ch
	return out
