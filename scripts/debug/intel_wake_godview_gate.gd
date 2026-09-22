extends SceneTree
# @bed-kind: invariant
# slice: 票 §6／§9.1 —— ★威脅判定路徑禁讀目標的真值欄位（靜態掃描閘）
#
# ★★★為什麼需要它（票 §9 的原話）：`record_claim` 函式裡【已經存在】一段
#   gate-ok 標記過的 god-view 讀（`_o`／`_t`，純統計）——★**後門連 file:line 都現成擺在那裡**。
#   ⇒ 新的威脅判定若順手用了 `_t`，**它會長得跟既有那段一模一樣**。
# ★★閘的形狀（票明文）：
#   **放過**：`var _tgt: TeamData = state.teams.get(tgt_id)`（取 handle）
#            `ThreatAssessment.score(state, _ob, _tgt)`（整個交出去）
#            `_ob.xxx`（觀察者【自己】的東西）
#            `if Probe.hot_detail:` 區塊裡的 `_o`／`_t`（既有 gate-ok）
#   **抓到**：威脅判定路徑上任何 `_tgt.<欄位>`／`_tgt.<方法>()`／`_t.`／`_o.`
# ★★★錨在【函式 ＋ 區塊】不在行號 —— 行號會被「同檔多 100 行」推走，而推走時它顯示為綠。
# ★而樣式在【執行期】組出來 ⇒ 這支閘不會掃到自己的說明文字。

const SRC: String = "res://scripts/simulation/belief_system.gd"

