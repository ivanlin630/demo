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
const RNG_RE := "\\b(randf_range|randi_range|randfn|randf|randi|randomize|seed|pick_random|shuffle)\\s*\\("
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
# ★★★gv_belief_pre / gv_belief_post（藍圖裁「開」，warn 層，2026-09-02）：
#   ★判準：決策檔裡，來自 `state.teams.get(<非自己>)` 的物件，其動態欄被【直讀】。
#   ★★兩個子形要分得開（藍圖要求）：
#      gv_belief_post ＝ 同函式內【已經】出現過 belief 呼叫之後才讀（過了閘還讀 live）
#      gv_belief_pre  ＝ 在任何 belief 呼叫【之前】就讀（用 live 決定算不算候選，更嚴重）
#   ★★★誠實限（實測逼出來的）：本判準只看得見【同一個函式裡】的直讀。
#      Fix A 的 live 讀發生在【被呼叫的另一支函式】裡，而那支拿到的是【參數】
#      ⇒ ★本偵測器【抓不到 Fix A】—— 那正是我把 Fix A 改成【型別防線】（簽名吃兩個 Vector2i）的理由。
const GV_TVAR_RE := "var\\s+(\\w+)\\s*:?[^=]*=\\s*state\\.teams\\.get\\("
const GV_BELIEF_CALL_RE := "BeliefSystem\\.(has_belief|belief_pos|best_estimate|known_targets)"
const GV_DYNFIELD_RE := "\\.(tile_pos|population|resources|armed|food|coin|morale|current_task)\\b"

func _initialize() -> void:
	var current: Dictionary = _scan()
	var baseline: Dictionary = _load_baseline()
	# ★★★warn 通道（systems 裁 2026-09-02，★bless 否決的正解）：
	#   `gv_belief_pre` / `gv_belief_post` ★不進 `current ⊆ baseline` 硬契約。
	#   ★理由：baseline 的語意是【已凍結承認】⇒ 把 23 顆【沒逐顆判過】的命中塞進去
	#     ＝ 讓它們【永久不再紅】＝ 把未確認寫成已知。
	#   ★★藍圖裁的是【warn 層】：印出來、計數、不 FAIL。
	#   ★★★升 hard 的條件（寫死在這裡，免得下一個人只看到「它不 FAIL」就以為它不重要）：
	#     23 顆逐顆判過之後 —— legit 的標 inline `# gate-ok`（不入 current）、真違規的修掉，
	#     ★剩下的才凍進 baseline。★★那時 baseline 才是【判過的】而不是【沒看過的】。
	const WARN_TYPES: Array = ["gv_belief_pre", "gv_belief_post"]
	var warn_hits: Array = []
	var added: Array = []
	for fp in current.keys():
		if String(fp).split("::")[-1] in WARN_TYPES:
			if not baseline.has(fp): warn_hits.append(fp)
			continue
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
	# ★warn 通道：印出來、計數、★不 FAIL（升 hard 的條件見上方 WARN_TYPES 註解）
	warn_hits.sort()
	if not warn_hits.is_empty():
		print("[gate] ⚠ WARN（不擋 merge）：gv_belief_* %d 顆 —— ★【沒有逐顆判過是否 legit】" % warn_hits.size())
		for fp in warn_hits:
			print("[gate]    ⚠ %s" % fp)
		print("[gate] ★★這個數字要【印出來】才不會靜靜長大；★★★而它不是「%d 個違憲」，是【%d 顆待判】。"
			% [warn_hits.size(), warn_hits.size()])
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
	var gv_tvar := RegEx.new(); gv_tvar.compile(GV_TVAR_RE)
	var gv_bel := RegEx.new(); gv_bel.compile(GV_BELIEF_CALL_RE)
	var gv_dyn := RegEx.new(); gv_dyn.compile(GV_DYNFIELD_RE)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null: return
	var rel: String = path.replace("res://", "")
	var is_decision: bool = dfile.search(rel) != null
	var is_gv_file: bool = gvfile.search(rel) != null
	var cur_func: String = "<global>"
	# ★gv_belief_* 的每函式狀態（換函式即重置——不重置會把上一支的 belief 呼叫算進來）
	var tvars: Dictionary = {}
	var seen_belief: bool = false
	# ★跨行 Probe 呼叫的括號結轉（★對照組實測抓到的缺陷 2026-08-26）：
	#   `Probe.bump("...%s" % [site,` 換行後，★續行上【一個 `Probe.` 字樣都沒有】
	#   ⇒ 只看單行的剝離會剝不到它，而那正是本次誤報的第二條。
	var probe_carry: int = 0
	while not f.eof_reached():
		var line: String = f.get_line()
		# ★★★剝離必須【每行無條件跑】——下面有多個 `continue`（非決策檔／gate-ok 行／非 dfunc），
		#   任何一個跳過都會讓跨行括號結轉失步 ⇒ ★之後每一行的剝離結果都是錯的，而且不會有症狀。
		var _sr: Array = _strip_observation(line, probe_carry)
		var probe_free: String = String(_sr[0])
		probe_carry = int(_sr[1])
		var fm := func_re.search(line)
		if fm != null:
			cur_func = fm.get_string(1)
			tvars.clear(); seen_belief = false
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
			# ★gv_belief_*：先記「哪些變數是他隊物件」，再看它們的動態欄有沒有被直讀
			# ★★★先剝註解 —— ★血證：我在 Fix A 的註解裡寫了 `prey.tile_pos`（在講它【原本】讀那個），
			#   而偵測器把【我的註解】當成 live 讀 ⇒ 修好的函式照樣紅。
			#   ★★這是今天第六次「註解自成一欄」，而這次是【我自己的偵測器被我自己的註解騙】。
			var _hash: int = line.find("#")
			var code_only: String = line if _hash == -1 else line.substr(0, _hash)
			var tv := gv_tvar.search(code_only)
			if tv != null:
				# ★排除【自己】：`state.teams.get(team.team_id)` 這種是自讀，R² 已確認合法
				#   ★★不排除的話這個桶會噴滿（實測未排除時 25 個命中，多數是自讀）
				if line.find("team.team_id") == -1 and line.find("self") == -1:
					tvars[tv.get_string(1)] = true
			if gv_bel.search(code_only) != null:
				seen_belief = true
			for vn in tvars:
				var _at: int = code_only.find(String(vn) + ".")
				if _at == -1:
					continue
				if gv_dyn.search(code_only.substr(_at + String(vn).length())) != null:
					out["%s::%s::%s" % [rel, cur_func, ("gv_belief_post" if seen_belief else "gv_belief_pre")]] = true
					break
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
		# ★★★觀測剝離（systems 派 2026-08-26 / slice constitution-gate-unblock）：
		#   ★病：閘分不出兩種比較 —— ①【決定的比較】`if x < THRESHOLD: return false`（該抓）
		#     ②【替已發生之事命名的比較】`Probe.bump("a" if x >= 3 else "b")`（不該抓）。
		#   ★★而我們正在【系統性地】加②：每一顆漏斗 tap 的核心工作就是「把一個出口分類」，
		#     而分類就是比較 ⇒ ★這個誤報會隨著儀器做得越好而越常出現。
		#
		# ★★★為什麼不是「整行含 `Probe.` 就跳過」（systems 的建議，我改了形狀）：
		#   `if x > SOME_THRESHOLD and Probe.enabled:` 這種行會被整行跳過 ⇒ ★真門檻被放行，
		#   而它【不會有任何症狀】——閘還是綠的。★★「跳過一整行」是用可能漏抓換不誤報。
		#   ⇒ 改成【把觀測呼叫從該行剝掉，再拿剩下的去測】：
		#     剝完沒東西剩 ⇒ 那個比較本來就在 Probe 的引數裡 ⇒ 不是決策；
		#     剝完還命中 ⇒ 決策在觀測【之外】⇒ 照抓不誤。
		#   ★★★而 systems 提的那個更嚴重的情況（把決策寫進 Probe 的回傳值，如 `if Probe.check(x>5): return`）
		#     在這個形狀下【自動保留】：剝掉 `Probe.check(...)` 後剩下 `if : return`，early_return 仍命中。
		# 值閘 B：硬門檻
		if thr.search(probe_free) != null:
			out["%s::%s::threshold" % [rel, cur_func]] = true
		# 值閘 C：override early-return
		if early.search(probe_free) != null:
			out["%s::%s::early_return" % [rel, cur_func]] = true
		# 控制流閘 E：手派 route
		if route.search(probe_free) != null:
			out["%s::%s::route" % [rel, cur_func]] = true
	f.close()

