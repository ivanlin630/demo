extends SceneTree
# @bed-kind: acceptance
# slice: fp 的導出檢查往【子層級】再做一次
#
# ★頂層那支【自己寫明看不到子層級】——而一個被寫下來的洞仍然是洞。
# ★★本床驗的是【清單是導出的、不亂紅、且「提及 ≠ 讀取」不重演】。
# ★★★而本票的產出【不是一份要修的清單】，是一份【被具名的清單】：
#   每一欄要嘛在尺裡、要嘛被具名 —— 不得有第三種狀態（沒人提過）。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 5

func _initialize() -> void:
	print("=== fp 子層級導出床 ===")
	_test_paired_controls()
	_test_no_false_red()
	_test_counts_sum_up()
	_test_blind_note_two_segments()
	_test_emit_registry_is_derived()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _fake() -> GDScript:
	var g := GDScript.new()
	g.source_code = "extends RefCounted\nvar alpha: int = 0\nvar beta: int = 0\nvar gamma: int = 0\n"
	g.reload()
	return g

func _test_paired_controls() -> void:
	print("-- ① ③ 成對對照（★餵假類 ＋ 假原始碼給推導本體）--")
	var body: String = "buf.append(t.alpha)\n"
	var d: Dictionary = StateFingerprint.derive_subfield_from(_fake(), body, "t")
	print("    假類 {alpha 被讀, beta, gamma} ⇒ %s" % str(d))
	_ok("alpha" in d["in_ruler"], "①真的被讀的欄位進【尺內】")
	_ok(("beta" in d["excluded"]) and ("gamma" in d["excluded"]), "①沒被讀的兩欄【具名】進排除清單")
	# ★把 beta 也讀進去 ⇒ 它離開排除清單（不是永遠紅）
	var d2: Dictionary = StateFingerprint.derive_subfield_from(_fake(), body + "buf.append(t.beta)\n")
	_ok(not ("beta" in d2["excluded"]), "①★另一半：讀了它 ⇒ 它離開排除清單")
	# ★★★spec ③（必做）：在【註解】裡提到它 ⇒ 它必須【留在】排除清單
	#   —— 這是頂層那支踩過的坑：我自己的註解讓一個欄位從盲區清單消失。
	var d3: Dictionary = StateFingerprint.derive_subfield_from(_fake(), body + "# 這裡提到 t.gamma 但沒讀\n", "t")
	_ok("gamma" in d3["excluded"], "③★提及 ≠ 讀取：註解裡的 t.gamma 不得讓它離開排除清單")
	# ★字串鍵那一桶（★量出來的第三種，不是設計出來的）
	var d4: Dictionary = StateFingerprint.derive_subfield_from(_fake(), body + 'buf.append(t.get("gamma"))\n', "t")
	_ok("gamma" in d4["string_read"],
		"★字串鍵讀取自成一桶（血證：farming_level 走 t.get(\"farming_level\")）—— 不併進尺內，漏報比誤報貴")
	# ★★★R² 補的那格：判準要綁【型別相符的那個變數】——
	#   否則函式裡第二個變數的同名欄位（tile_pos／faction_id 這種橫跨多類的常見名）
	#   會被算成「讀過了」⇒ 一個真的漏欄被判成在尺裡。
	var d5: Dictionary = StateFingerprint.derive_subfield_from(_fake(),
		"var t: Fake\nvar other: Something\nbuf.append(t.alpha)\nbuf.append(other.beta)\n", "t")
	_ok("beta" in d5["excluded"],
		"★綁定目標變數：別的變數的 other.beta 不得讓 Fake.beta 被算成【讀過了】")
	# ★而「抓不到型別變數」時要【拒絕判斷】，不是退回寬鬆比對
	var d6: Dictionary = StateFingerprint.derive_subfield_from(_fake(), "buf.append(t.alpha)\n", "")
	_ok((d6["in_ruler"] as Array).is_empty() and String((d6["excluded"] as Array)[0]).contains("不可判"),
		"★判不了要說判不了（accessor 空 ⇒ 本類不可判），不偷偷降級成寬鬆比對")
	_sections += 1

