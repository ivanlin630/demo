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

# 盲區只准變小 —— ★★★這一格從【觸發樣本】改成【棘輪】（systems 裁 2026-09-24）。
#
# ★原本它釘的是「`player_pending_targets` 必須在盲區裡」，而那個欄位【已經被修好了】
#   （`state_fingerprint.gd` 的 `_emit_player` 現在讀它）⇒ ★★這一格從此恆紅 ＝【到期】。
# ★★而換一個真實欄位只是把到期日往後推，還更糟：現在盲區裡是 `encounter_*` 那一族，
#   而它們【本來就該進 fp】（它們是世界狀態）⇒ 挑它們當「必須留在盲區」的樣本
#   ⇒ ★★★等於把一格守衛的存活，綁在一個缺陷的存活上。
#
# ★★★本格的獵物（已經發生過，我們有它的血證）：
#   2026-09-24 票5 一次加了四個 `player_*` 欄位（`pending_commands`／`command_seq`／
#   `command_log`／`command_results`）而【一個 tap 都沒接】—— 靠 implementer 自己回頭
#   發現，★而在那之前【沒有任何東西會紅】。那就是這一格存在的原因。
#
# ★紀律（systems 裁，同 defers 那條）：有人新增一個【真的不該進 fp】的欄位 ⇒ 本格會紅
#   ⇒ ★★【不准默默把上限改大】，要寫信由 systems 裁。理由：**一個可以被自己調高的棘輪，不是棘輪。**
#   ⇒ 而【調低】不需要問任何人 —— 那正是這一格希望發生的事。
const BLIND_CEILING: int = 30   # ★2026-09-24 實測值（origin/main 9c4b5cbe4）

func _test_trigger_sample() -> void:
	print("-- ① 盲區只准變小（棘輪）--")
	var d: Array = StateFingerprint.derived_excludes()
	print("    導出的頂層排除 %d 欄，前 5：%s" % [d.size(), str(d.slice(0, 5))])
	# ★★母體地板：`size() <= 30` 會被 `size() == 0` 滿足，而 0 正是【推導器壞了】的長相
	#   ⇒ ★★★沒有這一道，棘輪會在推導器死掉的那一天變成最綠的一格。
	_ok(d.size() > 0, "①母體地板：推導器真的吐出東西（%d 欄）—— 0 欄不是「沒有盲區」，是它壞了" % d.size())
	_ok(d.size() <= BLIND_CEILING,
		"①★棘輪：盲區 %d 欄 ≤ 上限 %d（只准變小；要調高須由 systems 裁）" % [d.size(), BLIND_CEILING])
	# ★而盲區必須【真的印在卷面上】，不是只活在某個 API 回傳值裡。
	#   ★★我第一版斷言「那一行含得下 `str(d.size())`」—— 而那是我【假設】的形狀：
	#     `blind_note()` 印的是【欄位名接起來】，不是欄位數 ⇒ 它當場紅給我看。
	#   ⇒ ★★★改成驗真正的那個性質：**每一個盲區欄位都要出現在那一行裡**
	#     （左＝API 的清單，右＝渲染出來的那一行 ⇒ 兩邊不同源）。
	var note: String = StateFingerprint.blind_note()
	var not_printed: Array = []
	for f in d:
		if not note.contains(String(f)):
			not_printed.append(String(f))
	for f in not_printed: print("    ✗ 盲區有「%s」而那一行沒印它" % String(f))
	_ok(not_printed.is_empty(),
		"①每一個盲區欄位都【真的印在 blind_note 那一行裡】（%d／%d 有印）" % [
			d.size() - not_printed.size(), d.size()])
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
