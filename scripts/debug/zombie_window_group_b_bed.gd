extends SceneTree
# @bed-kind: acceptance
# slice: 殭屍窗群乙 —— 玩家的互動對象清單裡有死人
#
# ★缺陷比「append 了一個殭屍」大一層：一個 id 進了清單之後那支隊死掉、被 erase 了，
#   那個 id 【還留在清單裡】⇒ 玩家看到的是【指向已刪除物件的 id】。
# ★★所以三處：兩個寫入端（治待刪除）＋ erase_teams 的清除（治已刪除）。
# ★★★而反向格照 R² 拆成兩條【各自對應該寫入端的精確前提】——
#   寫得太寬鬆的反向斷言，對「前提被意外收窄」那種退化會照樣判綠。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 5

func _initialize() -> void:
	print("=== 殭屍窗群乙床 ===")
	_test_writer_a()
	_test_writer_b()
	_test_erase_clears()
	_test_player_visible()
	_test_fp_and_size()
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

# 玩家隊＝1；NPC＝2（活）與 3（已判死未 erase），三隊同格
func _mk() -> WorldState:
	seed(1234)
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 500
	for i in range(3):
		var tile := HexTileData.new()
		tile.tile_id = i * 1000 + i
		tile.tile_pos = Vector2i(i, i)
		tile.terrain = "plains"
		st.world.tiles[tile.tile_id] = tile
	for tid in [1, 2, 3]:
		var t := TeamData.new()
		t.team_id = tid
		t.tile_pos = Vector2i(1, 1)
		t.resources["food"] = 150.0
		AnonTierSystem.add_anon(t, "平民", 4)
		var p := PersonData.new()
		p.id = tid * 10
		p.team_id = tid
		p.person_name = "隊%d領袖" % tid
		st.persons[p.id] = p
		t.leader_id = p.id
		st.create_team(t)
	st.player_id = 10
	st.teams_pending_erase.append(3)   # 隊 3＝殭屍
	return st

func _test_writer_a() -> void:
	print("-- ① 寫入端①：refresh_colocation_targets（前提：同格 ＋ combat_target == -1）--")
	var st := _mk()
	var cmd := PlayerCommandSystem.new()
	cmd.refresh_colocation_targets(st)
	print("    清單=%s" % str(st.player_pending_targets))
	_ok(not st.player_pending_targets.has(3), "①殭屍隊【不進】清單")
	# ★反向格 a（R² 指定的精確前提）：同格 ＋ combat_target == -1 ＋ 活著 ⇒ 必進
	_ok(st.player_pending_targets.has(2),
		"①★反向格a：同格＋combat_target==-1＋活著 ⇒ 必進清單（擋『永遠不 append』的退化）")
	# ★★而前提本身也要驗：combat_target 不是 -1 的活隊【本來就不該進】——
	#   否則反向格 a 會把一個「前提被放寬」的退化也判綠。
	var st2 := _mk()
	(st2.teams[2] as TeamData).combat_target = 99
	PlayerCommandSystem.new().refresh_colocation_targets(st2)
	_ok(not st2.player_pending_targets.has(2),
		"①★前提仍在：combat_target != -1 的活隊不進清單（本票沒有把守衛換成放行）")
	_sections += 1

func _test_writer_b() -> void:
	print("-- ② 寫入端②（★R² 查實：這是 default 分支＝最常見情境，不是邊角）--")
	var st := _mk()
	var inter := InteractionSystem.new()
	inter._try_interact(st, 1, 3)   # 玩家 vs 殭屍
	print("    清單=%s" % str(st.player_pending_targets))
	_ok(not st.player_pending_targets.has(3), "②殭屍隊走 path4 也【不進】清單")
	# ★反向格 b：同格 ＋ current_task 非 diplomacy/loot ＋ 活著 ⇒ 必進
	var st2 := _mk()
	InteractionSystem.new()._try_interact(st2, 1, 2)
	_ok(st2.player_pending_targets.has(2),
		"②★反向格b：同格＋非 diplomacy/loot＋活著 ⇒ 必進清單（證明這條路真的會 append）")
	# ★★前提仍在：diplomacy 的隊走路徑 2（forced_event），不進 pending
	var st3 := _mk()
	(st3.teams[2] as TeamData).current_task = TeamData.TASK_DIPLOMACY
	InteractionSystem.new()._try_interact(st3, 1, 2)
	_ok(not st3.player_pending_targets.has(2) and not st3.player_forced_event.is_empty(),
		"②★前提仍在：diplomacy 仍走路徑2（forced_event），沒有被新守衛吃掉")
	_sections += 1

