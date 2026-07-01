extends SceneTree

# seeded warring before/after 對照 harness（純 debug/infra，零 sim 邏輯變）。
# 固定 seed 跑 N 月 → 結構化 metric（意圖分布/CONQUER/established/capture.total/attrition%/teams 曲線+probe）。
# 對照模式：baseline（git ref/stash）dump JSON → branch 讀回逐點 diff → 判「哪 metric 真變、變多少、訊號非噪」。
#
# 用法（env）：
#   WARRING_SEEDS   多 seed 逗號集（避單 seed 偏），default "1337,42,7"
#   WARRING_MONTHS  跑幾月（短窗 default 3；長窗拉大 + GODOT_TIMEOUT）
#   WARRING_OUT     dump 本跑 metric 到 JSON 檔（baseline 端用）
#   WARRING_BASELINE 讀 baseline JSON → 逐點 diff（branch 端用）
#
# 典型對照：
#   1) baseline ref：WARRING_OUT=A:\...\base.json godot --script seeded_warring_bed.gd
#   2) branch     ：WARRING_BASELINE=A:\...\base.json godot --script seeded_warring_bed.gd
#      → 印每 seed 的 pointwise diff（無 diff = 零行為變證；有 diff = 該 metric 真變量）

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seeds: Array = _parse_seeds()
	var months: int = int(OS.get_environment("WARRING_MONTHS")) if OS.has_environment("WARRING_MONTHS") else 3
	var ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	print("=== seeded_warring_bed：seeds=%s months=%d (ticks=%d) ===" % [str(seeds), months, ticks])

	var results: Dictionary = {}
	for s in seeds:
		var r: Dictionary = WarringHarness.run(int(s), ticks)
		if r.is_empty():
			print("[FAIL] seed=%d harness 空（config 載入失敗？）" % int(s)); continue
		results[str(int(s))] = r
		_print_metrics(int(s), r)

	# dump baseline
	var out_path: String = OS.get_environment("WARRING_OUT")
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f == null:
			print("[FAIL] 無法寫 WARRING_OUT=%s" % out_path)
		else:
			f.store_string(JSON.stringify(results, "  "))
			f.close()
			print("[bed] baseline metric 已寫 → %s" % out_path)

	# before/after 逐點 diff
	var base_path: String = OS.get_environment("WARRING_BASELINE")
	if base_path != "":
		_compare_baseline(base_path, results)

	print("=== seeded_warring_bed DONE ===")

func _parse_seeds() -> Array:
	var raw: String = OS.get_environment("WARRING_SEEDS")
	if raw == "" and OS.has_environment("WARRING_SEED"):
		raw = OS.get_environment("WARRING_SEED")
	if raw == "":
		raw = "1337,42,7"
	var out: Array = []
	for tok in raw.split(",", false):
		var t: String = tok.strip_edges()
		if t.is_valid_int():
			out.append(int(t))
	return out

func _print_metrics(s: int, r: Dictionary) -> void:
	print("\n--- seed=%d ---" % s)
	print("[bed] final=%s" % str(r["final"]))
	print("[bed] start_pop=%d end_pop=%d attrition=%.1f%%" % [
		int(r["start_pop"]), int(r["end_pop"]), float(r["attrition_pct"])])
	print("[bed] final_intent=%s" % str(r["intent"]))
	for snap in r["curve"]:
		print("[bed] 月%s teams=%d factions=%d established=%d pop=%d 意圖=%s" % [
			str(snap["month"]), int(snap["teams"]), int(snap["factions"]),
			int(snap["established"]), int(snap["pop"]), str(snap["intent"])])
	print("[bed] probe=%s" % str(r["probe"]))

func _compare_baseline(base_path: String, results: Dictionary) -> void:
	var f := FileAccess.open(base_path, FileAccess.READ)
	if f == null:
		print("[FAIL] 無法讀 WARRING_BASELINE=%s" % base_path); return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if not (parsed is Dictionary):
		print("[FAIL] baseline JSON 格式錯"); return
	var baseline: Dictionary = parsed
	# 現跑結果經 JSON round-trip → 型別對齊 baseline（int↔float）
	var cur: Dictionary = JSON.parse_string(JSON.stringify(results))

	print("\n=== before/after 逐點對照（baseline=%s）===" % base_path)
	var total_diffs: int = 0
	var seed_keys: Array = cur.keys(); seed_keys.sort()
	for sk in seed_keys:
		if not baseline.has(sk):
			print("[diff] seed=%s baseline 缺此 seed" % sk); continue
		var diffs: Array = []
		_diff_recursive("", baseline[sk], cur[sk], diffs)
		if diffs.is_empty():
			print("[same] seed=%s 逐點相同（零行為變）" % sk)
		else:
			print("[DIFF] seed=%s %d 處：" % [sk, diffs.size()])
			for d in diffs:
				print("   %s: %s → %s" % [d["path"], str(d["base"]), str(d["cur"])])
			total_diffs += diffs.size()
	print("=== 對照結束：total_diffs=%d（0=零行為變證）===" % total_diffs)

# 遞迴逐葉 diff → 收 {path, base, cur}。dict/array 結構化下鑽。
func _diff_recursive(path: String, base, cur, out: Array) -> void:
	if base is Dictionary and cur is Dictionary:
		var keys: Dictionary = {}
		for k in base: keys[k] = true
		for k in cur: keys[k] = true
		var ks: Array = keys.keys(); ks.sort()
		for k in ks:
			var p: String = path + "." + str(k) if path != "" else str(k)
			if not base.has(k): out.append({"path": p, "base": "<缺>", "cur": cur[k]})
			elif not cur.has(k): out.append({"path": p, "base": base[k], "cur": "<缺>"})
			else: _diff_recursive(p, base[k], cur[k], out)
	elif base is Array and cur is Array:
		if base.size() != cur.size():
			out.append({"path": path + ".size", "base": base.size(), "cur": cur.size()})
		var n: int = mini(base.size(), cur.size())
		for i in range(n):
			_diff_recursive("%s[%d]" % [path, i], base[i], cur[i], out)
	else:
		if str(base) != str(cur):
			out.append({"path": path, "base": base, "cur": cur})
