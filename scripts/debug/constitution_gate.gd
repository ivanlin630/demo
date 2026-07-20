extends SceneTree

# ★★★ 沙盒憲法防閘 v2（site-freeze，抓全閘型）：零殘留 + 真統一證明機制。
# v1 只抓 TaskArbiter task 指派；v2 加值閘（RNG-in-decision / override early-return / 硬門檻）
# + 控制流閘（散落入口 rank_*/eval_* / 手派 route / TaskArbiter）。
# 指紋 = <relpath>::<func>::<type>。契約：current ⊆ baseline。added=FAIL（新閘）。removed=PASS（de-patch 進度）。
# ★不 auto-classify legit vs violation（做不到）——enumerate 全部；legit/violation 標記由後續 de-patch 人工判。
# 源碼行含 `# gate-ok` = 明允世界機制豁免（如 combat 擲骰），不入 current。
#
# ★★v3 加 god-view 偵測（感知鐵律機器證，2026-07-20）：決策讀 belief 非 live 他隊真值/whole-map 瞬知。
#   gv_teamstate = indexed `state.teams[id].<動態欄>`（1119 can_reach 型：刻意讀單一他隊 live 態）——高信號。
#   gv_mapscan   = `for x in <...>.tiles`（whole-map 瞬掃，Slice C 市集發現型）——中信號，地理/own-infra legit → # gate-ok。
#   ★限制：靜態 regex 分不出 loop var 是自/他 → 不抓「for t in teams: t.tile_pos」型（結構性全隊迭代=引擎 orchestration，噪音高故 DROP gv_teamscan）。
#   本 gate 是「明顯重引入」回歸閘非證明；細粒度 self/other 靠 review。enumerate→凍 baseline→NEW FAIL。legit(self/地理)標 # gate-ok。

const SCAN_DIR := "res://scripts/simulation"
const BASELINE := "res://scripts/debug/constitution_baseline_v2.txt"

# 決策路徑檔（值閘/控制流閘只在此掃；世界機制檔如 combat/resource RNG 不算決策閘）
const DECISION_FILE_RE := "(faction_ai_system|diplomatic_ai_system|npc_ai_system|strategic_ai_system|decision/)"
# god-view 檔（感知鐵律偵測；比決策檔廣一格：含 threat_assessment=威脅感知規範案）。獨立不擾值閘 baseline。
const GV_FILE_RE := "(faction_ai_system|diplomatic_ai_system|npc_ai_system|strategic_ai_system|threat_assessment|decision/)"
# 決策函式（override/threshold/route 只在此算）
const DECISION_FUNC_RE := "(^_pick_|^_decide_|^_evaluate_|^_facility_|^rank_|^to_task$|^applicable$|_score$|^_threat_recent$|^_consider_|^_trigger_|^_calc_|_deficit$|^_is_)"
# 散落入口（同決策多 dispatch 點：真統一破口）
const DISPATCH_FUNC_RE := "^(rank_survival|rank_threat|rank_scored|rank_scored_ctx|rank_ambient|_evaluate_survival|_evaluate_threat|_evaluate_unified|_evaluate_infrastructure)$"

# 值閘偵測器
const RNG_RE := "\\b(randf|randi|randomize)\\s*\\("
const TASKARBITER_RE := "TaskArbiter\\.(transition|try_set)\\("
# 硬門檻：if/elif/while 條件內比較具名常數(3+ 大寫)或數字字面
const THRESHOLD_RE := "\\b(if|elif|while|and|or)\\b.*[<>]=?\\s*([A-Z][A-Z0-9_]{2,}[A-Za-z0-9_.]*|[0-9]+\\.?[0-9]*)"
# override early-return：同行 if 守衛 return（rank/argmax 前 bypass）
const EARLY_RETURN_RE := "^\\s*if\\b.*:\\s*return\\b"
# 手派 route：按 uses_unified / 隊型 / tag / task 手動選路徑
const ROUTE_RE := "\\bif\\b.*(uses_unified|ambition_archetype\\s*==|current_task\\s*==|\\.tags\\.has\\(|is_merchant|is_subteam)"

# ─── god-view 偵測器（感知鐵律：決策讀 belief 非 live 他隊真值/whole-map 瞬知）───
# gv_teamstate：state.teams[id].<動態欄> = indexed live 他隊態讀（1119 can_reach 型；自讀/同-faction legit → # gate-ok）
const GV_TEAMSTATE_RE := "state\\.teams\\[[^\\]]+\\]\\.(tile_pos|armed|food|coin|population|morale|troops|current_task)"
# gv_mapscan：for x in <...>.tiles = whole-map tile 迭代（市集/資源瞬掃全圖；地理=公共知識 legit → # gate-ok）
const GV_MAPSCAN_RE := "for\\s+\\w+\\s+in\\s+[^#]*\\.tiles\\b"

func _initialize() -> void:
	var current: Dictionary = _scan()
	var baseline: Dictionary = _load_baseline()
	var added: Array = []
	for fp in current.keys():
		if not baseline.has(fp): added.append(fp)
	var removed: Array = []
	for fp in baseline.keys():
		if not current.has(fp): removed.append(fp)
	added.sort(); removed.sort()
	# 類型分布統計
	var by_type: Dictionary = {}
	for fp in current.keys():
		var t: String = String(fp).split("::")[-1]
		by_type[t] = int(by_type.get(t, 0)) + 1
	for fp in removed:
		print("[gate] removed (de-patch 進度): %s" % fp)
	print("[gate] 類型分布: %s" % str(by_type))
	if baseline.is_empty():
		# 首跑：無 baseline → 印全 enumerate 供產 baseline 檔（不判 pass/fail）
		print("[gate] ★baseline 空——enumerate %d 閘（下印全清單供凍結）：" % current.size())
		var all_fp: Array = current.keys(); all_fp.sort()
		for fp in all_fp:
			print(fp)
		print("[CONSTITUTION-GATE] BASELINE-MISSING（enumerate=%d，寫入 %s 後 re-run）" % [current.size(), BASELINE])
	elif added.is_empty():
		print("[CONSTITUTION-GATE] PASS (sites=%d, removed=%d)" % [current.size(), removed.size()])
	else:
		for fp in added:
			print("[gate] ❌ 新增閘: %s" % fp)
		print("[CONSTITUTION-GATE] FAIL：新增 %d 個閘。溶入引擎/統一，或呈報系統更新 baseline。" % added.size())
	quit()

