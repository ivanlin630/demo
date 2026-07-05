extends SceneTree

# ★★★ 沙盒憲法防閘（site-freeze）：鎖 TaskArbiter mutation 面 = 引擎外 task 指派。
# 契約：current 指紋 ⊆ baseline。新增 = FAIL（叫作者溶入引擎或呈報系統）。移除 = PASS（arc 溶解）。
# 指紋 = <relpath>::<enclosing_func>。coverage = TaskArbiter.transition/try_set 呼叫點（見 plan 誠實聲明）。

const SCAN_DIR := "res://scripts/simulation"
const BASELINE := "res://scripts/debug/constitution_baseline.txt"
const MUT_RE := "TaskArbiter\\.(transition|try_set)\\("

func _initialize() -> void:
	var current: Dictionary = _scan()           # 指紋 -> true
	var baseline: Dictionary = _load_baseline()  # 指紋 -> true
	var added: Array = []
	for fp in current.keys():
		if not baseline.has(fp): added.append(fp)
	var removed: Array = []
	for fp in baseline.keys():
		if not current.has(fp): removed.append(fp)
	added.sort(); removed.sort()
	for fp in removed:
		print("[gate] removed (arc 溶解進度): %s" % fp)
	if added.is_empty():
		print("[CONSTITUTION-GATE] PASS (sites=%d, removed=%d)" % [current.size(), removed.size()])
	else:
		for fp in added:
			print("[gate] ❌ 新增引擎外 task 指派: %s" % fp)
		print("[CONSTITUTION-GATE] FAIL：新增 %d 個引擎外 task 指派點。溶入決策引擎，或呈報系統更新 baseline。" % added.size())
	quit()

func _scan() -> Dictionary:
	var out: Dictionary = {}
	var re := RegEx.new(); re.compile(MUT_RE)
	var func_re := RegEx.new(); func_re.compile("^\\s*(?:static\\s+)?func\\s+(\\w+)")
	_walk(SCAN_DIR, re, func_re, out)
	return out

func _walk(dir_path: String, re: RegEx, func_re: RegEx, out: Dictionary) -> void:
	var d := DirAccess.open(dir_path)
	if d == null: return
	d.list_dir_begin()
	var name_s: String = d.get_next()
	while name_s != "":
		var full: String = dir_path + "/" + name_s
		if d.current_is_dir():
			if not name_s.begins_with("."):
				_walk(full, re, func_re, out)
		elif name_s.ends_with(".gd"):
			_scan_file(full, re, func_re, out)
		name_s = d.get_next()
	d.list_dir_end()

func _scan_file(path: String, re: RegEx, func_re: RegEx, out: Dictionary) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null: return
	var rel: String = path.replace("res://", "")
	var cur_func: String = "<global>"
	while not f.eof_reached():
		var line: String = f.get_line()
		var fm := func_re.search(line)
		if fm != null:
			cur_func = fm.get_string(1)
		if re.search(line) != null:
			out["%s::%s" % [rel, cur_func]] = true
	f.close()

func _load_baseline() -> Dictionary:
	var out: Dictionary = {}
	var f := FileAccess.open(BASELINE, FileAccess.READ)
	if f == null:
		push_error("baseline 不存在：%s（首次跑 Step 2 產生）" % BASELINE)
		return out
	while not f.eof_reached():
		var line: String = f.get_line().strip_edges()
		if line == "" or line.begins_with("#"): continue
		out[line] = true
	f.close()
	return out
