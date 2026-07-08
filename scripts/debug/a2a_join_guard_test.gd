extends SceneTree

# A2a 子隊 join-player guard 焦點驗證（acceptance §9 + §9b，scope B D4b/round-5）。
# 直測 FactionAISystem._try_join_target 兩路：
#   A. 投靠玩家(co-located) → 寫 forced_event、★不 try_set(JOIN)、不設 social_target、不呼 capture。
#   B. 投靠 NPC → try_set(TASK_JOIN) + set_social_target。
# 純建構最小 state（無 sim 迴圈），零外部依賴。
# 用法：.\tools\godot.ps1 --headless --script scripts/debug/a2a_join_guard_test.gd

var _fail: int = 0

func _initialize() -> void:
	_run(); quit()

func _chk(name: String, cond: bool) -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		print("  FAIL  %s" % name)
		_fail += 1

func _run() -> void:
	print("=== A2a join-guard test ===")
	var fai := FactionAISystem.new()

	# ── Case A：投靠玩家（同格）→ forced_event，不派 JOIN、不 capture ──
	var s := WorldState.new()
	HandBrainProbe.enabled = true; HandBrainProbe.reset()
	var pp := PersonData.new(); pp.id = 100; pp.team_id = 1
	s.persons[100] = pp; s.player_id = 100
	var pteam := TeamData.new(); pteam.team_id = 1; pteam.leader_id = 100; pteam.tile_pos = Vector2i(3, 3)
	s.teams[1] = pteam
	var sub_l := PersonData.new(); sub_l.id = 200; sub_l.team_id = 2
	s.persons[200] = sub_l
	var sub := TeamData.new(); sub.team_id = 2; sub.leader_id = 200
	sub.parent_team_id = 9; sub.tile_pos = Vector2i(3, 3)   # 與玩家隊同格
	s.teams[2] = sub

	var ok_a: bool = fai._try_join_target(s, sub, 1)   # target=玩家隊
	_chk("A.ret_true(已處理)", ok_a == true)
	_chk("A.forced_event 寫入", (not s.player_forced_event.is_empty()) \
		and String(s.player_forced_event.get("action", "")) == "join_request" \
		and int(s.player_forced_event.get("from_id", -1)) == 2)
	_chk("A.不派 JOIN task(仍 IDLE)", sub.current_task == TeamData.TASK_IDLE)
	_chk("A.不設 social_target", sub.social_target == -1)
	# §9b：forced_event 分支不進 HandBrainProbe（helper 本身不呼 capture；_decide_subteam 以 current_task!=JOIN 守）
	_chk("A.不呼 capture(decisions=0)", HandBrainProbe.decisions == 0)

	# ── Case A2：玩家隊「不同格」→ 不寫 forced_event、回 false（caller 會 continue，不 fallthrough try_set）──
	var s2 := WorldState.new()
	var pp2 := PersonData.new(); pp2.id = 100; pp2.team_id = 1
	s2.persons[100] = pp2; s2.player_id = 100
	var pt2 := TeamData.new(); pt2.team_id = 1; pt2.leader_id = 100; pt2.tile_pos = Vector2i(3, 3)
	s2.teams[1] = pt2
	var sl2 := PersonData.new(); sl2.id = 200; sl2.team_id = 2
	s2.persons[200] = sl2
	var far := TeamData.new(); far.team_id = 2; far.leader_id = 200
	far.parent_team_id = 9; far.tile_pos = Vector2i(9, 9)   # 遠離玩家
	s2.teams[2] = far
	var ok_a2: bool = fai._try_join_target(s2, far, 1)
	_chk("A2.ret_false(不同格不請求)", ok_a2 == false)
	_chk("A2.forced_event 未寫", s2.player_forced_event.is_empty())
	_chk("A2.不派 JOIN(仍 IDLE)", far.current_task == TeamData.TASK_IDLE)

	# ── Case B：投靠 NPC → try_set(TASK_JOIN) + social_target ──
	var npc := TeamData.new(); npc.team_id = 3; npc.tile_pos = Vector2i(5, 5)
	s.teams[3] = npc
	var sub2_l := PersonData.new(); sub2_l.id = 300; sub2_l.team_id = 4
	s.persons[300] = sub2_l
	var sub2 := TeamData.new(); sub2.team_id = 4; sub2.leader_id = 300
	sub2.parent_team_id = 9; sub2.tile_pos = Vector2i(2, 2)
	s.teams[4] = sub2
	var ok_b: bool = fai._try_join_target(s, sub2, 3)
	_chk("B.ret_true", ok_b == true)
	_chk("B.派 TASK_JOIN", sub2.current_task == TeamData.TASK_JOIN)
	_chk("B.social_target=3", sub2.social_target == 3)
	_chk("B.move_target=NPC 格", sub2.move_target == Vector2i(5, 5))

	# ── Case C：target 不存在 → false ──
	_chk("C.未知 target ret_false", fai._try_join_target(s, sub2, 999) == false)

	HandBrainProbe.enabled = false
	if _fail == 0:
		print("=== A2a join-guard test DONE (all PASS) ===")
	else:
		print("=== A2a join-guard test DONE (%d FAIL) ===" % _fail)
