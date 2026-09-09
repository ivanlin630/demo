extends SceneTree
# @bed-kind: acceptance
# slice: C1 票② 走查 ＋ 常駐狀態列
#
# 驗收（spec §4）：③狀態列四件事【都來自公開查詢動詞】④成對對照：查詢面拿不到 ⇒ 天窗
#   ⑤只讀不寫（呼叫查詢動詞前後 fingerprint 不變）
#   ★★走查腳本本身標 diagnostic（它的判準在真人眼睛）；本床驗的是【它讀的管道對不對】

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 4

func _initialize() -> void:
	print("=== C1 TICKET2（走查 ＋ 狀態列）===")
	var st := _mk()
	_test_status_line(st)
	_test_readonly(st)
	_test_walkthrough_only_uses_query_api()
	_test_drop_field_control(st)
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

func _mk() -> WorldState:
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 2880
	var tile := HexTileData.new()
	tile.tile_id = 2002
	tile.tile_pos = Vector2i(2, 2)
	tile.terrain = "plains"
	st.world.tiles[2002] = tile
	var t := TeamData.new()
	t.team_id = 3
	t.tile_pos = Vector2i(2, 2)
	AnonTierSystem.add_anon(t, "平民", 6)
	var ldr := PersonData.new()
	ldr.id = 30
	ldr.team_id = 3
	ldr.person_name = "測試領袖"
	st.persons[30] = ldr
	t.leader_id = 30
	st.teams[3] = t
	st.player_id = 30
	return st

func _test_status_line(st: WorldState) -> void:
	print("-- ③ 狀態列四件事，且【全部來自公開查詢動詞】--")
	var q := PlayerQueryApi.new()
	# 先讓引擎寫一次快照（★走 advance 那條真路徑）
	DecisionContext.gather(st, st.teams[3], true)
	var r: Dictionary = q.get_status_line(st)
	var d: Dictionary = r.get("data", {})
	print("    who=%s｜where=%s｜doing=%s｜clock.day=%s" % [
		str(d.get("who", "")), str(d.get("where", {})),
		str((d.get("doing", {}) as Dictionary).get("current_task", "")),
		str((d.get("clock", {}) as Dictionary).get("day", ""))])
	_ok(String(d.get("who", "")) == "測試領袖", "③我是誰：來自 get_player_snapshot 的真值")
	_ok((d.get("where", {}) as Dictionary).has("tile"), "③在哪：有 tile 欄")
	_ok((d.get("doing", {}) as Dictionary).has("current_task"), "③在做啥：來自 ctx 快照")
	_ok(int((d.get("clock", {}) as Dictionary).get("day", -1)) == 2, "③現在幾時：第 2 天（tick 2880）")
	var sources: Array = d.get("sources", [])
	_ok(sources.size() == 3 and ("get_world_clock" in sources),
		"③★狀態列自陳來源（%s）—— 讓「它有沒有走查詢面」可被查證" % str(sources))
	# ★成對對照：沒有快照的世界 ⇒ 在做啥要說【尚無快照】而不是編一個 idle
	var st2 := _mk()
	var d2: Dictionary = (q.get_status_line(st2).get("data", {}) as Dictionary).get("doing", {})
	_ok(not bool(d2.get("has_snapshot", true)),
		"★成對對照：沒跑過決策 ⇒ 狀態列明說【尚無快照】，不是填一個看起來正常的值")
	_sections += 1

func _test_readonly(st: WorldState) -> void:
	print("-- ⑤ 只讀不寫（★量 fp，不是宣稱）--")
	var q := PlayerQueryApi.new()
	var before: String = StateFingerprint.compute(st)
	q.get_status_line(st)
	q.get_world_clock(st)
	q.get_decision_snapshot(st)
	q.get_event_stream(st, 5)
	q.get_player_snapshot(st, {})
	var after: String = StateFingerprint.compute(st)
	print("    查詢前 %s ／ 查詢後 %s" % [before.substr(0, 12), after.substr(0, 12)])
	_ok(before == after, "⑤呼叫五支查詢動詞之後 fp 不變（★只讀不寫）")
	# ★成對對照：動一個真的在 fp 裡的欄位 ⇒ 必須變（否則上面那格是恆真）
	(st.teams[3] as TeamData).unrest_turns += 1
	_ok(StateFingerprint.compute(st) != after, "⑤★對照：動 unrest_turns ⇒ fp 真的變")
	_sections += 1

