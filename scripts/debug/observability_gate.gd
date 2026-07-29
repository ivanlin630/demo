extends SceneTree

# ★★★ 觀測盲點閘（Fix 4，2026-07-15）：凍結生產側 specimen capture 覆蓋 vs 決策 commit 點數。
# 契約：capture 點數 ≥ baseline（coverage 不退）；決策 try_set 點增加須伴隨 capture_decision 點增加
#   （新 commit 點無伴隨 tap → 計數失衡 FAIL）。runtime churn 床(tracer_completeness_test)續作語意驗。
# 更新：合法新增 tap 後同步更新 observability_baseline.txt（同 constitution_baseline 慣例）。

const SIM_DIR := "res://scripts/simulation"
const BASELINE := "res://scripts/debug/observability_baseline.txt"
const DEBUG_DIR := "res://scripts/debug"
# ★③ observer-no-global-RNG 靜態閘（HOW spec 2026-07-29）：observe-pure marker 檔禁 global-RNG 向量。
const OBSERVE_MARKER := "# @observe-pure"
# 7 類 global-RNG 向量：函式型（負向 lookbehind 逃生口=本地 rng.randf() 前綴 \w. 放行；bare 抓）。
# 長 alternative 先（randf_range 先於 randf，避 randf 誤配）。seed 裸括號=全域重播種（rng.seed=x property 無括號不命中）。
const RNG_FUNC_RE := "(?<![\\w.])(randf_range|randi_range|randfn|randf|randi|randomize|seed)\\s*\\("
# 方法型 pick_random/shuffle：Array/Dict 一律 global RNG（無本地版）→ 前綴 . 照抓（不吃逃生口，血證 2 = arr.pick_random()）。
const RNG_METHOD_RE := "\\.(pick_random|shuffle)\\s*\\("
# marker-missing WARN：檔名含觀測慣用詞但無 marker → 非阻斷提醒。
const OBSERVE_NAME_HINTS := ["tracer", "probe", "dump", "specimen", "observ"]

func _initialize() -> void:
	var cur: Dictionary = _counts()
	var base: Dictionary = _load_baseline()
	var fail: Array = []
	# ① capture 點不可少於 baseline（coverage 退化=FAIL）
	for k in ["capture_decision", "capture_reaction", "capture_intent", "capture_options"]:
		if int(cur.get(k, 0)) < int(base.get(k, 0)):
			fail.append("%s coverage 退：%d < baseline %d" % [k, int(cur.get(k, 0)), int(base.get(k, 0))])
	# ② 決策 try_set 點增加但 capture_decision 未增 → 新 commit 點疑漏 tap
	if int(cur.get("decision_tryset", 0)) > int(base.get("decision_tryset", 0)) \
			and int(cur.get("capture_decision", 0)) <= int(base.get("capture_decision", 0)):
		fail.append("決策 try_set 點增(%d>%d) 但 capture_decision 未增(%d) → 新 commit 疑漏 specimen tap" % [
			int(cur.get("decision_tryset", 0)), int(base.get("decision_tryset", 0)), int(cur.get("capture_decision", 0))])
	# ③ observe-no-global-RNG 靜態掃（observe-pure marker 檔禁 global-RNG 向量）+ marker-missing WARN。
	var rng_result: Dictionary = _rng_scan()
	fail.append_array(rng_result["fails"])
	if fail.is_empty():
		print("[OBSERVABILITY-GATE] PASS (cd=%d cr=%d ci=%d co=%d tryset=%d rng_scan=%d檔)" % [
			int(cur["capture_decision"]), int(cur["capture_reaction"]), int(cur["capture_intent"]),
			int(cur["capture_options"]), int(cur["decision_tryset"]), int(rng_result["scanned"])])
	else:
		for f in fail:
			print("[OBSERVABILITY-GATE] FAIL: %s" % f)
	quit()

# ③ observe-pure 檔 global-RNG 向量掃（純靜態零 RNG）。回 {fails:Array, scanned:int}。
func _rng_scan() -> Dictionary:
	var func_re := RegEx.new(); func_re.compile(RNG_FUNC_RE)
	var method_re := RegEx.new(); method_re.compile(RNG_METHOD_RE)
	var fails: Array = []
	var scanned: int = 0
	for path in _all_gd(DEBUG_DIR):
		var f := FileAccess.open(path, FileAccess.READ)
		if f == null: continue
		var txt := f.get_as_text(); f.close()
		var fname: String = path.get_file()
		var has_marker: bool = OBSERVE_MARKER in txt
		if not has_marker:
			# marker-missing WARN（非阻斷）：檔名含觀測慣用詞但無 marker → 提醒複查。
			var lower: String = fname.to_lower()
			for hint in OBSERVE_NAME_HINTS:
				if hint in lower:
					print("[OBSERVABILITY-GATE] WARN: %s 疑觀測 helper 未加 @observe-pure marker，複查" % fname)
					break
			continue
		scanned += 1
		var lines: PackedStringArray = txt.split("\n")
		for i in range(lines.size()):
			var line: String = lines[i]
			if line.strip_edges().begins_with("#"):
				continue   # 純註解行不判（含 marker 註本身/範例）
			var m := func_re.search(line)
			if m == null:
				m = method_re.search(line)
			if m != null:
				fails.append("%s:%d observe-pure 檔耗 global RNG: %s" % [fname, i + 1, m.get_string().strip_edges()])
	return {"fails": fails, "scanned": scanned}

func _counts() -> Dictionary:
	var c: Dictionary = {
		"capture_decision": 0, "capture_reaction": 0, "capture_intent": 0,
		"capture_options": 0, "decision_tryset": 0,
	}
	var tryset_re := RegEx.new(); tryset_re.compile("TaskArbiter\\.try_set\\(.*PRIO_(DISPATCH|SURVIVAL|THREAT)")
	for path in _all_gd(SIM_DIR):
		var f := FileAccess.open(path, FileAccess.READ)
		if f == null: continue
		var txt := f.get_as_text(); f.close()
		for line in txt.split("\n"):
			if "SpecimenTracer.capture_decision" in line: c["capture_decision"] += 1
			if "SpecimenTracer.capture_reaction" in line: c["capture_reaction"] += 1
			if "SpecimenTracer.capture_intent" in line: c["capture_intent"] += 1
			if "SpecimenTracer.capture_options" in line: c["capture_options"] += 1
			if tryset_re.search(line) != null: c["decision_tryset"] += 1
	return c

func _all_gd(dir: String) -> Array:
	var out: Array = []
	var d := DirAccess.open(dir)
	if d == null: return out
	d.list_dir_begin()
	var name := d.get_next()
	while name != "":
		var p := dir + "/" + name
		if d.current_is_dir():
			if not name.begins_with("."): out.append_array(_all_gd(p))
		elif name.ends_with(".gd"):
			out.append(p)
		name = d.get_next()
	d.list_dir_end()
	return out

func _load_baseline() -> Dictionary:
	var b: Dictionary = {}
	var f := FileAccess.open(BASELINE, FileAccess.READ)
	if f == null: return b
	var txt := f.get_as_text(); f.close()
	for line in txt.split("\n"):
		var s := line.strip_edges()
		if s.begins_with("#") or not ("=" in s): continue
		var kv := s.split("=")
		if kv.size() == 2: b[kv[0].strip_edges()] = int(kv[1].strip_edges())
	return b
