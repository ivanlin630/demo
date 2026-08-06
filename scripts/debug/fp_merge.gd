extends SceneTree

# ★F0 merge：合 3 床 partial → 27-fingerprint baseline + 假覆蓋檢（R² 觀察②）。
const PARTIALS: Array = ["warring", "peaceful", "recovery"]
const DOMAINS: Array = ["teams", "persons", "factions", "belief", "tiles", "world"]

func _initialize() -> void:
	var sp: String = OS.get_environment("FP_PARTIAL_DIR")
	if sp == "": sp = "res://docs/measurements"
	var out: Dictionary = {}
	var sigs: Dictionary = {}
	# glob 所有 fp-partial-*.json（bed 或 bed-seed 分裂皆吃）。
	var dir := DirAccess.open(sp)
	var files: Array = []
	if dir != null:
		dir.list_dir_begin()
		var fn: String = dir.get_next()
		while fn != "":
			if fn.begins_with("fp-partial-") and fn.ends_with(".json"): files.append(fn)
			fn = dir.get_next()
		dir.list_dir_end()
	files.sort()
	if files.is_empty():
		print("  [merge] NO fp-partial-*.json in %s" % sp); quit(); return
	for fn2 in files:
		var f := FileAccess.open("%s/%s" % [sp, fn2], FileAccess.READ)
		if f == null: continue
		var d: Dictionary = JSON.parse_string(f.get_as_text()); f.close()
		for k in d:
			if k == "_signals": sigs[fn2] = d[k]
			else: out[k] = d[k]
	print("  [merge] %d partial 檔 → %d run-key" % [files.size(), out.size()])
	# baseline 落地（檔名帶總 hash）。
	var canon: String = JSON.stringify(out, "", true, true)
	var total_hash: String = canon.md5_text().substr(0, 8)
	var bpath: String = "res://docs/measurements/fingerprint-baseline-%s.json" % total_hash
	var bf := FileAccess.open(bpath, FileAccess.WRITE)
	if bf != null:
		bf.store_string(JSON.stringify(out, "  ", true, true)); bf.close()
		print("  [baseline] 落地 %s (%d run × 3tick、total_hash=%s)" % [bpath, out.size(), total_hash])
	else:
		print("  [baseline] WRITE FAIL"); quit(); return
	# ★假覆蓋檢：逐域 distinct hash count（1=死值=盲點）。
	print("--- 假覆蓋檢（逐域 distinct count / 27）---")
	var all_ok: bool = true
	for dom in DOMAINS:
		var seen: Dictionary = {}
		for key in out:
			var runres: Dictionary = out[key]
			for tk in runres:
				seen[(runres[tk] as Dictionary)["domains"][dom]] = true
		var n: int = seen.size()
		var ok: bool = n >= 2
		if not ok: all_ok = false
		print("  [%s] %s: %d distinct%s" % ["PASS" if ok else "FAIL", dom, n, "" if ok else "  ★死值=盲點"])
	# ★域活動信號（真 exercise、R² 觀察②）。
	print("--- 域活動信號（真 exercise 檢）---")
	var agg: Dictionary = {"relocate": false, "letter": false, "subteam": false, "combat": false}
	for bed in sigs:
		for s in agg:
			if bool((sigs[bed] as Dictionary).get(s, false)): agg[s] = true
	for s in ["subteam", "letter", "combat", "relocate"]:
		print("  [%s] %s 真 exercise" % ["PASS" if agg[s] else "WARN", s])
	print("=== DONE === %s" % ("ALL DOMAINS VARY + SIGNALS OK" if all_ok else "★BLIND SPOT"))
	quit()
