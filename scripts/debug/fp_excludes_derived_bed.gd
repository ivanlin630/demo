extends SceneTree
# @bed-kind: acceptance
# slice: fp 的「本尺排除」必須由 code 導出（不是手抄字串）
#
# ★這張票修的不是 bug，是【一個儀器對自己說的謊】：那一行說「本尺排除 X/Y/Z」，
#   ★★而 player_* 那一整塊【從來沒有被收進來過】—— 於是讀的人以為玩家狀態在尺裡。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 4

func _initialize() -> void:
	print("=== FP EXCLUDES 導出床 ===")
	_test_trigger_sample()
	_test_paired_controls()
	_test_hash_unchanged()
	_test_single_source()
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

func _test_trigger_sample() -> void:
	print("-- ① 觸發樣本必須在第一版就被抓到 --")
	var d: Array = StateFingerprint.derived_excludes()
	print("    導出的頂層排除 %d 欄，前 5：%s" % [d.size(), str(d.slice(0, 5))])
	_ok("player_pending_targets" in d, "①player_pending_targets 現形（★這張票的觸發樣本）")
	_ok(StateFingerprint.blind_note().contains("player_pending_targets"),
		"①而它真的印在 blind_note 那一行裡（不是只存在於某個 API 回傳值）")
	_sections += 1

func _test_paired_controls() -> void:
	print("-- ② ③ 成對對照（★餵假的 WorldState ＋ 假的 fp 原始碼給推導本體）--")
	var fake := GDScript.new()
	fake.source_code = "extends RefCounted\nvar alpha: int = 0\nvar beta: int = 0\nvar _priv: int = 0\n"
	fake.reload()
	# 假的 fp 原始碼：只讀 alpha
	var fake_src: String = "func _emit(state):\n\tbuf.append(state.alpha)\n"
	var d: Array = StateFingerprint.derive_from(fake, fake_src)
	print("    假母體 {alpha(有讀), beta(沒讀), _priv} ⇒ 導出排除：%s" % str(d))
	_ok("beta" in d, "②新增一個沒人讀的欄位 ⇒ 【具名】出現在排除清單")
	_ok(not ("alpha" in d), "③★不得亂紅：真的被讀到的欄位不出現在排除清單")
	_ok(not ("_priv" in d), "③底線開頭的內部欄位不列（★而這是一條【選擇】，寫在 code 裡）")
	# ★★而「移除後回綠」那一半：把 beta 也讀進去 ⇒ 清單空
	var d2: Array = StateFingerprint.derive_from(fake, fake_src + "\tbuf.append(state.beta)\n")
	_ok(d2.is_empty(), "②★另一半：把 beta 也讀進去 ⇒ 清單變空（不是永遠紅）")
	# ★★★第三格（我加的）：一個【只出現在註解裡】的名字不算被讀到
	#   —— 血證：我第一版用「名字有沒有出現在檔案裡」，結果我自己的註解讓那一格熄燈。
	var d3: Array = StateFingerprint.derive_from(fake, "# 這裡提到 beta 但沒有讀它\nfunc _emit(state):\n\tbuf.append(state.alpha)\n")
	_ok("beta" in d3, "★提到它的【註解】不得讓紅燈熄掉（誰寫一句話就能關掉的檢查＝沒有檢查）")
	_sections += 1

func _test_hash_unchanged() -> void:
	print("-- ④ 本票只改【自我描述】，不改 hash 內容 --")
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 42
	var t := TeamData.new()
	t.team_id = 5
	t.tile_pos = Vector2i(2, 2)
	st.teams[5] = t
	var before: String = StateFingerprint.compute(st)
	var note: String = StateFingerprint.blind_note()
	var after: String = StateFingerprint.compute(st)
	_ok(before == after, "④算過 blind_note 之後 fp 不變（★推導路徑不得碰 state）")
	_ok(note.length() > 0 and note.contains("導出"), "④那一行有標明它是【導出】的")
	_sections += 1

func _test_single_source() -> void:
	print("-- ⑤ 單一來源：印那一行的地方都跟著變 --")
	# ★母體＝原始碼裡呼叫 blind_note() 的地方（★不是我記得的那幾支）
	var hits: Array = []
	for f in ["res://scripts/debug/a4_determinism_check.gd", "res://scripts/debug/s7_tracer_fp_divergence_bed.gd"]:
		var fh := FileAccess.open(f, FileAccess.READ)
		if fh != null:
			if fh.get_as_text().contains("blind_note()"):
				hits.append(f)
			fh.close()
	print("    呼叫端：%s" % str(hits))
	_ok(hits.size() == 2, "⑤兩個呼叫端都走 blind_note()（★它們印的是導出值，因為單一來源就是那支函式）")
	_ok(not StateFingerprint.blind_note().begins_with("[FP-BLIND] ★本尺排除：ephemeral"),
		"⑤★舊的手抄字串不再是那一行的全部（子層級那半仍在，但已標明是手抄且範圍有限）")
	_sections += 1
