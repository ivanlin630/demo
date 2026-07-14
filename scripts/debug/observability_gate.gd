extends SceneTree

# ★★★ 觀測盲點閘（Fix 4，2026-07-15）：凍結生產側 specimen capture 覆蓋 vs 決策 commit 點數。
# 契約：capture 點數 ≥ baseline（coverage 不退）；決策 try_set 點增加須伴隨 capture_decision 點增加
#   （新 commit 點無伴隨 tap → 計數失衡 FAIL）。runtime churn 床(tracer_completeness_test)續作語意驗。
# 更新：合法新增 tap 後同步更新 observability_baseline.txt（同 constitution_baseline 慣例）。

const SIM_DIR := "res://scripts/simulation"
const BASELINE := "res://scripts/debug/observability_baseline.txt"

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
	if fail.is_empty():
		print("[OBSERVABILITY-GATE] PASS (cd=%d cr=%d ci=%d co=%d tryset=%d)" % [
			int(cur["capture_decision"]), int(cur["capture_reaction"]), int(cur["capture_intent"]),
			int(cur["capture_options"]), int(cur["decision_tryset"])])
	else:
		for f in fail:
			print("[OBSERVABILITY-GATE] FAIL: %s" % f)
	quit()

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