# ★把該行的觀測呼叫剝掉（`Probe.xxx(...)` 連同括號內全部，含巢狀）。
# ★保留 `Probe.enabled` 這種【無括號】的旗標讀取——它若出現在條件裡，剩下的部分仍會被測到。
# ★★純字串處理、零 regex 遞迴：找 "Probe."，往後找第一個 "("，配對到對應的 ")"，整段刪掉。
# ★把該行的觀測呼叫剝掉（`Probe.xxx(...)` 連同括號內全部，含巢狀與【跨行】）。
# ★保留 `Probe.enabled` 這種【無括號】的旗標讀取——它若出現在條件裡，剩下的部分仍會被測到。
# 回傳 [剝完的字串, 結轉的未閉合括號深度]。
func _strip_observation(line: String, carry: int) -> Array:
	var s2: String = line
	var depth: int = carry
	# ①先處理【上一行帶下來的未閉合 Probe 呼叫】：吃掉本行屬於那個呼叫的部分
	if depth > 0:
		var cut: int = s2.length()
		for k in range(s2.length()):
			var ch0: String = s2[k]
			if ch0 == "(": depth += 1
			elif ch0 == ")":
				depth -= 1
				if depth == 0:
					cut = k + 1
					break
		s2 = ("" if depth > 0 else s2.substr(cut))
		if depth > 0:
			return ["", depth]
	# ②本行自己的 Probe 呼叫
	var guard: int = 0
	while true:
		guard += 1
		if guard > 16: break   # ★防呆上限：一行不會有 16 個 Probe 呼叫
		var p: int = s2.find("Probe.")
		if p == -1: break
		var op: int = s2.find("(", p)
		if op == -1:
			# 無括號（例：`Probe.enabled`）⇒ 只去掉 token，繼續找下一個
			s2 = s2.substr(0, p) + s2.substr(p + 6)
			continue
		var d2: int = 0
		var close: int = -1
		for k2 in range(op, s2.length()):
			var ch: String = s2[k2]
			if ch == "(": d2 += 1
			elif ch == ")":
				d2 -= 1
				if d2 == 0:
					close = k2
					break
		if close == -1:
			# 括號沒閉合＝跨行呼叫的第一行 ⇒ 砍到行尾並把深度結轉給下一行
			return [s2.substr(0, p), d2]
		s2 = s2.substr(0, p) + s2.substr(close + 1)
	return [s2, 0]

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