func _test_walkthrough_only_uses_query_api() -> void:
	print("-- ①② 走查腳本【只走查詢面】（結構檢查）--")
	var f := FileAccess.open("res://scripts/debug/c1_walkthrough.gd", FileAccess.READ)
	if f == null:
		_fails += 1
		push_error("[FAIL] 讀不到走查腳本")
		_sections += 1
		return
	var src: String = f.get_as_text()
	f.close()
	# ★允許：建世界／推進／讀 tsv；★★不允許：直接從 state 掏欄位當畫面內容
	var bad: Array = []
	var in_control: bool = false
	for line in src.split("\n"):
		var l: String = String(line)
		# ★對照函式 _drop_field_from_query_surface 【故意】動查詢面的上游 ⇒ 不算違規，
		#   ★★它動的是 state 不是畫面：印畫面那段程式碼不知道有這回事。
		if l.begins_with("func "):
			in_control = l.contains("_drop_field_from_query_surface")
		if in_control or l.strip_edges().begins_with("#"):
			continue
		for pat in ["st.teams[", "state.teams[", ".resources", ".goal_state", ".ctx_snapshot"]:
			if l.contains(pat) and not l.contains("st.persons.has") :
				bad.append(l.strip_edges().substr(0, 60))
	print("    可疑的直讀 state 行：%d" % bad.size())
	for b in bad.slice(0, mini(3, bad.size())):
		print("      · %s" % String(b))
	_ok(bad.size() <= 1,
		"①走查沒有直讀 state 當畫面內容（附身選人那行例外，%d 行）" % bad.size())
	_ok(src.contains("★未接出"), "②天窗會被【印出來】（沉默的空白會被讀成「這個世界沒有這個東西」）")
	_ok(src.contains("埋了 %d 顆已知錯"), "★種錯【明示】：N 講明、位置不講（暗埋＝對老闆設局）")
	_sections += 1

func _test_drop_field_control(st: WorldState) -> void:
	print("-- ④ 成對對照：從查詢面拿掉一欄 ⇒ 那一格變天窗（★這裡驗查詢面那一半）--")
	var q := PlayerQueryApi.new()
	DecisionContext.gather(st, st.teams[3], true)
	var f0: Dictionary = (q.get_decision_snapshot(st).get("data", {}) as Dictionary).get("fields", {})
	var n0: int = f0.size()
	_ok(f0.has("food_stock"), "④乾淨版：查詢面回得出 food_stock（★對照的前提，不是恆真）")
	# ★★這一格是【床自己撞出來的缺陷】變成的守衛：回傳的若是本體，
	#   下面那個 erase 會把 f0 一起改掉 ⇒ 對照就變成在跟自己比。
	f0["__probe__"] = 1
	_ok(not (st.teams[3] as TeamData).ctx_snapshot.has("__probe__"),
		"④★查詢回的是【副本】：改它不會改到引擎的快照（觀測不得改變被觀測物）")
	f0.erase("__probe__")
	(st.teams[3] as TeamData).ctx_snapshot.erase("food_stock")
	var f1: Dictionary = (q.get_decision_snapshot(st).get("data", {}) as Dictionary).get("fields", {})
	_ok(not f1.has("food_stock"), "④拿掉之後：查詢面【真的】回不出它（不是快取重播）")
	_ok(f1.size() == n0 - 1, "④只掉那一欄（%d → %d）—— 拿掉一欄不會連坐" % [n0, f1.size()])
	# ★另一半（走查那一格會印成「★未接出」）由走查腳本自己的 else 分支負責，
	#   ★★而它是【同一段程式碼】處理所有天窗 —— 已在 §①② 那格驗過會印出來。
	_sections += 1
