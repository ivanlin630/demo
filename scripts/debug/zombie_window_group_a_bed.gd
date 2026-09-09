extends SceneTree
# @bed-kind: acceptance
# slice: 殭屍窗群甲（清除被早退跳過 ＋ 決策污染兩站）
#
# ★★本票是這批第一張【會改變行為】的票 ⇒ 驗收主詞換了：
#   fp【必須變】，fp 相同反而是紅燈（表示守衛沒咬到任何東西）。
#   ★而 fp 變了不代表變對了 ⇒ 歸因靠②③④，不靠⑤。
# ★★★而⑤照 R² 的規定跑在【①②的同一個構造場景】上：不得用自然長跑／隨機 seed 驗，
#   否則「沒觸發」與「沒做」分不出來。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 5

func _initialize() -> void:
	print("=== 殭屍窗群甲床 ===")
	_test_cleanup_not_skipped()
	_test_window_length()
	_test_strength_inflation()
	_test_belief_pollution()
	_test_fp_must_change()
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

# ── 構造場景：encounter 進行中 ＋ 已經有一支判死待清的隊 ──────────────────
#   ★R²查實：encounter 期間【不會新增】待清除者（判死的 code 在 encounter 期間不執行）
#   ⇒ 要驗的正是【encounter 開始那一刻已經在 pending 裡的那些】。
func _mk(with_encounter: bool) -> WorldState:
	seed(7777)
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 100
	for i in range(4):
		var tile := HexTileData.new()
		tile.tile_id = i * 1000 + i
		tile.tile_pos = Vector2i(i, i)
		tile.terrain = "plains"
		st.world.tiles[tile.tile_id] = tile
	for tid in [1, 2, 3]:
		var t := TeamData.new()
		t.team_id = tid
		t.tile_pos = Vector2i(1, 1)
		t.resources["food"] = 200.0
		AnonTierSystem.add_anon(t, "平民", 4)
		var p := PersonData.new()
		p.id = tid * 10
		p.team_id = tid
		p.person_name = "隊%d領袖" % tid
		st.persons[p.id] = p
		t.leader_id = p.id
		st.teams[tid] = t
	st.teams_by_tile_rebuild() if st.has_method("teams_by_tile_rebuild") else null
	# 隊 3 被判死、還沒 erase ＝ 殭屍
	st.teams_pending_erase.append(3)
	st.encounter_active = with_encounter
	return st

func _test_cleanup_not_skipped() -> void:
	print("-- ① 根：清除不再被【早退】跳過（encounter 進行中）--")
	var st := _mk(true)
	var runner := SimRunner.new()
	runner.advance_tick(st, Vector2i(-1, -1))
	print("    encounter 路跑完一 tick：pending=%s｜teams=%s" % [str(st.teams_pending_erase), str(st.teams.keys())])
	_ok(st.teams_pending_erase.is_empty(), "①encounter 期間也清乾淨（pending 空）")
	_ok(not st.teams.has(3), "①那支殭屍真的從 state.teams 消失了")
	# ★★成對對照：走【沒有 wrapper】的那條路（直接呼 body）⇒ 這一格必須紅
	var st2 := _mk(true)
	var runner2 := SimRunner.new()
	runner2._advance_tick_body(st2, Vector2i(-1, -1))
	print("    對照（直接呼 body＝修之前的行為）：pending=%s" % str(st2.teams_pending_erase))
	_ok(not st2.teams_pending_erase.is_empty() and st2.teams.has(3),
		"①★成對對照：沒有 wrapper 那條路 ⇒ 殭屍還在（證明綠的是 wrapper 不是別的東西）")
	_sections += 1

func _test_window_length() -> void:
	print("-- ② 窗長度：從判死到真的消失，經過幾個 tick --")
	var st := _mk(true)
	var runner := SimRunner.new()
	var n: int = 0
	for i in range(5):
		if not st.teams.has(3):
			break
		runner.advance_tick(st, Vector2i(-1, -1))
		n += 1
	_ok(n == 1, "②修後：encounter 情境下窗＝%d tick" % n)
	# 修前（body-only）：★窗＝encounter 全長 ＋ 1 —— 而【本床的 encounter 只有 1 tick】
	#   ⇒ 這裡量得到的差是 1 vs 2，不是 1 vs 5。★★說清楚比湊大聲好：
	#   本床證明的是【清除被跳過了那幾 tick】，不是「殭屍永遠不會死」。
	var st2 := _mk(true)
	var runner2 := SimRunner.new()
	var n2: int = 0
	var enc_ticks: int = 0
	for i in range(6):
		if not st2.teams.has(3):
			break
		if st2.encounter_active:
			enc_ticks += 1
		runner2._advance_tick_body(st2, Vector2i(-1, -1))
		n2 += 1
	print("    修前形狀：窗＝%d tick（其中 encounter 進行中 %d tick）" % [n2, enc_ticks])
	_ok(n2 > n, "②★修前形狀：同一場景窗＝%d tick > 修後 %d ⇒ 被跳過的就是那幾 tick" % [n2, n])
	_ok(n2 == enc_ticks + 1, "②★形狀對得上 spec：窗 ＝ encounter 全長(%d) ＋ 1" % enc_ticks)
	_sections += 1