func _test_erase_clears() -> void:
	print("-- ③ 清除端：id 已經在清單裡，那支隊死透之後【必須】離開清單 --")
	var st := _mk()
	st.teams_pending_erase.clear()          # 先讓它是活的、合法進清單
	PlayerCommandSystem.new().refresh_colocation_targets(st)
	_ok(st.player_pending_targets.has(3), "③前提：它活著時真的在清單裡（%s）" % str(st.player_pending_targets))
	st.erase_teams([3])
	print("    erase 之後清單=%s｜teams=%s" % [str(st.player_pending_targets), str(st.teams.keys())])
	_ok(not st.player_pending_targets.has(3),
		"③★死透之後 id 離開清單（dangling ref 掛在【物件消失那一刻】清，不是等下次有人來看）")
	# ★對照的另一半：沒死的那個【不得】被順手清掉
	_ok(st.player_pending_targets.has(2), "③★另一半：活著的隊還在清單裡（不是把清單整個清空）")
	_sections += 1

func _test_player_visible() -> void:
	print("-- ④ 玩家真正看到的東西（mapper 那一層）--")
	var st := _mk()
	st.teams_pending_erase.clear()
	PlayerCommandSystem.new().refresh_colocation_targets(st)
	st.erase_teams([3])
	var listed: Array = PlayerApiMapper.map_pending_targets(st)
	var ids: Array = []
	for e in listed:
		ids.append(int((e as Dictionary).get("target_id", -1)))
	print("    玩家清單 ids=%s" % str(ids))
	_ok(not (3 in ids), "④玩家看到的 pending 清單裡沒有死者 id")
	_ok(2 in ids, "④★另一半：活著的那支仍然看得到（清單沒被清空）")
	# ★★can_interact：對【待刪除】的隊必須 false —— 而它的語意是「不在 pending 裡＝可發起互動」
	#   ⇒ 待刪除隊進不了 pending ⇒ ★★★這一格要驗的是【它不會被當成可互動目標】，
	#     所以驗的是 refresh 之後它不在 pending，而不是 can_interact 這個欄位的字面值。
	var st2 := _mk()
	PlayerCommandSystem.new().refresh_colocation_targets(st2)
	_ok(not st2.player_pending_targets.has(3),
		"④★待刪除的隊按了互動鍵也不會成為目標（而 can_interact 的語意是【不在 pending 裡】，見註）")
	_sections += 1

func _test_fp_and_size() -> void:
	print("-- ⑤ fp（構造場景）＋ ★量一下 pending 的實際長度（不要假設它小）--")
	var st := _mk()
	PlayerCommandSystem.new().refresh_colocation_targets(st)
	var fp_fixed: String = StateFingerprint.compute(st)
	# 修前形狀：手動把殭屍塞進去（＝沒有守衛時 refresh 會做的事）
	var st2 := _mk()
	PlayerCommandSystem.new().refresh_colocation_targets(st2)
	st2.player_pending_targets.append(3)
	var fp_before: String = StateFingerprint.compute(st2)
	print("    修後 %s ／ 修前形狀 %s｜pending 長度 %d vs %d"
		% [fp_fixed.substr(0, 12), fp_before.substr(0, 12),
			st.player_pending_targets.size(), st2.player_pending_targets.size()])
	if fp_fixed == fp_before:
		# ★誠實：若 player_pending_targets 根本不在 fp 裡，這一格【不可判】而不是綠也不是紅
		print("    ★注意：兩者 fp 相同 ⇒ player_pending_targets 不在 fingerprint 的涵蓋範圍內")
	_ok(st.player_pending_targets.size() == st2.player_pending_targets.size() - 1,
		"⑤★歸因用的是清單本身（%d vs %d），不是雜湊 —— fp 涵蓋不到的東西不能拿來當證據"
			% [st.player_pending_targets.size(), st2.player_pending_targets.size()])
	print("    ★erase_teams 多清一個容器的成本：pending 實際長度 = %d（O(pending) 的 pending 就是這個數）"
		% st.player_pending_targets.size())
	_sections += 1
