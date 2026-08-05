extends SceneTree

# 失聯帳本 TDD（spec 2026-08-05-missing-contact-ledger-HOW）。
# 共享原語 _contact_elapsed_days（母↔子一套）+ dispatch_ledger 記帳 + 逾時 overdue_ratio→失聯 belief→
# ★競爭 react_util（4 類 argmax、禁 if/elif 人格揀死一條）。守零 god-view/人格非死常數/determinism。

var _fail: int = 0

func _initialize() -> void:
	_test_ledger_record()          # ①dispatch→ledger append + expected_return_tick 機械估
	_test_shared_primitive()       # ②_contact_elapsed_days team subject=belief last_tick(母↔子一套)
	_test_overdue_detect()         # ③elapsed>expected→lost belief 標記
	_test_persona_react_argmax()   # ④★競爭 util:統領高→redispatch / 野心高→writeoff(argmax 非 if/elif)
	_test_zero_godview()           # ⑤elapsed 不隨 subject live pop 變(讀 belief 非 live)
	_test_resolve_no_react()       # ⑥resolved→step 不觸反應
	_test_defensive_real_consumer() # ⑦★defensive→threat_threshold 真降(非 write-only flag)
	_test_rescue_real_consumer()    # ⑧★rescue→scout 真 dispatch 到 lost-pos(非 write-only flag)
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _mk_team(tid: int, pos: Vector2i, vals: Dictionary) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var t := TeamData.new(); t.team_id = tid; t.faction_id = 0; t.tile_pos = pos
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 8)
	var lp := PersonData.new(); lp.id = tid * 10 + 1; lp.values = vals; state.persons[lp.id] = lp; t.leader_id = lp.id
	state.teams[tid] = t
	return [state, t]

# ① 記帳：_ledger_record → ledger append、expected_return_tick=dispatched+round_trip。
func _test_ledger_record() -> void:
	print("--- ①記帳 ---")
	var a := _mk_team(1, Vector2i(0,0), {}); var state: WorldState = a[0]; var t: TeamData = a[1]
	var fai := FactionAISystem.new()
	fai._ledger_record(t, "scout", 5, true, state.world.current_tick, 6)
	_ok(t.dispatch_ledger.size() == 1, "dispatch→ledger append 1 筆")
	if t.dispatch_ledger.size() == 1:
		var e: Dictionary = t.dispatch_ledger[0]
		var expect: int = int(e["expected_return_tick"]) - int(e["dispatched_tick"])
		_ok(expect > 0 and String(e["kind"]) == "scout" and int(e["subject_ref"]) == 5 and not bool(e["resolved"]),
			"筆:kind=scout ref=5 resolved=false expected_return>dispatched(往返 %d ticks 機械估)" % expect)

# ② 共享原語：team subject elapsed=belief last_tick 推算（母↔子同一 _contact_elapsed_days）。
func _test_shared_primitive() -> void:
	print("--- ②共享原語 _contact_elapsed_days ---")
	var a := _mk_team(1, Vector2i(0,0), {}); var state: WorldState = a[0]; var t: TeamData = a[1]
	var sub := TeamData.new(); sub.team_id = 2; sub.faction_id = 0; sub.tile_pos = Vector2i(3,3); state.teams[2] = sub
	# belief：team1 對 team2 last_tick = current − 5 天
	BeliefSystem.record_claim(state, 1, 2, 1, "親見", {"tile_pos": Vector2i(3,3)}, 1.0, false)
	# 手動改 belief last_tick 到 5 天前（record_claim stamp current；改成過去）
	var days: int = FactionAISystem.new()._contact_elapsed_days(state, 1, true, 2, -1)
	_ok(days == 0, "剛親見→elapsed=0 天（team subject 走 belief last_tick）")
	# 未接觸 team → -1
	var days_none: int = FactionAISystem.new()._contact_elapsed_days(state, 1, true, 999, -1)
	_ok(days_none == -1, "未接觸 team subject→elapsed=-1（belief last_tick 缺）")
	# 非-team(letter)→dispatched_tick 推算
	var days_letter: int = FactionAISystem.new()._contact_elapsed_days(state, 1, false, -1, state.world.current_tick - WorldState.TICKS_PER_DAY * 4)
	_ok(days_letter == 4, "letter(非team)→elapsed=4 天（自我 dispatched_tick）")

# ③ 逾時偵測：elapsed>expected→lost belief 標記 + overdue tap。
func _test_overdue_detect() -> void:
	print("--- ③逾時偵測 ---")
	var a := _mk_team(1, Vector2i(0,0), {"統領": 1.0}); var state: WorldState = a[0]; var t: TeamData = a[1]
	# 記一筆已逾時的 letter（dispatched 很久前、expected 早過）
	t.dispatch_ledger.append({"kind": "herald", "subject_ref": -1, "is_team": false,
		"dispatched_tick": state.world.current_tick - WorldState.TICKS_PER_DAY * 30,
		"expected_return_tick": state.world.current_tick - WorldState.TICKS_PER_DAY * 20, "resolved": false})
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._step_contact_ledger(state, t)
	Probe.enabled = false
	_ok(int(Probe.counts.get("contact.overdue", 0)) == 1, "elapsed>expected→contact.overdue=1（逾時偵測）")