func _initialize() -> void:
	var fail: int = 0
	var cells: int = 0
	print("=== 威脅判定禁 god-view 閘（%s）===" % SRC)

	var raw: String = FileAccess.get_file_as_string(SRC)
	if raw == "":
		push_error("[GV][不可判] 讀不到 %s ⇒ 母體 0（不是沒有違規）" % SRC)
		quit(2)
		return
	var lines: PackedStringArray = raw.split("\n")

	# ── ①錨：函式範圍（★不是行號）──
	var fn_start: int = -1
	var fn_end: int = lines.size()
	for i in range(lines.size()):
		var s: String = String(lines[i])
		if fn_start < 0 and s.begins_with("static func record_claim("):
			fn_start = i
			continue
		if fn_start >= 0 and (s.begins_with("static func ") or s.begins_with("func ")):
			fn_end = i
			break
	print("[GV] ★錨：`record_claim` 函式範圍 ＝ 行 %d~%d（由 `static func ` 邊界求得，不是寫死行號）" % [
		fn_start + 1, fn_end])
	if fn_start < 0:
		push_error("[GV][不可判] 找不到 `record_claim` ⇒ 錨腐爛（函式改名／搬走）—— ★不是沒有違規")
		quit(2)
		return
	cells += 1

	# ── ②既有 gate-ok 區塊（`if Probe.hot_detail:`）的範圍 ──
	var gk_start: int = -1
	var gk_end: int = -1
	for j in range(fn_start, fn_end):
		var t: String = String(lines[j])
		if gk_start < 0 and t.strip_edges().begins_with("if Probe.hot_detail:"):
			gk_start = j
			continue
		if gk_start >= 0 and t.strip_edges() != "" and not t.begins_with("\t\t"):
			gk_end = j
			break
	if gk_end < 0: gk_end = fn_end
	print("[GV] ★★既有 gate-ok 區塊（`if Probe.hot_detail:`）＝ 行 %d~%d ⇒ **閘放過它**" % [
		gk_start + 1, gk_end])
	if gk_start < 0:
		push_error("[GV][不可判] 找不到 `if Probe.hot_detail:` ⇒ 既有 gate-ok 區塊的錨腐爛")
		fail += 1
	cells += 1

	# ── ③掃描（樣式執行期組出來 ⇒ 不掃到自己的註解）──
	var banned: Array = ["_tgt" + ".", "_t" + ".", "_o" + "."]
	var hits: Array = []
	for k in range(fn_start, fn_end):
		if gk_start >= 0 and k >= gk_start and k < gk_end: continue    # ★放過既有 gate-ok 區塊
		var ln: String = String(lines[k])
		var code: String = ln
		var hi: int = code.find("#")
		if hi >= 0: code = code.substr(0, hi)                          # ★剝註解（否則說明文字會誤判）
		for b in banned:
			if code.find(b) >= 0:
				hits.append("行 %d：%s" % [k + 1, ln.strip_edges()])
				break
	# ── ★★★正向錨（systems 2026-09-22）：**被守的東西必須還在這裡** ──
	#   ★沒有它，這支閘是【恆真】的：它證明的是「`record_claim` 裡沒有 god-view 讀」，
	#     而威脅判定一旦搬到別的函式，那句話**自動成立** ⇒ 畫面永遠是綠的。
	#   ★★所以「找不到負向錨 ⇒ 不可判」只做對一半 —— **這是另一半**。
	var guarded_found: bool = false
	for gi in range(fn_start, fn_end):
		var gl: String = String(lines[gi])
		var gc: String = gl
		var gh: int = gc.find("#")
		if gh >= 0: gc = gc.substr(0, gh)
		if gc.find("ThreatAssessment" + ".score") >= 0:
			guarded_found = true
			break
	print("[GV] ★★★正向錨：`ThreatAssessment.score` 在 `record_claim` 內 ＝ %s" % str(guarded_found))
	if not guarded_found:
		push_error("[GV][不可判] 威脅判定不在 `record_claim` 裡了 ⇒ ★本閘變成恆真 ⇒ **不是綠**")
		quit(2)
		return
	cells += 1

	# ── ★★★B6（systems 2026-09-22 重新指向）：**抑制必須由【內容】決定，不得是常數** ──
	#   ★原本的 B6 是「把威脅也折進排定 ⇒ B2 惡化」,而 B2 已降級 ⇒ 它的目標消失了。
	#   ★★新目標：**構造檢查** —— emit 的 wake 參數必須是【由威脅判定導出的變數】,
	#     而不是 `false`／`true` 這種常數。★★★把它改成常數 ⇒ 這一格必須紅。
	#   ★它是秒級的靜態檢查,不吃機器 —— 比舊版好。
	var emit_line: String = ""
	var wake_asg: String = ""
	for bi in range(fn_start, fn_end):
		var bl: String = String(lines[bi])
		var bc: String = bl
		var bh: int = bc.find("#")
		if bh >= 0: bc = bc.substr(0, bh)
		if bc.find("WorldEvents" + ".emit(") >= 0 and bc.find("intel_arrived") >= 0:
			emit_line = bc.strip_edges()
		if bc.find("_wake" + " = ") >= 0 and bc.find("THREAT_BASE_THRESHOLD") >= 0:
			wake_asg = bc.strip_edges()
	print("[GV] ★★★B6 構造檢查（抑制必須由內容決定,不得是常數）")
	print("[GV]   emit 那一行：%s" % (emit_line if emit_line != "" else "★找不到"))
	print("[GV]   _wake 的來源：%s" % (wake_asg if wake_asg != "" else "★找不到"))
	var b6_ok: bool = true
	if emit_line == "":
		push_error("[GV][不可判] 找不到 intel_arrived 的 emit ⇒ 錨腐爛,不是沒有違規")
		b6_ok = false
	elif emit_line.find(", false)") >= 0 or emit_line.find(", true)") >= 0:
		push_error("[GV][FAIL] B6：emit 的 wake 參數是【常數】⇒ ★抑制不再由內容決定")
		b6_ok = false
	if wake_asg == "":
		push_error("[GV][FAIL] B6：找不到由 `THREAT_BASE_THRESHOLD` 導出的 `_wake` ⇒ ★謂詞不見了")
		b6_ok = false
	if b6_ok: print("[GV]   ⇒ ✔ wake 參數是變數且由威脅門檻導出（emit 帶變數 ＋ 賦值含 THREAT_BASE_THRESHOLD）")
	else: fail += 1
	cells += 1

	print("[GV] 掃到違規 %d 處（★掃的是 `record_claim` 內、gate-ok 區塊外）" % hits.size())
	for h in hits: print("[GV]   ★%s" % String(h))
	if hits.size() > 0:
		push_error("[GV][FAIL] 威脅判定路徑上有 %d 處直讀目標真值 ⇒ 違反感知鐵律" % hits.size())
		fail += 1
	cells += 1

	# ── ④★★★陽性對照：兩種形狀各試一次（票 §9.1 明文要求）──
	#   ★用【合成行】餵同一套掃描邏輯 —— 它證明「這個判準會咬」，
	#   ★★而它不能取代真檔掃描（合成行是照我的偵測器形狀造的）。
	var probes: Array = [
		["讀欄位", "\t\t\tvar _x: int = _tg" + "t.population"],
		["呼叫方法", "\t\t\tvar _y = _tg" + "t.is_alive()"],
		["用既有 gate-ok 的 handle", "\t\t\tvar _z = _" + "t.tile_pos"],
	]
	var ctrl_ok: int = 0
	for pr in probes:
		var line: String = String(pr[1])
		var c2: String = line
		var h2: int = c2.find("#")
		if h2 >= 0: c2 = c2.substr(0, h2)
		var caught: bool = false
		for b2 in banned:
			if c2.find(b2) >= 0: caught = true
		print("[GV] ★陽性對照（%s）：`%s` ⇒ %s" % [String(pr[0]), line.strip_edges(),
			"會紅 ✔" if caught else "★不會紅 ✘"])
		if caught: ctrl_ok += 1
	print("[GV] 陽性對照 %d／%d 會紅" % [ctrl_ok, probes.size()])
	if ctrl_ok != probes.size():
		push_error("[GV][FAIL] 陽性對照 %d／%d ⇒ 這個判準對某些形狀不敏感" % [ctrl_ok, probes.size()])
		fail += 1
	cells += 1

	# ── ⑤★陰性對照：合法形狀【不得】被咬 ──
	var ok_probes: Array = [
		"\t\t\tvar _tg" + "t: TeamData = state.teams.get(tgt_id)",
		"\t\t\t_threat_score = ThreatAssessment.score(state, _ob, _tg" + "t)",
		"\t\t\tvar _d: int = FactionAISystem._hex_dist(_ob.tile_pos, fields[\"tile_pos\"])",
	]
	var false_pos: int = 0
	for op in ok_probes:
		var c3: String = String(op)
		var h3: int = c3.find("#")
		if h3 >= 0: c3 = c3.substr(0, h3)
		var bit: bool = false
		for b3 in banned:
			if c3.find(b3) >= 0: bit = true
		print("[GV] ★陰性對照：`%s` ⇒ %s" % [String(op).strip_edges(), "★被誤咬 ✘" if bit else "放行 ✔"])
		if bit: false_pos += 1
	if false_pos > 0:
		push_error("[GV][FAIL] %d 個【合法形狀】被誤咬 ⇒ 閘會擋掉正確的寫法" % false_pos)
		fail += 1
	cells += 1

	print("[GV] ★★誠實限：本閘只掃 `record_claim`；威脅判定若被搬到別的函式，★錨會失效而畫面是綠的")
	print("=== INTEL-WAKE-GODVIEW-GATE %s（fail=%d｜到場點名 %d／7）===" % [
		"PASS" if fail == 0 else "FAIL", fail, cells])
	if cells != 7:
		push_error("[GV][FAIL] 到場點名 %d／7 ⇒ 有格沒跑到" % cells)
		fail += 1
	quit(1 if fail > 0 else 0)
