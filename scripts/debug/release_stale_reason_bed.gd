extends SceneTree
# @observe-pure
# ★★★`release()` 漏清 `task_reason` —— 而它讓【一整欄量測不可信】。
#   ★systems 差點拿 idle 隊身上的 `reason=survival` 當成「引擎想求生卻沒派出去」的證據，
#   ★★而那其實是【上一個任務的殘留】。
# ★★★本床要證兩件（缺一不可）：
#   ①殘留【真的存在】：release 當下 task_reason 非空的次數 > 0
#     —— ★沒有這條，「修完是 0」會與「根本沒 release 過」長得一樣
#   ②修完之後：idle 的隊身上 reason 是空的（★下游讀不到殘留）

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _init() -> void:
	print("=== release() 清 task_reason ===")
	var state := MeasureBedHelper.arm_and_new()
	seed(1337)
	var t := HexTileData.new()
	t.tile_id = 5005; t.tile_pos = Vector2i(5, 5); t.terrain = "plains"
	state.world.tiles[t.tile_id] = t
	var ldr := PersonData.new(); ldr.id = 1; ldr.team_id = 0
	state.persons[1] = ldr
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 1; team.tile_pos = Vector2i(5, 5)
	state.teams[0] = team
	state.add_member(team, 1)
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 4)

	# ① 先派一個帶 reason 的任務（走真 arbiter）
	var ok: bool = TaskArbiter.try_set(state, team, TeamData.TASK_FORAGE,
		Vector2i(5, 5), TaskArbiter.PRIO_SURVIVAL, "survival")
	_ok(ok and team.task_reason == "survival",
		"前提：任務真的被派出去且 reason 被寫上（reason=%s）★沒有這條，下面的空字串證不到是我清的" % team.task_reason)

	# ② release
	TaskArbiter.release(team)
	var stale_n: int = int(Probe.counts.get("commit.release_with_stale_reason", 0))
	print("  release 時 task_reason 非空的次數 = %d" % stale_n)
	_ok(stale_n > 0, "★★殘留【真的存在】（非 0）—— ★沒有這條，『修完是空的』與『根本沒 release 過』長得一樣")
	_ok(team.current_task == TeamData.TASK_IDLE and team.task_priority == 0, "前提：真的 release 了")
	_ok(team.task_reason == "", "★★★idle 的隊身上 reason 是空的 ⇒ 下游讀不到殘留（實際=%s）" % team.task_reason)

	print("  ★誠實限：①本床是【定向觸發】，證的是 release 這條路會清")
	print("    ★★證不到【沒有別的路徑會留下 stale reason】（例如 transition 就地轉換）")
	print("    ★★★而 transition 是【不改釋放流程】的就地轉換 ⇒ 它本來就該保留 reason，不是漏")
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()
