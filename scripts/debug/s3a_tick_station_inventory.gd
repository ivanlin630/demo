extends SceneTree
# @observe-pure
# ★★★S3a：【每 tick 站】構造性盤點（純盤點、零 production 改動）。
#
# 問題：從 tick 迴圈頂層出發，哪些分支【沒有任何 cadence 閘】一路跑到葉節點？
#
# ★終止條件【重用 bare_tick 規則表的 cadence 形狀】，不是人眼判：
#   撞到 gate 形狀 ⇒ gated（記 file:line 與撞在哪一行）
#   葉節點都沒撞到 ⇒ true_candidate
#   ★★撞到動態解析（變數持有的參照、型別宣告不出來）⇒ untraceable
#
# ★★★第三桶不是保守，是【防虛報】：
#   GDScript 鴨子定型 ⇒ 那種分支的真實深度是【未知】，不是【確認沒 gate】。
#   硬算進 true_candidate 等於虛報一個根本沒驗過的站。
#
# ★★★★而靜態只是一半：每個 true_candidate 都要用實測次數複驗
#   （propagate 那顆教過：看起來掛每 tick，實測兩根兩床呼叫次數完全相同）。

const ROOTS: Array = ["res://scripts/simulation", "res://scripts/data", "res://scripts/ui"]
const ENTRY_FILE: String = "res://scripts/simulation/sim_runner.gd"
const ENTRY_FUNC: String = "_advance_tick_body"
const MAX_DEPTH: int = 12

var _funcs: Dictionary = {}      # "file::func" -> Array[{n,s}]
var _types: Dictionary = {}      # file -> { 變數名 -> 型別 }
var _class_file: Dictionary = {} # class_name -> file
var _gate_re: RegEx
var _call_self_re: RegEx
var _call_cls_re: RegEx
var _call_var_re: RegEx
var _rows: Array = []
var _seen: Dictionary = {}

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	# ★gate 形狀：與 bare_tick_triage 規則表同一族（餘數週期 / next_tick 排程 / LOD cadence）
	_gate_re = RegEx.new()
	_gate_re.compile("%[^=]*(==|!=)\\s*0|_next_tick|_eval_tick|NEAR_CADENCE|FAR_ZONE_INTERVAL|_INTERVAL|_CADENCE|TICKS_PER_")
	_call_self_re = RegEx.new(); _call_self_re.compile("(?<![A-Za-z0-9_.])(_[A-Za-z0-9_]+)\\(")
	_call_cls_re = RegEx.new();  _call_cls_re.compile("([A-Z][A-Za-z0-9_]+)\\.([a-z_][A-Za-z0-9_]*)\\(")
	_call_var_re = RegEx.new();  _call_var_re.compile("(?<![A-Za-z0-9_.])(_[a-z][A-Za-z0-9_]*)\\.([a-z_][A-Za-z0-9_]*)\\(")
	for r in ROOTS:
		_index_dir(r)
	print("[S3a] 索引：%d 個函式｜%d 個 class_name" % [_funcs.size(), _class_file.size()])
	_walk(ENTRY_FILE, ENTRY_FUNC, 0, ENTRY_FUNC)

	var tally: Dictionary = {}
	for row in _rows:
		tally[row["bucket"]] = int(tally.get(row["bucket"], 0)) + 1
	var keys: Array = tally.keys(); keys.sort()
	var total: int = 0
	print("\n[S3a] 三桶對帳：")
	for k in keys:
		print("   %-16s = %d" % [String(k), int(tally[k])])
		total += int(tally[k])
	print("   %-16s = %d" % ["分支總數", total])

	var out: Array = [
		"# S3a 每 tick 站盤點（靜態）",
		"# 三桶：gated / true_candidate / untraceable ——★相加 = 分支總數，一筆都不准無處置",
		"# ★untraceable 必須出現在【輸出裡】：它的真實深度是未知，不是『確認沒 gate』",
		"# 欄位：bucket|reason|path|line|target|via"]
	for k2 in keys:
		out.append("# %-16s = %d" % [String(k2), int(tally[k2])])
	out.append("# %-16s = %d" % ["分支總數", total])
	out.append("#")
	for row in _rows:
		out.append("%s|%s|%s|%d|%s|%s" % [row["bucket"], row["reason"], row["path"], int(row["line"]), row["target"], row["via"]])
	var path: String = _env("S3A_OUT", "docs/measurements/2026-08-27-s3a-tick-stations.txt")
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(PackedStringArray(out)) + "\n"); f.close()
		print("[S3a] 落地：%s" % path)
	print("=== s3a_tick_station_inventory DONE ===")

