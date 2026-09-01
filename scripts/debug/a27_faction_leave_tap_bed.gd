extends SceneTree
# @observe-pure
# ★★★A#27 驗收床：faction-leave 的 tap —— 互斥且窮盡 ＋ 分母 ＋ 0 分得出「掛錯」還是「不可達」。
#
# ★掛點：`WorldState.set_team_faction()` 的【早退之後】（systems 2026-09-02 裁）
#   ⇒ 早退天然擋掉 6 顆 `set_team_faction(t, -1)` 的 fresh-team no-op
#   ⇒ ★★分母（join / leave / total）與被數的東西在【同一個窄口】產生
#
# ★★★而本床要防的是【最容易騙人的那一格】：「四個出口都 0」——
#   它可以是「這個窗裡沒發生」，也可以是「掛錯了」。分開它們的是【總數】。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _mk(state: WorldState, tid: int) -> TeamData:
	var pos := Vector2i(3 + tid, 5)
	var t := HexTileData.new()
	t.tile_id = pos.x * 1000 + pos.y; t.tile_pos = pos; t.terrain = "plains"
	state.world.tiles[t.tile_id] = t
	var ldr := PersonData.new(); ldr.id = tid * 100 + 1; ldr.team_id = tid
	ldr.skills = {"統領": 0.3}
	state.persons[ldr.id] = ldr
	var team := TeamData.new(); team.team_id = tid; team.leader_id = ldr.id
	team.tile_pos = pos
	state.teams[tid] = team
	state.add_member(team, ldr.id)
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 3)
	return team

func _init() -> void:
	print("=== A#27 faction-leave tap ===")
	var state := MeasureBedHelper.arm_and_new()
	seed(1337)
	for i in range(6):
		_mk(state, i)

	# ① fresh team 的 no-op：早退應擋住，★不得記成離團
	var before_total: int = int(Probe.counts.get("faction.change_total", 0))
	state.set_team_faction(state.teams[5], -1)          # fresh team，faction_id 本來就是 -1
	_ok(int(Probe.counts.get("faction.change_total", 0)) == before_total,
		"★fresh-team no-op 沒有被記成一次變更（早退擋住）")

	# ② join（分母的另一半）
	var fid: int = state.create_faction(0)
	for i in [1, 2, 3, 4]:
		state.set_team_faction(state.teams[i], fid)
	print("  join 累計 = %d" % int(Probe.counts.get("faction.join", 0)))
	_ok(int(Probe.counts.get("faction.join", 0)) > 0, "★join 有分母（不是只數 leave）")

	# ③ 逐 reason 各走一次（★互斥：一次呼叫只進一個桶）
	state.clear_team_faction(state.teams[1], WorldState.LEAVE_UPRISING_INDEPENDENT)
	state.clear_team_faction(state.teams[2], WorldState.LEAVE_DEFECT_INDEPENDENT)
	state.clear_team_faction(state.teams[3], WorldState.LEAVE_BETRAYAL)
	# ④ ★勢力解散那條（原本直寫繞過窄口，A#27 導回）——它是本票的核心
	state.disband_faction(fid)

	var total: int = int(Probe.counts.get("faction.leave_total", 0))
	var sum_r: int = 0
	print("  ── 逐 reason ──")
	for r in WorldState.LEAVE_REASONS:
		var c: int = int(Probe.counts.get("faction.leave." + r, 0))
		sum_r += c
		print("    %-26s = %d" % [r, c])
	var unknown: int = int(Probe.counts.get("faction.leave.unknown_reason", 0))
	print("    %-26s = %d" % ["unknown_reason", unknown])
	print("  leave_total = %d ／ 逐 reason 加總 = %d ／ change_total = %d"
		% [total, sum_r, int(Probe.counts.get("faction.change_total", 0))])

	_ok(total == sum_r, "★★互斥且窮盡：leave_total ＝ 逐 reason 加總（不重不漏）")
	_ok(unknown == 0, "★★★unknown_reason ＝ 0（非 0 ＝ 有人打錯字或新增了沒登記的理由）")
	_ok(int(Probe.counts.get("faction.leave." + WorldState.LEAVE_UNSET, 0)) == 0,
		"★unset ＝ 0（非 0 ＝ 有呼叫端沒標 reason）")
	_ok(int(Probe.counts.get("faction.leave." + WorldState.LEAVE_FACTION_DISSOLVED, 0)) > 0,
		"★★★勢力解散那條【走得到窄口】—— 它原本直寫 faction_id 繞過整條路")
	_ok(int(Probe.counts.get("faction.change_total", 0)) ==
		total + int(Probe.counts.get("faction.join", 0)),
		"★change_total ＝ leave_total ＋ join（窄口自己對得起帳）")

	print("  ★★0 的讀法（防最容易騙人的那一格）：")
	print("    leave_total > 0 而某 reason = 0 ⇒ ★那個出口【這個窗裡沒發生】，不是掛錯")
	print("    leave_total = 0                ⇒ ★★先懷疑【掛錯】，不要讀成「世界沒人離團」")
	print("  ★誠實限：本床是【定向觸發】—— 它證 tap 接得到那些路，")
	print("    ★★證不到【真實世界裡各出口的比例】（那要跑真 config，另一輪）")
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()