func _scan() -> Dictionary:
	var out: Dictionary = {}
	var dfile := RegEx.new(); dfile.compile(DECISION_FILE_RE)
	var dfunc := RegEx.new(); dfunc.compile(DECISION_FUNC_RE)
	var disp := RegEx.new(); disp.compile(DISPATCH_FUNC_RE)
	var func_re := RegEx.new(); func_re.compile("^\\s*(?:static\\s+)?func\\s+(\\w+)")
	var rng := RegEx.new(); rng.compile(RNG_RE)
	var ta := RegEx.new(); ta.compile(TASKARBITER_RE)
	var thr := RegEx.new(); thr.compile(THRESHOLD_RE)
	var early := RegEx.new(); early.compile(EARLY_RETURN_RE)
	var route := RegEx.new(); route.compile(ROUTE_RE)
	var gvfile := RegEx.new(); gvfile.compile(GV_FILE_RE)
	var gv_ts := RegEx.new(); gv_ts.compile(GV_TEAMSTATE_RE)
	var gv_map := RegEx.new(); gv_map.compile(GV_MAPSCAN_RE)
	var res: Array = [dfile, dfunc, disp, func_re, rng, ta, thr, early, route, gvfile, gv_ts, gv_map]
	_walk(SCAN_DIR, res, out)
	return out

func _walk(dir_path: String, res: Array, out: Dictionary) -> void:
	var d := DirAccess.open(dir_path)
	if d == null: return
	d.list_dir_begin()
	var name_s: String = d.get_next()
	while name_s != "":
		var full: String = dir_path + "/" + name_s
		if d.current_is_dir():
			if not name_s.begins_with("."):
				_walk(full, res, out)
		elif name_s.ends_with(".gd"):
			_scan_file(full, res, out)
		name_s = d.get_next()
	d.list_dir_end()

func _scan_file(path: String, res: Array, out: Dictionary) -> void:
	var dfile: RegEx = res[0]; var dfunc: RegEx = res[1]; var disp: RegEx = res[2]
	var func_re: RegEx = res[3]; var rng: RegEx = res[4]; var ta: RegEx = res[5]
	var thr: RegEx = res[6]; var early: RegEx = res[7]; var route: RegEx = res[8]
	var gvfile: RegEx = res[9]; var gv_ts: RegEx = res[10]; var gv_map: RegEx = res[11]
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null: return
	var rel: String = path.replace("res://", "")
	var is_decision: bool = dfile.search(rel) != null
	var is_gv_file: bool = gvfile.search(rel) != null
	var cur_func: String = "<global>"
	while not f.eof_reached():
		var line: String = f.get_line()
		var fm := func_re.search(line)
		if fm != null:
			cur_func = fm.get_string(1)
			# 散落入口：dispatch 函式定義本身 = 一個閘（多決策入口）
			if is_decision and disp.search(cur_func) != null:
				out["%s::%s::dispatch_entry" % [rel, cur_func]] = true
		# TaskArbiter（回歸：v1 task 指派全檔仍抓）
		if ta.search(line) != null:
			out["%s::%s::taskarbiter" % [rel, cur_func]] = true
		# god-view 閘（感知鐵律）——gv_file 全 func（含 threat_assessment、helper 如 _precond_met/consolidate_target_of），非只 dfunc。# gate-ok 豁免自讀/同-faction/公共地理。
		if is_gv_file and line.find("# gate-ok") == -1:
			if gv_ts.search(line) != null:
				out["%s::%s::gv_teamstate" % [rel, cur_func]] = true
			if gv_map.search(line) != null:
				out["%s::%s::gv_mapscan" % [rel, cur_func]] = true
		if not is_decision:
			continue
		if line.find("# gate-ok") != -1:
			continue   # 明允世界機制豁免
		# 值閘 A：RNG-in-decision
		if rng.search(line) != null:
			out["%s::%s::rng" % [rel, cur_func]] = true
		var in_dfunc: bool = dfunc.search(cur_func) != null
		if not in_dfunc:
			continue
		# 值閘 B：硬門檻
		if thr.search(line) != null:
			out["%s::%s::threshold" % [rel, cur_func]] = true
		# 值閘 C：override early-return
		if early.search(line) != null:
			out["%s::%s::early_return" % [rel, cur_func]] = true
		# 控制流閘 E：手派 route
		if route.search(line) != null:
			out["%s::%s::route" % [rel, cur_func]] = true
	f.close()

func _load_baseline() -> Dictionary:
	var out: Dictionary = {}
	var f := FileAccess.open(BASELINE, FileAccess.READ)
	if f == null:
		return out
	while not f.eof_reached():
		var line: String = f.get_line().strip_edges()
		if line == "" or line.begins_with("#"): continue
		# 容許行內註解（# gate-ok / # 待de-patch）——取 `#` 前的指紋
		var h: int = line.find("#")
		if h != -1:
			line = line.substr(0, h).strip_edges()
		if line != "":
			out[line] = true
	f.close()
	return out