func _walk(file: String, fn: String, depth: int, via: String) -> void:
	var key: String = file + "::" + fn
	if depth > MAX_DEPTH:
		_rows.append({"bucket": "untraceable", "reason": "遞迴深度超過 %d 層，未追到底" % MAX_DEPTH,
			"path": file, "line": 0, "target": fn, "via": via})
		return
	if _seen.has(key):
		return
	_seen[key] = true
	if not _funcs.has(key):
		return
	var lines: Array = _funcs[key]
	var gate_indent: int = -1
	var gate_line: int = 0
	for item in lines:
		var ln: int = int(item["n"])
		var raw: String = String(item["s"])
		var code: String = raw
		var h: int = code.find("#")
		if h != -1:
			code = code.substr(0, h)
		if code.strip_edges() == "":
			continue
		var indent: int = code.length() - code.lstrip("\t").length()
		if gate_indent != -1 and indent <= gate_indent:
			gate_indent = -1
		var st: String = code.strip_edges()
		if _gate_re.search(code) != null and (st.begins_with("if ") or st.begins_with("elif ")):
			gate_indent = indent
			gate_line = ln
			continue
		var gated: bool = gate_indent != -1
		for m in _call_self_re.search_all(code):
			_emit(file, m.get_string(1), ln, gated, gate_line, depth, via, file)
		for m2 in _call_cls_re.search_all(code):
			var cls: String = m2.get_string(1)
			if not _class_file.has(cls):
				continue
			_emit(String(_class_file[cls]), m2.get_string(2), ln, gated, gate_line, depth, via, file)
		for m3 in _call_var_re.search_all(code):
			var vn: String = m3.get_string(1)
			var t: String = String((_types.get(file, {}) as Dictionary).get(vn, ""))
			if t == "" or not _class_file.has(t):
				_rows.append({"bucket": "untraceable", "reason": "變數持有的呼叫，型別解析不出（鴨子定型）",
					"path": file, "line": ln, "target": vn + "." + m3.get_string(2), "via": via})
				continue
			_emit(String(_class_file[t]), m3.get_string(2), ln, gated, gate_line, depth, via, file)

# ★★★單位是【頂層 step】不是【每一個葉節點呼叫】。
#   ★第一版我把每個葉呼叫（.new()、AnonCohort.total…）都算一個分支
#     ⇒ 34 筆 true_candidate 幾乎全是工具函式 ⇒ ★★【虛報】。
#   ★★★而 systems 講死「虛報一個站就可能把整條路走錯」⇒ 改成：
#     只有【tick 迴圈頂層直接呼叫的那層】算一個站；
#     更深的遞迴只用來回答【這個站內部有沒有 gate】。
func _emit(target_file: String, target_fn: String, ln: int, gated: bool, gate_line: int, depth: int, via: String, from_file: String) -> void:
	var key: String = target_file + "::" + target_fn
	if depth > 0:
		if _funcs.has(key):
			_walk(target_file, target_fn, depth + 1, via + ">" + target_fn)
		return
	if gated:
		_rows.append({"bucket": "gated", "reason": "呼叫點就在 cadence 閘內（%s:%d）" % [from_file.get_file(), gate_line],
			"path": from_file, "line": ln, "target": target_fn, "via": via})
		return
	if not _funcs.has(key):
		_rows.append({"bucket": "leaf_util", "reason": "頂層呼叫的是索引外/內建函式（不是一個站）",
			"path": from_file, "line": ln, "target": target_fn, "via": via})
		return
	# ★內部有沒有 gate：看它自己的 body
	var has_gate: bool = false
	for it in (_funcs[key] as Array):
		var c: String = String(it["s"])
		var hh: int = c.find("#")
		if hh != -1: c = c.substr(0, hh)
		if _gate_re.search(c) != null and (c.strip_edges().begins_with("if ") or c.strip_edges().begins_with("elif ")):
			has_gate = true
			break
	if has_gate:
		_rows.append({"bucket": "gated", "reason": "呼叫點未閘，但函式【內部】自己有 cadence 閘",
			"path": target_file, "line": ln, "target": target_fn, "via": via})
		return
	_rows.append({"bucket": "true_candidate", "reason": "呼叫點未閘、函式內部也沒有 cadence 閘 ⇒ ★待實測複驗",
		"path": target_file, "line": ln, "target": target_fn, "via": via})
	_walk(target_file, target_fn, depth + 1, via + ">" + target_fn)

func _index_dir(dir_path: String) -> void:
	var d := DirAccess.open(dir_path)
	if d == null:
		return
	d.list_dir_begin()
	var n: String = d.get_next()
	while n != "":
		var full: String = dir_path + "/" + n
		if d.current_is_dir():
			if not n.begins_with("."):
				_index_dir(full)
		elif n.ends_with(".gd"):
			_index_file(full)
		n = d.get_next()
	d.list_dir_end()

func _index_file(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var cur: String = ""
	var ln: int = 0
	var tmap: Dictionary = {}
	while not f.eof_reached():
		var s: String = f.get_line(); ln += 1
		if s.begins_with("class_name "):
			_class_file[s.substr(11).strip_edges()] = path
		var st: String = s.strip_edges()
		if st.begins_with("var _") and st.find(":") != -1:
			var nm: String = st.substr(4, st.find(":") - 4).strip_edges()
			var rest: String = st.substr(st.find(":") + 1).strip_edges()
			var ty: String = rest.split(" ")[0].split("=")[0].strip_edges()
			if ty != "":
				tmap[nm] = ty
		if st.begins_with("func "):
			var p: int = st.find("(")
			if p > 5:
				cur = path + "::" + st.substr(5, p - 5).strip_edges()
				_funcs[cur] = []
		elif cur != "":
			(_funcs[cur] as Array).append({"n": ln, "s": s})
	f.close()
	_types[path] = tmap

func _env(k: String, d: String) -> String:
	var v: String = OS.get_environment(k)
	return v if v != "" else d
