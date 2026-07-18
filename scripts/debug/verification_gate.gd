extends SceneTree

# ★★★ verification-gate（sim 量測 → QA 故事稽核 fail-closed coupling，用戶 rule 2026-07-18）。
# 根：驗證紀律在意圖層 doc→跳工作照前進無後果→衰減。運輸層(hook)跳工作動不了→自我強制不衰減。
# rule：slice 有 sim 量測(.measure.json is_sim:true)→必需 .qa.json verdict:PASS 才可 merge；
#       無 sim measure→無要件(量測 discretionary,byte-identical/char-bed/純結構免)。
# 只堵「sim 量測了卻沒 QA 讀故事」的 attrition 誤讀病。sibling of constitution_gate（非 behavior，process 工具）。
#
# 部署裁定（spec §部署裁定）：
#  1. 既存檔 grandfather via _archive/（gate 只檢 active，非 _archive/）。
#  2. active verdict 缺 is_sim → FAIL（強制 schema 前進，不追溯）。
#  3. QA 格式 = .qa.json only（going-forward）。
#  4. branch-scoped：傳 --slice=<name> 只查該 slice（免 stale 誤擋）；無參掃全 active。
#  5. is_sim cross-check raw_logs（sim 關鍵字卻 is_sim=false → WARN 疑漏標）。
#
# 用法：
#   .\tools\godot.ps1 --headless --script scripts/debug/verification_gate.gd            # 全 active
#   .\tools\godot.ps1 --headless --script scripts/debug/verification_gate.gd -- --slice=<name>   # branch-scoped

const VERDICTS_DIR := "res://docs/process/verdicts"

func _initialize() -> void:
	var scope_slice: String = ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--slice="):
			scope_slice = a.substr("--slice=".length())
	var ok: bool = _run(scope_slice)
	quit(0 if ok else 1)

func _run(scope_slice: String) -> bool:
	var d := DirAccess.open(VERDICTS_DIR)
	if d == null:
		print("[VERIFICATION-GATE] PASS (no verdicts dir)")
		return true
	var fails: Array = []
	var warns: Array = []
	var checked: int = 0
	d.list_dir_begin()
	var fname: String = d.get_next()
	while fname != "":
		# _archive/ 子目錄 grandfather（不遞迴掃）；只檢 active *.measure.json
		if not d.current_is_dir() and fname.ends_with(".measure.json"):
			var slice: String = fname.substr(0, fname.length() - ".measure.json".length())
			if scope_slice == "" or slice == scope_slice:
				checked += 1
				_check_measure(slice, fails, warns)
		fname = d.get_next()
	d.list_dir_end()
	for w in warns:
		print("[VERIFICATION-GATE] WARN: %s" % w)
	if fails.is_empty():
		var scope_s: String = ("slice=%s" % scope_slice) if scope_slice != "" else "all active"
		print("[VERIFICATION-GATE] PASS (%s, checked=%d)" % [scope_s, checked])
		return true
	for f in fails:
		print("[VERIFICATION-GATE] FAIL: %s" % f)
	print("[VERIFICATION-GATE] FAIL — %d verdict(s) 缺 QA 故事稽核 or is_sim。sim 量測必需 .qa.json verdict:PASS。" % fails.size())
	return false

func _check_measure(slice: String, fails: Array, warns: Array) -> void:
	var mpath: String = "%s/%s.measure.json" % [VERDICTS_DIR, slice]
	var mf := FileAccess.open(mpath, FileAccess.READ)
	if mf == null:
		return
	var raw_text: String = mf.get_as_text()
	mf.close()
	var mdata = JSON.parse_string(raw_text)
	if not (mdata is Dictionary):
		fails.append("%s: .measure.json JSON parse error" % slice)
		return
	# 裁定 #2：active verdict 缺 is_sim → FAIL（measurer 必設，強制 schema 前進）。
	if not mdata.has("is_sim"):
		fails.append("%s: active .measure.json 缺 is_sim 欄（measurer 必設 true/false）" % slice)
		return
	var is_sim: bool = bool(mdata["is_sim"])
	if not is_sim:
		# 裁定 #5：is_sim=false 但 raw_logs 含 sim 關鍵字 → WARN 疑漏標（auto-infer 為 S2 強化）。
		var raw_l: String = str(mdata.get("raw_logs", "")).to_lower()
		if "seeded_warring" in raw_l or "game_sim" in raw_l or "organic" in raw_l or "warring" in raw_l:
			warns.append("%s: is_sim=false 但 raw_logs 含 sim 關鍵字（漏標?→應 is_sim=true 觸 QA 故事稽核）" % slice)
		return   # 無 sim measure → 無 QA 要件（量測 discretionary）
	# is_sim=true → 必需 .qa.json verdict:PASS（fail-closed coupling）。
	var qpath: String = "%s/%s.qa.json" % [VERDICTS_DIR, slice]
	if not FileAccess.file_exists(qpath):
		fails.append("%s: sim-measured (is_sim=true) 但無 QA verdict（.qa.json 缺）——用戶 rule:有 sim 量測必跑 QA 故事稽核" % slice)
		return
	var qf := FileAccess.open(qpath, FileAccess.READ)
	var qdata = JSON.parse_string(qf.get_as_text())
	qf.close()
	if not (qdata is Dictionary):
		fails.append("%s: .qa.json JSON parse error" % slice)
		return
	var verdict: String = String(qdata.get("verdict", ""))
	if verdict != "PASS":
		fails.append("%s: sim-measured 但 QA verdict != PASS（got '%s'；THRASH/FAIL 不可 merge）" % [slice, verdict])
