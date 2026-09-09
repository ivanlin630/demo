extends SceneTree
# @bed-kind: acceptance
# slice: is_live_actor —— 把「這支隊還活著嗎」變成有名字的謂詞（★零行為改變）
#
# ★spec §2 驗收②：三格都要，因為【剛判死未 erase】與【已 erase】回同一個答案而理由不同
#   ⇒ 只驗第三格 ⇒ 殭屍窗那格完全沒被測到（★而殭屍窗正是這張票存在的理由）。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 2

func _initialize() -> void:
	print("=== IS_LIVE_TEAM 謂詞床 ===")
	_test_three_states()
	_test_pending_set()
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
	for tid in [1, 2, 3]:
		var t := TeamData.new()
		t.team_id = tid
		t.tile_pos = Vector2i(tid, 0)
		st.teams[tid] = t
	return st

func _test_three_states() -> void:
	print("-- ② 三種狀態（★其中兩種回同一個答案而理由不同）--")
	var st := _mk()
	_ok(st.is_live_team(1), "①正常隊 ⇒ true")
	# ②剛判死、還沒 erase ＝【殭屍窗】：teams 裡還在，但它已經不是行為者
	st.teams_pending_erase.append(2)
	_ok(st.teams.has(2), "  （前提：判死之後它【還在 state.teams 裡】—— 這就是那個窗）")
	_ok(not st.is_live_team(2), "②剛判死未 erase ⇒ false（★殭屍窗：teams.has 仍為 true）")
	# ③真的 erase 掉
	st.erase_teams([3])
	_ok(not st.teams.has(3), "  （前提：erase 之後 teams 裡沒有它）")
	_ok(not st.is_live_team(3), "③已 erase ⇒ false（理由與②不同：這次是 teams.has 假）")
	# ★第四種組合（spec §⑦）：teams=false 而 pending=true —— 存在於 erase_teams 與 clear() 之間
	st.teams_pending_erase.append(3)
	_ok(not st.is_live_team(3), "★第四種（teams 假＋pending 真，cleanup 中途）⇒ 一樣 false")
	# ★成對對照：不在母體裡的 tid ⇒ false（★★而它不是「死了」，是【從來沒有過】——
	#   謂詞不區分這兩者，這一格把那個界限釘住，免得以後有人拿它當「曾經存在」用。
	_ok(not st.is_live_team(999), "★界限：從來不存在的 tid ⇒ false（謂詞不區分「死了」與「沒有過」）")
	_sections += 1

func _test_pending_set() -> void:
	print("-- 第二個名字：pending_erase_set()（★餵 succeed_or_disband_faction 的排除集合）--")
	var st := _mk()
	_ok(st.pending_erase_set().is_empty(), "空 pending ⇒ 空集合（★不是 null，呼叫端不用防）")
	st.teams_pending_erase.append(2)
	st.teams_pending_erase.append(3)
	var s: Dictionary = st.pending_erase_set()
	_ok(s.size() == 2 and s.has(2) and s.has(3), "兩個判死 ⇒ {2,3}（與原本那三行逐字等價）")
	# ★對照：回的是副本 ⇒ 呼叫端改它不會改到 state（觀測不得改變被觀測物）
	s[99] = true
	_ok(not st.teams_pending_erase.has(99), "★改回傳的集合不會改到 teams_pending_erase")
	_sections += 1
