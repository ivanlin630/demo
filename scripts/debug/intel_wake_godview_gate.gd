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
	print("=== INTEL-WAKE-GODVIEW-GATE %s（fail=%d｜到場點名 %d／5）===" % [
		"PASS" if fail == 0 else "FAIL", fail, cells])
	if cells != 5:
		push_error("[GV][FAIL] 到場點名 %d／5 ⇒ 有格沒跑到" % cells)
		fail += 1
	quit(1 if fail > 0 else 0)
