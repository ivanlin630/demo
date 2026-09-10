extends SceneTree
# @bed-kind: acceptance
# slice: live_team() 便捷式（★改人不如改路）
#
# ★三格都要：正常隊回物件／pending_erase 回 null／從不存在回 null
#   ★★前兩格【回不同答案而理由不同】—— 只驗第三格會漏掉殭屍窗那格（同 is_live_team 那張）。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 2

func _initialize() -> void:
	print("=== live_team 床 ===")
	_test_three()
	_test_shorter_than_two_steps()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _test_three() -> void:
	print("-- ① 三格 --")
	var st := WorldState.new()
	st.world = WorldData.new()
	for tid in [1, 2]:
		var t := TeamData.new()
		t.team_id = tid
		st.create_team(t)
	st.teams_pending_erase.append(2)
	var t1 = st.live_team(1)
	_ok(t1 != null and (t1 as TeamData).team_id == 1, "①正常隊 ⇒ 回物件本身")
	_ok(st.live_team(2) == null, "①剛判死未 erase（殭屍窗）⇒ null（★teams.has 仍為 true）")
	_ok(st.live_team(999) == null, "①從不存在 ⇒ null（理由與上一格不同）")
	# ★與既有布林版一致（兩支不得各自漂）
	_ok((st.live_team(1) != null) == st.is_live_team(1)
		and (st.live_team(2) != null) == st.is_live_team(2), "①★與 is_live_team 逐格一致（兩支不得各自漂）")
	_sections += 1

func _test_shorter_than_two_steps() -> void:
	print("-- ★人體工學：新寫法要比舊寫法短（否則沒有人會用它）--")
	var new_way: String = "var t := state.live_team(tid)"
	var old_way: String = "if not state.teams.has(tid): continue" + "\n" + "var t: TeamData = state.teams[tid]"
	print("    新：%s\n    舊：%s" % [new_way, old_way.replace("\n", " ／ ")])
	_ok(new_way.length() < old_way.length(),
		"★新寫法 %d 字元 < 舊寫法 %d 字元 —— 寫法要贏在人體工學，不贏在紀律" % [new_way.length(), old_way.length()])
	_sections += 1