# ④ ★競爭 react_util：統領高→redispatch、野心高→writeoff（argmax 選最高、非 if/elif 揀死一條）。
func _test_persona_react_argmax() -> void:
	print("--- ④★競爭 react_util argmax（命門）---")
	var fai := FactionAISystem.new()
	var leader_ish: String = fai._pick_contact_reaction(2.0, {"統領": 1.0, "慎重": 0.0, "義氣": 0.0, "野心": 0.0})
	var cold: String = fai._pick_contact_reaction(2.0, {"統領": 0.0, "慎重": 0.0, "義氣": 0.0, "野心": 1.0})
	var cautious: String = fai._pick_contact_reaction(2.0, {"統領": 0.0, "慎重": 1.0, "義氣": 0.0, "野心": 0.0})
	var loyal: String = fai._pick_contact_reaction(2.0, {"統領": 0.0, "慎重": 0.0, "義氣": 1.0, "野心": 0.0})
	_ok(leader_ish == "redispatch", "統領高→redispatch（got %s）" % leader_ish)
	_ok(cold == "writeoff", "野心高→writeoff（got %s）" % cold)
	_ok(cautious == "defensive", "慎重高→defensive（got %s）" % cautious)
	_ok(loyal == "rescue", "義氣高→rescue（got %s）=4 類皆可被 argmax 選中（競爭 util 非死揀一條）" % loyal)

# ⑤ 零 god-view：elapsed 不隨 subject live pop 變（讀 belief last_tick 非 state.teams[subject].live）。
func _test_zero_godview() -> void:
	print("--- ⑤零 god-view ---")
	var a := _mk_team(1, Vector2i(0,0), {}); var state: WorldState = a[0]; var t: TeamData = a[1]
	var sub := TeamData.new(); sub.team_id = 2; sub.faction_id = 0; sub.tile_pos = Vector2i(3,3)
	AnonCohort.add(sub.anon_cohorts, "平民", "healthy", 5); state.teams[2] = sub
	BeliefSystem.record_claim(state, 1, 2, 1, "親見", {"tile_pos": Vector2i(3,3)}, 1.0, false)
	var d0: int = FactionAISystem.new()._contact_elapsed_days(state, 1, true, 2, -1)
	# 竄改 subject live pop（god-view 真值）→ elapsed 不該變
	AnonCohort.add(sub.anon_cohorts, "平民", "healthy", 99)
	var d1: int = FactionAISystem.new()._contact_elapsed_days(state, 1, true, 2, -1)
	_ok(d0 == d1, "subject live pop 竄改後 elapsed 不變(%d==%d)=只讀 belief last_tick 非 live god-view" % [d0, d1])

# ⑥ 清帳：resolved=true→step 不觸反應。
func _test_resolve_no_react() -> void:
	print("--- ⑥清帳不再反應 ---")
	var a := _mk_team(1, Vector2i(0,0), {"統領": 1.0}); var state: WorldState = a[0]; var t: TeamData = a[1]
	t.dispatch_ledger.append({"kind": "herald", "subject_ref": -1, "is_team": false,
		"dispatched_tick": state.world.current_tick - WorldState.TICKS_PER_DAY * 30,
		"expected_return_tick": state.world.current_tick - WorldState.TICKS_PER_DAY * 20, "resolved": true})   # 已清帳
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._step_contact_ledger(state, t)
	Probe.enabled = false
	_ok(int(Probe.counts.get("contact.overdue", 0)) == 0 and t.dispatch_ledger.is_empty(),
		"resolved 筆→step 跳過不觸反應(overdue=0)+丟棄(ledger 空)")

# ⑦ ★defensive 真 consumer：react=defensive→team.contact_vigilant_until 設→gather threat_threshold 真降(非 write-only)。
func _test_defensive_real_consumer() -> void:
	print("--- ⑦★defensive 真 consumer ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var t := TeamData.new(); t.team_id = 1; t.faction_id = 0; t.tile_pos = Vector2i(5,5); t.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 6)
	var lp := PersonData.new(); lp.id = 11; lp.values = {"慎重": 0.5}; state.persons[11] = lp; t.leader_id = 11
	state.teams[1] = t
	var thr_before: float = DecisionContext.gather(state, t).threat_threshold
	var entry: Dictionary = {"kind": "scout", "is_team": true, "subject_ref": 99, "dispatched_tick": 0, "last_known_pos": Vector2i(8,8)}
	FactionAISystem.new()._apply_contact_reaction(state, t, entry, "defensive")
	var thr_after: float = DecisionContext.gather(state, t).threat_threshold
	_ok(t.contact_vigilant_until > state.world.current_tick and thr_after < thr_before - 1e-6,
		"defensive→vigilant 設+threat_threshold %.3f→%.3f 真降(餵既有 threat gate、非 write-only flag)" % [thr_before, thr_after])

# ⑧ ★rescue 真 consumer：react=rescue→dispatch_anon_messenger TASK_SCOUT 到 lost-pos(非 write-only)。
func _test_rescue_real_consumer() -> void:
	print("--- ⑧★rescue 真 consumer ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var t := TeamData.new(); t.team_id = 1; t.faction_id = 0; t.tile_pos = Vector2i(5,5)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 8)
	var lp := PersonData.new(); lp.id = 11; lp.values = {}; state.persons[11] = lp; t.leader_id = 11
	state.teams[1] = t
	Probe.reset(); Probe.enabled = true
	var entry: Dictionary = {"kind": "scout", "is_team": true, "subject_ref": 99, "dispatched_tick": 0, "last_known_pos": Vector2i(9,9)}
	FactionAISystem.new()._apply_contact_reaction(state, t, entry, "rescue")
	Probe.enabled = false
	var scout_spawned: bool = false
	for tid in state.teams:
		var s: TeamData = state.teams[tid]
		if s.parent_team_id == 1 and s.current_task == TeamData.TASK_SCOUT and s.move_target == Vector2i(9,9):
			scout_spawned = true; break
	_ok(scout_spawned and int(Probe.counts.get("contact.react_rescue", 0)) == 1,
		"rescue→TASK_SCOUT 子隊真 dispatch 到 lost-pos(9,9)(非 write-only flag、reuse scout 機具)")