func _test_no_false_red() -> void:
	print("-- ② 不得亂紅：真的在 _emit_teams 裡被讀的欄位不得出現在排除清單 --")
	var all: Dictionary = StateFingerprint.derived_subfield_excludes()
	var team: Dictionary = all.get("TeamData", {})
	for f in ["population", "current_task", "tile_pos", "resources", "recent_failures"]:
		_ok(not (f in team.get("excluded", [])), "②TeamData.%s 沒有被誤判成排除" % f)
	_sections += 1

func _test_counts_sum_up() -> void:
	print("-- ⑥ 第三種狀態要歸零：每一類【尺內 ＋ 字串鍵 ＋ 具名排除 ＝ var 欄位總數】--")
	var all: Dictionary = StateFingerprint.derived_subfield_excludes()
	var paths := {
		"TeamData": "res://scripts/data/team_data.gd",
		"PersonData": "res://scripts/data/person_data.gd",
		"FactionData": "res://scripts/data/faction_data.gd",
		"HexTileData": "res://scripts/data/tile_data.gd",
		"WorldData": "res://scripts/data/world_data.gd",
	}
	for cls in paths:
		var sc = load(paths[cls])
		var total: int = 0
		for pi in sc.get_script_property_list():
			var n: String = String(pi.get("name", ""))
			if n == "" or n.begins_with("_"):
				continue
			if int(pi.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
				continue
			total += 1
		var d: Dictionary = all[cls]
		var got: int = (d["in_ruler"] as Array).size() + (d["string_read"] as Array).size() + (d["excluded"] as Array).size()
		print("    %-12s 尺內 %2d ＋ 字串鍵 %d ＋ 排除 %2d ＝ %d（總 %d）" % [cls,
			(d["in_ruler"] as Array).size(), (d["string_read"] as Array).size(),
			(d["excluded"] as Array).size(), got, total])
		_ok(got == total, "⑥%s 沒有第三種狀態（沒人提過的欄位＝0）" % cls)
	_sections += 1

func _test_blind_note_two_segments() -> void:
	print("-- ④ ⑤ blind_note 兩段都在；fp 值不變 --")
	var note: String = StateFingerprint.blind_note()
	_ok(note.contains("頂層欄位") and note.contains("子層級"), "④兩個粒度各自標明，同一行印得出來")
	_ok(note.contains("三層以下"), "④★第三層看不到那句【住在輸出裡】，不是只住在交件信裡")
	var st := WorldState.new()
	st.world = WorldData.new()
	var t := TeamData.new()
	t.team_id = 3
	st.teams[3] = t
	var before: String = StateFingerprint.compute(st)
	StateFingerprint.blind_note()
	StateFingerprint.derived_subfield_excludes()
	_ok(StateFingerprint.compute(st) == before, "⑤本票只改自我描述 ⇒ 算過清單之後 fp 不變")
	_sections += 1

func _test_emit_registry_is_derived() -> void:
	print("-- ★R² 補的第一格：SUBFIELD_MAP 自己也是手抄的 ⇒ 行集要導出 --")
	var gaps: Array = StateFingerprint.emit_registry_gaps()
	print("    未登記的 _emit_*：%s" % str(gaps))
	_ok(gaps.is_empty(), "未登記的 _emit_* ＝ 0（★新增第 8 支時這裡會具名紅）")
	# ★母體地板：這格不能因為【一支 _emit_* 都沒掃到】而空綠
	var f := FileAccess.open("res://scripts/simulation/state_fingerprint.gd", FileAccess.READ)
	var n_emit: int = 0
	if f != null:
		for l in f.get_as_text().split("\n"):
			if String(l).begins_with("static func _emit_"):
				n_emit += 1
		f.close()
	var registered: int = 0
	for e in StateFingerprint.SUBFIELD_MAP:
		if String(e[2]) != "":
			registered += 1
	print("    本檔 _emit_* 共 %d 支｜登記 %d 支｜明示不適用 %d 支" % [
		n_emit, registered, StateFingerprint.SUBFIELD_NOT_APPLICABLE.size()])
	_ok(n_emit >= 6, "★母體地板：真的掃到 %d 支 _emit_*（空母體不得判綠）" % n_emit)
	_ok(registered + StateFingerprint.SUBFIELD_NOT_APPLICABLE.size() == n_emit,
		"★每一支 _emit_* 要嘛被登記、要嘛被【明示標記不適用】—— 沒有第三種狀態")
	_sections += 1