func _test_strength_inflation() -> void:
	print("-- ③ 戰力灌水：殭屍護衛不得計入 --")
	var st := _mk(false)
	var combat := NpcCombatSystem.new()
	# 隊 2＝隊 1 的護衛（同格、TASK_ESCORT、order_target_id=1）
	var esc: TeamData = st.teams[2]
	esc.current_task = TeamData.TASK_ESCORT
	esc.order_target_id = 1
	# 隊 3 也是護衛，但它是【殭屍】
	var zesc: TeamData = st.teams[3]
	zesc.current_task = TeamData.TASK_ESCORT
	zesc.order_target_id = 1
	var with_zombie: float = combat.team_strength(st, 1)
	# ★具名：把殭屍改成活的 ⇒ 差額就是【它本來會灌多少】
	st.teams_pending_erase.clear()
	var if_alive: float = combat.team_strength(st, 1)
	print("    Team1 戰力：殭屍護衛在 pending 時=%.2f｜若它是活的=%.2f｜差額=%.2f"
		% [with_zombie, if_alive, if_alive - with_zombie])
	_ok(if_alive > with_zombie, "③殭屍護衛【沒有】被算進去（差額 %.2f 就是它本來會灌的水）" % (if_alive - with_zombie))
	# ★對照的另一半：活著的護衛【必須】被算進去（否則這格可能是把護衛整個關掉）
	var st2 := _mk(false)
	var base_only: float = NpcCombatSystem.new().team_strength(st2, 1)
	var e2: TeamData = st2.teams[2]
	e2.current_task = TeamData.TASK_ESCORT
	e2.order_target_id = 1
	var with_escort: float = NpcCombatSystem.new().team_strength(st2, 1)
	_ok(with_escort > base_only, "③★另一半：活護衛仍然計入（%.2f → %.2f）—— 沒有把護衛整個關掉" % [base_only, with_escort])
	_sections += 1

func _test_belief_pollution() -> void:
	print("-- ④ belief 污染：不得發現一支這 tick 就會消失的隊 --")
	var st := _mk(false)
	var vision := VisionSystem.new()
	vision.tick_discovery(st, st.teams.keys(), 1.0)
	var disc1: Array = st.team_discovered.get(1, [])
	print("    隊1 發現到：%s（隊3＝殭屍）" % str(disc1))
	_ok(not (3 in disc1), "④殭屍隊【沒有】被寫進 belief")
	# ★對照的另一半：同一格世界、把它變成活的 ⇒ 必須被發現
	#   ★★否則「0 筆」可能只是【這一站在本窗不可達】（spec ④ 明文要求分辨這兩者）
	var st2 := _mk(false)
	st2.teams_pending_erase.clear()
	VisionSystem.new().tick_discovery(st2, st2.teams.keys(), 1.0)
	var disc2: Array = st2.team_discovered.get(1, [])
	print("    對照（隊3 是活的）：%s" % str(disc2))
	_ok(3 in disc2, "④★另一半：同一格世界改成活隊 ⇒ 它【會】被發現（證明本站在本窗可達）")
	_sections += 1

func _test_fp_must_change() -> void:
	print("-- ⑤ fp：★必須【變】（fp 相同反而是紅燈）--")
	# ★跑在①②的同一個構造場景上（R² 規定：不得用自然長跑／隨機 seed）
	var fixed := _mk(true)
	var r1 := SimRunner.new()
	r1.advance_tick(fixed, Vector2i(-1, -1))
	var fp_fixed: String = StateFingerprint.compute(fixed)
	var before := _mk(true)
	var r2 := SimRunner.new()
	r2._advance_tick_body(before, Vector2i(-1, -1))
	var fp_before: String = StateFingerprint.compute(before)
	print("    修後 %s ／ 修前形狀 %s" % [fp_fixed.substr(0, 12), fp_before.substr(0, 12)])
	_ok(fp_fixed != fp_before, "⑤★反向斷言：兩條路的 fp【不同】—— 相同就代表守衛沒咬到東西")
	# ★而「不同」要能歸因：差在哪一個欄位（不然它只是一個雜湊不一樣）
	_ok(before.teams.has(3) and not fixed.teams.has(3),
		"⑤★歸因：差異來自【那支殭屍在不在 state.teams 裡】，不是一個說不出來源的雜湊差")
	_sections += 1
